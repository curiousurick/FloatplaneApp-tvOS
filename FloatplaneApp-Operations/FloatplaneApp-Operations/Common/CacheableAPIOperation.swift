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
import FloatplaneApp_Utilities

/// A Cacheable API operation which not only relies on HTTP cache but long-term memory and disk storage.
/// This is because some APIs don't want the response to be cached, but in order to save on bandwidth (and server cost),
/// I implemented an explicit cache which remains even after the app is terminated.
/// The basic expiry is only 5 minutes so that content feed isn't stale for very long.
/// The default count limit is 50 because most APIs will not have more than 50 different hashable requests.
///
/// Note: A CacheableAPIOperation must be implemented to use an Alamofire DataRequest.
public class CacheableAPIOperation<I: Hashable, O: Codable> {
    private let logger = Log4S()
    private let cacheQueueLabel = "com.georgie.cacheQueue"
    
    private let cacheExpiration: TimeInterval
    private let storage: Storage<I, O>
    private let cacheQueue: DispatchQueue
    /// The Alamofire DataRequest.
    private var request: DataRequest?

    /// These are Alamofire states which indicate that the operation can be canceled.
    private let activeStates: [DataRequest.State] = [
        .initialized,
        .resumed,
        .suspended
    ]
    
    let baseUrl: URL
    
    /// Initializer that creates a Storage for the cache. Takes some basic configuration with default parameters.
    /// countLimit - The number of items that can be stored in the storage.
    /// cacheExpiration - The time that a given item will be valid, after which, isExpiredObject will return true.
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
          transformer: TransformerFactory.forCodable(ofType: O.self)
        )
        // For thread-safe access to the Storage object.
        cacheQueue = DispatchQueue(label: cacheQueueLabel)
    }
    
    /// The actual API consumers will use to get a parameterized response.
    /// request - This is the request whose type is determined by the Request generics paramters of the final implementation.
    /// invalidateCache - This is an optional parameter that lets caller explicitly make the actual network call.
    /// completion - The block that returns the response.
    public final func get(
        request: I,
        invalidateCache: Bool = false,
        completion: ((O?, Error?) -> Void)?
    ) {
        // TODO: Investigate if this cacheQueue block can be reduced in scope.
        cacheQueue.async {
            do {
                // Get rid of the cache if it's expired or explicitly asked to clear.
                if try self.storage.isExpiredObject(forKey: request) || invalidateCache {
                    try self.storage.removeExpiredObjects()
                }
                else {
                    // Gets the response from the cache. Yay!
                    let response = try self.storage.object(forKey: request) as O
                    completion?(response, nil)
                    return
                }
            }
            // Access to storage failed for some reason. Returns with error.
            // TODO: Determine if we should just fallthrough to the network call.
            catch {
                completion?(nil, error)
                return
            }
            // No cache available. Make network call.
            self.request = self._get(request: request) { response, error in
                if let response = response {
                    self.setCache(request: request, response: response)
                }
                self.request = nil
                completion?(response, error)
            }
        }
    }
    
    /// Actual implementation of the network call. Implemented by the actual operations.
    /// Would love to make this entire class an abstract class but that's not how swift works.
    func _get(request: I, completion: ((O?, Error?) -> Void)?) -> DataRequest {
        fatalError("Not implemented. Do not use instance of CacheableAPIOperation")
    }
    
    /// Returns whether or not the Alamofire DataRequest is in an active state.
    public func isActive() -> Bool {
        if let request = request {
            return activeStates.contains(request.state)
        }
        return false
    }
    
    /// Cancels the active Alamofire DataRequest
    public func cancel() {
        request?.cancel()
        request = nil
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
    private func setCache(request: I, response: O) {
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
