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
import Kenmore_Models
import Kenmore_Utilities

protocol DataSourceUpdating: AnyObject, Hashable {
    func feedUpdated(feed: [FeedItem]?)
    func feedAppended(feed: [FeedItem])
    func baseCreatorsUpdated(baseCreators: [BaseCreator]?)
    func activeCreator(activeCreator: Creator?)
    func activeBaseCreator(activeBaseCreator: BaseCreator?)
    func searchResultsUpdated(results: [FeedItem]?)
    func searchResultsAppended(results: [FeedItem])
}

extension DataSourceUpdating {
    func feedUpdated(feed _: [FeedItem]?) {}
    func feedAppended(feed _: [FeedItem]) {}
    func baseCreatorsUpdated(baseCreators _: [BaseCreator]?) {}
    func activeCreator(activeCreator _: Creator?) {}
    func activeBaseCreator(activeBaseCreator _: BaseCreator?) {}
    func searchResultsUpdated(results _: [FeedItem]?) {}
    func searchResultsAppended(results _: [FeedItem]) {}
}

private class DataSourceUpdatingSet {
    private var delegates: Set<AnyHashable> = []

    func insert(delegate: any DataSourceUpdating) {
        _ = delegates.insert(delegate)
    }

    func iterate(doing: (any DataSourceUpdating) -> Void) {
        for item in delegates {
            doing(item as! any DataSourceUpdating)
        }
    }
}

class DataSource {
    private let logger = Log4S()

    static let instance = DataSource()

    private init() {}

    var feed: [FeedItem]? {
        didSet {
            if let feed = feed, let oldValue = oldValue,
               feed.contains(oldValue) {
                var newStuff = feed
                newStuff.removeSubrange(0 ..< oldValue.count)
                delegates.iterate { $0.feedAppended(feed: newStuff) }
            }
            else {
                delegates.iterate { $0.feedUpdated(feed: feed) }
            }
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

    var searchResults: [FeedItem]? {
        didSet {
            if let searchResults = searchResults, let oldValue = oldValue,
               searchResults.contains(oldValue) {
                var newStuff = searchResults
                newStuff.removeSubrange(0 ..< oldValue.count)
                delegates.iterate { $0.searchResultsAppended(results: newStuff) }
            }
            else {
                delegates.iterate { $0.searchResultsUpdated(results: searchResults) }
            }
        }
    }

    private var delegates: DataSourceUpdatingSet = .init()

    func registerDelegate(delegate: any DataSourceUpdating) {
        delegates.insert(delegate: delegate)
    }

    func clearData() {
        baseCreators = nil
        activeCreator = nil
        activeBaseCreator = nil
        feed = nil
    }
}
