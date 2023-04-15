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

/// Metadata about a FeedItem.
public struct Metadata: Hashable, Codable, Equatable {
    public let audioCount: UInt64
    public let audioDuration: UInt64
    public let galleryCount: UInt64
    public let hasAudio: Bool
    public let hasGallery: Bool
    public let hasPicture: Bool
    public let hasVideo: Bool
    public let isFeatured: Bool
    public let pictureCount: UInt64
    public let videoCount: UInt64
    public let videoDuration: UInt64

    public init(
        audioCount: UInt64, audioDuration: UInt64, galleryCount: UInt64, hasAudio: Bool,
        hasGallery: Bool, hasPicture: Bool, hasVideo: Bool, isFeatured: Bool,
        pictureCount: UInt64, videoCount: UInt64, videoDuration: UInt64
    ) {
        self.audioCount = audioCount
        self.audioDuration = audioDuration
        self.galleryCount = galleryCount
        self.hasAudio = hasAudio
        self.hasGallery = hasGallery
        self.hasPicture = hasPicture
        self.hasVideo = hasVideo
        self.isFeatured = isFeatured
        self.pictureCount = pictureCount
        self.videoCount = videoCount
        self.videoDuration = videoDuration
    }
}
