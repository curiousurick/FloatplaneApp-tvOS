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
import FloatplaneApp_Utilities
import FloatplaneApp_Models

public class BaseCreatorStore {
    
    private let logger = Log4S()
    private let CreatorStoreKey = "CreatorStoreKey"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    public static let instance = BaseCreatorStore()
    
    private let keychain: UICKeyChainStore
    
    private init() {
        keychain = KeychainManager.instance.keychain
    }
    
    public func getCreators() -> [BaseCreator]? {
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
    
    public func setCreators(creators: [BaseCreator]) {
        do {
            let data = try encoder.encode(creators)
            keychain.setData(data, forKey: CreatorStoreKey)
            let userInfo = [
                FPNotifications.CreatorListUpdated.creatorsKey : creators
            ]
            let name = FPNotifications.CreatorListUpdated.name
            let notification = Notification(name: name, object: nil, userInfo: userInfo)
            NotificationCenter.default.post(notification)
        }
        catch {
            logger.error("Failed to save creators to keychain")
        }
    }

}
