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
import FloatplaneApp_Utilities
import FloatplaneApp_Models

// Protocol implementation to allow mocking
protocol SearchOperationStrategy: InternalOperationStrategy<SearchRequest, SearchResponse> { }

/// Performs a search on a given creator for a given query.
/// Today, this search is basic and limited to videos because this is for tvOS.
/// TODO: Determine if tvOS makes sense to support image and text posts.
class SearchOperationStrategyImpl: SearchOperationStrategy {
    private let logger = Log4S()
    
    private let baseUrl = URL(string: "\(OperationConstants.domainBaseUrl)/api/v3/content/creator")!
    
    var dataRequest: DataRequest?
    
    /// Performs search for a given creator and query string.
    /// Includes pagination through fetchAfter field,
    /// Includes order through sortOrder field.
    func get(request: SearchRequest) async -> OperationResponse<SearchResponse> {
        let dataRequest = AF.request(baseUrl, parameters: request.params)
        self.dataRequest = dataRequest
        return await withCheckedContinuation { continuation in
            dataRequest.responseDecodable(of: [FeedItem].self, decoder: FloatplaneDecoder()) { response in
                // This is because we don't want to burden the caller with handling this.
                // Search Queries will update views upon results and a failed/canceled call while
                // typing shouldn't erase what is currently visible.
                if let error = response.error, error.isExplicitlyCancelledError {
                    self.logger.info("SearchRequest canceled before response was ready. This is okay")
                    return
                }
                guard let items = response.value else {
                    self.logger.error("SearchRequest returned with no error but also no results.")
                    return
                }
                let searchResponse = SearchResponse(items: items)
                continuation.resume(returning: OperationResponse(response: searchResponse, error: nil))
            }
        }
    }
}
