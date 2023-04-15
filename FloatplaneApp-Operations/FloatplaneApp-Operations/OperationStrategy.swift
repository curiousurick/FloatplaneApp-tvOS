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

/// These are Alamofire states which indicate that the operation can be canceled.
private let activeStates: [DataRequest.State] = [
    .initialized,
    .resumed,
    .suspended,
]

/// The most basic definition of an operation strategy. Defined with only the functions that should be publicly
/// available.
public protocol OperationStrategy {
    /// Cancels the operation
    func cancel()
    /// Checks if the operation is currently active.
    func isActive() -> Bool
}

/// This protocol adds additional constraints on an OperationStrategy.
protocol InternalOperationStrategy<Request, Response>: OperationStrategy {
    /// Defines the minimum type requirement of Request will be for the implementation of the strategy.
    associatedtype Request: OperationRequest
    /// Defines the minimum type requirement of Response will be for the implementation of the strategy.
    /// Must be Codable.
    associatedtype Response: Codable

    /// An Alamofire DataRequest. This is optional and allows a base implementation of
    /// cancel and isActive to be based on this DataRequest.
    /// Implementations of InternalOperationStrategy may override cancel and isActive.
    var dataRequest: DataRequest? { get }

    /// The implementation of getting a response for a given request.
    /// Asynchronous function that may make network calls.
    func get(request: Request) async -> OperationResponse<Response>
}

extension InternalOperationStrategy {
    /// Base implementation of cancel which cancels the DataRequest.
    func cancel() {
        dataRequest?.cancel()
    }

    /// Base implementation of isActive which checks if the DataRequest is in one of the active states.
    func isActive() -> Bool {
        if let dataRequest = dataRequest {
            return activeStates.contains(dataRequest.state)
        }
        return false
    }
}
