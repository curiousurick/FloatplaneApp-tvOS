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
import FloatplaneApp_Utilities
import FloatplaneApp_Models

public protocol CacheableStrategyBasedOperation<Request, Response>: StrategyBasedOperation {
    
    func get(request: Request, invalidateCache: Bool) async -> OperationResponse<Response>
    
    func clearCache()
}

class CacheableStrategyBasedOperationImpl<I: Hashable, O: Codable>: CacheableStrategyBasedOperation {
    typealias Request = I
    typealias Response = O
    
    private let logger = Log4S()
    private let cacheQueueLabel = "com.georgie.cacheQueue"
    
    private let cacheExpiration: TimeInterval
    private let storage: Storage<Request, Response>
    private let cacheQueue: DispatchQueue
    
    let strategy: any InternalOperationStrategy<Request, Response>
    
    init(
        strategy: any InternalOperationStrategy<Request, Response>,
        countLimit: UInt = 50,
        // Default 5 minutes
        cacheExpiration: TimeInterval = 5 * 60
    ) {
        self.strategy = strategy
        self.cacheExpiration = cacheExpiration
        
        let expiry: Expiry = .date(Date().addingTimeInterval(cacheExpiration))
        let diskConfig = DiskConfig(name: "org.georgie.\(String.fromClass(Request.self))", expiry: expiry)
        let memoryConfig = MemoryConfig(expiry: expiry, countLimit: countLimit, totalCostLimit: 0)

        self.storage = try! Storage(
          diskConfig: diskConfig,
          memoryConfig: memoryConfig,
          transformer: TransformerFactory.forCodable(ofType: Response.self)
        )
        // For thread-safe access to the Storage object.
        cacheQueue = DispatchQueue(label: cacheQueueLabel)
    }
    
    /// The actual API consumers will use to get a parameterized response.
    /// request - This is the request whose type is determined by the Request generics paramters of the final implementation.
    public func get(request: Request) async -> OperationResponse<Response> {
        return await get(request: request, invalidateCache: false)
    }
    
    /// The actual API consumers will use to get a parameterized response.
    /// request - This is the request whose type is determined by the Request generics paramters of the final implementation.
    /// invalidateCache - This is an optional parameter that lets caller explicitly make the actual network call.
    public func get(request: Request, invalidateCache: Bool) async -> OperationResponse<Response> {
        do {
            // Get rid of the cache if it's expired or explicitly asked to clear.
            if try self.storage.isExpiredObject(forKey: request) || invalidateCache {
                try self.storage.removeExpiredObjects()
            }
            else {
                // Gets the response from the cache. Yay!
                let response = try self.storage.object(forKey: request) as Response
                return OperationResponse(response: response, error: nil)
            }
        }
        // Access to storage failed for some reason. Returns with error.
        // TODO: Determine if we should just fallthrough to the network call.
        catch {
            return OperationResponse(response: nil, error: error)
        }
        // No cache available. Make network call.
        let result = await self.strategy.get(request: request)
        if let response = result.response {
            self.setCache(request: request, response: response)
        }
        return result
    }
    
    /// Clears the storage cache of all data for this API.
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
    
    /// Writes to the cache where key is the hashable request and response is the operation's response.
    /// TODO: Investigate if this function should throw or return a boolean so the implementation can act on failure to write.
    private func setCache(request: Request, response: Response) {
        cacheQueue.async {
            do {
                try self.storage.setObject(response, forKey: request)
            }
            catch {
                self.logger.error("Error setting cache. \(error) Request type \(String.fromClass(request))) and Response type \(String.fromClass(response))")
            }
        }
    }
    
    public func cancel() {
        strategy.cancel()
    }
    
    public func isActive() -> Bool {
        return strategy.isActive()
    }
}
