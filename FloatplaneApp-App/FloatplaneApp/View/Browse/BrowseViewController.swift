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
import AVKit
import FloatplaneApp_Operations
import FloatplaneApp_Models
import FloatplaneApp_Utilities
import FloatplaneApp_DataStores

class BrowseViewController: UIViewController, UICollectionViewDelegate,
                            UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    struct CollectionConstants {
        static let rowCount: CGFloat = 4
        static let totalSpacing: CGFloat = 100
        
        static let headerHeight: CGFloat = 340
        
        static let sectionTopInset: CGFloat = 40
        static let contentVerticalInset: CGFloat = 10
        static let contentHorizontalInset: CGFloat = 50
    }
    
    private let logger = Log4S()
    private let pageLimit: UInt64 = 20
    private let contentFeedOperation = OperationManager.instance.contentFeedOperation
    private let dataSource = DataSource.instance
    
    @IBOutlet var videoCollectionView: UICollectionView!
    @IBOutlet var creatorListView: CreatorListView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.dataSource.registerDelegate(delegate: self)
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
        
        let flowLayout = UICollectionViewFlowLayout()

        let viewWidth = view.bounds.width
        let width = viewWidth / CollectionConstants.rowCount - CollectionConstants.totalSpacing
        let height = width
        
        flowLayout.headerReferenceSize = CGSizeMake(viewWidth, CollectionConstants.headerHeight)
        flowLayout.itemSize = CGSize(width: width, height: height)
        let noInset: CGFloat = 0
        flowLayout.sectionInset = .init(top: CollectionConstants.sectionTopInset, left: noInset, bottom: noInset, right: noInset)
        
        videoCollectionView.register(
            UINib(nibName: FeedItemCollectionViewCell.nibName, bundle: nil),
            forCellWithReuseIdentifier: FeedItemCollectionViewCell.identifier
        )
        videoCollectionView.collectionViewLayout = flowLayout
        videoCollectionView.remembersLastFocusedIndexPath = true
        let vertInset = CollectionConstants.contentVerticalInset
        let horizInset = CollectionConstants.contentHorizontalInset
        videoCollectionView.contentInset = .init(top: vertInset, left:  horizInset, bottom: vertInset, right: horizInset)
    }
    
    @objc private func getInitialFeed() {
        self.dataSource.feed = nil
        getNextPage()
    }
    
    private func getNextPage() {
        logger.debug("Fetching next page of content for feed")
        guard let creator = dataSource.activeCreator, !contentFeedOperation.isActive() else {
            logger.warn("Trying to get next page in feed while I am already loading")
            return
        }
        let fetchAfter = dataSource.feed?.count ?? 0
        let request = ContentFeedRequest(
            fetchAfter: fetchAfter,
            limit: pageLimit,
            creatorId: creator.id
        )
        contentFeedOperation.get(request: request) { fetchedFeed, error in
            guard error == nil,
                  let fetchedFeed = fetchedFeed else {
                self.logger.error("Failed to retrieve next page of content from \(fetchAfter). Error \(error.debugDescription)")
                return
            }
            if let existingFeed = self.dataSource.feed {
                self.dataSource.feed = existingFeed + fetchedFeed.items
            }
            else {
                self.dataSource.feed = fetchedFeed.items
            }
        }
    }
}

// MARK: CollectionView Delegate and DataSource

extension BrowseViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let view: BrowseReusableHeaderView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: BrowseReusableHeaderView.identifier,
            for: indexPath
        ) as! BrowseReusableHeaderView
        
        if let feed = dataSource.feed {
            view.updateUI(item: feed[indexPath.row])
        }
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == dataSource.feed!.count - 4 && !self.contentFeedOperation.isActive() {
            getNextPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.feed?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let feed = dataSource.feed else {
            return UICollectionViewCell()
        }
        
        let cell = FeedItemCollectionViewCell.dequeueFromCollectionView(collectionView: collectionView, indexPath: indexPath)
        let item = feed[indexPath.row]
        cell.setFeedViewItem(item: item)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let feed = dataSource.feed else {
            logger.error("Selected item while feed was nil")
            return
        }
        let vodPlayerViewController = UIStoryboard.main.getVodPlayerViewController()
        vodPlayerViewController.feedItem = feed[indexPath.row]
        vodPlayerViewController.vodDelegate = self
        present(vodPlayerViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // Begin asynchronously fetching data for the requested index paths.
        guard let feed = dataSource.feed else { return }
        let imageRequests = indexPaths.map { $0.row }
            .map { feed[$0] }
            .map { $0.imageViewUrl }
            .map { URLRequest(url: $0) }
        UIImageView.af.sharedImageDownloader.download(imageRequests)
    }
}

extension BrowseViewController: VODPlayerViewDelegate {
    
    func videoDidEnd(guid: String) {
        guard let progress = ProgressStore.instance.getProgress(for: guid) else {
            logger.warn("No progress found for video on return from ending")
            return
        }
        videoCollectionView.indexPathsForSelectedItems?.forEach {
            let cell = videoCollectionView.cellForItem(at: $0) as! FeedItemCollectionViewCell
            cell.setProgress(progress: progress)
        }
    }
    
}

extension BrowseViewController: DataSourceUpdating {
    
    func feedUpdated(feed: [FeedItem]?) {
        DispatchQueue.main.async {
            self.videoCollectionView?.reloadData()
        }
    }
}
