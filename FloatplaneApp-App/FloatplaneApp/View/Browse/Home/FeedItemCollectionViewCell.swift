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
import SwiftDate
import ParallaxView
import FloatplaneApp_Models
import FloatplaneApp_DataStores

protocol FeedViewItem {
    var imageViewUrl: URL { get }
    var titleLabel: String { get }
    var typeLabel: String { get }
    var channelLabel: String { get }
    var timeSinceReleaseLabel: String { get }
    var progress: TimeInterval? { get }
    var duration: TimeInterval { get }
}

extension FeedItem: FeedViewItem {
    var imageViewUrl: URL {
        thumbnail.path
    }

    var titleLabel: String {
        title
    }

    var typeLabel: String {
        " Video "
    }

    var channelLabel: String {
        channel.title
    }

    var timeSinceReleaseLabel: String {
        releaseDate.toRelative(since: nil, dateTimeStyle: .numeric, unitsStyle: .full)
    }

    var progress: TimeInterval? {
        if !videoAttachments.isEmpty,
           let progressStore = UserStoreImpl.instance.getProgressStore() {
            let videoGuid = videoAttachments[0]
            return progressStore.getProgress(for: videoGuid)
        }
        return nil
    }

    var duration: TimeInterval {
        TimeInterval(metadata.videoDuration)
    }
}

class FeedItemCollectionViewCell: ParallaxCollectionViewCell {
    static let defaultDurationText = "0:00"
    static let identifier = "FeeditemCell"
    static let nibName = "FeedItemCollectionViewCell"

    let imageCornerRadiusValue: CGFloat = 20
    let typeLabelCornerRadiusValue: CGFloat = 5

    @IBOutlet var image: UIImageView!
    @IBOutlet var title: UITextView!
    @IBOutlet var type: UILabel!
    @IBOutlet var channel: UILabel!
    @IBOutlet var timeSinceRelease: UILabel!
    @IBOutlet var progressBar: FeedItemProgressBarView!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var clockImage: UIImageView!

    var feedItem: FeedViewItem!

    static func dequeueFromCollectionView(
        collectionView: UICollectionView,
        indexPath: IndexPath
    )
        -> FeedItemCollectionViewCell {
        collectionView.dequeueReusableCell(
            withReuseIdentifier: FeedItemCollectionViewCell.identifier,
            for: indexPath
        ) as! FeedItemCollectionViewCell
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        title.textContainerInset = .init(top: 5.0, left: 0.0, bottom: 0.0, right: 0.0)

        image.clipsToBounds = true
        layer.cornerRadius = imageCornerRadiusValue
        layer.masksToBounds = true
        type.layer.cornerRadius = typeLabelCornerRadiusValue
        type.layer.masksToBounds = true
    }

    func setProgress(progress: TimeInterval) {
        if progress != 0, feedItem.duration != 0 {
            let percent = (progress / feedItem.duration)
            // Sometimes progress goes just over duration.
            // Bar width becomes progress proportion of
            // Cell width.
            let width = bounds.width * min(percent, 1)
            progressBar.updateWidth(width: width)
            progressBar.isHidden = false
        }
        else {
            progressBar.isHidden = true
        }
    }

    func setFeedViewItem(item: FeedViewItem) {
        feedItem = item
        image.image = nil
        image.af.setImage(withURL: item.imageViewUrl)
        title.text = item.titleLabel
        type.text = item.typeLabel
        channel.text = item.channelLabel
        timeSinceRelease.text = item.timeSinceReleaseLabel
        if item.duration > 0 {
            durationLabel.isHidden = false
            clockImage.isHidden = false
            durationLabel.text = DateComponentsFormatter().string(from: item.duration)
        }
        else {
            durationLabel.isHidden = true
            clockImage.isHidden = true
        }
        setProgress(progress: item.progress ?? 0)
    }
}
