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

class ContentFeedOperation: CacheableAPIOperation<ContentFeedRequest, CreatorFeed> {
    
    typealias Request = ContentFeedRequest
    typealias ResponseValue = CreatorFeed
    
    static let base = URL(string: "https://\(OperationConstants.domain)/api/v3/content/creator")!
    
    init() {
        super.init(baseUrl: ContentFeedOperation.base)
    }
    
    override func get(request: ContentFeedRequest, completion: ((CreatorFeed?, Error?) -> Void)? = nil) {
        if let cache = getCache(request: request) {
            completion?(cache, nil)
            return
        }
        let params: [String: Any] = [
            "fetchAfter" : request.fetchAfter,
            "id" : request.creatorId,
            "limit" : request.limit
        ]
        
        AF.request(baseUrl, parameters: params)
            .responseDecodable(of: [CreatorFeed.FeedItem].self, decoder: CreatorFeedDecoder()) { response in
            let items = response.value!
            let creatorFeed = CreatorFeed(items: items)
            self.setCache(request: request, response: creatorFeed)
            completion?(creatorFeed, nil)
        }
    }
}
