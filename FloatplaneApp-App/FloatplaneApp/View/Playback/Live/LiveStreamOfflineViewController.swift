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
import AlamofireImage
import FloatplaneApp_Utilities
import FloatplaneApp_Operations
import FloatplaneApp_Models

class LiveStreamOfflineViewController: UIViewController, DataSourceUpdating {
    private let logger = Log4S()
    private let liveDeliveryKeyOperation = OperationManager.instance.liveDeliveryKeyOperation
    private let dataSource = DataSource.instance
    
    @IBOutlet var offlineThumbnailView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateThumbnailView()
        checkIfVideoOnline()
    }
    
    func checkIfVideoOnline() {
        guard let activeCreator = dataSource.activeCreator else {
            logger.error("Cannot start live stream because liveSream is nil")
            return
        }
        let liveStream = activeCreator.liveStream
        let request = LiveDeliveryKeyRequest(creator: liveStream.owner)
        guard liveDeliveryKeyOperation.isAllowedToCheckForLiveStream(request: request) else {
            logger.info("Cannot check if live because not allowed to check.")
            return
        }
        liveDeliveryKeyOperation.get(request: request) { deliveryKey, error in
            if let deliveryKey = deliveryKey {
                self.logger.error("Unable to get live delivery key for owner \(liveStream.owner).")
                guard let tabBarController = self.tabBarController as? FPTabBarController else {
                    return
                }
                tabBarController.updateLiveTab(online: true, deliverKey: deliveryKey)
            }
        }
    }
    
    func activeCreatorUpdated(activeCreator: Creator) {
        updateThumbnailView()
    }
    
    func updateThumbnailView() {
        if let offlineThumbnailView = self.offlineThumbnailView,
           let activeCreator = dataSource.activeCreator {
            DispatchQueue.main.async {
                if let url = activeCreator.liveStream.offline?.thumbnail.path {
                    offlineThumbnailView.af.setImage(withURL: url)
                }
                else {
                    offlineThumbnailView.image = nil
                }
            }
        }
    }
}
