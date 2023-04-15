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
import Foundation
@testable import FloatplaneApp_Utilities

class Log4STest: XCTestCase {
    private var subject: Log4S!

    override func setUp() {
        super.setUp()
        subject = Log4S()
    }

    func testLogLevel() {
        subject.logLevel = .debug
        subject.logLevel = .trace
        subject.logLevel = .info
        subject.logLevel = .warning
        subject.logLevel = .notice
        subject.logLevel = .error
        subject.logLevel = .critical
    }

    func testDebug() {
        let variable = "My input"
        subject.debug("My cool message \(variable)")
    }

    func testTrace() {
        let variable = "My input"
        subject.trace("My cool message \(variable)")
    }

    func testWarn() {
        let variable = "My input"
        subject.warn("My cool message \(variable)")
    }

    func testInfo() {
        let variable = "My input"
        subject.info("My cool message \(variable)")
    }

    func testNotice() {
        let variable = "My input"
        subject.notice("My cool message \(variable)")
    }

    func testCritical() {
        let variable = "My input"
        subject.critical("My cool message \(variable)")
    }

    func testError() {
        let variable = "My input"
        subject.error("My cool message \(variable)")
    }
}
