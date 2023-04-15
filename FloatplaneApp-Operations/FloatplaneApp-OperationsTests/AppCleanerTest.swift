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
import FloatplaneApp_DataStores
@testable import FloatplaneApp_Operations

class AppCleanerTest: XCTestCase {
    /// Mocks
    private var mockUserStore: MockUserStore!
    private var mockOperationManager: MockOperationManager!
    private var mockUrlCache: MockURLCache!

    private var subject: AppCleanerImpl!

    override func setUp() {
        super.setUp()

        mockUserStore = MockUserStore()
        mockOperationManager = MockOperationManager()
        mockUrlCache = MockURLCache()

        subject = AppCleanerImpl(
            userStore: mockUserStore,
            operationManager: mockOperationManager,
            urlCache: mockUrlCache
        )
    }

    func testNoArgInit() {
        subject = AppCleanerImpl()

        // Assert
        XCTAssertNotNil(subject)
        // NoOp because members are private.
    }

    func testClean() {
        // Act
        subject.clean()

        // Assert
        XCTAssertEqual(mockUserStore.removeUserCallCount, 1)
        XCTAssertEqual(mockOperationManager.cancelAllOperationsCallCount, 1)
        XCTAssertEqual(mockOperationManager.clearCacheCallCount, 1)
        XCTAssertEqual(mockUrlCache.removeAllCachedResponsesCallCount, 1)
    }
}
