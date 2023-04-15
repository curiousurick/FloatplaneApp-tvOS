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
import Foundation
@testable import FloatplaneApp_DataStores

extension Expiry: Equatable {
    public static func == (lhs: Expiry, rhs: Expiry) -> Bool {
        lhs.date == rhs.date
    }
}

class MockDiskStorageWrapper<K: Hashable & Equatable, V: Codable & Equatable>: DiskStorageWrapper<K, V> {
    private var writeObjectCalledParams: [(V, K, Expiry?)] = []
    func verifyWriteObject(value: V, key: K, expiry: Expiry?) {
        XCTAssertTrue(writeObjectCalledParams.contains { $0 == (value, key, expiry) })
    }

    var writeObjectCallCount = 0
    override func writeObject(_ object: V, forKey key: K, expiry: Expiry? = nil) {
        writeObjectCallCount += 1
        writeObjectCalledParams.append((object, key, expiry))
    }

    private var readObjectCalledParams: [K] = []
    func verifyReadObject(key: K) {
        XCTAssertTrue(readObjectCalledParams.contains { $0 == key })
    }

    var readObjectCallCount = 0
    var mockReadObject: [K: V] = [:]
    override func readObject(forKey key: K) -> V? {
        readObjectCallCount += 1
        readObjectCalledParams.append(key)
        return mockReadObject[key]
    }

    var mockIsExpiredObject = false
    var isExpiredObjectCallCount = 0
    override func isExpiredObject(forKey _: K) -> Bool {
        isExpiredObjectCallCount += 1
        return mockIsExpiredObject
    }

    var removeExpiredObjectsCallCount = 0
    var receivedRemoveExpiredObjectCompletion: ((Result<Void>) -> Void)?
    override func removeExpiredObjects(completion: ((Result<Void>) -> Void)? = nil) {
        removeExpiredObjectsCallCount += 1
        receivedRemoveExpiredObjectCompletion = completion
    }

    var removeAllCallCount = 0
    var receivedRemoveAllCompletion: ((Result<Void>) -> Void)?
    override func removeAll(completion: ((Result<Void>) -> Void)? = nil) {
        removeAllCallCount += 1
        receivedRemoveAllCompletion = completion
    }
}
