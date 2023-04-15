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
import FloatplaneApp_DataStores

/// This class is the central component to clear the app of data which should only live through a User lifecyle.
/// When the user is logged out, this class should be invoked to clean the app of user data.
public protocol AppCleaner {
    /// Cleans the app of
    func clean()
}

public class AppCleanerImpl: AppCleaner {
    private let userStore: UserStore
    private let operationManager: OperationManager
    private let urlCache: URLCache

    public convenience init() {
        self.init(
            userStore: UserStoreImpl.instance,
            operationManager: OperationManagerImpl.instance,
            urlCache: URLCache.shared
        )
    }

    init(
        userStore: UserStore,
        operationManager: OperationManager,
        urlCache: URLCache
    ) {
        self.userStore = userStore
        self.operationManager = operationManager
        self.urlCache = urlCache
    }

    public func clean() {
        // Removes user from keychain.
        userStore.removeUser()
        // Cancels all network calls
        operationManager.cancelAllOperations()
        // Clears all URL cache from disk cache.
        operationManager.clearCache()
        // Clears all URL cache from iOS's URLCache.
        urlCache.removeAllCachedResponses()
    }
}
