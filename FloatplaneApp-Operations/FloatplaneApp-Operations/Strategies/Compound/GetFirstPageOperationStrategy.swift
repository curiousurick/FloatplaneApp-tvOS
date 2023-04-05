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

import FloatplaneApp_Models
import FloatplaneApp_Utilities
import Alamofire

/// Multi-step asynchronous operation to get all the data you need to display the first page of results.
/// BaseCreators - Array<BaseCreator> - This is the list of the creators the user is subscribed to. It does not include all the info we need, though.
/// ActiveCreator - Creator - This is the full metadata for the first creator in the list. This is the creator whose feed will be displayed on first load.
/// Feed - Array<FeedItem> - This is the first page of video items that will be displayed on the browse tab.
///
/// The active creator call and first page feed call are made at the same time to improve latency.
protocol GetFirstPageOperationStrategy: InternalOperationStrategy<GetFirstPageRequest, GetFirstPageResponse> { }

class GetFirstPageOperationStrategyImpl: GetFirstPageOperationStrategy {
    private let logger = Log4S()
    
    private let creatorOperation: any CacheableStrategyBasedOperation<CreatorRequest, Creator>
    private let contentFeedOperation: any CacheableStrategyBasedOperation<ContentFeedRequest, CreatorFeed>
    private let creatorListOperation: any CacheableStrategyBasedOperation<CreatorListRequest, CreatorListResponse>
    
    var dataRequest: DataRequest?
    
    convenience init() {
        let operationManager = OperationManager.instance
        self.init(
            creatorOperation: operationManager.creatorOperation,
            contentFeedOperation: operationManager.contentFeedOperation,
            creatorListOperation: operationManager.creatorListOperation
        )
    }
    
    /// This is only for testing
    init(
        creatorOperation: any CacheableStrategyBasedOperation<CreatorRequest, Creator>,
        contentFeedOperation: any CacheableStrategyBasedOperation<ContentFeedRequest, CreatorFeed>,
        creatorListOperation: any CacheableStrategyBasedOperation<CreatorListRequest, CreatorListResponse>
    ) {
        self.creatorOperation = creatorOperation
        self.contentFeedOperation = contentFeedOperation
        self.creatorListOperation = creatorListOperation
    }
    
    /// Asynchronous retrieves the first page of data required to display the browse page
    func get(request _: GetFirstPageRequest) async -> OperationResponse<GetFirstPageResponse> {
        async let baseCreatorsAsync = creatorListOperation.get(request: CreatorListRequest())
        guard let baseCreators = await baseCreatorsAsync.response?.creators, !baseCreators.isEmpty else {
            return OperationResponse(response: nil, error: await baseCreatorsAsync.error)
        }
        let activeBaseCreator = baseCreators[0]
        let creatorRequest = CreatorRequest(named: activeBaseCreator.urlname)
        async let activeCreatorAsync = creatorOperation.get(request: creatorRequest)
        let contentFeedRequest = ContentFeedRequest.firstPage(for: activeBaseCreator.id)
        async let firstPageAsync = contentFeedOperation.get(request: contentFeedRequest)
        guard let activeCreator = await activeCreatorAsync.response else {
            return OperationResponse(response: nil, error: await activeCreatorAsync.error)
        }
        guard let firstPage = await firstPageAsync.response?.items else {
            return OperationResponse(response: nil, error: await firstPageAsync.error)
        }
        let response = GetFirstPageResponse(firstPage: firstPage, activeCreator: activeCreator, baseCreators: baseCreators)
        return OperationResponse(response: response, error: nil)
    }
}
