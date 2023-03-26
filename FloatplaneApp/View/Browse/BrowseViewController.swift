//
//  ViewController.swift
//  FloatplaneApp
//
//  Created by George Urick on 3/25/23.
//

import UIKit
import AVKit

class BrowseViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    private var feed: CreatorFeed?
    
    @IBOutlet var videoCollectionView: UICollectionView!
    
    var isLoading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flowLayout = UICollectionViewFlowLayout()
        // 4 cells per row with edge inset of 10 between cells (3 spaces) + each side of screen (left and right) = 50
        let cellWidth: CGFloat = (view.bounds.width / 4) - 50
        let cellHeight: CGFloat = cellWidth
        let edgeInset: CGFloat = 10
        
        flowLayout.headerReferenceSize = CGSizeMake(view.bounds.width, 340)
        
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        flowLayout.sectionInset = UIEdgeInsets(top: edgeInset + 20, left: edgeInset + 20, bottom: edgeInset, right: edgeInset + 20)
        flowLayout.minimumInteritemSpacing = edgeInset
        
        videoCollectionView.collectionViewLayout = flowLayout
        
        getInitialFeed()
    }
    
    private func getInitialFeed() {
        if isLoading {
            print("Trying to get initial feed while I am already loading")
            return
        }
        isLoading = true
        let request = ContentFeedRequest(fetchAfter: 0, limit: 20, creatorId: OperationConstants.lttCreatorID)
        ContentFeedOperation().get(params: request) { feed, error in
            if let error = error {
                print("Oh no. Error \(error)")
            }
            if let feed = feed {
                self.feed = feed
            }
            DispatchQueue.main.async {
                self.videoCollectionView.reloadData()
                self.isLoading = false
            }
        }
    }
    
    private func getNextPage() {
        if isLoading {
            print("Trying to get next page in feed while I am already loading")
            return
        }
        isLoading = true
        guard let feed = feed else {
            print("Trying to get next page even though we don't have a feed")
            return
        }
        let request = ContentFeedRequest(fetchAfter: feed.items.count, limit: 20, creatorId: OperationConstants.lttCreatorID)
        ContentFeedOperation().get(params: request) { fetchedFeed, error in
            if let error = error {
                print("Oh no. Error \(error)")
                return
            }
            if let fetchedFeed = fetchedFeed {
                self.feed = self.feed?.combine(with: fetchedFeed.items)
            }
            DispatchQueue.main.async {
                self.videoCollectionView.reloadData()
                self.isLoading = false
            }
        }
    }
    
    private func startVideo(video: CreatorFeed.FeedItem) {
        guard video.videoAttachments.count > 0 else {
            return
        }
        let guid = video.videoAttachments[0]
        let request = DeliveryKeyRequest(guid: guid, type: .vod)
        DeliveryKeyOperation().get(params: request) { deliveryKey, error in
            guard error == nil, let deliveryKey = deliveryKey else {
                print("Oh shit. Error \(error!)")
                return
            }
            DispatchQueue.main.async {
                self.startVideo(deliveryKey: deliveryKey)
            }
        }
    }
    
    private func startVideo(deliveryKey: DeliveryKey) {
        let playerViewController = AVPlayerViewController()
        
        let url = StreamUrl(deliveryKey: deliveryKey, qualityLevelName: UserSettings.instance.qualitySettings).url
        let player = AVPlayer(url: url)
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Unrecognized element of kind: \(kind)")
        }
        
        let view: BrowseReusableHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "BrowseReusableHeaderView", for: indexPath) as! BrowseReusableHeaderView
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedItemCell", for: indexPath) as! FeedItemCollectionViewCell
        let item = feed.items[indexPath.row]
        cell.setFeedViewItem(item: item)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let video = feed?.items[indexPath.row] else {
            return
        }
        startVideo(video: video)
    }
}
