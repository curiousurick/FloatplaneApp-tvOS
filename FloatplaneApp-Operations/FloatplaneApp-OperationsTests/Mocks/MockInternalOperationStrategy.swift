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

import Alamofire
import Foundation
import FloatplaneApp_Models
@testable import FloatplaneApp_Operations

class MockInternalOperationStrategy<I: OperationRequest, O: Codable>: InternalOperationStrategy {
    typealias Request = I
    typealias Response = O

    var dataRequest: Alamofire.DataRequest?

    var getCallCount = 0
    var mockRequest: ((Request) -> OperationResponse<Response>)?
    func get(request: I) async -> OperationResponse<Response> {
        getCallCount += 1
        return mockRequest?(request) ?? OperationResponse(response: nil, error: nil)
    }

    var cancelCallCount = 0
    func cancel() {
        cancelCallCount += 1
    }

    var mockIsActive = false
    var isActiveCallCount = 0
    func isActive() -> Bool {
        isActiveCallCount += 1
        return mockIsActive
    }
}
