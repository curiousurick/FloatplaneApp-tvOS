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

import Cache
import Foundation
import FloatplaneApp_Models
import FloatplaneApp_Utilities
import FloatplaneApp_DataStores

/// Inherits from StrategyBasedOperation but also uses Disk and Memory caching to replace strategy implementations with
/// usage of said cache.
/// Users of this operation can defined a limit of items to be stored for the request type as well as time before
/// expiration of the object.
///
/// Uses a DispatchQueue for thread-safe access to the Storage object.
public protocol CacheableStrategyBasedOperation<Request, Response>: StrategyBasedOperation {
    /// Uses either cache or strategy to get a response for the given request.
    ///
    /// request - The request metadata used to dynamically get a response. Used a the cache key.
    /// invalidateCache - Allows callers to explicitly use the strategy and remove the old cache.
    func get(request: Request, invalidateCache: Bool) async -> OperationResponse<Response>

    /// Clears the storage of cached data.
    func clearCache()
}

class CacheableStrategyBasedOperationImpl<I: OperationRequest, O: Codable>: CacheableStrategyBasedOperation {
    typealias Request = I
    typealias Response = O

    private let logger = Log4S()
    private let cacheQueueLabel = "com.georgie.cacheQueue"

    private let storage: DiskStorageWrapper<Request, Response>
    private let cacheQueue: DispatchQueue

    /// The implementation of the operation.
    let strategy: any InternalOperationStrategy<Request, Response>

    convenience init(
        strategy: any InternalOperationStrategy<Request, Response>,
        countLimit: UInt = 50,
        // Default 5 minutes
        cacheExpiration: TimeInterval = 5 * 60
    ) {
        let expiry: Expiry = .date(Date().addingTimeInterval(cacheExpiration))
        let diskConfig = DiskConfig(name: "org.georgie.\(String.fromClass(Request.self))", expiry: expiry)
        let memoryConfig = MemoryConfig(expiry: expiry, countLimit: countLimit, totalCostLimit: 0)

        let storage: Storage<Request, Response> = try! Storage(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: TransformerFactory.forCodable(ofType: Response.self)
        )
        let storageWrapper = DiskStorageWrapper(storage: storage)
        self.init(
            strategy: strategy,
            storage: storageWrapper
        )
    }

    init(
        strategy: any InternalOperationStrategy<Request, Response>,
        storage: DiskStorageWrapper<Request, Response>
    ) {
        // For thread-safe access to the Storage object.
        cacheQueue = DispatchQueue(label: cacheQueueLabel)
        self.strategy = strategy
        self.storage = storage
    }

    /// The actual API consumers will use to get a parameterized response.
    /// request - This is the request whose type is determined by the Request generics paramters of the final
    /// implementation.
    public func get(request: Request) async -> OperationResponse<Response> {
        await get(request: request, invalidateCache: false)
    }

    /// The actual API consumers will use to get a parameterized response.
    /// request - This is the request whose type is determined by the Request generics paramters of the final
    /// implementation.
    /// invalidateCache - This is an optional parameter that lets caller explicitly make the actual network call.
    public func get(request: Request, invalidateCache: Bool) async -> OperationResponse<Response> {
        if let cache = getCache(request: request, invalidateCache: invalidateCache) {
            return cache
        }
        // No cache available. Make network call.
        let result = await strategy.get(request: request)
        if let response = result.response {
            setCache(request: request, response: response)
        }
        return result
    }

    /// Tells the strategy to cancel
    public func cancel() {
        strategy.cancel()
    }

    /// Checks if the strategy of the operation is active.
    public func isActive() -> Bool {
        strategy.isActive()
    }

    /// Clears the storage cache of all data for this API.
    func clearCache() {
        cacheQueue.sync {
            self.storage.removeAll()
        }
    }
}

// MARK: Caching functions

private extension CacheableStrategyBasedOperationImpl {
    /// Gets response from cache if available.
    private func getCache(request: Request, invalidateCache: Bool) -> OperationResponse<Response>? {
        cacheQueue.sync {
            // Get rid of the cache if it's expired or explicitly asked to clear.
            if invalidateCache || self.storage.isExpiredObject(forKey: request) {
                self.storage.removeExpiredObjects()
                return nil
            }
            // Gets the response from the cache. Yay!
            if let response = self.storage.readObject(forKey: request) {
                return OperationResponse(response: response, error: nil)
            }
            return nil
        }
    }

    /// Writes to the cache where key is the hashable request and response is the operation's response.
    /// TODO: Investigate if this function should throw or return a boolean so the implementation can act on failure to
    /// write.
    private func setCache(request: Request, response: Response) {
        cacheQueue.async {
            self.storage.writeObject(response, forKey: request)
        }
    }
}
