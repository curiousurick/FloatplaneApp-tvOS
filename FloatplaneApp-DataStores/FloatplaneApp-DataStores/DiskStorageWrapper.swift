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
import Foundation
import FloatplaneApp_Utilities

/// Wrapper for Cache framework's Storage object
public class DiskStorageWrapper<Key: Hashable, Value: Codable> {
    private let logger = Log4S()

    /// Actual storage
    private let storage: Storage<Key, Value>

    public init(storage: Storage<Key, Value>) {
        self.storage = storage
    }

    /// Reads an object for given key.
    public func readObject(forKey key: Key) -> Value? {
        do {
            return try storage.object(forKey: key)
        }
        catch {
            logger.debug("Unable to read object for key \(String.fromClass(key)). Error \(error)")
            return nil
        }
    }

    /// Write given object for given key. Expiry indicates when the data will be considered expired.
    /// Note: Storage does not automatically delete object when expired
    public func writeObject(_ object: Value, forKey key: Key, expiry: Expiry? = nil) {
        do {
            try storage.setObject(object, forKey: key, expiry: expiry)
        }
        catch {
            logger.info("Unable to write object for key \(String.fromClass(key)). Error \(error)")
        }
    }

    public func isExpiredObject(forKey key: Key) -> Bool {
        do {
            let entry = try storage.entry(forKey: key)
            return entry.expiry.isExpired
        }
        catch {
            logger.info("Unable to check if object is expired for key \(String.fromClass(key)). Error \(error)")
            return true
        }
    }

    public func removeExpiredObjects(completion: ((Result<Void>) -> Void)? = nil) {
        storage.async.removeExpiredObjects { result in
            completion?(result)
        }
    }

    public func removeAll(completion: ((Result<Void>) -> Void)? = nil) {
        storage.async.removeAll { result in
            completion?(result)
        }
    }
}
