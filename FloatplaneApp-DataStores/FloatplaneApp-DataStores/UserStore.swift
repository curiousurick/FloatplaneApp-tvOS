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
import FloatplaneApp_Models
import FloatplaneApp_Utilities

public protocol UserStore {
    func getUser() -> User?

    func getProgressStore() -> ProgressStore?

    func setUser(user: User)

    func removeUser()
}

/// Keychain-based data store for User information.
public class UserStoreImpl: UserStore {
    private let logger = Log4S()
    private let UserStoreKey = "UserStoreKey"
    /// Data is stored as JSON
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    /// Package-level access to Keychain
    private let keychainAccess: KeychainAccess

    /// Singleton instance of the UserStore.
    public static let instance: UserStore = UserStoreImpl()

    init(
        keychainAccess: KeychainAccess,
        encoder: JSONEncoder,
        decoder: JSONDecoder
    ) {
        self.keychainAccess = keychainAccess
        self.encoder = encoder
        self.decoder = decoder
    }

    private convenience init() {
        self.init(
            keychainAccess: KeychainAccess.instance,
            encoder: JSONEncoder(),
            decoder: JSONDecoder()
        )
    }

    /// Returns a User if one exists in keychain.
    /// If nil returned, that means the user is not logged in.
    public func getUser() -> User? {
        guard let data = keychainAccess.data(forKey: UserStoreKey) else {
            logger.info("User is not logged in")
            return nil
        }
        do {
            return try decoder.decode(User.self, from: data)
        }
        catch {
            logger.error("Failed to decode creators from keychain")
            return nil
        }
    }

    /// Returns a ProgressStore instance for the logged-in User.
    /// Returns nil if the user is not logged in.
    public func getProgressStore() -> ProgressStore? {
        if let user = getUser() {
            let userId = user.id
            return ProgressStore(userId: userId)
        }
        return nil
    }

    /// Saved user to keychain.
    public func setUser(user: User) {
        do {
            let data = try encoder.encode(user)
            keychainAccess.setData(data, forKey: UserStoreKey)
        }
        catch {
            logger.error("Failed to save creators to keychain")
        }
    }

    /// Removes saved user from keychain upon logout
    public func removeUser() {
        keychainAccess.removeItem(forKey: UserStoreKey)
    }
}
