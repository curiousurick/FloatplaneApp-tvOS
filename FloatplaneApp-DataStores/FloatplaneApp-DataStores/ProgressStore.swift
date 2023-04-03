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
import Cache

public class ProgressStore {
    
    public static let instance = ProgressStore()
    public static let updateInterval: TimeInterval = 10
    
    private let storage: DiskStorageWrapper<String, TimeInterval>
    
    @available(*, deprecated, message: "VisibleForTesting")
    init(storage: DiskStorageWrapper<String, TimeInterval>) {
        self.storage = storage
    }
    
    private init() {
        let diskConfig = DiskConfig(name: "org.georgie.ProgressStore", expiry: .never)
        let memoryConfig = MemoryConfig(expiry: .never)

        let storage: Storage<String, TimeInterval> = try! Storage(
          diskConfig: diskConfig,
          memoryConfig: memoryConfig,
          transformer: TransformerFactory.forCodable(ofType: TimeInterval.self)
        )
        self.storage = DiskStorageWrapper(storage: storage)
    }
    
    public func getProgress(for videoGuid: String) -> TimeInterval? {
        return storage.readObject(forKey: videoGuid)
    }
    
    public func setProgress(for videoGuid: String, progress: TimeInterval) {
        storage.writeObject(progress, forKey: videoGuid)
    }

}
