//
//  FeedItemCollectionViewCell.swift
//  FloatplaneApp
//
//  Created by George Urick on 3/25/23.
//

import Foundation
import UIKit
import ParallaxView
import AlamofireImage
import SwiftDate

protocol FeedViewItem {
    var imageViewUrl: URL { get }
    var titleLabel: String { get }
    var typeLabel: String { get }
    var channelLabel: String { get }
    var timeSinceReleaseLabel: String { get }
}

extension CreatorFeed.FeedItem: FeedViewItem {
    var imageViewUrl: URL {
        get {
            self.thumbnail.path
        }
    }
    
    var titleLabel: String {
        get {
            title
        }
    }
    
    var typeLabel: String {
        get {
            " Video "
        }
    }
    
    var channelLabel: String {
        get {
            self.channel.title
        }
    }
    
    var timeSinceReleaseLabel: String {
        releaseDate.toRelative(since: nil, dateTimeStyle: .numeric, unitsStyle: .full)
    }
    
}

class FeedItemCollectionViewCell: ParallaxCollectionViewCell {
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var type: UILabel!
    @IBOutlet var channel: UILabel!
    @IBOutlet var timeSinceRelease: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 10
        layer.masksToBounds = true
        image.layer.masksToBounds = true
        type.layer.cornerRadius = 5
        type.layer.masksToBounds = true
    }
    
    func setFeedViewItem(item: FeedViewItem) {
        image.af.setImage(withURL: item.imageViewUrl)
        title.text = item.titleLabel
        type.text = item.typeLabel
        channel.text = item.channelLabel
        timeSinceRelease.text = item.timeSinceReleaseLabel
    }
}
