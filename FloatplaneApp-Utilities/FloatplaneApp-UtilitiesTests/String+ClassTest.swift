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

import XCTest
import FloatplaneApp_Models
@testable import FloatplaneApp_Utilities

final class StringClassTest: XCTestCase {
    func testStringForObject() {
        // Arrange
        let request = ContentFeedRequest(fetchAfter: 20, limit: 20, creatorId: "CreatorId")

        // Act
        let result = String.fromClass(request)

        // Assert
        XCTAssertEqual(result, "ContentFeedRequest")
    }

    /// Unfortunately, I haven't found a way to get the type of a nil value.
    /// The best we can do now is to describe that it's nil
    func testStringForNilObject() {
        // Arrange
        let request: ContentFeedRequest? = nil

        // Act
        let result = String.fromClass(request)

        // Assert
        XCTAssertEqual(result, "Optional<Any>(nil)")
    }

    func testStringForClass() {
        // Act
        let result = String.fromClass(ContentFeedRequest.self)

        // Assert
        XCTAssertEqual(result, "ContentFeedRequest")
    }
}
