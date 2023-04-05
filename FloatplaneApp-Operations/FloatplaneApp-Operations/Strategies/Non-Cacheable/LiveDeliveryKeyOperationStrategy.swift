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
import Alamofire
import FloatplaneApp_Models

/// This operation retrieves a delivery key for the active creator's live stream.
/// The delivery key contains a set of streams, parameterized by quality level.
/// However, the delivery key looks different for VOD and Live so the responses are different.
/// The result of this operation is not cached.
protocol LiveDeliveryKeyOperationStrategy: InternalOperationStrategy<LiveDeliveryKeyRequest, DeliveryKey> { }

class LiveDeliveryKeyOperationStrategyImpl: LiveDeliveryKeyOperationStrategy {
    private let baseUrl: URL = URL(string: "\(OperationConstants.domainBaseUrl)/api/v2/cdn/delivery")!
    
    var dataRequest: DataRequest?
    
    func get(request: LiveDeliveryKeyRequest) async -> OperationResponse<DeliveryKey> {
        let dataRequest = AF.request(baseUrl, parameters: request.params)
        self.dataRequest = dataRequest
        return await withCheckedContinuation { continuation in
            AF.request(baseUrl, parameters: request.params).responseDecodable(of: DeliveryKey.self) { response in
                continuation.resume(returning: OperationResponse(response: response.value, error: response.error))
            }
        }
    }
}
