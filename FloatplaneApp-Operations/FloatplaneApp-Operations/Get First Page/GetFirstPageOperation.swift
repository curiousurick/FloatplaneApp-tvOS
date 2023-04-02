//
//  GetFirstPageOperation.swift
//  FloatplaneApp-Operations
//
//  Created by George Urick on 4/2/23.
//

import FloatplaneApp_Models
import FloatplaneApp_Utilities

public class GetFirstPageOperation {
    private let logger = Log4S()
    
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
    
    private func getCreators() async -> ([BaseCreator]?, Error?) {
        return await withCheckedContinuation { continuation in
            OperationManager.instance.creatorListOperation.get(request: CreatorListRequest()) { response, error in
                return continuation.resume(returning: (response?.creators, error))
            }
        }
    }
    
    private func getActiveCreator(urlName: String) async -> (Creator?, Error?) {
        let request = CreatorRequest(named: urlName)
        return await withCheckedContinuation { continutation in
            OperationManager.instance.creatorOperation.get(request: request) { response, error in
                continutation.resume(returning: (response, error))
            }
        }
    }
    
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
