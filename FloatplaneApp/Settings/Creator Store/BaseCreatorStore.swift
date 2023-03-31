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

import UIKit
import UICKeyChainStore

class BaseCreatorStore {
    
    private let logger = Log4S()
    private let CreatorStoreKey = "CreatorStoreKey"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    static let instance = BaseCreatorStore()
    
    private let keychain: UICKeyChainStore
    
    private init() {
        keychain = KeychainManager.instance.keychain
    }
    
    func getCreators() -> [BaseCreator]? {
        guard let data = keychain.data(forKey: CreatorStoreKey) else {
            logger.error("Failed to retrieve creators from keychain")
            return nil
        }
        do {
            return try decoder.decode([BaseCreator].self, from: data)
        }
        catch {
            logger.error("Failed to decode creators from keychain")
        }
        return nil
    }
    
    func setCreators(creators: [BaseCreator]) {
        do {
            let data = try encoder.encode(creators)
            keychain.setData(data, forKey: CreatorStoreKey)
            NotificationCenter.default.post(FPNotifications.CreatorListUpdated.create(creators: creators))
        }
        catch {
            logger.error("Failed to save creators to keychain")
        }
    }

}
