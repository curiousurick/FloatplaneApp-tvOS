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

extension SearchViewController {
    static func createEmbeddedInNavigationController() -> UINavigationController {
        let searchViewController = SearchViewController()
        let searchController = UISearchController(searchResultsController: searchViewController)
        searchViewController.searchController = searchController
        let searchContainerController = UISearchContainerViewController(searchController: searchController)
        searchController.searchResultsUpdater = searchViewController
        return UINavigationController(rootViewController: searchContainerController)
    }
}

final class SearchViewController: UICollectionViewController, UISearchResultsUpdating, UICollectionViewDataSourcePrefetching {
    private let logger = Log4S()
    private let pageLimit: UInt64 = 20
    fileprivate var searchController: UISearchController!
    private let searchOperation = SearchOperation()
    
    private var searchString: String?
    private var results: SearchResponse?

    init() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.invalidateLayout()
        super.init(collectionViewLayout: flowLayout)
        let width = view.bounds.width / 4 - 80
        let height = view.bounds.width / 4 - 80
        flowLayout.itemSize = CGSize(width: width, height: height)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(UINib(nibName: "FeedItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeeditemCell")
        collectionView?.contentInset = .init(top: 10, left:  50, bottom: 50, right: 50)
        collectionView.alwaysBounceVertical = true
        collectionView.remembersLastFocusedIndexPath = true
        collectionView.bounces = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
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
        if newSearchString.count > 2 {
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
        if searchOperation.isActive() {
            searchOperation.cancel()
        }
        let fetchAfter = results?.items.count ?? 0
        let request = SearchRequest(
            creatorId: OperationConstants.lttCreatorID,
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
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results?.items.count ?? 0
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("Will display cell at \(indexPath)")
        if let results = results, let searchString = searchString,
           indexPath.row == results.items.count - 4 && !searchOperation.isActive() {
            print("going to get next page of results")
            getNextPage(searchString: searchString)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeeditemCell", for: indexPath) as! FeedItemCollectionViewCell
        cell.setFeedViewItem(item: results!.items[indexPath.row])
        
        return cell
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
