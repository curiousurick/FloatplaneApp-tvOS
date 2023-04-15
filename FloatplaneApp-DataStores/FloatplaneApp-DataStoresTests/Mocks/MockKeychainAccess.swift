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
@testable import FloatplaneApp_DataStores

class MockKeychainAccess: KeychainAccess {
    init() {
        super.init(keychain: MockUICKeyChainStore())
    }

    var mockDataForKey: (String, Data?)?
    var dataForKeyCallCount = 0
    override func data(forKey key: String) -> Data? {
        dataForKeyCallCount += 1
        if let mockDataForKey = mockDataForKey,
           mockDataForKey.0 == key {
            return mockDataForKey.1
        }
        return nil
    }

    var setDataForKeyCallCount = 0
    override func setData(_: Data?, forKey _: String) {
        setDataForKeyCallCount += 1
    }

    var removeItemCallCount = 0
    override func removeItem(forKey _: String) {
        removeItemCallCount += 1
    }
}
