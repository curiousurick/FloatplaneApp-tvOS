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

class SearchOperationStrategyTest: OperationStrategyTestBase<SearchOperationStrategyImpl> {
    override func setUp() {
        super.setUp()

        subject = SearchOperationStrategyImpl(session: session)
        request = TestModelSupplier.searchRequest
        baseUrl = URL(string: "\(OperationConstants.domainBaseUrl)/api/v3/content/creator")!
    }

    override func setupSuccessMock(response: Codable, delayMilliseconds: Int = 0) throws {
        try mockGet(baseUrl: baseUrl, request: request, response: response, delayMilliseconds: delayMilliseconds)
    }

    func testGetHappyCase() async throws {
        // Arrange
        let response = TestModelSupplier.searchResponse
        try setupSuccessMock(response: response.items)

        // Act
        let result = await subject.get(request: request)

        // Assert
        XCTAssertNil(result.error)
        XCTAssertEqual(result.response, response)
    }

    func testGetCanceled() async throws {
        // Arrange
        let response = TestModelSupplier.searchResponse

        try mockGet(baseUrl: baseUrl, request: request, response: response.items, delayMilliseconds: 1000)

        // Act
        async let resultAsync = subject.get(request: request)
        // Canceling once the data request has definitely been saved.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.subject.cancel()
        }
        let result = await resultAsync

        // Assert
        XCTAssertNotNil(result.error)
        let error = result.error!.asAFError!
        XCTAssertTrue(error.isExplicitlyCancelledError)
        XCTAssertNil(result.response)
    }

    func testGetHTTPError() async throws {
        // Arrange
        try mockHTTPError(baseUrl: baseUrl, request: request, statusCode: 403)

        // Act
        let result = await subject.get(request: request)

        // Assert
        XCTAssertNotNil(result.error)
        XCTAssertNil(result.response)
    }

    func testGetSerializationError() async throws {
        // Arrange
        try mockWrongResponse(baseUrl: baseUrl, request: request)

        // Act
        let result = await subject.get(request: request)

        // Assert
        XCTAssertNotNil(result.error)
        XCTAssertNil(result.response)
    }
}
