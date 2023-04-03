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

/// This gets a page of the ContentFeed for a given creator's ID. Takes other parameters like the limit of results and fetchAfter which indicates the index to start returning for pagination.
/// Note: This API has a max limit of 20 results per call.
public class ContentFeedOperation: CacheableAPIOperation<ContentFeedRequest, CreatorFeed> {
    
    typealias Request = ContentFeedRequest
    typealias ResponseValue = CreatorFeed
    
    private static let base = URL(string: "\(OperationConstants.domainBaseUrl)/api/v3/content/creator")!
    
    init() {
        super.init(baseUrl: ContentFeedOperation.base)
    }
    
    /// Gets a list of FeedItems for a given creator, limit, and fetchAfter.
    override func _get(request: ContentFeedRequest, completion: ((CreatorFeed?, Error?) -> Void)? = nil) -> DataRequest {
        return AF.request(baseUrl, parameters: request.params).responseDecodable(of: [FeedItem].self, decoder: FloatplaneDecoder()) { response in
            if let items = response.value {
                let creatorFeed = CreatorFeed(items: items)
                completion?(creatorFeed, nil)
            }
            else {
                completion?(nil, response.error)
            }
        }
    }
}
