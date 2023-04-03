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

protocol DataSourceUpdating: AnyObject, Hashable {
    func feedUpdated(feed: [FeedItem]?)
    func baseCreatorsUpdated(baseCreators: [BaseCreator]?)
    func activeCreator(activeCreator: Creator?)
    func activeBaseCreator(activeBaseCreator: BaseCreator?)
}
extension DataSourceUpdating {
    func feedUpdated(feed: [FeedItem]?) { }
    func baseCreatorsUpdated(baseCreators: [BaseCreator]?) { }
    func activeCreator(activeCreator: Creator?) { }
    func activeBaseCreator(activeBaseCreator: BaseCreator?) { }
}

fileprivate class DataSourceUpdatingSet {
    private var delegates: Set<AnyHashable> = []
    
    func insert(delegate: any DataSourceUpdating) {
        let _ = delegates.insert(delegate)
    }
    
    func iterate( doing: (any DataSourceUpdating) -> Void ) {
        for item in delegates {
            doing(item as! any DataSourceUpdating)
        }
    }
}

class DataSource {
    private let logger = Log4S()
    
    static let instance = DataSource()
    
    private init() { }
    
    var feed: [FeedItem]? {
        didSet {
            delegates.iterate { $0.feedUpdated(feed: feed) }
        }
    }
    var baseCreators: [BaseCreator]? {
        didSet {
            delegates.iterate { $0.baseCreatorsUpdated(baseCreators: baseCreators) }
        }
    }
    var activeCreator: Creator? {
        didSet {
            delegates.iterate { $0.activeCreator(activeCreator: activeCreator) }
        }
    }
    var activeBaseCreator: BaseCreator? {
        didSet {
            delegates.iterate { $0.activeBaseCreator(activeBaseCreator: activeBaseCreator) }
        }
    }
    
    private var delegates: DataSourceUpdatingSet = DataSourceUpdatingSet()
    
    func registerDelegate(delegate: any DataSourceUpdating) {
        delegates.insert(delegate: delegate)
    }
    
    func clearData() {
        self.baseCreators = nil
        self.activeCreator = nil
        self.activeBaseCreator = nil
        self.feed = nil
    }
}
