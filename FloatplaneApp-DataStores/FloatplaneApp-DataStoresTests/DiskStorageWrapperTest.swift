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

private struct ErroneousEncodable: Codable {
    private let value: String

    init(value: String) {
        self.value = value
    }

    init(from _: Decoder) throws {
        throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "AHHHH"))
    }

    enum CodingKeys: CodingKey {
        case valueKey
    }

    func encode(to _: Encoder) throws {
        let emptyArray: [String] = []
        throw EncodingError.invalidValue(emptyArray, .init(codingPath: [], debugDescription: "OH NO"))
    }
}

class DiskStorageWrapperTest: XCTestCase {
    private var subject: DiskStorageWrapper<String, TimeInterval>!

    override func setUp() {
        super.setUp()

        let storage: Storage<String, TimeInterval> = try! Storage(
            diskConfig: DiskConfig(name: "FakeDiskConfig"),
            memoryConfig: MemoryConfig(),
            transformer: TransformerFactory.forCodable(ofType: TimeInterval.self)
        )
        try! storage.removeAll()

        subject = DiskStorageWrapper(storage: storage)
    }

    func testWriteThenReadObject() {
        // Arrange
        let key = "Key"
        let value: TimeInterval = 1.0

        // Act 1
        subject.writeObject(value, forKey: key)

        // Act
        let result = subject.readObject(forKey: key)

        // Assert
        XCTAssertEqual(result, value)
    }

    func testReadObject_unknownKey() {
        // Act
        let result = subject.readObject(forKey: "UnknownKey")

        // Assert
        XCTAssertNil(result)
    }

    func testWriteObjectThrowsWhenReadFromDisk() {
        // Arrange
        let storage: Storage<String, ErroneousEncodable> = try! Storage(
            diskConfig: DiskConfig(name: "FakeDiskConfig"),
            memoryConfig: MemoryConfig(countLimit: 1),
            transformer: TransformerFactory.forCodable(ofType: ErroneousEncodable.self)
        )

        let subject = DiskStorageWrapper(storage: storage)
        let encodable = ErroneousEncodable(value: "blah")
        let key1 = "key1"
        let key2 = "key2"

        // Act
        // Write twice so the first one is booted from memory.
        subject.writeObject(encodable, forKey: key1)
        subject.writeObject(encodable, forKey: key2)
        let read1 = subject.readObject(forKey: key1)

        // Assert
        XCTAssertNil(read1)
    }

    func testIsExpiredObject_isExpired() {
        // Arrange
        let expiry = Expiry.seconds(0.1)
        let storage: Storage<String, TimeInterval> = try! Storage(
            diskConfig: DiskConfig(name: "FakeDiskConfig"),
            memoryConfig: MemoryConfig(expiry: expiry),
            transformer: TransformerFactory.forCodable(ofType: TimeInterval.self)
        )
        let subject = DiskStorageWrapper(storage: storage)
        let key = "Key"
        let value: TimeInterval = 1.0
        subject.writeObject(value, forKey: key)
        let isExpiredExpectation = expectation(description: "Object is expired")

        // Act
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let result = subject.isExpiredObject(forKey: key)

            // Assert
            XCTAssertTrue(result)
            isExpiredExpectation.fulfill()
        }
        wait(for: [isExpiredExpectation], timeout: 1.0)
    }

    func testIsExpiredObject_notExpired() {
        // Arrange
        let key = "Key"
        let value = 1.0
        subject.writeObject(value, forKey: key)

        // Act
        let result = subject.isExpiredObject(forKey: key)

        // Assert
        XCTAssertFalse(result)
    }

    func testIsExpiredObject_noObject() {
        // Arrange
        let key = "Key"

        // Act
        let result = subject.isExpiredObject(forKey: key)

        // Assert
        XCTAssertTrue(result)
    }

    func testRemoveExpiredObjectsWithCompletion() {
        // Arrange
        let completionExpectation = expectation(description: "Completion called")

        // Act
        subject.removeExpiredObjects { _ in
            completionExpectation.fulfill()
        }

        // Assert
        wait(for: [completionExpectation], timeout: 1.0)
    }

    func testRemoveExpiredObjectsWithNoCompletion() {
        // Act
        subject.removeExpiredObjects()
    }

    func testRemoveAllWithCompletion() {
        // Arrange
        let completionExpectation = expectation(description: "Completion called")

        // Act
        subject.removeAll { _ in
            completionExpectation.fulfill()
        }

        // Assert
        wait(for: [completionExpectation], timeout: 1.0)
    }

    func testRemoveAllWithNoCompletion() {
        // Act
        subject.removeAll()
    }
}
