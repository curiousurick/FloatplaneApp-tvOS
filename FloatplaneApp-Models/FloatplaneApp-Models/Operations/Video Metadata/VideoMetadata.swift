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

public struct VideoMetadata: Codable, Equatable {
    public let id: String
    public let guid: String
    public let title: String
    public let type: PostType
    public let channel: Channel
    public let description: String
    public let releaseDate: Date?
    public let duration: UInt64
    public let creator: ContentCreator
    public let likes: UInt64
    public let dislikes: UInt64
    public let score: UInt64
    public let thumbnail: Icon
    public let levels: [QualityLevel]
    public let deliveryKey: DeliveryKey
    
    public init(
        feedItem: FeedItem,
        contentVideoResponse: ContentVideoResponse,
        deliveryKey: DeliveryKey
    ) {
        self.id = contentVideoResponse.id
        self.guid = contentVideoResponse.guid
        self.title = contentVideoResponse.title
        self.type = contentVideoResponse.type
        self.channel = feedItem.channel
        self.description = feedItem.text
        self.releaseDate = feedItem.releaseDate
        self.duration = contentVideoResponse.duration
        self.creator = feedItem.creator
        self.likes = contentVideoResponse.likes
        self.dislikes = contentVideoResponse.dislikes
        self.score = contentVideoResponse.score
        self.thumbnail = contentVideoResponse.thumbnail
        self.levels = contentVideoResponse.levels
        self.deliveryKey = deliveryKey
    }
}
