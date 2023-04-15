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

class StrategyBasedOperationTest: XCTestCase {
    private var mockStrategy: MockInternalOperationStrategy<SearchRequest, SearchResponse>!
    private var searchRequest: SearchRequest!
    private var searchResponse: SearchResponse!

    private var subject: StrategyBasedOperationImpl<SearchRequest, SearchResponse>!

    override func setUp() {
        super.setUp()

        searchRequest = TestModelSupplier.searchRequest
        searchResponse = TestModelSupplier.searchResponse
        mockStrategy = MockInternalOperationStrategy()

        subject = StrategyBasedOperationImpl(strategy: mockStrategy)
    }

    func testGet() async {
        // Arrange
        mockStrategy.mockRequest = { request in
            if request == self.searchRequest {
                return OperationResponse(response: self.searchResponse, error: nil)
            }
            return OperationResponse(response: nil, error: nil)
        }

        // Act
        let result = await subject.get(request: searchRequest)

        // Assert
        XCTAssertNil(result.error)
        XCTAssertEqual(result.response, searchResponse)
    }

    func testCancel() {
        // Act
        subject.cancel()

        // Assert
        XCTAssertEqual(mockStrategy.cancelCallCount, 1)
    }

    func testCancelTrueFromStrategy() {
        // Arrange
        mockStrategy.mockIsActive = true

        // Act
        let result = subject.isActive()

        // Assert
        XCTAssertTrue(result)
        XCTAssertEqual(mockStrategy.isActiveCallCount, 1)
    }

    func testCancelFalseFromStrategy() {
        // Arrange
        mockStrategy.mockIsActive = false

        // Act
        let result = subject.isActive()

        // Assert
        XCTAssertFalse(result)
        XCTAssertEqual(mockStrategy.isActiveCallCount, 1)
    }
}
