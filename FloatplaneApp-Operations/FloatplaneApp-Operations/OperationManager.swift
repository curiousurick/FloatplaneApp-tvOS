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

public protocol OperationManager {
    
    var contentFeedOperation: any CacheableStrategyBasedOperation<ContentFeedRequest, CreatorFeed> { get }
    var subscriptionOperation: any CacheableStrategyBasedOperation<SubscriptionRequest, SubscriptionResponse> { get }
    var searchOperation: any CacheableStrategyBasedOperation<SearchRequest, SearchResponse> { get }
    var creatorListOperation: any CacheableStrategyBasedOperation<CreatorListRequest, CreatorListResponse> { get }
    var creatorOperation: any CacheableStrategyBasedOperation<CreatorRequest, Creator> { get }
    var contentVideoOperation: any CacheableStrategyBasedOperation<ContentVideoRequest, ContentVideoResponse> { get }
    
    var vodDeliveryKeyOperation: any StrategyBasedOperation<VodDeliveryKeyRequest, DeliveryKey> { get }
    var liveDeliveryKeyOperation: any StrategyBasedOperation<LiveDeliveryKeyRequest, DeliveryKey> { get }
    var loginOperation: any StrategyBasedOperation<LoginRequest, LoginResponse> { get }
    var logoutOperation: any StrategyBasedOperation<LogoutRequest, LogoutResponse> { get }
    
    // Compound Operations
    var videoMetadataOperation: any VideoMetadataOperation { get }
    var getFirstPageOperation: any GetFirstPageOperation { get }
    
    func clearCache()
    
    func cancelAllOperations()
}


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
public class OperationManagerImpl: OperationManager {
    /// Singleton access to OperationManager
    public static let instance = OperationManagerImpl()
    
    private let operationFactory: OperationFactory
    
    public var contentFeedOperation: any CacheableStrategyBasedOperation<ContentFeedRequest, CreatorFeed>
    public var subscriptionOperation: any CacheableStrategyBasedOperation<SubscriptionRequest, SubscriptionResponse>
    public var searchOperation: any CacheableStrategyBasedOperation<SearchRequest, SearchResponse>
    public var creatorListOperation: any CacheableStrategyBasedOperation<CreatorListRequest, CreatorListResponse>
    public var creatorOperation: any CacheableStrategyBasedOperation<CreatorRequest, Creator>
    public var contentVideoOperation: any CacheableStrategyBasedOperation<ContentVideoRequest, ContentVideoResponse>
    
    private lazy var allCacheableOperations: [any CacheableStrategyBasedOperation] = [
        
    ]
    
    public var vodDeliveryKeyOperation: any StrategyBasedOperation<VodDeliveryKeyRequest, DeliveryKey>
    public var liveDeliveryKeyOperation: any StrategyBasedOperation<LiveDeliveryKeyRequest, DeliveryKey>
    public var loginOperation: any StrategyBasedOperation<LoginRequest, LoginResponse>
    public var logoutOperation: any StrategyBasedOperation<LogoutRequest, LogoutResponse>
    
    // Compound Operations
    public var videoMetadataOperation: any VideoMetadataOperation
    public var getFirstPageOperation: any GetFirstPageOperation
    
    private convenience init() {
        let operationFactory = OperationFactory()
        let contentVideoOperation = operationFactory.createCachedOp(strategy: operationFactory.contentVideoStrategy)
        let vodDeliveryKeyOperation = operationFactory.createOp(strategy: operationFactory.vodDeliveryKeyStrategy)
        let creatorOperation = operationFactory.createCachedOp(strategy: operationFactory.creatorStrategy)
        let creatorListOperation = operationFactory.createCachedOp(strategy: operationFactory.creatorListStrategy)
        let contentFeedOperation = operationFactory.createCachedOp(strategy: operationFactory.contentFeedStrategy)
        self.init(
            operationFactory: operationFactory,
            contentFeedOperation: contentFeedOperation,
            subscriptionOperation: operationFactory.createCachedOp(strategy: operationFactory.subscriptionStrategy),
            searchOperation: operationFactory.createCachedOp(
                strategy: operationFactory.searchStrategy,
                countLimit: 500,
                // 30 minutes
                cacheExpiration: 30 * 60
            ),
            creatorListOperation: creatorListOperation,
            creatorOperation: creatorOperation,
            contentVideoOperation: contentVideoOperation,
            vodDeliveryKeyOperation: vodDeliveryKeyOperation,
            liveDeliveryKeyOperation: operationFactory.createOp(strategy: operationFactory.liveDeliveryKeyStrategy),
            loginOperation: operationFactory.createOp(strategy: operationFactory.loginStrategy),
            logoutOperation: operationFactory.createOp(strategy: operationFactory.logoutStrategy),
            videoMetadataOperation: VideoMetadataOperationImpl(
                contentVideoOperation: contentVideoOperation,
                vodDeliveryKeyOperation: vodDeliveryKeyOperation
            ),
            getFirstPageOperation: GetFirstPageOperationImpl(
                creatorOperation: creatorOperation,
                contentFeedOperation: contentFeedOperation,
                creatorListOperation: creatorListOperation
            )
        )
    }
    
