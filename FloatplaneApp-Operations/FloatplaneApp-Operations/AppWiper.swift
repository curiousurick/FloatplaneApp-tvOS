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

public protocol AppWiper {
    
    func clean()
}

public class AppWiperImpl: AppWiper {
    
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
        self.userStore.removeUser()
        self.operationManager.cancelAllOperations()
        self.operationManager.clearCache()
        self.urlCache.removeAllCachedResponses()
    }
}
