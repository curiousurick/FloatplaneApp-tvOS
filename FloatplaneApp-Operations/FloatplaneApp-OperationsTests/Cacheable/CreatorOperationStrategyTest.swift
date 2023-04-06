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
import Alamofire
import Mocker

class CreatorOperationStrategyTest: OperationStrategyTestBase {
    private let baseUrl = URL(string: "\(OperationConstants.domainBaseUrl)/api/v2/creator/named")!
    
    private var subject: CreatorOperationStrategyImpl!
    
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.af.default
        configuration.protocolClasses = [MockingURLProtocol.self] + (configuration.protocolClasses ?? [])
        let sessionManager = Session(configuration: configuration)
        
        subject = CreatorOperationStrategyImpl(session: sessionManager)
    }
    
    func testGetHappyCase() async throws {
        // Arrange
        let request = TestModelSupplier.creatorRequest
        let response = TestModelSupplier.creator
        try mockGet(baseUrl: baseUrl, request: request, response: [response])
        
        // Act
        let result = await subject.get(request: request)
        
        // Assert
        XCTAssertNil(result.error)
        XCTAssertEqual(result.response, response)
    }
    
    func testGetEmptyArray() async throws {
        // Arrange
        let request = TestModelSupplier.creatorRequest
        let response: [Creator] = []
        try mockGet(baseUrl: baseUrl, request: request, response: response)
        
        // Act
        let result = await subject.get(request: request)
        
        // Assert
        XCTAssertNil(result.error)
        XCTAssertNil(result.response)
    }
    
    func testGetMoreThanOneCreator() async throws {
        // Arrange
        let request = TestModelSupplier.creatorRequest
        let response: [Creator] = [TestModelSupplier.creator, TestModelSupplier.creator]
        try mockGet(baseUrl: baseUrl, request: request, response: response)
        
        // Act
        let result = await subject.get(request: request)
        
        // Assert
        XCTAssertNil(result.error)
        XCTAssertNil(result.response)
    }
    
    func testGetHTTPError() async throws {
        // Arrange
        let request = TestModelSupplier.creatorRequest
        try mockHTTPError(baseUrl: baseUrl, request: request, statusCode: 403)
        
        // Act
        let result = await subject.get(request: request)
        
        // Assert
        XCTAssertNotNil(result.error)
        XCTAssertNil(result.response)
    }
    
    func testGetSerializationError() async throws {
        // Arrange
        let request = TestModelSupplier.creatorRequest
        try mockWrongResponse(baseUrl: baseUrl, request: request)
        
        // Act
        let result = await subject.get(request: request)
        
        // Assert
        XCTAssertNotNil(result.error)
        XCTAssertNil(result.response)
    }

}
