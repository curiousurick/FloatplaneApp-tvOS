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

/// Contains info about the user's notification settings for a creator.
public struct UserNotificationSetting: Codable, Equatable {
    public let contentEmail: Bool
    public let contentFirebase: Bool
    public let createdAt: Date
    public let creator: String
    public let creatorMessageEmail: Bool
    public let id: String
    public let updatedAt: Date
    public let user: String

    public init(
        contentEmail: Bool, contentFirebase: Bool, createdAt: Date, creator: String,
        creatorMessageEmail: Bool, id: String, updatedAt: Date, user: String
    ) {
        self.contentEmail = contentEmail
        self.contentFirebase = contentFirebase
        self.createdAt = createdAt
        self.creator = creator
        self.creatorMessageEmail = creatorMessageEmail
        self.id = id
        self.updatedAt = updatedAt
        self.user = user
    }
}
