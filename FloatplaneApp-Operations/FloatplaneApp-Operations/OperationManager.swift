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

// This is the sole gateway to any operation. In order to maintain efficient access to cached data and to simplify the
// logout process, all operations are created once
// per application lifecycle so that we don't have to create a new Storage access every time an operation is called.
//
// APIs
// - Access to all operations for the app.
// - cancelAllOperations - Iterates all cacheable operations and cancels them.
// - clearCache - Clears the cache for every cacheable operation
//
// Note: All the operations are lazy for two reasons.
// 1. So we don't have to create these operations are start time
// 2. Because some operations are compound operations that require access back to OperationManager. Without laziness, it
// would cause an infinite loop.

public protocol OperationManager {
    /// Gets a creator's ContentFeed.
    /// Cached
    var contentFeedOperation: any CacheableStrategyBasedOperation<ContentFeedRequest, CreatorFeed> { get }

    /// Gets the list of subscribed creators for the user.
    /// Cached
    var subscriptionOperation: any CacheableStrategyBasedOperation<SubscriptionRequest, SubscriptionResponse> { get }

    /// Filters a creator's feed by search query.
    /// Cached
    var searchOperation: any CacheableStrategyBasedOperation<SearchRequest, SearchResponse> { get }

    /// Gets the list of basic creator metadata to which the user is subscribed.
    /// Cached
    var creatorListOperation: any CacheableStrategyBasedOperation<CreatorListRequest, CreatorListResponse> { get }

    /// Gets the full metadata for a single Creator.
    /// Cached
    var creatorOperation: any CacheableStrategyBasedOperation<CreatorRequest, Creator> { get }

    /// Gets more metadata about a single video.
    /// Cached
    var contentVideoOperation: any CacheableStrategyBasedOperation<ContentVideoRequest, ContentVideoResponse> { get }

    /// Gets a delivery key for a given vod video.
    /// Not cached.
    var vodDeliveryKeyOperation: any StrategyBasedOperation<VodDeliveryKeyRequest, DeliveryKey> { get }
    /// Gets a delivery key for a given live video.
    /// Not cached.
    var liveDeliveryKeyOperation: any StrategyBasedOperation<LiveDeliveryKeyRequest, DeliveryKey> { get }
    /// Attempts to login the customer for a given username and password.
    /// Result is not cached.
    var loginOperation: any StrategyBasedOperation<LoginRequest, LoginResponse> { get }
    /// Logs the user out which results in clearing the session cookies for the login session.
    /// Result is not cached.
    var logoutOperation: any StrategyBasedOperation<LogoutRequest, LogoutResponse> { get }

    /// Compound Operations
    /// This is a compound operation to get metadata about the content of the video as well as the delivery key.
    var videoMetadataOperation: any VideoMetadataOperation { get }
    /// This is a compound operation to get the list of basic info for creators, full metadata for the active creator,
    /// and first page of the content feed for that creator.
    var getFirstPageOperation: any GetFirstPageOperation { get }

    /// Clears URL cache and Disk cache for all cacheable operations.
    func clearCache()

    /// Cancels all active operations
    func cancelAllOperations()
}

public class OperationManagerImpl: OperationManager {
    /// Singleton access to OperationManager
    public static let instance = OperationManagerImpl()

    /// Allows for simpler creation of operations for given strategies.
    private let operationFactory: OperationFactory

    public var contentFeedOperation: any CacheableStrategyBasedOperation<ContentFeedRequest, CreatorFeed>
    public var subscriptionOperation: any CacheableStrategyBasedOperation<SubscriptionRequest, SubscriptionResponse>
    public var searchOperation: any CacheableStrategyBasedOperation<SearchRequest, SearchResponse>
    public var creatorListOperation: any CacheableStrategyBasedOperation<CreatorListRequest, CreatorListResponse>
    public var creatorOperation: any CacheableStrategyBasedOperation<CreatorRequest, Creator>
    public var contentVideoOperation: any CacheableStrategyBasedOperation<ContentVideoRequest, ContentVideoResponse>

    public var vodDeliveryKeyOperation: any StrategyBasedOperation<VodDeliveryKeyRequest, DeliveryKey>
    public var liveDeliveryKeyOperation: any StrategyBasedOperation<LiveDeliveryKeyRequest, DeliveryKey>
    public var loginOperation: any StrategyBasedOperation<LoginRequest, LoginResponse>
    public var logoutOperation: any StrategyBasedOperation<LogoutRequest, LogoutResponse>

    /// Compound Operations
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
            contentVideoOperation,
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
            getFirstPageOperation,
        ]
        allOps.forEach {
            $0.cancel()
        }
    }
}

/// Internal class to create operations for given strategies. Used for readability.
class OperationFactory {
    lazy var sessionFactory = SessionFactory()
    lazy var session = sessionFactory.get()

    /// Cacheable Operation implementations.
    lazy var contentFeedStrategy = ContentFeedOperationStrategyImpl(session: session)
    lazy var subscriptionStrategy = SubscriptionOperationStrategyImpl(session: session)
    lazy var searchStrategy = SearchOperationStrategyImpl(session: session)
    lazy var creatorListStrategy = CreatorListOperationStrategyImpl(session: session)
    lazy var creatorStrategy = CreatorOperationStrategyImpl(session: session)
    lazy var contentVideoStrategy = ContentVideoOperationStrategyImpl(session: session)

    /// Non-Cached Operations
    lazy var vodDeliveryKeyStrategy = VodDeliveryKeyOperationStrategyImpl(session: session)
    lazy var liveDeliveryKeyStrategy = LiveDeliveryKeyOperationStrategyImpl(session: session)
    lazy var loginStrategy = LoginOperationStrategyImpl(session: session)
    lazy var logoutStrategy = LogoutOperationStrategyImpl(session: session)

    /// Creates a strategy-based operation for given strategy
    func createOp<I: OperationRequest,
        O: Codable>(strategy: any InternalOperationStrategy<I, O>) -> any StrategyBasedOperation<I, O> {
        StrategyBasedOperationImpl(strategy: strategy)
    }

    /// Creates a cacheable strategy-based operation for given strategy.
    func createCachedOp<I: OperationRequest, O: Codable>(
        strategy: any InternalOperationStrategy<I, O>
    ) -> any CacheableStrategyBasedOperation<I, O> {
        CacheableStrategyBasedOperationImpl(strategy: strategy)
    }

    /// Creates a cacheable strategy-based operation for a given strategy, including countLimit and cacheExpiration for
    /// the disk and memory storages.
    func createCachedOp<I: OperationRequest, O: Codable>(
        strategy: any InternalOperationStrategy<I, O>,
        countLimit: UInt,
        cacheExpiration: TimeInterval
    ) -> any CacheableStrategyBasedOperation<I, O> {
        CacheableStrategyBasedOperationImpl(
            strategy: strategy,
            countLimit: countLimit,
            cacheExpiration: cacheExpiration
        )
    }
}
