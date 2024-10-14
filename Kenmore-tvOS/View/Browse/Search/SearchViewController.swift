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
import Alamofire
import AsyncObjects
import Kenmore_Models
import Kenmore_Utilities
import Kenmore_DataStores
import Kenmore_Operations

final class SearchViewController: UIViewController, UISearchResultsUpdating, ContentFeedDelegate {
    enum CollectionConstants {
        static let rowCount: CGFloat = 4
        static let cellSpacing: CGFloat = 40

        static let headerHeight: CGFloat = 340

        static let sectionTopInset: CGFloat = 40
        static let contentVerticalInset: CGFloat = 10
        static let contentHorizontalInset: CGFloat = 40
    }

    private let logger = Log4S()
    private let pageLimit: UInt64 = 20
    private let searchOperation = OperationManagerImpl.instance.searchOperation
    private let minimumQueryLength = 3
    private var dataSource = DataSource.instance

    private var searchString: String?
    private var results: SearchResponse?
    private var collectionManager: BrowseCollectionManager!

    private lazy var searchOperationQueue = TaskQueue()

    @IBOutlet var collectionView: UICollectionView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        dataSource.registerDelegate(delegate: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionManager = BrowseCollectionManager(
            collectionView: collectionView,
            useHeader: false
        )
        collectionManager.delegate = self

        collectionView.alwaysBounceVertical = true
        collectionView.bounces = true
    }

    func updateSearchResults(for searchController: UISearchController) {
        let newSearchString = searchController.searchBar.text
        guard let newSearchString = newSearchString else {
            return
        }
        if let searchString = searchString, searchString == newSearchString {
            return
        }
        searchString = newSearchString
        if newSearchString.count >= minimumQueryLength {
            search(searchString: newSearchString)
        }
        else {
            collectionManager.setFeed(feed: [])
        }
    }

    func search(searchString: String) {
        searchOperationQueue.addTask { [weak self] in
            guard let self = self else {
                return
            }
            await self.logger.info("Getting results for \(searchString)")
            await self.dataSource.searchResults = nil
            let results = await self.fetchVideos(fetchAfter: 0, limit: self.collectionManager.pageLimit)
            if let results = results {
                await self.logger.info("Results for \(searchString) got \(results.count) results")
                await self.collectionManager.setFeed(feed: results)
            }
        }
    }

    func getVideos(fetchAfter: Int, limit: UInt64) async {
        let _ = await fetchVideos(fetchAfter: fetchAfter, limit: limit)
    }

    func fetchVideos(fetchAfter: Int, limit: UInt64) async -> [FeedItem]? {
        guard let activeCreator = dataSource.activeCreator,
              let searchString = searchString else {
            return nil
        }
        logger.debug("Fetching next page of content for feed")
        if searchOperation.isActive() {
            searchOperation.cancel()
        }
        let request = SearchRequest(
            creatorId: activeCreator.id,
            sort: .descending,
            searchQuery: searchString,
            fetchAfter: fetchAfter,
            limit: Int(limit)
        )
        let opResponse = await searchOperation.get(request: request)
        guard opResponse.error == nil,
              let searchResult = opResponse.response?.items else {
            let errorString = opResponse.error.debugDescription
            logger.warn("Failed to retrieve next page of content from \(fetchAfter). Error \(errorString)")
            if let error = opResponse.error as? AFError,
               error.isExplicitlyCancelledError {
                return nil
            }
            return nil
        }
        collectionManager.reachedEnd = searchResult.isEmpty
        if let existingResults = dataSource.searchResults {
            dataSource.searchResults = existingResults + searchResult
        }
        else {
            dataSource.searchResults = searchResult
        }
        return searchResult
    }

    func videoSelected(feedItem: FeedItem) {
        let vodPlayerViewController = UIStoryboard.main.getVodPlayerViewController()
        if let availableItem = feedItem.availableItem {
            vodPlayerViewController.feedItem = availableItem
            vodPlayerViewController.vodDelegate = self
            present(vodPlayerViewController, animated: true)
        }
        else {
            let alert = UIAlertController(
                title: "Video Unavailable",
                message: "Head to floatplane.com to unlock this video",
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            present(alert, animated: true)
        }
    }
}

extension SearchViewController: VODPlayerViewDelegate {
    func videoDidEnd(guid: String) {
        guard let progressStore = UserStoreImpl.instance.getProgressStore(),
              let progress = progressStore.getProgress(for: guid) else {
            logger.warn("No progress found for video on return from ending")
            return
        }
        collectionManager.updateProgress(progress: progress, for: guid)
    }
}

extension SearchViewController: DataSourceUpdating {
    func searchResultsUpdated(results: [FeedItem]?) {
        if let results = results {
            collectionManager.setFeed(feed: results)
        }
    }

    func searchResultsAppended(results: [FeedItem]) {
        collectionManager.addToFeed(feed: results)
    }
}
