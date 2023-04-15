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

/// Metadata about a creator's channel.
public struct Channel: Hashable, Codable, Equatable {
    public let about: String
    public let card: String?
    public let cover: String?
    public let creator: String
    public let icon: Icon
    public let id: String
    public let order: UInt64
    public let title: String
    public let urlname: String

    public init(
        about: String, card: String?, cover: String?, creator: String,
        icon: Icon, id: String, order: UInt64, title: String, urlname: String
    ) {
        self.about = about
        self.card = card
        self.cover = cover
        self.creator = creator
        self.icon = icon
        self.id = id
        self.order = order
        self.title = title
        self.urlname = urlname
    }
}
