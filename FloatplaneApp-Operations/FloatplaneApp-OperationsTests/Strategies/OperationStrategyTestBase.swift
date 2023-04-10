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

fileprivate struct UnknownObject: Codable {
    let thingy: String
    let weirdDate: Date
    let wrongNum: UInt8
    let bigNum: Int64
    
    static let defaultVal = UnknownObject(thingy: "thangy", weirdDate: Date.distantFuture, wrongNum: 2, bigNum: 3958395)
}

class OperationStrategyTestBase<T: InternalOperationStrategy>: XCTestCase {
    
    var session: Session!
    
    var baseUrl: URL!
    var subject: T!
    var request: T.Request!
    
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.af.default
        configuration.protocolClasses = [MockingURLProtocol.self] + (configuration.protocolClasses ?? [])
        self.session = Session(configuration: configuration)
    }
    
    func setupSuccessMock(response: Codable, delayMilliseconds: Int = 0) throws {
        try mockGet(baseUrl: baseUrl, request: request, response: response, delayMilliseconds: delayMilliseconds)
    }
    
    func testCancel() async throws {

        // Arrange
        let emptyResponseArray: [T.Response] = []
        try setupSuccessMock(response: emptyResponseArray, delayMilliseconds: 500)
        async let unused = subject.get(request: request)
        let expectation = self.expectation(description: "Canceled data request")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.subject.cancel()
            
            // Assert
            XCTAssertNotNil(self.subject.dataRequest)
            XCTAssertTrue(self.subject.dataRequest!.isCancelled)
            expectation.fulfill()
        }
        
        self.wait(for: [expectation], timeout: 2.0)
        print(await unused)
    }
    
    func testIsActiveWhenActive() async throws {

        // Arrange
        let emptyResponseArray: [T.Response] = []
        try setupSuccessMock(response: emptyResponseArray, delayMilliseconds: 500)
        async let unused = subject.get(request: request)
        let expectation = self.expectation(description: "Canceled data request")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let result = self.subject.isActive()
            
            // Assert
            XCTAssertTrue(result)
            expectation.fulfill()
        }
        
        self.wait(for: [expectation], timeout: 2.0)
        print(await unused)
    }
    
    func testActiveWhenNoDataRequest() async {

        // Arrange
        let result = self.subject.isActive()
            
        // Assert
        XCTAssertFalse(result)
    }
    
    func testActiveWhenCanceledDataRequest() async throws {

        // Arrange
        let emptyResponseArray: [T.Response] = []
        try setupSuccessMock(response: emptyResponseArray, delayMilliseconds: 500)
        async let unused = subject.get(request: request)
        let expectation = self.expectation(description: "Canceled data request")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.subject.cancel()
            let result = self.subject.isActive()
            
            // Assert
            XCTAssertFalse(result)
            expectation.fulfill()
        }
        
        self.wait(for: [expectation], timeout: 2.0)
        print(await unused)
    }
    
    func mockGet(
        baseUrl: URL, request: T.Request? = nil,
        response: Codable?, delayMilliseconds: Int? = nil,
        method: Mock.HTTPMethod = .get,
        additionalHeaders: [String : String] = [:]
    ) throws {
        let urlRequest = try getUrlRequest(baseUrl: baseUrl, method: method, request: request)
        var jsonData: Data?
        var jsonMap: [Mock.HTTPMethod: Data] = [:]
        if let response = response {
            jsonData = try FloatplaneEncoder().encode(response)
            jsonMap[method] = jsonData
        }
        var mock = Mock(
            url: urlRequest.url!,
            dataType: .json,
            statusCode: 200,
            data: jsonMap,
            additionalHeaders: additionalHeaders
        )
        if let delayMilliseconds = delayMilliseconds {
            mock.delay = DispatchTimeInterval.milliseconds(delayMilliseconds)
        }
        mock.register()
    }
    
    func mockHTTPError(
        baseUrl: URL, request: T.Request? = nil,
        statusCode: Int, delayMilliseconds: Int? = nil,
        method: Mock.HTTPMethod = .get,
        additionalHeaders: [String : String] = [:]
    ) throws {
        let urlRequest = try getUrlRequest(baseUrl: baseUrl, method: method, request: request)
        let error = URLError(.badServerResponse)
        var mock = Mock(
            url: urlRequest.url!,
            dataType: .json,
            statusCode: statusCode,
            data: [method : Data()],
            additionalHeaders: additionalHeaders,
            requestError: error
        )
        if let delayMilliseconds = delayMilliseconds {
            mock.delay = DispatchTimeInterval.milliseconds(delayMilliseconds)
        }
        mock.register()
    }
    
    func mockWrongResponse(
        baseUrl: URL, request: T.Request? = nil,
        delayMilliseconds: Int? = nil,
        method: Mock.HTTPMethod = .get,
        additionalHeaders: [String : String] = [:]
    ) throws {
        let urlRequest = try getUrlRequest(baseUrl: baseUrl, method: method, request: request)
        let response = UnknownObject.defaultVal
        let jsonData = try JSONEncoder().encode(response)
        var mock = Mock(
            url: urlRequest.url!,
            dataType: .json,
            statusCode: 200,
            data: [method : jsonData],
            additionalHeaders: additionalHeaders
        )
        if let delayMilliseconds  = delayMilliseconds {
            mock.delay = DispatchTimeInterval.milliseconds(delayMilliseconds)
        }
        mock.register()
    }
    
    private func getUrlRequest(baseUrl: URL, method: Mock.HTTPMethod, request: T.Request?) throws -> URLRequest {
        var urlRequest = try URLRequest(url: baseUrl, method: method.toHTTPMethod())
        guard let request = request else {
            return urlRequest
        }
        if method == .post {
            urlRequest.httpBody = try? JSONEncoder().encode(request)
        }
        else if method == .get {
            var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)!
            urlComponents.queryItems = getQueryItems(request: request)
            urlRequest.url = try urlComponents.asURL()
        }
        return urlRequest
    }
    
    private func getQueryItems(request: T.Request?) -> [URLQueryItem]? {
        guard let request = request else { return nil }
        // We sort the keys first because Alamofire seems to do this and Mocker
        // requires an exact URL match, which is dumb.
        return request.params.keys.sorted().compactMap {
            if let value = request.params[$0] {
                return URLQueryItem(name: "\($0)", value: "\(value)")
            }
            return nil
        }
    }
}

extension Mock.HTTPMethod {
    func toHTTPMethod() -> HTTPMethod {
        switch self {
        case .post:
            return .post
        case .get:
            return .get
        case .delete:
            return .delete
        case .connect:
            return .connect
        case .head:
            return .head
        case .options:
            return .options
        case .patch:
            return .patch
        case .put:
            return .put
        case .trace:
            return .trace
        }
    }
}
