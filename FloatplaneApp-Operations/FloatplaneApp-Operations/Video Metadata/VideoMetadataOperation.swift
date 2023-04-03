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

/// Gets the full video metadata wrapper object for a given feed item.
/// This is a compound API operation which gets a DeliveryKey and full ContentVideoResponse and wraps it in VideoMetadata with the given FeedItem.
/// Note: DeliveryKey will not be cached but ContentVideoOperation is a CacheableAPIOperation
public class VideoMetadataOperation {
    
    /// Takes a feedItem and the video's GUID and returns a wrapper object with more full metadata with:
    /// 1. The video including quality levels
    /// 2. The delivery key for the video.
    /// 3. The given FeedItem object
    public func get(request: VideoMetadataRequest, completion: ((VideoMetadata?, Error?) -> Void)? = nil) {
        Task {
            async let deliveryKey = await getDeliveryKey(id: request.id)
            async let contentVideo = await getContentVideo(id: request.id)
            if let deliveryKey = await deliveryKey.0,
               let contentVideo = await contentVideo.0 {
                let result = VideoMetadata(feedItem: request.feedItem, contentVideoResponse: contentVideo, deliveryKey: deliveryKey)
                completion?(result, nil)
            }
            else {
                let deliveryKeyError = await deliveryKey.1
                let contentVideoError = await contentVideo.1
                let error: Error? = deliveryKeyError ?? contentVideoError
                completion?(nil, error)
            }
        }
    }
    
    /// Retrieves the full metadata for a given video ID.
    private func getContentVideo(id: String) async -> (ContentVideoResponse?, Error?) {
        await withCheckedContinuation({ continuation in
            let request = ContentVideoRequest(id: id)
            OperationManager.instance.contentVideoOperation.get(request: request) { contentVideo, error in
                continuation.resume(returning: (contentVideo, error))
            }
        })
    }
    
    /// Retrieves the DeliveryKey for a given video ID.
    private func getDeliveryKey(id: String) async -> (DeliveryKey?, Error?) {
        await withCheckedContinuation({ continuation in
            let request = VodDeliveryKeyRequest(guid: id)
            VodDeliveryKeyOperation().get(request: request) { deliveryKey, error in
                continuation.resume(returning: (deliveryKey, error))
            }
        })
    }
}
