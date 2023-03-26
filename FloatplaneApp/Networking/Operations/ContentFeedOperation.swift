//
//  GetVideos.swift
//  Floatplane App
//
//  Created by George Urick on 3/25/23.
//

import Foundation
import Alamofire

class ContentFeedOperation: APIOperation {
    
    typealias RequestParams = ContentFeedRequest
    typealias ResponseValue = CreatorFeed
    
    let baseUrl = URL(string: "https://\(OperationConstants.domain)/api/v3/content/creator")!
    
    func get(params: ContentFeedRequest, completion: ((CreatorFeed?, Error?) -> Void)? = nil) {
        let params: [String: Any] = [
            "id" : params.creatorId,
            "limit" : params.limit
        ]
        
        let request = AF.request(baseUrl, parameters: params)
        
        request.responseDecodable(of: [CreatorFeed.FeedItem].self, decoder: CreatorFeedDecoder()) { response in
            print("About to print decoded object")
            let items = response.value!
            let feed = CreatorFeed(items: items)
            completion?(feed, nil)
        }
    }
}
