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

/// Gets the full video metadata wrapper object for a given feed item.
/// This is a compound API operation which gets a DeliveryKey and full ContentVideoResponse and wraps it in
/// VideoMetadata with the given FeedItem.
/// Note: DeliveryKey will not be cached but ContentVideoOperation is a CacheableAPIOperation
public protocol VideoMetadataOperation: Operation<VideoMetadataRequest, VideoMetadata> {}

class VideoMetadataOperationImpl: VideoMetadataOperation {
    private let contentVideoOperation: any CacheableStrategyBasedOperation<ContentVideoRequest, ContentVideoResponse>
    private let vodDeliveryKeyOperation: any StrategyBasedOperation<VodDeliveryKeyRequest, DeliveryKey>

    init(
        contentVideoOperation: any CacheableStrategyBasedOperation<ContentVideoRequest, ContentVideoResponse>,
        vodDeliveryKeyOperation: any StrategyBasedOperation<VodDeliveryKeyRequest, DeliveryKey>
    ) {
        self.contentVideoOperation = contentVideoOperation
        self.vodDeliveryKeyOperation = vodDeliveryKeyOperation
    }

    var dataRequest: Alamofire.DataRequest?

    /// Takes a feedItem and the video's GUID and returns a wrapper object with more full metadata with:
    /// 1. The video including quality levels
    /// 2. The delivery key for the video.
    /// 3. The given FeedItem object
    func get(request: VideoMetadataRequest) async -> OperationResponse<VideoMetadata> {
        let deliveryKeyRequest = VodDeliveryKeyRequest(guid: request.id)
        async let deliveryKey = await vodDeliveryKeyOperation.get(request: deliveryKeyRequest)
        let contentVideoRequest = ContentVideoRequest(id: request.id)
        async let contentVideo = await contentVideoOperation.get(request: contentVideoRequest)
        if let deliveryKey = await deliveryKey.response,
           let contentVideo = await contentVideo.response {
            let result = VideoMetadata(
                feedItem: request.feedItem,
                contentVideoResponse: contentVideo,
                deliveryKey: deliveryKey
            )
            return OperationResponse(response: result, error: nil)
        }
        let deliveryKeyError = await deliveryKey.error
        let contentVideoError = await contentVideo.error
        let error: Error? = deliveryKeyError ?? contentVideoError
        return OperationResponse(response: nil, error: error)
    }

    func isActive() -> Bool {
        contentVideoOperation.isActive() ||
            vodDeliveryKeyOperation.isActive()
    }

    func cancel() {
        contentVideoOperation.cancel()
        vodDeliveryKeyOperation.cancel()
    }
}
