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
@testable import FloatplaneApp_Operations

final class ImageGrabberTest: XCTestCase {
    private var subject: ImageGrabber!

    override func setUp() {
        super.setUp()
        subject = ImageGrabber.instance
    }

    func testGrab() {
        let url =
            URL(
                string: "https://fastly.picsum.photos/id/798/200/300.jpg?hmac=yFyrzP0X505Qku3jZc0D4qL6MX_xXeHRP4K_006XD9M"
            )!
        let expectsCompletion = expectation(description: "Should call completion block")
        subject.grab(url: url) { data in
            XCTAssertNotNil(data)
            let image = UIImage(data: data!)
            XCTAssertNotNil(image)
            expectsCompletion.fulfill()
        }
        wait(for: [expectsCompletion], timeout: 10.0)
    }

    func testGrab_twice() {
        let url =
            URL(
                string: "https://fastly.picsum.photos/id/798/200/300.jpg?hmac=yFyrzP0X505Qku3jZc0D4qL6MX_xXeHRP4K_006XD9M"
            )!
        let expectsCompletionFirst = expectation(description: "Should call completion block 1st time")
        let expectsCompletionSecond = expectation(description: "Should call completion block 2nd time")
        subject.grab(url: url) { data in
            XCTAssertNotNil(data)
            let image = UIImage(data: data!)
            XCTAssertNotNil(image)
            expectsCompletionFirst.fulfill()
        }
        subject.grab(url: url) { data in
            XCTAssertNotNil(data)
            let image = UIImage(data: data!)
            XCTAssertNotNil(image)
            expectsCompletionSecond.fulfill()
        }
        wait(for: [expectsCompletionFirst, expectsCompletionSecond], timeout: 10.0)
    }

    func testGrab_badURL() {
        let url = URL(string: "https://eatmyshorts.com/fakeimage.jpg")!
        let expectsCompletion = expectation(description: "Should call completion block")
        subject.grab(url: url) { data in
            XCTAssertNil(data)
            expectsCompletion.fulfill()
        }
        wait(for: [expectsCompletion], timeout: 10.0)
    }
}
