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

/// Gets full metadata for a single creator by urlname
/// Additional metadata over the base creator includes liveStream and subscription plans.
/// NOTE: This is a cacheable API operation which means the result will be stored in memory and disk until expired.
/// It uses the default expiry for CachableAPIOperation
protocol CreatorOperationStrategy: InternalOperationStrategy<CreatorRequest, Creator> {}

class CreatorOperationStrategyImpl: CreatorOperationStrategy {
    private let baseUrl = URL(string: "\(OperationConstants.domainBaseUrl)/api/v2/creator/named")!

    private let session: Session

    var dataRequest: DataRequest?

    init(session: Session) {
        self.session = session
    }

    /// Gets the full metadata for a creator given its urlname
    func get(request: CreatorRequest) async -> OperationResponse<Creator> {
        let dataRequest = session.request(baseUrl, parameters: request.params)
        self.dataRequest = dataRequest

        return await withCheckedContinuation { continuation in
            dataRequest.responseDecodable(of: [Creator].self) { response in
                // We should only be getting a single creator object back, even though it comes in an array.
                if let creators = response.value,
                   creators.count == 1 {
                    continuation.resume(returning: OperationResponse(response: creators[0], error: nil))
                }
                else {
                    continuation.resume(returning: OperationResponse(response: nil, error: response.error))
                }
            }
        }
    }
}
