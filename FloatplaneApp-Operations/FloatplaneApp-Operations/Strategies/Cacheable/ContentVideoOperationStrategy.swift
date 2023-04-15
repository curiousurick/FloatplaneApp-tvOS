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

/// This gets the full metadata for a given Video ID.
/// It includes additional metadata not included in a FeedItem, such as quality levels.
/// NOTE: This is a CacheableAPIOperation and uses the default expiry and capacity limits
protocol ContentVideoOperationStrategy: InternalOperationStrategy<ContentVideoRequest, ContentVideoResponse> {}

class ContentVideoOperationStrategyImpl: ContentVideoOperationStrategy {
    private let baseUrl = URL(string: "\(OperationConstants.domainBaseUrl)/api/v3/content/video")!

    private let session: Session

    var dataRequest: DataRequest?

    init(session: Session) {
        self.session = session
    }

    /// Gets the full metadata for a given video ID.
    func get(request: ContentVideoRequest) async -> OperationResponse<ContentVideoResponse> {
        let dataRequest = session.request(baseUrl, parameters: request.params)
        self.dataRequest = dataRequest
        return await withCheckedContinuation { continuation in
            dataRequest.responseDecodable(of: ContentVideoResponse.self, decoder: FloatplaneDecoder()) { response in
                if let response = response.value {
                    continuation.resume(returning: OperationResponse(response: response, error: nil))
                }
                else {
                    continuation.resume(returning: OperationResponse(response: nil, error: response.error))
                }
            }
        }
    }
}
