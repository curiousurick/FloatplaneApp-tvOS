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

/// A basic protocol that allows the OperationManager to cancel ops and clear the cache for CacheableAPIOperations.
/// This is done as a workaround to allow the OperationManager to collect all of them despite generics.
/// As of Swift 5.5, Arrays can not collect objects of different types that belong to the same protocol, but not if they have generic parameters.
protocol CacheableOperation {
    /// Cancels whatever asynchronous operation is active.
    func cancel()
    /// Clears the memory and disk cache for the operation.
    func clearCache()
}

/// Applies this non-generics protocol to CacheableaAPIOperation so we can collect them to clear the cache or cancel all ops.
extension CacheableAPIOperation: CacheableOperation { }

/// This is the sole gateway to any operation. In order to maintain efficient access to cached data and to simplify logout, all operations are created once
/// per application lifecycle so that we don't have to create a new Storage access every time an operation is called.
///
/// APIs
/// - Access to all operations for the app.
/// - cancelAllOperations - Iterates all cacheable operations and cancels them.
///     TODO: Add support for all operations.
/// - clearCache - Clears the cache for every cacheable operation
public class OperationManager {
    /// Singleton access to OperationManager
    public static let instance = OperationManager()

    // Cacheable Operations
    public let contentFeedOperation = ContentFeedOperation()
    public let subscriptionOperation = SubscriptionOperation()
    public let searchOperation = SearchOperation()
    public let creatorListOperation = CreatorListOperation()
    public let creatorOperation = CreatorOperation()
    public let contentVideoOperation = ContentVideoOperation()
    
    // Non-cached Operations
    public let vodDeliveryKeyOperation = VodDeliveryKeyOperation()
    public let liveDeliveryKeyOperation = LiveDeliveryKeyOperation()
    public let loginOperation = LoginOperation()
    public let logoutOperation = LogoutOperation()
    public let videoMetadataOperation = VideoMetadataOperation()
    public let getFirstPageOperation = GetFirstPageOperation()
    
    private let allCacheableOperations: [CacheableOperation]
    
    private init() {
        allCacheableOperations = [
            contentFeedOperation,
            subscriptionOperation,
            searchOperation,
            creatorListOperation,
            creatorOperation,
            contentVideoOperation
        ]
    }
    
    /// Clears the cache for all cacheable operations
    public func clearCache() {
        allCacheableOperations.forEach {
            $0.clearCache()
        }
    }
    
    /// Cancels all cacheable operations.
    /// TODO: Support all operations
    public func cancelAllOperations() {
        allCacheableOperations.forEach {
            $0.cancel()
        }
    }
}
