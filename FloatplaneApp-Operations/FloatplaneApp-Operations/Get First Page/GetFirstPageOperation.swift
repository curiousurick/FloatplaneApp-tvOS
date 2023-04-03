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

/// Multi-step asynchronous operation to get all the data you need to display the first page of results.
/// BaseCreators - Array<BaseCreator> - This is the list of the creators the user is subscribed to. It does not include all the info we need, though.
/// ActiveCreator - Creator - This is the full metadata for the first creator in the list. This is the creator whose feed will be displayed on first load.
/// Feed - Array<FeedItem> - This is the first page of video items that will be displayed on the browse tab.
///
/// The active creator call and first page feed call are made at the same time to improve latency.
public class GetFirstPageOperation {
    private let logger = Log4S()
    
    /// Asynchronous retrieves the first page of data required to display the browse page
    public func get() async -> (GetFirstPageResponse?, Error?) {
        async let baseCreatorsAsync = getCreators()
        guard let baseCreators = await baseCreatorsAsync.0, !baseCreators.isEmpty else {
            return (nil, await baseCreatorsAsync.1)
        }
        let activeBaseCreator = baseCreators[0]
        async let activeCreatorAsync = getActiveCreator(urlName: activeBaseCreator.urlname)
        async let firstPageAsync = getFirstPage(creatorId: activeBaseCreator.id)
        guard let activeCreator = await activeCreatorAsync.0 else {
            return (nil, await activeCreatorAsync.1)
        }
        guard let firstPage = await firstPageAsync.0 else {
            return (nil, await firstPageAsync.1)
        }
        let response = GetFirstPageResponse(firstPage: firstPage, activeCreator: activeCreator, baseCreators: baseCreators)
        return (response, nil)
    }
    
    /// Gets the list of basic metadata for the creators the user is subscribed to.
    private func getCreators() async -> ([BaseCreator]?, Error?) {
        return await withCheckedContinuation { continuation in
            OperationManager.instance.creatorListOperation.get(request: CreatorListRequest()) { response, error in
                return continuation.resume(returning: (response?.creators, error))
            }
        }
    }
    
    /// Gets the full metadata for the active creator selected by the default.
    private func getActiveCreator(urlName: String) async -> (Creator?, Error?) {
        let request = CreatorRequest(named: urlName)
        return await withCheckedContinuation { continutation in
            OperationManager.instance.creatorOperation.get(request: request) { response, error in
                continutation.resume(returning: (response, error))
            }
        }
    }
    
    /// Gets the first page of feed items for the active creator.
    private func getFirstPage(creatorId: String) async -> ([FeedItem]?, Error?) {
        logger.debug("Fetching next page of content for feed")
        let request = ContentFeedRequest.firstPage(for: creatorId)
        return await withCheckedContinuation { continuation in
            OperationManager.instance.contentFeedOperation.get(request: request) { fetchedFeed, error in
                continuation.resume(returning: (fetchedFeed?.items, error))
            }
        }
    }
    
}
