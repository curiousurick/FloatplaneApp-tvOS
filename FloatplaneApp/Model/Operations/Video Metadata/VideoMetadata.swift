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

struct VideoMetadata {
    let id: String
    let guid: String
    let title: String
    let type: PostType
    let channel: Channel
    let description: String
    let releaseDate: Date?
    let duration: UInt64
    let creator: ContentCreator
    let likes: UInt64
    let dislikes: UInt64
    let score: UInt64
    let thumbnail: Icon
    let levels: [QualityLevel]
    let deliveryKey: VodDeliveryKey
    
    init(
        feedItem: FeedItem,
        contentVideoResponse: ContentVideoResponse,
        deliveryKey: VodDeliveryKey
    ) {
        self.id = contentVideoResponse.id
        self.guid = contentVideoResponse.guid
        self.title = contentVideoResponse.title
        self.type = contentVideoResponse.type
        self.channel = feedItem.channel
        self.description = contentVideoResponse.description
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
