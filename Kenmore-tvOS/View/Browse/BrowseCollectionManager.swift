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
import Kenmore_Models
import Kenmore_Utilities

protocol ContentFeedDelegate {
    func getVideos(fetchAfter: Int, limit: UInt64) async

    func videoSelected(feedItem: FeedItem)
}

class BrowseCollectionManager: NSObject, UICollectionViewDelegate, UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {
    enum CollectionConstants {
        static let rowCount: CGFloat = 4
        static let cellSpacing: CGFloat = 40

        static let headerHeight: CGFloat = 340

        static let sectionTopInset: CGFloat = 40
        static let contentVerticalInset: CGFloat = 10
        static let contentHorizontalInset: CGFloat = 40
    }

    private let logger = Log4S()
    let pageLimit: UInt64 = 20

    private(set) var feed: [FeedItem]
    var activeFetching = false
    var reachedEnd = false
    var delegate: ContentFeedDelegate?

    private let collectionView: UICollectionView

    init(
        collectionView: UICollectionView,
        initialFeed: [FeedItem] = [],
        useHeader: Bool
    ) {
        self.collectionView = collectionView
        feed = initialFeed
        super.init()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.prefetchDataSource = self
        collectionView.register(
            UINib(nibName: FeedItemCollectionViewCell.nibName, bundle: nil),
            forCellWithReuseIdentifier: FeedItemCollectionViewCell.identifier
        )

        let flowLayout = UICollectionViewFlowLayout()
        var sectionTopInset: CGFloat = 0
        if useHeader {
            sectionTopInset = CollectionConstants.sectionTopInset
            let viewWidth = collectionView.frame.width
            flowLayout.headerReferenceSize = CGSizeMake(viewWidth, CollectionConstants.headerHeight)
        }
        let horizInset = CollectionConstants.cellSpacing
        let vertInset = CollectionConstants.contentVerticalInset
        flowLayout.sectionInset = .init(
            top: sectionTopInset,
            left: horizInset,
            bottom: vertInset,
            right: horizInset
        )
        collectionView.collectionViewLayout = flowLayout
    }

    func setFeed(feed: [FeedItem]) {
        self.feed = feed
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    func addToFeed(feed: [FeedItem]) {
        let oldCount = self.feed.count
        self.feed += feed
        let newCount = self.feed.count
        var indexPaths: [IndexPath] = []
        for i in oldCount ..< newCount {
            indexPaths.append(IndexPath(row: i, section: 0))
        }
        DispatchQueue.main.async {
            self.collectionView.insertItems(at: indexPaths)
        }
    }

    func updateProgress(progress: TimeInterval, for _: String) {
        collectionView.indexPathsForSelectedItems?.forEach {
            let cell = collectionView.cellForItem(at: $0) as! FeedItemCollectionViewCell
            cell.setProgress(progress: progress)
        }
    }

    func numberOfSections(in _: UICollectionView) -> Int {
        1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let view: BrowseReusableHeaderView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: BrowseReusableHeaderView.identifier,
            for: indexPath
        ) as! BrowseReusableHeaderView

        view.updateUI(item: feed[indexPath.row])
        return view
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        minimumLineSpacingForSectionAt _: Int
    ) -> CGFloat {
        CollectionConstants.cellSpacing
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let viewWidth = collectionView.frame.width
        let horizInset = CollectionConstants.cellSpacing
        // Space between 4 cells (3) + space between edge cells and edge (2)
        let totalSpacing = ((CollectionConstants.rowCount + 1) * horizInset)
        // 36 is a random number that we have to reduce from total width of cells before it allows 4 cells per row.
        // Mathematically, I think it should be (totalWidth - spaceWidth*(cells-1+edges)) / cells.
        // But in that case, they end up being too wide.
        // TODO: Figure out why this doesn't work without extra width removed.
        let width = (viewWidth - (totalSpacing + 36)) / CollectionConstants.rowCount
        let height = width - 20
        return CGSize(width: width, height: height)
    }

    func collectionView(_: UICollectionView, willDisplay _: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let delegate = delegate else {
            return
        }
        if indexPath.row == feed.count - 4, !activeFetching, !reachedEnd {
            activeFetching = true
            Task {
                // We look up results. DataSourceUpdating will set the new feed.
                await delegate.getVideos(fetchAfter: feed.count, limit: pageLimit)
                activeFetching = false
            }
        }
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        feed.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = FeedItemCollectionViewCell.dequeueFromCollectionView(
            collectionView: collectionView,
            indexPath: indexPath
        )
        let item = feed[indexPath.row]
        cell.setFeedViewItem(item: item)

        return cell
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.videoSelected(feedItem: feed[indexPath.row])
    }

    func collectionView(_: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // Begin asynchronously fetching data for the requested index paths.
        let imageRequests = indexPaths.map(\.row)
            .map { feed[$0] }
            .map(\.imageViewUrl)
            .map { URLRequest(url: $0) }
        UIImageView.af.sharedImageDownloader.download(imageRequests)
    }
}
