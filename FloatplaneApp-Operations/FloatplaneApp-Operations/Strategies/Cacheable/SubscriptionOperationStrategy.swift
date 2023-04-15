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

/// Looks up user subscriptions. Includes information about the subscription itself.
/// May need to use this in the future to determine if the user has access to a given video.
/// TODO: Investigate if ContentFeed returns videos that user does not have access to. Maybe need to do client-side
/// limiting to avoid CX cliff.
protocol SubscriptionOperationStrategy: InternalOperationStrategy<SubscriptionRequest, SubscriptionResponse> {}

class SubscriptionOperationStrategyImpl: SubscriptionOperationStrategy {
    private let baseUrl = URL(string: "\(OperationConstants.domainBaseUrl)/api/v3/user/subscriptions")!

    private let session: Session

    var dataRequest: DataRequest?

    init(session: Session) {
        self.session = session
    }

    /// Looks up subscription data for the user, including the level of support for each subscribed creator.
    func get(request _: SubscriptionRequest) async -> OperationResponse<SubscriptionResponse> {
        let dataRequest = session.request(baseUrl)
        self.dataRequest = dataRequest
        return await withCheckedContinuation { continuation in
            dataRequest.responseDecodable(of: [Subscription].self, decoder: FloatplaneDecoder()) { response in
                if let subscriptions = response.value {
                    let subsResponse = SubscriptionResponse(subscriptions: subscriptions)
                    let opResponse = OperationResponse(response: subsResponse, error: nil)
                    continuation.resume(returning: opResponse)
                }
                else {
                    continuation.resume(returning: OperationResponse(response: nil, error: response.error))
                }
            }
        }
    }
}
