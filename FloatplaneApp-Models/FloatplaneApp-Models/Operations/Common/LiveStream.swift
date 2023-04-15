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

/// Metadata about a channel's live stream.
public struct LiveStream: Hashable, Codable, Equatable {
    /// Info for display when the livestream is offline.
    public struct Offline: Hashable, Codable, Equatable {
        public let description: String
        public let thumbnail: Icon
        public let title: String

        public init(description: String, thumbnail: Icon, title: String) {
            self.description = description
            self.thumbnail = thumbnail
            self.title = title
        }
    }

    public let channel: String
    public let description: String
    public let id: String
    public let offline: Offline?
    public let owner: String
    public let streamPath: String
    public let thumbnail: Icon
    public let title: String

    public init(
        channel: String, description: String, id: String, offline: Offline?,
        owner: String, streamPath: String, thumbnail: Icon, title: String
    ) {
        self.channel = channel
        self.description = description
        self.id = id
        self.offline = offline
        self.owner = owner
        self.streamPath = streamPath
        self.thumbnail = thumbnail
        self.title = title
    }
}
