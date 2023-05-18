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

import AVKit
import UIKit
import Kenmore_Models
import Kenmore_Utilities
import Kenmore_DataStores
import Kenmore_Operations

class BrowseViewController: UIViewController {
    private let logger = Log4S()
    private let contentFeedOperation = OperationManagerImpl.instance.contentFeedOperation
    private let dataSource = DataSource.instance

    @IBOutlet var videoCollectionView: UICollectionView!
    @IBOutlet var creatorListView: CreatorListView!

    private var collectionManager: BrowseCollectionManager!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        dataSource.registerDelegate(delegate: self)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(getInitialFeed),
            name: .NSExtensionHostWillEnterForeground,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionManager = BrowseCollectionManager(
            collectionView: videoCollectionView,
            initialFeed: dataSource.feed ?? [],
            useHeader: true
        )
        collectionManager.delegate = self

        videoCollectionView.remembersLastFocusedIndexPath = true
    }

    @objc private func getInitialFeed() {
        dataSource.feed = nil
        Task {
            guard let results = await fetchVideos(fetchAfter: 0, limit: self.collectionManager.pageLimit) else {
                let owner = dataSource.activeCreator?.owner ?? "nil"
                logger.error("Unable to get first page of videos for creator \(owner)")
                return
            }
            collectionManager.setFeed(feed: results)
        }
    }
}

// MARK: ContentFeedDelegate

extension BrowseViewController: ContentFeedDelegate {
    func getVideos(fetchAfter: Int, limit: UInt64) async {
        let _ = await fetchVideos(fetchAfter: fetchAfter, limit: limit)
    }

    func fetchVideos(fetchAfter: Int, limit: UInt64) async -> [FeedItem]? {
        logger.debug("Fetching next page of content for feed")
        guard let creator = dataSource.activeCreator, !contentFeedOperation.isActive() else {
            logger.warn("Trying to get next page in feed while I am already loading")
            return []
        }
        let request = ContentFeedRequest(
            fetchAfter: fetchAfter,
            limit: limit,
            creatorId: creator.id
        )
        let opResponse = await contentFeedOperation.get(request: request)
        guard opResponse.error == nil,
              let fetchedFeed = opResponse.response?.items else {
            let errorString = String(describing: opResponse.error.debugDescription)
            logger.error("Failed to retrieve next page of content from \(fetchAfter). Error \(errorString)")
            return []
        }
        collectionManager.reachedEnd = fetchedFeed.isEmpty
        if let existingFeed = dataSource.feed {
            dataSource.feed = existingFeed + fetchedFeed
        }
        else {
            dataSource.feed = fetchedFeed
        }
        return fetchedFeed
    }

    func videoSelected(feedItem: FeedItem) {
        let vodPlayerViewController = UIStoryboard.main.getVodPlayerViewController()
        vodPlayerViewController.feedItem = feedItem
        vodPlayerViewController.vodDelegate = self
        present(vodPlayerViewController, animated: true)
    }
}

extension BrowseViewController: VODPlayerViewDelegate {
    func videoDidEnd(guid: String) {
        guard let progressStore = UserStoreImpl.instance.getProgressStore(),
              let progress = progressStore.getProgress(for: guid) else {
            logger.warn("No progress found for video on return from ending")
            return
        }
        collectionManager.updateProgress(progress: progress, for: guid)
    }
}

extension BrowseViewController: DataSourceUpdating {
    func feedUpdated(feed: [FeedItem]?) {
        if let feed = feed {
            collectionManager.setFeed(feed: feed)
        }
    }

    func feedAppended(feed: [FeedItem]) {
        collectionManager.addToFeed(feed: feed)
    }
}
