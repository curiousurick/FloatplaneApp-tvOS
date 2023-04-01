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

/// This operation retrieves a delivery key for the active creator's live stream.
/// The delivery key contains a set of streams, parameterized by quality level.
/// However, the delivery key looks different for VOD and Live so the responses are different.
/// The result of this operation is not cached.
class LiveDeliveryKeyOperation: APIOperation {
    typealias Request = LiveDeliveryKeyRequest
    typealias Response = LiveDeliveryKey
    
    let baseUrl: URL = URL(string: "\(OperationConstants.domainBaseUrl)/api/v2/cdn/delivery")!
    
    // 1 minute
    let timeBetweenLiveStreamChecks: TimeInterval = 60 * 1
    var lastCheck: [LiveDeliveryKeyRequest : Date] = [:]
    
    /// If this request has been made in the last minute, it's not allowed.
    /// This is because the LiveStream View and Offline View both check
    /// if the stream is happening. If the status changes, the view will switch
    /// to the other. However, sometimes, livestreams end and the deliveryKey
    /// remains available. Because of this, the offline view may think it's online
    /// and switch back. As of now, there's no signal that 100% proves it's offline
    /// until an AVPlayer attempts to play.
    /// TODO: Find a better solution that just stopping the request from being made again.
    func isAllowedToCheckForLiveStream(request: LiveDeliveryKeyRequest) -> Bool {
        if let lastCheck = lastCheck[request] {
            return Date().timeIntervalSince(lastCheck) > timeBetweenLiveStreamChecks
        }
        return true
    }
    
    func get(request: LiveDeliveryKeyRequest, completion: ((LiveDeliveryKey?, Error?) -> Void)? = nil) {
        AF.request(baseUrl, parameters: request.params).responseDecodable(of: LiveDeliveryKey.self) { response in
            completion?(response.value!, nil)
            self.lastCheck[request] = Date()
        }
    }
}
