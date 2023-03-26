//
//  GetVideos.swift
//  Floatplane App
//
//  Created by George Urick on 3/25/23.
//

import Foundation
import Alamofire

class GetVideos {
    
    let feed = "https://www.floatplane.com/api/v3/content/creator?id=59f94c0bdd241b70349eb72b&limit=20"
    let video = "https://cdn-vod-drm2.floatplane.com//Videos/wcKzVJkZMg/1080.mp4"
    
    func get() {
        
        let cookieProps = [
            HTTPCookiePropertyKey.domain: "www.floatplane.com",
            HTTPCookiePropertyKey.path: "/",
            HTTPCookiePropertyKey.name: UserConfiguration.cookieKey,
            HTTPCookiePropertyKey.value: UserConfiguration.cookie
           ]
        
        if let cookie = HTTPCookie(properties: cookieProps) {
            AF.session.configuration.httpCookieStorage?.setCookie(cookie)
        }
        
        let request = AF.request(URL(string: feed)!)
        
        request.responseJSON { response in
            print("About to print decoded object")
        }
        
        request.responseDecodable(of: [CreatorFeed].self, decoder: CreatorFeedDecoder()) { response in
            print("About to print decoded object")
        }
    }
}
