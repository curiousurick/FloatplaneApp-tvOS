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

import Foundation
@testable import FloatplaneApp_Operations
import FloatplaneApp_Models

class MockCacheableStrategyBasedOperation<I: Hashable, O: Codable>: CacheableStrategyBasedOperation {
    typealias Request = I
    typealias Response = O
    
    var getWithInvalidateCallCount = 0
    var mockGetWithInvalidate: ((Request, Bool) -> OperationResponse<Response>)?
    func get(request: Request, invalidateCache: Bool) async -> OperationResponse<Response> {
        getWithInvalidateCallCount += 1
        return mockGetWithInvalidate?(request, invalidateCache) ?? OperationResponse(response: nil, error: nil)
    }
    
    var clearCacheCallCount = 0
    func clearCache() {
        clearCacheCallCount += 1
    }
    
    var getCallCount = 0
    var mockGet: ((Request) -> OperationResponse<Response>)?
    func get(request: Request) async -> OperationResponse<Response> {
        getCallCount += 1
        return mockGet?(request) ?? OperationResponse(response: nil, error: nil)
    }
    
    var isActiveCallCount = 0
    var mockIsActive: Bool = false
    func isActive() -> Bool {
        isActiveCallCount += 1
        return mockIsActive
    }
    
    var cancelCallCount = 0
    func cancel() {
        cancelCallCount += 1
    }
    
    
}
