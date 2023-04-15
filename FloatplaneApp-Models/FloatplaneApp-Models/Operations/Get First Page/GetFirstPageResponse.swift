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

/// The data needed to display the first page in the app when logged in.
public struct GetFirstPageResponse: Codable {
    /// Active creator's first page of results (20 items as of 4/8/2023)
    public var firstPage: [FeedItem]
    /// Full metadata for the active creator.
    public var activeCreator: Creator
    /// List of basic metadata for all creators to which the user is subscribed.
    public var baseCreators: [BaseCreator]

    public init(firstPage: [FeedItem], activeCreator: Creator, baseCreators: [BaseCreator]) {
        self.firstPage = firstPage
        self.activeCreator = activeCreator
        self.baseCreators = baseCreators
    }
}
