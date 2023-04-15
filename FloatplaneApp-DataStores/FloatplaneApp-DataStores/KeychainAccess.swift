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
import UICKeyChainStore

/// Wrapper for UICKeyChainStore's accesspoint.
/// Note this class is not public because otherwise, consumers would have to import UICKeyChainStore
/// Access to this class will be specialized for its defined input and output purposes, such as UserStore.
class KeychainAccess {
    /// Singleton access to KeychainAccess
    static let instance = KeychainAccess()

    /// Actual keychain implementation
    let keychain: UICKeyChainStore

    @available(*, deprecated, message: "VisibleForTesting")
    init(keychain: UICKeyChainStore) {
        self.keychain = keychain
    }

    private init() {
        keychain = UICKeyChainStore(service: "org.georgie.Floatplane.Keychain")
    }

    /// Returns saved data if found for key
    func data(forKey key: String) -> Data? {
        keychain.data(forKey: key)
    }

    /// Writes data to keychain for the given key
    func setData(_ data: Data?, forKey key: String) {
        keychain.setData(data, forKey: key)
    }

    /// Removes whatever item exists for the given key
    func removeItem(forKey key: String) {
        keychain.removeItem(forKey: key)
    }
}
