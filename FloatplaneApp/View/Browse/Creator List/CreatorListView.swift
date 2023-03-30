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

class CreatorListView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    var creators: [BaseCreator] = []
    
    @IBOutlet var collectionView: UICollectionView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updatedCreators(notification:)),
            name: FPNotifications.CreatorListUpdated.name,
            object: nil
        )
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.darkGray.withAlphaComponent(0.20)
        
        let flowLayout = UICollectionViewFlowLayout()
        // 4 cells per row with edge inset of 10 between cells (3 spaces) + each side of screen (left and right) = 50
        let width = bounds.width - 10
        let height = width
        
        flowLayout.itemSize = CGSize(width: width, height: height)
        flowLayout.minimumLineSpacing = 20
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
        return creators.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreatorListViewCell", for: indexPath) as! CreatorListViewCell
        cell.updateImage(creator: creators[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedBaseCreator = creators[indexPath.row]
        let navController = AppDelegate.instance.topNavigationController
        navController?.activeBaseCreator = selectedBaseCreator
    }
}
