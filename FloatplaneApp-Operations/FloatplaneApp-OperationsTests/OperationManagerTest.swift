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

import XCTest
import FloatplaneApp_Models
@testable import FloatplaneApp_Operations

class OperationManagerTest: XCTestCase {
    /// Mocks
    private var mockContentFeedOperation: MockCacheableStrategyBasedOperation<ContentFeedRequest, CreatorFeed> =
        MockCacheableStrategyBasedOperation()
    private var mockSubscriptionOperation: MockCacheableStrategyBasedOperation<
        SubscriptionRequest,
        SubscriptionResponse
    > = MockCacheableStrategyBasedOperation()
    private var mockSearchOperation: MockCacheableStrategyBasedOperation<SearchRequest, SearchResponse> =
        MockCacheableStrategyBasedOperation()
    private var mockCreatorListOperation: MockCacheableStrategyBasedOperation<CreatorListRequest, CreatorListResponse> =
        MockCacheableStrategyBasedOperation()
    private var mockCreatorOperation: MockCacheableStrategyBasedOperation<CreatorRequest, Creator> =
        MockCacheableStrategyBasedOperation()
    private var mockContentVideoOperation: MockCacheableStrategyBasedOperation<
        ContentVideoRequest,
        ContentVideoResponse
    > = MockCacheableStrategyBasedOperation()
    private var mockVodDeliveryKeyOperation: MockStrategyBasedOperation<VodDeliveryKeyRequest, DeliveryKey> =
        MockStrategyBasedOperation()
    private var mockLiveDeliveryKeyOperation: MockStrategyBasedOperation<LiveDeliveryKeyRequest, DeliveryKey> =
        MockStrategyBasedOperation()
    private var mockLoginOperation: MockStrategyBasedOperation<LoginRequest, LoginResponse> =
        MockStrategyBasedOperation()
    private var mockLogoutOperation: MockStrategyBasedOperation<LogoutRequest, LogoutResponse> =
        MockStrategyBasedOperation()
    private var mockVideoMetadataOperation = MockVideoMetadataOperation()
    private var mockGetFirstPageOperation = MockGetFirstPageOperation()
    private var mockOperationFactory: OperationFactory! = OperationFactory()

    private var subject: OperationManagerImpl!

    override func setUp() {
        super.setUp()

        mockContentFeedOperation = MockCacheableStrategyBasedOperation()
        mockSubscriptionOperation = MockCacheableStrategyBasedOperation()
        mockSearchOperation = MockCacheableStrategyBasedOperation()
        mockCreatorListOperation = MockCacheableStrategyBasedOperation()
        mockCreatorOperation = MockCacheableStrategyBasedOperation()
        mockContentVideoOperation = MockCacheableStrategyBasedOperation()
        mockVodDeliveryKeyOperation = MockStrategyBasedOperation()
        mockLiveDeliveryKeyOperation = MockStrategyBasedOperation()
        mockLoginOperation = MockStrategyBasedOperation()
        mockLogoutOperation = MockStrategyBasedOperation()
        mockVideoMetadataOperation = MockVideoMetadataOperation()
        mockGetFirstPageOperation = MockGetFirstPageOperation()
        mockOperationFactory = OperationFactory()

        subject = OperationManagerImpl(
            operationFactory: mockOperationFactory,
            contentFeedOperation: mockContentFeedOperation,
            subscriptionOperation: mockSubscriptionOperation,
            searchOperation: mockSearchOperation,
            creatorListOperation: mockCreatorListOperation,
            creatorOperation: mockCreatorOperation,
            contentVideoOperation: mockContentVideoOperation,
            vodDeliveryKeyOperation: mockVodDeliveryKeyOperation,
            liveDeliveryKeyOperation: mockLiveDeliveryKeyOperation,
            loginOperation: mockLoginOperation,
            logoutOperation: mockLogoutOperation,
            videoMetadataOperation: mockVideoMetadataOperation,
            getFirstPageOperation: mockGetFirstPageOperation
        )
    }

    func testSingletonInstance() {
        let result = OperationManagerImpl.instance

        XCTAssertNotNil(result)
    }

    func testSingletonGetOperationsReturnsValidOperations() {
        XCTAssertNotNil(OperationManagerImpl.instance.contentFeedOperation)
        XCTAssertNotNil(OperationManagerImpl.instance.subscriptionOperation)
        XCTAssertNotNil(OperationManagerImpl.instance.searchOperation)
        XCTAssertNotNil(OperationManagerImpl.instance.creatorListOperation)
        XCTAssertNotNil(OperationManagerImpl.instance.creatorOperation)
        XCTAssertNotNil(OperationManagerImpl.instance.contentVideoOperation)
        XCTAssertNotNil(OperationManagerImpl.instance.vodDeliveryKeyOperation)
        XCTAssertNotNil(OperationManagerImpl.instance.liveDeliveryKeyOperation)
        XCTAssertNotNil(OperationManagerImpl.instance.loginOperation)
        XCTAssertNotNil(OperationManagerImpl.instance.logoutOperation)
        XCTAssertNotNil(OperationManagerImpl.instance.videoMetadataOperation)
        XCTAssertNotNil(OperationManagerImpl.instance.getFirstPageOperation)
    }

    func testClearCache() {
        // Act
        subject.clearCache()

        // Assert
        XCTAssertEqual(mockContentFeedOperation.clearCacheCallCount, 1)
        XCTAssertEqual(mockSubscriptionOperation.clearCacheCallCount, 1)
        XCTAssertEqual(mockSearchOperation.clearCacheCallCount, 1)
        XCTAssertEqual(mockCreatorListOperation.clearCacheCallCount, 1)
        XCTAssertEqual(mockCreatorOperation.clearCacheCallCount, 1)
        XCTAssertEqual(mockContentVideoOperation.clearCacheCallCount, 1)
    }

    func testCancelAllOperations() {
        // Act
        subject.cancelAllOperations()

        // Assert
        XCTAssertEqual(mockContentFeedOperation.cancelCallCount, 1)
        XCTAssertEqual(mockSubscriptionOperation.cancelCallCount, 1)
        XCTAssertEqual(mockSearchOperation.cancelCallCount, 1)
        XCTAssertEqual(mockCreatorListOperation.cancelCallCount, 1)
        XCTAssertEqual(mockCreatorOperation.cancelCallCount, 1)
        XCTAssertEqual(mockContentVideoOperation.cancelCallCount, 1)
        XCTAssertEqual(mockVodDeliveryKeyOperation.cancelCallCount, 1)
        XCTAssertEqual(mockLiveDeliveryKeyOperation.cancelCallCount, 1)
        XCTAssertEqual(mockLoginOperation.cancelCallCount, 1)
        XCTAssertEqual(mockLogoutOperation.cancelCallCount, 1)
        XCTAssertEqual(mockVideoMetadataOperation.cancelCallCount, 1)
        XCTAssertEqual(mockGetFirstPageOperation.cancelCallCount, 1)
    }
}
