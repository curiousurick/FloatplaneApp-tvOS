//
//  GetFirstPageResponse.swift
//  FloatplaneApp-Models
//
//  Created by George Urick on 4/2/23.
//

import Foundation

public struct GetFirstPageResponse: Codable {
    public var firstPage: [FeedItem]
    public var activeCreator: Creator
    public var baseCreators: [BaseCreator]
    
    public init(firstPage: [FeedItem], activeCreator: Creator, baseCreators: [BaseCreator]) {
        self.firstPage = firstPage
        self.activeCreator = activeCreator
        self.baseCreators = baseCreators
    }
}
