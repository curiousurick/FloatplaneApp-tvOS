
import UIKit
import AlamofireImage

class BrowseReusableHeaderView: UICollectionReusableView {
    @IBOutlet var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(item: CreatorFeed.FeedItem) {
        let coverUrl = item.creator.cover.path
        imageView.af.setImage(withURL: coverUrl)
    }
}
