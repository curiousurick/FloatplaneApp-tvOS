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
@testable import FloatplaneApp_DataStores

final class KeychainAccessTest: XCTestCase {
    private var keychainStoreMock: MockUICKeyChainStore!

    private var subject: KeychainAccess!

    override func setUp() {
        super.setUp()

        keychainStoreMock = MockUICKeyChainStore()
        subject = KeychainAccess(keychain: keychainStoreMock)
    }

    func testSingletonAccess() {
        subject = KeychainAccess.instance
    }

    func testDataForKey() {
        // Arrange
        let data = Data(bytes: [0x89, 0x80, 0x12], count: 3)
        keychainStoreMock.mockDataForKey = data

        // Act
        let result = subject.data(forKey: "Key")

        // Assert
        XCTAssertEqual(result, data)
        XCTAssertEqual(keychainStoreMock.dataForKeyCallCount, 1)
    }

    func testDataForKey_nil() {
        // Act
        let result = subject.data(forKey: "Key")

        // Assert
        XCTAssertNil(result)
        XCTAssertEqual(keychainStoreMock.dataForKeyCallCount, 1)
    }

    func testSetDataForKey() {
        // Act
        subject.setData(Data(), forKey: "Key")

        // Assert
        XCTAssertEqual(keychainStoreMock.setDataForKeyCallCount, 1)
    }

    func testRemoveItem() {
        // Act
        subject.removeItem(forKey: "Key")

        // Assert
        XCTAssertEqual(keychainStoreMock.removeItemCallCount, 1)
    }
}
