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

/// Request to get search results for a given creator, filtered by the search query.
public struct SearchRequest: OperationRequest {
    public let creatorId: String
    public let sort: SortOrder
    public let searchQuery: String
    public let fetchAfter: Int
    public let limit: Int
    private let hasVideo: Bool = true
    private let hasAudio: Bool = false
    private let hasPicture: Bool = false
    private let hasText: Bool = false

    public init(
        creatorId: String,
        sort: SortOrder,
        searchQuery: String,
        fetchAfter: Int,
        limit: Int
    ) {
        self.creatorId = creatorId
        self.sort = sort
        self.searchQuery = searchQuery
        self.fetchAfter = fetchAfter
        self.limit = limit
    }

    public var params: [String: Any] {
        [
            "id": creatorId,
            "sort": sort.rawValue,
            "hasVideo": hasVideo.stringValue,
            "hasAudio": hasAudio.stringValue,
            "hasPicture": hasPicture.stringValue,
            "hasText": hasText.stringValue,
            "search": searchQuery,
            "fetchAfter": fetchAfter,
            "limit": limit,
        ]
    }
}
