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

/// Gets a delivery key for a given video GUID. This delivery key is used to generate a stream URL for an m3u8 (as of
/// 4/3/2023) stream.
/// This is not a cached API call because we should only retrieve it when starting a video and I think it's generated on
/// demand.
protocol VodDeliveryKeyOperationStrategy: InternalOperationStrategy<VodDeliveryKeyRequest, DeliveryKey> {}

class VodDeliveryKeyOperationStrategyImpl: VodDeliveryKeyOperationStrategy {
    private let baseUrl: URL = .init(string: "\(OperationConstants.domainBaseUrl)/api/v2/cdn/delivery")!

    private let session: Session

    var dataRequest: DataRequest?

    init(session: Session) {
        self.session = session
    }

    /// Gets a DeliveryKey for a given video GUID
    func get(request: VodDeliveryKeyRequest) async -> OperationResponse<DeliveryKey> {
        let dataRequest = session.request(baseUrl, parameters: request.params)
        self.dataRequest = dataRequest
        return await withCheckedContinuation { continuation in
            dataRequest.responseDecodable(of: DeliveryKey.self) { response in
                continuation.resume(returning: OperationResponse(response: response.value, error: response.error))
            }
        }
    }
}
