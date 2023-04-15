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

/// Request to get a content feed. Allows for pagination by setting the index to fetch after.
/// Note: The max limit is 20. If it's higher, the API will reject.
public struct ContentFeedRequest: OperationRequest {
    public let fetchAfter: Int
    public let limit: UInt64
    public let creatorId: String
    public let channel: String?
    private let hasVideo: Bool = true
    private let hasAudio: Bool = false
    private let hasPicture: Bool = false
    private let hasText: Bool = false

    /// Simplifier for creating a request to get the first 20 items for a creator.
    public static func firstPage(for creatorId: String, channel: String? = nil) -> ContentFeedRequest {
        ContentFeedRequest(fetchAfter: 0, limit: 20, creatorId: creatorId, channel: channel)
    }

    public init(
        fetchAfter: Int,
        limit: UInt64,
        creatorId: String,
        channel: String? = nil
    ) {
        self.fetchAfter = fetchAfter
        self.limit = limit
        self.creatorId = creatorId
        self.channel = channel
    }

    public var params: [String: Any] {
        var map: [String: Any] = [
            "fetchAfter": fetchAfter,
            "id": creatorId,
            "limit": limit,
            "hasVideo": hasVideo.stringValue,
            "hasAudio": hasAudio.stringValue,
            "hasPicture": hasPicture.stringValue,
            "hasText": hasText.stringValue,
        ]
        if let channel = channel {
            map["channel"] = channel
        }
        return map
    }
}
