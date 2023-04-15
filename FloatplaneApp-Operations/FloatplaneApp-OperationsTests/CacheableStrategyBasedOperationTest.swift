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
import XCTest
import FloatplaneApp_Models
@testable import FloatplaneApp_Operations

class CacheableStrategyBasedOperationTest: XCTestCase {
    private var searchRequest: SearchRequest!
    private var searchResponse: SearchResponse!

    /// Mocks
    private var mockDiskStorageWrapper: MockDiskStorageWrapper<SearchRequest, SearchResponse>!
    private var mockInternalOperationStrategy: MockInternalOperationStrategy<SearchRequest, SearchResponse>!

    private var subject: CacheableStrategyBasedOperationImpl<SearchRequest, SearchResponse>!

    override func setUp() {
        super.setUp()

        searchRequest = TestModelSupplier.searchRequest
        searchResponse = TestModelSupplier.searchResponse

        let storage: Storage<SearchRequest, SearchResponse> = try! Storage(
            diskConfig: DiskConfig(name: "FakeDiskConfig"),
            memoryConfig: MemoryConfig(),
            transformer: TransformerFactory.forCodable(ofType: SearchResponse.self)
        )
        mockDiskStorageWrapper = MockDiskStorageWrapper(storage: storage)
        mockInternalOperationStrategy = MockInternalOperationStrategy()
        mockInternalOperationStrategy.mockRequest = { _ in
            OperationResponse(response: nil, error: nil)
        }

        subject = CacheableStrategyBasedOperationImpl(
            strategy: mockInternalOperationStrategy,
            storage: mockDiskStorageWrapper
        )
    }

    func testGetWithNoCache() async {
        // Arrange
        mockDiskStorageWrapper.mockReadObject[searchRequest] = nil
        mockInternalOperationStrategy.mockRequest = { request in
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
        XCTAssertEqual(mockDiskStorageWrapper.readObjectCallCount, 1)
        XCTAssertEqual(mockDiskStorageWrapper.isExpiredObjectCallCount, 1)
        XCTAssertEqual(mockInternalOperationStrategy.getCallCount, 1)

        let writeCacheExpectation = expectation(description: "Did write to cache")
        DispatchQueue.main.async {
            while self.mockDiskStorageWrapper.writeObjectCallCount == 0 {}
            writeCacheExpectation.fulfill()
        }

        await waitForExpectations(timeout: 1.0)
    }

    func testGetFromCache() async {
        // Arrange
        mockDiskStorageWrapper.mockReadObject[searchRequest] = searchResponse

        // Act
        let result = await subject.get(request: searchRequest)

        // Assert
        XCTAssertNil(result.error)
        XCTAssertEqual(result.response, searchResponse)
        XCTAssertEqual(mockDiskStorageWrapper.readObjectCallCount, 1)
        XCTAssertEqual(mockDiskStorageWrapper.isExpiredObjectCallCount, 1)
        XCTAssertEqual(mockInternalOperationStrategy.getCallCount, 0)
        XCTAssertEqual(mockDiskStorageWrapper.writeObjectCallCount, 0)
    }

    func testGetWithInvalidateCache() async {
        // Arrange
        mockDiskStorageWrapper.mockReadObject[searchRequest] = searchResponse
        mockInternalOperationStrategy.mockRequest = { request in
            if request == self.searchRequest {
                return OperationResponse(response: self.searchResponse, error: nil)
            }
            return OperationResponse(response: nil, error: nil)
        }

        // Act
        let result = await subject.get(request: searchRequest, invalidateCache: true)

        // Assert
        XCTAssertNil(result.error)
        XCTAssertEqual(result.response, searchResponse)
        XCTAssertEqual(mockDiskStorageWrapper.readObjectCallCount, 0)
        XCTAssertEqual(mockDiskStorageWrapper.isExpiredObjectCallCount, 0)
        XCTAssertEqual(mockInternalOperationStrategy.getCallCount, 1)
        let writeCacheExpectation = expectation(description: "Did write to cache")
        DispatchQueue.main.async {
            while self.mockDiskStorageWrapper.writeObjectCallCount == 0 {}
            writeCacheExpectation.fulfill()
        }

        await waitForExpectations(timeout: 1.0)
    }

    func testGetWithExpiredCache() async {
        // Arrange
        mockDiskStorageWrapper.mockReadObject[searchRequest] = searchResponse
        mockDiskStorageWrapper.mockIsExpiredObject = true
        mockInternalOperationStrategy.mockRequest = { request in
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
        XCTAssertEqual(mockDiskStorageWrapper.readObjectCallCount, 0)
        XCTAssertEqual(mockDiskStorageWrapper.isExpiredObjectCallCount, 1)
        XCTAssertEqual(mockDiskStorageWrapper.removeExpiredObjectsCallCount, 1)
        XCTAssertEqual(mockInternalOperationStrategy.getCallCount, 1)
        let writeCacheExpectation = expectation(description: "Did write to cache")
        DispatchQueue.main.async {
            while self.mockDiskStorageWrapper.writeObjectCallCount == 0 {}
            writeCacheExpectation.fulfill()
        }

        await waitForExpectations(timeout: 1.0)
    }

    func testCancel() {
        // Act
        subject.cancel()

        // Assert
        XCTAssertEqual(mockInternalOperationStrategy.cancelCallCount, 1)
    }

    func testIsActiveComesFromStrategyTrue() {
        // Arrange
        mockInternalOperationStrategy.mockIsActive = true

        // Act
        let result = subject.isActive()

        // Assert
        XCTAssertTrue(result)
        XCTAssertEqual(mockInternalOperationStrategy.isActiveCallCount, 1)
    }

    func testIsActiveComesFromStrategyFalse() {
        // Arrange
        mockInternalOperationStrategy.mockIsActive = false

        // Act
        let result = subject.isActive()

        // Assert
        XCTAssertFalse(result)
        XCTAssertEqual(mockInternalOperationStrategy.isActiveCallCount, 1)
    }

    func testClearCache() {
        // Act
        subject.clearCache()

        // Assert
        XCTAssertEqual(mockDiskStorageWrapper.removeAllCallCount, 1)
    }
}
