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

class OperationStrategyTestBase: XCTestCase {
    
    var session: Session!
    
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.af.default
        configuration.protocolClasses = [MockingURLProtocol.self] + (configuration.protocolClasses ?? [])
        self.session = Session(configuration: configuration)
    }
    
    func mockGet(baseUrl: URL, request: any OperationRequest, response: Codable) throws {
        var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)!
        let queryItems = request.params.map {
            return URLQueryItem(name: "\($0)", value: "\($1)")
        }
        urlComponents.queryItems = queryItems
        let jsonData = try JSONEncoder().encode(response)
        let mock = try Mock(url: urlComponents.asURL(), dataType: .json, statusCode: 200, data: [
            .get : jsonData
        ])
        mock.register()
    }
    
    func mockHTTPError(baseUrl: URL, request: any OperationRequest, statusCode: Int) throws {
        var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)!
        let queryItems = request.params.map {
            return URLQueryItem(name: "\($0)", value: "\($1)")
        }
        urlComponents.queryItems = queryItems
        let mock = try Mock(url: urlComponents.asURL(), dataType: .json, statusCode: statusCode, data: [
            .get : Data()
        ])
        mock.register()
    }
    
    func mockWrongResponse(baseUrl: URL, request: any OperationRequest) throws {
        var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)!
        let queryItems = request.params.map {
            return URLQueryItem(name: "\($0)", value: "\($1)")
        }
        urlComponents.queryItems = queryItems
        let response = UnknownObject.defaultVal
        let jsonData = try JSONEncoder().encode(response)
        let mock = try Mock(url: urlComponents.asURL(), dataType: .json, statusCode: 200, data: [
            .get : jsonData
        ])
        mock.register()
    }
}
