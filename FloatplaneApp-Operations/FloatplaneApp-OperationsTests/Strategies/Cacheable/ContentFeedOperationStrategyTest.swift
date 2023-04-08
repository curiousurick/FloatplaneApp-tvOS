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

class ContentFeedOperationStrategyTest: OperationStrategyTestBase {
    private let baseUrl = URL(string: "\(OperationConstants.domainBaseUrl)/api/v3/content/creator")!
    
    private var subject: ContentFeedOperationStrategyImpl!
    
    override func setUp() {
        super.setUp()
        
        subject = ContentFeedOperationStrategyImpl(session: session)
    }
    
    func testGetHappyCase() async throws {
        // Arrange
        let request = TestModelSupplier.contentFeedRequest
        let response = TestModelSupplier.creatorFeed
        
        try mockGet(baseUrl: baseUrl, request: request, response: response.items)
        
        // Act
        let result = await subject.get(request: request)
        
        // Assert
        XCTAssertNil(result.error)
        XCTAssertEqual(result.response, response)
    }
    
    func testGetHTTPError() async throws {
        // Arrange
        let request = TestModelSupplier.contentFeedRequest
        try mockHTTPError(baseUrl: baseUrl, request: request, statusCode: 403)
        
        // Act
        let result = await subject.get(request: request)
        
        // Assert
        XCTAssertNotNil(result.error)
        XCTAssertNil(result.response)
    }
    
    func testGetSerializationError() async throws {
        // Arrange
        let request = TestModelSupplier.contentFeedRequest
        try mockWrongResponse(baseUrl: baseUrl, request: request)
        
        // Act
        let result = await subject.get(request: request)
        
        // Assert
        XCTAssertNotNil(result.error)
        XCTAssertNil(result.response)
    }

}
