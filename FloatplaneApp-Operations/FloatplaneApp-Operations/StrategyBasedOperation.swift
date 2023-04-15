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

/// Operation which takes a strategy to perform the defined operation. Generics used to indicate the request and
/// response type.
/// The strategy is used to define the types.
///
/// Request - Can be anything. Strategy may add further requirements.
/// Response - Must be codable. This is because strategies will require them to be decodable from HTTP responses.
public protocol StrategyBasedOperation<Request, Response>: Operation {}

public class StrategyBasedOperationImpl<I: OperationRequest, O: Codable>: StrategyBasedOperation {
    public typealias Request = I
    public typealias Response = O

    /// Strategy used to execute get.
    let strategy: any InternalOperationStrategy<Request, Response>

    init(strategy: any InternalOperationStrategy<Request, Response>) {
        self.strategy = strategy
    }

    /// The actual API consumers will use to get a parameterized response. Relies on strategy to provide response
    /// request - This is the request whose type is determined by the Request generics paramters of the final
    /// implementation.
    public func get(request: Request) async -> OperationResponse<Response> {
        await strategy.get(request: request)
    }

    /// Cancel's the strategy in progress.
    public func cancel() {
        strategy.cancel()
    }

    /// Checks if the strategy is active.
    public func isActive() -> Bool {
        strategy.isActive()
    }
}
