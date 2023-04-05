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
import FloatplaneApp_Models


/// This is the sole gateway to any operation. In order to maintain efficient access to cached data and to simplify logout, all operations are created once
/// per application lifecycle so that we don't have to create a new Storage access every time an operation is called.
///
/// APIs
/// - Access to all operations for the app.
/// - cancelAllOperations - Iterates all cacheable operations and cancels them.
///     TODO: Add support for all operations.
/// - clearCache - Clears the cache for every cacheable operation
///
/// Note: All the operations are lazy for two reasons.
/// 1. So we don't have to create these operations are start time
/// 2. Because some operations are compound operations that require access back to OperationManager. Without laziness, it would cause an infinite loop.
public class OperationManager {
    /// Singleton access to OperationManager
    public static let instance = OperationManager()
    private let operationFactory = OperationFactory()
    
    public lazy var contentFeedOperation = operationFactory.createCachedOp(strategy: operationFactory.contentFeedStrategy)
    public lazy var subscriptionOperation = operationFactory.createCachedOp(strategy: operationFactory.subscriptionStrategy)
    public lazy var searchOperation = operationFactory.createCachedOp(
        strategy: operationFactory.searchStrategy,
        countLimit: 500,
        // 30 minutes
        cacheExpiration: 30 * 60
    )
    public lazy var creatorListOperation = operationFactory.createCachedOp(strategy: operationFactory.creatorListStrategy)
    public lazy var creatorOperation = operationFactory.createCachedOp(strategy: operationFactory.creatorStrategy)
    public lazy var contentVideoOperation = operationFactory.createCachedOp(strategy: operationFactory.contentVideoStrategy)
    
    private lazy var allCacheableOperations: [any CacheableStrategyBasedOperation] = [
        contentFeedOperation,
        subscriptionOperation,
        searchOperation,
        creatorListOperation,
        creatorOperation,
        contentVideoOperation
    ]
    
    public lazy var vodDeliveryKeyOperation = operationFactory.createOp(strategy: operationFactory.vodDeliveryKeyStrategy)
    public lazy var liveDeliveryKeyOperation = operationFactory.createOp(strategy: operationFactory.liveDeliveryKeyStrategy)
    public lazy var loginOperation = operationFactory.createOp(strategy: operationFactory.loginStrategy)
    public lazy var logoutOperation = operationFactory.createOp(strategy: operationFactory.logoutStrategy)
    
    // Compound Operations
    public lazy var videoMetadataOperation = operationFactory.createOp(strategy: operationFactory.videoMetadataStrategy)
    public lazy var getFirstPageOperation = operationFactory.createOp(strategy: operationFactory.getFirstPageStrategy)
    
    private init() {
    }
    
    /// Clears the cache for all cacheable operations
    public func clearCache() {
        allCacheableOperations.forEach {
            $0.clearCache()
        }
    }
    
    /// Cancels all cacheable operations.
    /// TODO: Support all operations
    public func cancelAllOperations() {
        allCacheableOperations.forEach {
            $0.cancel()
        }
    }
}

class OperationFactory {
    // Cacheable Operation implementations.
    lazy var contentFeedStrategy = ContentFeedOperationStrategyImpl()
    lazy var subscriptionStrategy = SubscriptionOperationStrategyImpl()
    lazy var searchStrategy = SearchOperationStrategyImpl()
    lazy var creatorListStrategy = CreatorListOperationStrategyImpl()
    lazy var creatorStrategy = CreatorOperationStrategyImpl()
    lazy var contentVideoStrategy = ContentVideoOperationStrategyImpl()
    
    // Non-Cached Operations
    lazy var vodDeliveryKeyStrategy = VodDeliveryKeyOperationStrategyImpl()
    lazy var liveDeliveryKeyStrategy = LiveDeliveryKeyOperationStrategyImpl()
    lazy var loginStrategy = LoginOperationStrategyImpl()
    lazy var logoutStrategy = LogoutOperationStrategyImpl()
    
    // Compound Operations
    lazy var videoMetadataStrategy = VideoMetadataOperationStrategyImpl()
    lazy var getFirstPageStrategy = GetFirstPageOperationStrategyImpl()
    
    func createOp<I: Hashable, O: Codable>(strategy: any InternalOperationStrategy<I, O>) -> any StrategyBasedOperation<I, O> {
        return StrategyBasedOperationImpl(strategy: strategy)
    }
    
    func createCachedOp<I: Hashable, O: Codable>(
        strategy: any InternalOperationStrategy<I, O>
    ) -> any CacheableStrategyBasedOperation<I, O> {
        return CacheableStrategyBasedOperationImpl(strategy: strategy)
    }
    
    func createCachedOp<I: Hashable, O: Codable>(
        strategy: any InternalOperationStrategy<I, O>,
        countLimit: UInt,
        cacheExpiration: TimeInterval
    ) -> any CacheableStrategyBasedOperation<I, O> {
        return CacheableStrategyBasedOperationImpl(strategy: strategy, countLimit: countLimit, cacheExpiration: cacheExpiration)
    }
}