    init(
        operationFactory: OperationFactory,
        contentFeedOperation: any CacheableStrategyBasedOperation<ContentFeedRequest, CreatorFeed>,
        subscriptionOperation: any CacheableStrategyBasedOperation<SubscriptionRequest, SubscriptionResponse>,
        searchOperation: any CacheableStrategyBasedOperation<SearchRequest, SearchResponse>,
        creatorListOperation: any CacheableStrategyBasedOperation<CreatorListRequest, CreatorListResponse>,
        creatorOperation: any CacheableStrategyBasedOperation<CreatorRequest, Creator>,
        contentVideoOperation: any CacheableStrategyBasedOperation<ContentVideoRequest, ContentVideoResponse>,
        vodDeliveryKeyOperation: any StrategyBasedOperation<VodDeliveryKeyRequest, DeliveryKey>,
        liveDeliveryKeyOperation: any StrategyBasedOperation<LiveDeliveryKeyRequest, DeliveryKey>,
        loginOperation: any StrategyBasedOperation<LoginRequest, LoginResponse>,
        logoutOperation: any StrategyBasedOperation<LogoutRequest, LogoutResponse>,
        videoMetadataOperation: any VideoMetadataOperation,
        getFirstPageOperation: any GetFirstPageOperation
        
    ) {
        self.operationFactory = operationFactory
        self.contentFeedOperation = contentFeedOperation
        self.subscriptionOperation = subscriptionOperation
        self.searchOperation = searchOperation
        self.creatorListOperation = creatorListOperation
        self.creatorOperation = creatorOperation
        self.contentVideoOperation = contentVideoOperation
        self.vodDeliveryKeyOperation = vodDeliveryKeyOperation
        self.liveDeliveryKeyOperation = liveDeliveryKeyOperation
        self.loginOperation = loginOperation
        self.logoutOperation = logoutOperation
        self.videoMetadataOperation = videoMetadataOperation
        self.getFirstPageOperation = getFirstPageOperation
    }
    
    /// Clears the cache for all cacheable operations
    public func clearCache() {
        let cacheableOps: [any CacheableStrategyBasedOperation] = [
            contentFeedOperation,
            subscriptionOperation,
            searchOperation,
            creatorListOperation,
            creatorOperation,
            contentVideoOperation
        ]
        cacheableOps.forEach {
            $0.clearCache()
        }
    }
    
    /// Cancels all cacheable operations.
    /// TODO: Support all operations
    public func cancelAllOperations() {
        let allOps: [any Operation] = [
            contentFeedOperation,
            subscriptionOperation,
            searchOperation,
            creatorListOperation,
            creatorOperation,
            contentVideoOperation,
            vodDeliveryKeyOperation,
            liveDeliveryKeyOperation,
            loginOperation,
            logoutOperation,
            videoMetadataOperation,
            getFirstPageOperation
        ]
        allOps.forEach {
            $0.cancel()
        }
    }
}

class OperationFactory {
    
    lazy var sessionFactory = SessionFactory()
    
    // Cacheable Operation implementations.
    lazy var contentFeedStrategy = ContentFeedOperationStrategyImpl(session: sessionFactory.get())
    lazy var subscriptionStrategy = SubscriptionOperationStrategyImpl(session: sessionFactory.get())
    lazy var searchStrategy = SearchOperationStrategyImpl(session: sessionFactory.get())
    lazy var creatorListStrategy = CreatorListOperationStrategyImpl(session: sessionFactory.get())
    lazy var creatorStrategy = CreatorOperationStrategyImpl(session: sessionFactory.get())
    lazy var contentVideoStrategy = ContentVideoOperationStrategyImpl(session: sessionFactory.get())
    
    // Non-Cached Operations
    lazy var vodDeliveryKeyStrategy = VodDeliveryKeyOperationStrategyImpl(session: sessionFactory.get())
    lazy var liveDeliveryKeyStrategy = LiveDeliveryKeyOperationStrategyImpl(session: sessionFactory.get())
    lazy var loginStrategy = LoginOperationStrategyImpl(session: sessionFactory.get())
    lazy var logoutStrategy = LogoutOperationStrategyImpl(session: sessionFactory.get())
    
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
