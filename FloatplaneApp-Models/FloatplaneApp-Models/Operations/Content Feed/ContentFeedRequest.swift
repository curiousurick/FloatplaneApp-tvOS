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
import FloatplaneApp_Utilities

public struct ContentFeedRequest: OperationRequest {
    public let fetchAfter: Int
    public let limit: UInt64
    public let creatorId: String
    private let hasVideo: Bool = true
    private let hasAudio: Bool = false
    private let hasPicture: Bool = false
    private let hasText: Bool = false
    
    public static func firstPage(for creatorId: String) -> ContentFeedRequest {
        return ContentFeedRequest(fetchAfter: 0, limit: 20, creatorId: creatorId)
    }
    
    public init(fetchAfter: Int, limit: UInt64, creatorId: String) {
        self.fetchAfter = fetchAfter
        self.limit = limit
        self.creatorId = creatorId
    }
    
    public var params: [String : Any] {
        return [
            "fetchAfter" : fetchAfter,
            "id" : creatorId,
            "limit" : limit,
            "hasVideo" : hasVideo.stringValue,
            "hasAudio" : hasAudio.stringValue,
            "hasPicture" : hasPicture.stringValue,
            "hasText" : hasText.stringValue
        ]
    }
    
    
}
