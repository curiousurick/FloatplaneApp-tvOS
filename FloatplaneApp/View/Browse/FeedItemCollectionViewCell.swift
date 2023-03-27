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
