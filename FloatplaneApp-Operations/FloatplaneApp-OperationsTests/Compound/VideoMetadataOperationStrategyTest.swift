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
@testable import FloatplaneApp_Operations
import FloatplaneApp_Models

class VideoMetadataOperationStrategyTest: XCTestCase {
    
    // Mocks
    private var mockContentVideoOperation: MockCacheableStrategyBasedOperation<ContentVideoRequest, ContentVideoResponse>!
    private var mockVodDeliveryKeyOperation: MockCacheableStrategyBasedOperation<VodDeliveryKeyRequest, DeliveryKey>!
    
    private var subject: VideoMetadataOperationImpl!
    
    override func setUp() {
        super.setUp()
        
        mockContentVideoOperation = MockCacheableStrategyBasedOperation()
        mockVodDeliveryKeyOperation = MockCacheableStrategyBasedOperation()
        
        // Default setup for happy case
        let videoMetadataRequest = TestModelSupplier.videoMetadataRequest
        let vodDeliveryRequest = VodDeliveryKeyRequest(guid: videoMetadataRequest.id)
        mockContentVideoOperation.mockGet = { request in
            if request == TestModelSupplier.contentVideoRequest {
                return OperationResponse(response: TestModelSupplier.contentVideoResponse, error: nil)
            }
            return OperationResponse(response: nil, error: nil)
        }
        mockVodDeliveryKeyOperation.mockGet = { request in
            if request == vodDeliveryRequest {
                return OperationResponse(response: TestModelSupplier.deliveryKey, error: nil)
            }
            return OperationResponse(response: nil, error: nil)
        }
        
        subject = VideoMetadataOperationImpl(
            contentVideoOperation: mockContentVideoOperation,
            vodDeliveryKeyOperation: mockVodDeliveryKeyOperation
        )
    }
    
    func testGetHappyCase() async {
        // Act
        let videoMetadataRequest = TestModelSupplier.videoMetadataRequest
        let result = await subject.get(request: videoMetadataRequest)
        
        // Assert
        XCTAssertNil(result.error)
        XCTAssertNotNil(result.response)
        let response = result.response!
        let expectedResponse = TestModelSupplier.videoMetadata
        XCTAssertEqual(response, expectedResponse)
        
        XCTAssertEqual(mockContentVideoOperation.getCallCount, 1)
        XCTAssertEqual(mockVodDeliveryKeyOperation.getCallCount, 1)
    }
    
    func testGetContentVideoOpFails() async {
        // Arrange
        let error = TestingError.reallyBad
        mockContentVideoOperation.mockGet = { request in
            if request == TestModelSupplier.contentVideoRequest {
                return OperationResponse(response: nil, error: error)
            }
            return OperationResponse(response: nil, error: nil)
        }
        
        // Act
        let videoMetadataRequest = TestModelSupplier.videoMetadataRequest
        let result = await subject.get(request: videoMetadataRequest)
        
        // Assert
        XCTAssertNotNil(result.error)
        XCTAssertNil(result.response)
        XCTAssertTrue(result.error is TestingError)
        let resultantError = result.error as! TestingError
        XCTAssertEqual(resultantError, error)
        
        XCTAssertEqual(mockContentVideoOperation.getCallCount, 1)
        XCTAssertEqual(mockVodDeliveryKeyOperation.getCallCount, 1)
    }
    
    func testGetDeliveryKeyOpFails() async {
        // Arrange
        let error = TestingError.reallyBad
        let videoMetadataRequest = TestModelSupplier.videoMetadataRequest
        let vodDeliveryRequest = VodDeliveryKeyRequest(guid: videoMetadataRequest.id)
        mockVodDeliveryKeyOperation.mockGet = { request in
            if request == vodDeliveryRequest {
                return OperationResponse(response: nil, error: error)
            }
            return OperationResponse(response: nil, error: nil)
        }
        
        // Act
        let result = await subject.get(request: videoMetadataRequest)
        
        // Assert
        XCTAssertNotNil(result.error)
        XCTAssertNil(result.response)
        XCTAssertTrue(result.error is TestingError)
        let resultantError = result.error as! TestingError
        XCTAssertEqual(resultantError, error)
        
        XCTAssertEqual(mockContentVideoOperation.getCallCount, 1)
        XCTAssertEqual(mockVodDeliveryKeyOperation.getCallCount, 1)
    }
}
