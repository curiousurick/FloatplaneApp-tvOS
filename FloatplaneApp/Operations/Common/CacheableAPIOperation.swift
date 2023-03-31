//  Copyright © 2023 George Urick
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import Cache
import Alamofire

class CacheableAPIOperation<I: Hashable, O: Codable>: APIOperation {
    private let logger = Log4S()
    private let cacheQueueLabel = "com.georgie.cacheQueue"
    
    private let cacheExpiration: TimeInterval
    private let storage: Storage<Request, Response>
    private let cacheQueue: DispatchQueue
    private var request: DataRequest?
    
    private let activeStates: [DataRequest.State] = [
        .initialized,
        .resumed,
        .suspended
    ]
    
    typealias Request = I
    typealias Response = O
    
    let baseUrl: URL
    
    init(
        countLimit: UInt = 50,
        // Default 5 minutes
        cacheExpiration: TimeInterval = 5 * 60,
        baseUrl: URL
    ) {
        self.cacheExpiration = cacheExpiration
        self.baseUrl = baseUrl
        
        let expiry: Expiry = .date(Date().addingTimeInterval(cacheExpiration))
        let diskConfig = DiskConfig(name: "org.georgie.\(baseUrl)", expiry: expiry)
        let memoryConfig = MemoryConfig(expiry: expiry, countLimit: countLimit, totalCostLimit: 0)

        self.storage = try! Storage(
          diskConfig: diskConfig,
          memoryConfig: memoryConfig,
          transformer: TransformerFactory.forCodable(ofType: Response.self)
        )
        cacheQueue = DispatchQueue(label: cacheQueueLabel)
    }
    
    final func get(request: Request, completion: ((Response?, Error?) -> Void)?) {
        get(request: request, invalidateCache: false, completion: completion)
    }
    
    final func get(request: Request, invalidateCache: Bool = false, completion: ((Response?, Error?) -> Void)?) {
        cacheQueue.async {
            do {
                if try self.storage.isExpiredObject(forKey: request) || invalidateCache {
                    try self.storage.removeExpiredObjects()
                }
                else {
                    let response = try self.storage.object(forKey: request) as Response
                    completion?(response, nil)
                    return
                }
            }
            catch {
                completion?(nil, error)
                return
            }
            // No cache available.
            self.request = self._get(request: request) { response, error in
                if let response = response {
                    self.setCache(request: request, response: response)
                }
                self.request = nil
                completion?(response, error)
            }
        }
    }
    
    func _get(request: Request, completion: ((Response?, Error?) -> Void)?) -> DataRequest {
        fatalError("Not implemented. Do not use instance of CacheableAPIOperation")
    }
    
    func isActive() -> Bool {
        if let request = request {
            return activeStates.contains(request.state)
        }
        return false
    }
    
    func cancel() {
        request?.cancel()
        request = nil
    }
    
    func clearCache() {
        cacheQueue.sync {
            do {
                try self.storage.removeAll()
            }
            catch {
                self.logger.error("Error clearing cache. \(error)")
            }
        }
    }
    
    func setCache(request: Request, response: Response) {
        cacheQueue.async {
            do {
                try self.storage.setObject(response, forKey: request)
            }
            catch {
                self.logger.error("Error setting cache. \(error) Request type \(String.fromClass(request))) and Response type \(String.fromClass(response))")
            }
        }
        
    }
}
