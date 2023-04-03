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
import FloatplaneApp_Operations
import FloatplaneApp_Utilities
import FloatplaneApp_Models
import FloatplaneApp_DataStores

final class SearchViewController: UICollectionViewController, UISearchResultsUpdating, CreatorViewControllerProtocol {
    struct CollectionConstants {
        static let rowCount: CGFloat = 4
        static let totalSpacing: CGFloat = 80
        
        static let contentVerticalInset: CGFloat = 10
        static let contentHorizontalInset: CGFloat = 50
    }
    
    private let logger = Log4S()
    private let pageLimit: UInt64 = 20
    private let searchOperation = OperationManager.instance.searchOperation
    private let minimumQueryLength = 3
    
    private var searchString: String?
    private var results: SearchResponse?
    
    var activeCreator: Creator!
    var baseCreators: [BaseCreator]!

    override func viewDidLoad() {
        super.viewDidLoad()
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.invalidateLayout()
        let width = view.bounds.width / CollectionConstants.rowCount - CollectionConstants.totalSpacing
        let height = width
        flowLayout.itemSize = CGSize(width: width, height: height)
        collectionView.collectionViewLayout = flowLayout
        
        collectionView?.register(
            UINib(nibName: FeedItemCollectionViewCell.nibName, bundle: nil),
            forCellWithReuseIdentifier: FeedItemCollectionViewCell.identifier
        )
        let vertInset = CollectionConstants.contentVerticalInset
        let horizInset = CollectionConstants.contentHorizontalInset
        collectionView?.contentInset = .init(top: vertInset, left:  horizInset, bottom: vertInset, right: horizInset)
        collectionView.alwaysBounceVertical = true
        collectionView.bounces = true
        collectionView.isPrefetchingEnabled = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let newSearchString = searchController.searchBar.text
        guard let newSearchString = newSearchString else {
            return
        }
        if let searchString = self.searchString, searchString == newSearchString {
            return
        }
        self.searchString = newSearchString
        if newSearchString.count >= minimumQueryLength {
            getInitialFeed(searchString: newSearchString)
        }
        else {
            self.results = nil
            self.collectionView.reloadData()
        }
    }
    
    @objc private func getInitialFeed(searchString: String) {
        self.results = nil
        getNextPage(searchString: searchString)
    }
    
    private func getNextPage(searchString: String) {
        logger.debug("Fetching next page of content for feed")
        guard let creator = activeCreator else {
            logger.error("Trying to search with no active creator")
            return
        }
        if searchOperation.isActive() {
            searchOperation.cancel()
        }
        let fetchAfter = results?.items.count ?? 0
        let request = SearchRequest(
            creatorId: creator.id,
            sort: .descending,
            searchQuery: searchString,
            fetchAfter: fetchAfter
        )
        searchOperation.get(request: request) { searchResult, error in
            guard error == nil,
                  let searchResult = searchResult else {
                self.logger.error("Failed to retrieve next page of content from \(fetchAfter). Error \(error.debugDescription)")
                return
            }
            if let existingResults = self.results {
                self.results = existingResults.combine(with: searchResult.items)
            }
            else {
                self.results = searchResult
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
}

extension SearchViewController: UICollectionViewDataSourcePrefetching {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results?.items.count ?? 0
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let results = results, let searchString = searchString,
           indexPath.row == results.items.count - 4 && !searchOperation.isActive() {
            getNextPage(searchString: searchString)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = FeedItemCollectionViewCell.dequeueFromCollectionView(collectionView: collectionView, indexPath: indexPath)
        cell.setFeedViewItem(item: results!.items[indexPath.row])
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let items = self.results?.items else {
            logger.error("Clicked on result item while there are no results")
            return
        }
        let vodPlayerViewController = UIStoryboard.main.getVodPlayerViewController()
        vodPlayerViewController.feedItem = items[indexPath.row]
        vodPlayerViewController.vodDelegate = self
        present(vodPlayerViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // Begin asynchronously fetching data for the requested index paths.
        guard let results = results else { return }
        let imageRequests = indexPaths.map { $0.row }
            .map { results.items[$0] }
            .map { $0.imageViewUrl }
            .map { URLRequest(url: $0) }
        UIImageView.af.sharedImageDownloader.download(imageRequests)
    }
}

extension SearchViewController: VODPlayerViewDelegate {
    
    func videoDidEnd(guid: String) {
        guard let progress = ProgressStore.instance.getProgress(for: guid) else {
            logger.warn("No progress found for video on return from ending")
            return
        }
        collectionView.indexPathsForSelectedItems?.forEach {
            let cell = collectionView.cellForItem(at: $0) as! FeedItemCollectionViewCell
            cell.setProgress(progress: progress)
        }
    }
    
}
