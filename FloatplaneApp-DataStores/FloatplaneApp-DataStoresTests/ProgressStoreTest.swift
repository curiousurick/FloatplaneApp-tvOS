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

import Cache
import XCTest
@testable import FloatplaneApp_DataStores

final class ProgressStoreTest: XCTestCase {
    private let VideoKey = "VideoKey"
    private let ProgressValue: TimeInterval = 10.0

    private var mockDiskStorageWrapper: MockDiskStorageWrapper<String, TimeInterval>!

    private var subject: ProgressStore!

    override func setUp() {
        super.setUp()

        let storage: Storage<String, TimeInterval> = try! Storage(
            diskConfig: DiskConfig(name: "FakeDiskConfig"),
            memoryConfig: MemoryConfig(),
            transformer: TransformerFactory.forCodable(ofType: TimeInterval.self)
        )
        mockDiskStorageWrapper = MockDiskStorageWrapper(storage: storage)
        subject = ProgressStore(storage: mockDiskStorageWrapper)
    }

    func testGetProgress() {
        // Arrange
        mockDiskStorageWrapper.mockReadObject[VideoKey] = ProgressValue

        // Act
        let result = subject.getProgress(for: VideoKey)

        // Assert
        XCTAssertEqual(result, ProgressValue)
        XCTAssertEqual(mockDiskStorageWrapper.readObjectCallCount, 1)
        mockDiskStorageWrapper.verifyReadObject(key: VideoKey)
    }

    func testGetProgressNotFound() {
        // Arrange
        mockDiskStorageWrapper.mockReadObject[VideoKey] = nil

        // Act
        let result = subject.getProgress(for: VideoKey)

        // Assert
        XCTAssertNil(result)
        XCTAssertEqual(mockDiskStorageWrapper.readObjectCallCount, 1)
        mockDiskStorageWrapper.verifyReadObject(key: VideoKey)
    }

    func testSetProgress() {
        // Act
        subject.setProgress(for: VideoKey, progress: ProgressValue)

        // Assert
        XCTAssertEqual(mockDiskStorageWrapper.writeObjectCallCount, 1)
        mockDiskStorageWrapper.verifyWriteObject(value: ProgressValue, key: VideoKey, expiry: nil)
    }
}
