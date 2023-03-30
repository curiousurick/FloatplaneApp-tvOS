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

class SearchOperation: CacheableAPIOperation<SearchRequest, SearchResponse> {
    
    typealias Request = SearchRequest
    typealias Response = SearchResponse
    static let base = URL(string: "https://\(OperationConstants.domain)/api/v3/content/creator")!
    
    init() {
        super.init(
            countLimit: 500,
            // Default 30 minutes
            cacheExpiration: 30 * 60,
            baseUrl: SearchOperation.base
        )
    }
    
    override func _get(request: SearchRequest, completion: ((SearchResponse?, Error?) -> Void)? = nil) -> DataRequest {
        return AF.request(SearchOperation.base, parameters: request.params)
            .responseDecodable(of: [FeedItem].self, decoder: CreatorFeedDecoder()) { response in
            if let error = response.error, error.isExplicitlyCancelledError {
                return
            }
            let items = response.value!
            let searchResponse = SearchResponse(items: items)
            completion?(searchResponse, nil)
        }
    }
}
