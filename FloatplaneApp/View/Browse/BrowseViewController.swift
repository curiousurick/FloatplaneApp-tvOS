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
import Logging
import Alamofire

class BrowseViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    private let logger = Log4S()
    private let pageLimit: UInt64 = 20
    
    var feed: CreatorFeed?
    
    @IBOutlet var videoCollectionView: UICollectionView!
    
    var isLoading: Bool = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
        // 4 cells per row with edge inset of 10 between cells (3 spaces) + each side of screen (left and right) = 50
        let width = view.bounds.width / 4 - 80
        let height = view.bounds.width / 4 - 80
        
        flowLayout.headerReferenceSize = CGSizeMake(view.bounds.width, 340)
        flowLayout.itemSize = CGSize(width: width, height: height)
        
        videoCollectionView.register(UINib(nibName: "FeedItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeeditemCell")
        videoCollectionView.collectionViewLayout = flowLayout
        videoCollectionView.contentInset = .init(top: 10, left:  50, bottom: 10, right: 50)
        
        getInitialFeed()
    }
    
    @objc private func getInitialFeed() {
        self.feed = nil
        getNextPage()
    }
    
    private func getNextPage() {
        logger.debug("Fetching next page of content for feed")
        if isLoading {
            logger.warn("Trying to get next page in feed while I am already loading")
            return
        }
        isLoading = true
        let fetchAfter = feed?.items.count ?? 0
        let request = ContentFeedRequest(
            fetchAfter: fetchAfter,
            limit: pageLimit,
            creatorId: OperationConstants.lttCreatorID
        )
        ContentFeedOperation().get(request: request) { fetchedFeed, error in
            guard error == nil,
                  let fetchedFeed = fetchedFeed else {
                self.logger.error("Failed to retrieve next page of content from \(fetchAfter). Error \(error.debugDescription)")
                return
            }
            if let existingFeed = self.feed {
                self.feed = existingFeed.combine(with: fetchedFeed.items)
            }
            else {
                self.feed = fetchedFeed
            }
            DispatchQueue.main.async {
                self.videoCollectionView.reloadData()
                self.isLoading = false
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlayVideoSegue" {
            let playerViewController = segue.destination as! VODPlayerViewController
            playerViewController.video = feed?.items[videoCollectionView.indexPathsForSelectedItems![0].row]
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
        
        if let feed = feed {
            view.updateUI(item: feed.items[indexPath.row])
        }
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == feed!.items.count - 4 && !self.isLoading {
            getNextPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feed?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let feed = feed else {
            return UICollectionViewCell()
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeeditemCell", for: indexPath) as! FeedItemCollectionViewCell
        let item = feed.items[indexPath.row]
        cell.setFeedViewItem(item: item)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "BrowseViewcontroller.PlayVideoSegue", sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // Begin asynchronously fetching data for the requested index paths.
        guard let feed = feed else { return }
        let imageRequests = indexPaths.map { $0.row }
            .map { feed.items[$0] }
            .map { $0.imageViewUrl }
            .map { URLRequest(url: $0) }
        UIImageView.af.sharedImageDownloader.download(imageRequests)
    }
}
