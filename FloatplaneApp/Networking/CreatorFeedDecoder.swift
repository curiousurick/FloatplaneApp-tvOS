//
//  CreatorFeedDecoder.swift
//  Floatplane App
//
//  Created by George Urick on 3/25/23.
//

import Foundation

class CreatorFeedDecoder: JSONDecoder {
    
    override init() {
        super.init()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateDecodingStrategy = .formatted(dateFormatter)
    }
}
