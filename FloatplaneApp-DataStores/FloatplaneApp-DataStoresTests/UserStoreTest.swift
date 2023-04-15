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
@testable import FloatplaneApp_DataStores

final class UserStoreTest: XCTestCase {
    private let UserStoreKey = "UserStoreKey"

    private let id = "UserId"
    private let username = "username"
    private let height: UInt64 = 480
    private let path = URL(string: "fakeUrl")!
    private let width: UInt64 = 720
    private let userDataObject = Data()

    /// Mocks
    private var mockDecoder: MockJSONDecoder!
    private var mockEncoder: MockJSONEncoder!
    private var mockKeychainAccess: MockKeychainAccess!

    private var subject: UserStoreImpl!

    override func setUp() {
        super.setUp()

        mockDecoder = MockJSONDecoder()
        mockEncoder = MockJSONEncoder()
        mockKeychainAccess = MockKeychainAccess()
        let icon = Icon(childImages: [], height: height, path: path, width: width)
        let user = User(id: id, username: username, profileImage: icon)
        mockDecoder.mockDecodeResult = { _ in
            user
        }

        mockEncoder.mockDataResult = { _ in
            self.userDataObject
        }

        subject = UserStoreImpl(
            keychainAccess: mockKeychainAccess,
            encoder: mockEncoder,
            decoder: mockDecoder
        )
    }

    func testSingletonAccess() {
        let _ = UserStoreImpl.instance
    }

    func testGetUser() {
        // Arrange
        let icon = Icon(childImages: [], height: height, path: path, width: width)
        let user = User(id: id, username: username, profileImage: icon)
        mockKeychainAccess.mockDataForKey = (UserStoreKey, userDataObject)

        // Act
        let result = subject.getUser()

        // Assert
        XCTAssertEqual(result, user)
        XCTAssertEqual(mockKeychainAccess.dataForKeyCallCount, 1)
    }

    func testGetUser_nilData() {
        // Act
        let result = subject.getUser()

        // Assert
        XCTAssertNil(result)
        XCTAssertEqual(mockKeychainAccess.dataForKeyCallCount, 1)
    }

    func testGetUser_invalidData() {
        mockDecoder.mockThrownError = DecodingError
            .dataCorrupted(.init(codingPath: [], debugDescription: "Datat isn't good"))
        mockKeychainAccess.mockDataForKey = (UserStoreKey, userDataObject)

        // Act
        let result = subject.getUser()

        // Assert
        XCTAssertNil(result)
        XCTAssertEqual(mockKeychainAccess.dataForKeyCallCount, 1)
    }

    func testGetProgressStore() {
        let icon = Icon(childImages: [], height: height, path: path, width: width)
        let user = User(id: id, username: username, profileImage: icon)
        let userData = try! JSONEncoder().encode(user)
        mockKeychainAccess.mockDataForKey = (UserStoreKey, userData)

        // Act
        let result = subject.getProgressStore()

        // Assert
        XCTAssertNotNil(result)
    }

    func testGetProgressStore_notLoggedIn() {
        mockKeychainAccess.mockDataForKey = (UserStoreKey, nil)

        // Act
        let result = subject.getProgressStore()

        // Assert
        XCTAssertNil(result)
    }

    func testGetProgressStore_invalidUserData() {
        mockDecoder.mockThrownError = DecodingError
            .dataCorrupted(.init(codingPath: [], debugDescription: "Datat isn't good"))
        mockKeychainAccess.mockDataForKey = (UserStoreKey, userDataObject)

        // Act
        let result = subject.getProgressStore()

        // Assert
        XCTAssertNil(result)
    }

    func testSetUser() {
        // Arrange
        let icon = Icon(childImages: [], height: height, path: path, width: width)
        let user = User(id: id, username: username, profileImage: icon)

        // Act
        subject.setUser(user: user)

        // Assert
        XCTAssertEqual(mockKeychainAccess.setDataForKeyCallCount, 1)
    }

    func testSetUser_unableToEncode() {
        // Arrange
        let icon = Icon(childImages: [], height: height, path: path, width: width)
        let error = EncodingError.invalidValue(
            icon,
            .init(codingPath: [], debugDescription: "Icon is not encodable or something")
        )
        mockEncoder.mockThrownError = error
        let user = User(id: id, username: username, profileImage: icon)

        // Act
        subject.setUser(user: user)

        // Assert
        XCTAssertEqual(mockKeychainAccess.setDataForKeyCallCount, 0)
    }

    func testRemoveUser() {
        // Act
        subject.removeUser()

        // Assert
        XCTAssertEqual(mockKeychainAccess.removeItemCallCount, 1)
    }
}
