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

/// The response from the ContentVideoOperation.
public struct ContentVideoResponse: Codable, Equatable {
    public let id: String
    public let guid: String
    public let title: String
    public let type: PostType
    public let description: String
    public let releaseDate: Date?
    public let duration: UInt64
    public let creator: String
    public let likes: UInt64
    public let dislikes: UInt64
    public let score: UInt64
    public let isProcessing: Bool
    public let primaryBlogPost: String
    public let thumbnail: Icon
    public let isAccessible: Bool
    public let blogPosts: [String]
    public let timelineSprite: Icon?
    public let userInteraction: [String]
    public let levels: [QualityLevel]

    public init(
        id: String, guid: String, title: String, type: PostType, description: String,
        releaseDate: Date?, duration: UInt64, creator: String, likes: UInt64, dislikes: UInt64,
        score: UInt64, isProcessing: Bool, primaryBlogPost: String, thumbnail: Icon,
        isAccessible: Bool, blogPosts: [String], timelineSprite: Icon?, userInteraction: [String],
        levels: [QualityLevel]
    ) {
        self.id = id
        self.guid = guid
        self.title = title
        self.type = type
        self.description = description
        self.releaseDate = releaseDate
        self.duration = duration
        self.creator = creator
        self.likes = likes
        self.dislikes = dislikes
        self.score = score
        self.isProcessing = isProcessing
        self.primaryBlogPost = primaryBlogPost
        self.thumbnail = thumbnail
        self.isAccessible = isAccessible
        self.blogPosts = blogPosts
        self.timelineSprite = timelineSprite
        self.userInteraction = userInteraction
        self.levels = levels
    }
}
