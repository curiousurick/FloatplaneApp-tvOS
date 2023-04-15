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
@testable import FloatplaneApp_Operations

class MockOperationManager: OperationManager {
    var contentFeedOperation: any CacheableStrategyBasedOperation<ContentFeedRequest, CreatorFeed>
    var subscriptionOperation: any CacheableStrategyBasedOperation<SubscriptionRequest, SubscriptionResponse>
    var searchOperation: any CacheableStrategyBasedOperation<SearchRequest, SearchResponse>
    var creatorListOperation: any CacheableStrategyBasedOperation<CreatorListRequest, CreatorListResponse>
    var creatorOperation: any CacheableStrategyBasedOperation<CreatorRequest, Creator>
    var contentVideoOperation: any CacheableStrategyBasedOperation<ContentVideoRequest, ContentVideoResponse>

    var vodDeliveryKeyOperation: any StrategyBasedOperation<VodDeliveryKeyRequest, DeliveryKey>
    var liveDeliveryKeyOperation: any StrategyBasedOperation<LiveDeliveryKeyRequest, DeliveryKey>
    var loginOperation: any StrategyBasedOperation<LoginRequest, LoginResponse>
    var logoutOperation: any StrategyBasedOperation<LogoutRequest, LogoutResponse>

    /// Compound Operations
    var videoMetadataOperation: any VideoMetadataOperation
    var getFirstPageOperation: any GetFirstPageOperation

    init() {
        contentFeedOperation = MockCacheableStrategyBasedOperation()
        subscriptionOperation = MockCacheableStrategyBasedOperation()
        searchOperation = MockCacheableStrategyBasedOperation()
        creatorListOperation = MockCacheableStrategyBasedOperation()
        creatorOperation = MockCacheableStrategyBasedOperation()
        contentVideoOperation = MockCacheableStrategyBasedOperation()
        vodDeliveryKeyOperation = MockCacheableStrategyBasedOperation()
        liveDeliveryKeyOperation = MockCacheableStrategyBasedOperation()
        loginOperation = MockCacheableStrategyBasedOperation()
        logoutOperation = MockCacheableStrategyBasedOperation()
        videoMetadataOperation = MockVideoMetadataOperation()
        getFirstPageOperation = MockGetFirstPageOperation()
    }

    var clearCacheCallCount = 0
    func clearCache() {
        clearCacheCallCount += 1
    }

    var cancelAllOperationsCallCount = 0
    func cancelAllOperations() {
        cancelAllOperationsCallCount += 1
    }
}
