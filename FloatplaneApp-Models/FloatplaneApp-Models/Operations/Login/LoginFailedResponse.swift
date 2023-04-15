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

/// Swift Error for failure to login. Contains the API's LoginFailedResponse with info why it failed.
public enum LoginFailedError: Error {
    /// Should remain the only option
    case error(response: LoginFailedResponse)

    /// Extracts the response because Swift errors are weird.
    public var response: LoginFailedResponse {
        switch self {
        case let .error(response):
            return response
        }
    }
}

/// Contains info about errors which occurred when the cloud tried to login the user.
public struct LoginFailedResponse: Codable, Equatable {
    public struct LoginError: Codable, Equatable {
        public let id: String
        /// Readable info about the error that occurred while logging in. Will be displayed to customer.
        public let message: String
        public let name: String

        public init(id: String, message: String, name: String) {
            self.id = id
            self.message = message
            self.name = name
        }
    }

    public let errors: [LoginError]
    public let message: String

    public init(errors: [LoginError], message: String) {
        self.errors = errors
        self.message = message
    }
}
