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
import FloatplaneApp_Models

/// A basic public protocol that allows the OperationManager to cancel ops and check if they are active.
/// This is done as a workaround to allow the OperationManager to collect all of them despite generics.
/// As of Swift 5.5, Arrays can not collect objects of different types that belong to the same protocol, but not if they
/// have generic parameters.
public protocol Operation<Request, Response> {
    associatedtype Request: Any
    associatedtype Response: Codable

    /// The actual API consumers will use to get a parameterized response.
    /// request - This is the request whose type is determined by the Request generics paramters of the final
    /// implementation.
    func get(request: Request) async -> OperationResponse<Response>

    /// Returns whether or not the Alamofire operation is in an active state.
    func isActive() -> Bool

    /// Cancels whatever asynchronous operation is active.
    func cancel()
}
