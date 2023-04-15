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

/// Gets the list of basic creator metadata. Essentially treated as the Subscriptions for the customer to be displayed
/// on the browse view's sidebar.
/// This is not sufficient to keep track of the active creator because it does not include livestream or subscription
/// information.
/// It also gets an object called UserNotificationSetting for each creator but its not really utilized on tvOS.
protocol CreatorListOperationStrategy: InternalOperationStrategy<CreatorListRequest, CreatorListResponse> {}

class CreatorListOperationStrategyImpl: CreatorListOperationStrategy {
    private let baseUrl = URL(string: "\(OperationConstants.domainBaseUrl)/api/v3/user/notification/list")!

    private let session: Session

    var dataRequest: DataRequest?

    init(session: Session) {
        self.session = session
    }

    /// Gets the list of BaseCreator information for every creator the user is subscribed to.
    func get(request _: CreatorListRequest) async -> OperationResponse<CreatorListResponse> {
        let dataRequest = session.request(baseUrl)
        self.dataRequest = dataRequest
        return await withCheckedContinuation { continuation in
            dataRequest.responseDecodable(
                of: [CreatorListResponse.CreatorResponseObject].self,
                decoder: FloatplaneDecoder()
            ) { response in
                if let value = response.value {
                    let creatorListResponse = CreatorListResponse(responseObjects: value)
                    continuation.resume(returning: OperationResponse(response: creatorListResponse, error: nil))
                }
                else {
                    continuation.resume(returning: OperationResponse(response: nil, error: response.error))
                }
            }
        }
    }
}
