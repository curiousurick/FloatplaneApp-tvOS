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
import FloatplaneApp_Models
import FloatplaneApp_Utilities

class CreatorListView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    var creators: [BaseCreator]? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var widthConstraint: NSLayoutConstraint!
    
    private let backgroundAlpha: CGFloat = 0.20
    
    private struct CollectionConstants {
        static let totalSpacing: CGFloat = 10
        static let minimumLineSpacing: CGFloat = 20
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.darkGray.withAlphaComponent(backgroundAlpha)
        
        let flowLayout = UICollectionViewFlowLayout()
        let width = bounds.width - CollectionConstants.totalSpacing
        let height = width
        
        flowLayout.itemSize = CGSize(width: width, height: height)
        flowLayout.minimumLineSpacing = CollectionConstants.minimumLineSpacing
        collectionView.remembersLastFocusedIndexPath = true
        
        collectionView.collectionViewLayout = flowLayout
    }
    
    @objc private func updatedCreators(notification: Notification) {
        guard let userInfo = notification.userInfo,
        let creators = userInfo[FPNotifications.CreatorListUpdated.creatorsKey] as? [BaseCreator] else {
            return
        }
        self.creators = creators
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return creators?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreatorListViewCell.identifier, for: indexPath) as! CreatorListViewCell
        cell.updateImage(creator: creators![indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedBaseCreator = creators![indexPath.row]
        let navController = AppDelegate.instance.topNavigationController
        navController?.changeSelectedCreator(baseCreator: selectedBaseCreator)
    }
}
