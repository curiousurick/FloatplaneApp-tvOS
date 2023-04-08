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
import FloatplaneApp_Operations
import FloatplaneApp_Models

class LivePlayerViewController: BaseVideoPlayerViewController {
    private var menuPressRecognizer: UITapGestureRecognizer?
    private let liveDeliveryKeyOperation = OperationManagerImpl.instance.liveDeliveryKeyOperation
    private let dataSource = DataSource.instance
    private var timeObserverToken: Any?
    private let liveStreamEndNotification = Notification.Name.AVPlayerItemDidPlayToEndTime
    private var registeredForLiveStreamEndNotification = false
    private let liveDeliveryKeyDebuff = LiveDeliveryKeyDebuffImpl.instance
    
    var deliveryKey: DeliveryKey?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        setupMenuButtonPress()
        startVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let menuPressRecognizer = menuPressRecognizer {
            self.view.removeGestureRecognizer(menuPressRecognizer)
        }
        menuPressRecognizer = nil
        self.tabBarController?.tabBar.isHidden = false
        if let player = player {
            player.pause()
        }
    }
    
    override func playbackFailed() {
        cleanupAndExit()
    }
    
    private func startVideo() {
        // You're being presented when you already have an active stream going.
        if let player = player {
            player.play()
            return
        }
        // You're being presented to replace the offline screen
        else if let deliveryKey = deliveryKey {
            startVideo(deliveryKey: deliveryKey)
            return
        }
        // You're being presented without knowledge of livestream availability.
        guard let activeCreator = dataSource.activeCreator else {
            logger.error("LivePlayerViewController opened without an activeCreator")
            return
        }
        let liveStream = activeCreator.liveStream
        Task {
            let liveDeliveryKeyRequest = LiveDeliveryKeyRequest(creator: liveStream.owner)
            self.liveDeliveryKeyDebuff.lastCheck[liveDeliveryKeyRequest] = Date()
            let opResponse = await self.liveDeliveryKeyOperation.get(request: liveDeliveryKeyRequest)
            if let deliveryKey = opResponse.response {
                self.deliveryKey = deliveryKey
                DispatchQueue.main.async {
                    self.startVideo(deliveryKey: deliveryKey)
                }
            }
            else {
                let errorString = String(describing: opResponse.error)
                self.logger.error("Unable to get live delivery key for owner \(liveStream.owner). Error \(errorString)")
                guard let tabBarController = tabBarController as? FPTabBarController else {
                    logger.error("LivePlayerViewController's tabBarController is not the FPTabBarController")
                    return
                }
                tabBarController.updateLiveTab(online: false)
            }
        }
    }
    
    private func startVideo(deliveryKey: DeliveryKey) {
        let url = StreamUrl(deliveryKey: deliveryKey).url
        let player = AVPlayer(url: url)
        self.player = player
        player.play()
        if !registeredForLiveStreamEndNotification {
            NotificationCenter.default.addObserver(self, selector: #selector(liveStreamEnded(notification:)), name: liveStreamEndNotification, object: nil)
            registeredForLiveStreamEndNotification = true
        }
        logger.debug("Started playing video \(url)")
    }
}

// MARK: Menu Button Press Behavior
extension LivePlayerViewController {
    private func setupMenuButtonPress() {
        menuPressRecognizer = UITapGestureRecognizer()
        if let menuPressRecognizer = menuPressRecognizer {
            menuPressRecognizer.addTarget(self, action: #selector(menuButtonAction(recognizer:)))
            menuPressRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
            self.view.addGestureRecognizer(menuPressRecognizer)
        }
    }
    
    @objc func menuButtonAction(recognizer: UITapGestureRecognizer) {
        guard let tabBarController = tabBarController as? FPTabBarController else {
            logger.error("LivePlayerViewController's tabBarController is not the FPTabBarController")
            return
        }
        tabBarController.selectedIndex = 1
    }
}

// MARK: End of stream behavior
extension LivePlayerViewController {
    @objc private func liveStreamEnded(notification: Notification) {
        cleanupAndExit()
    }
    
    private func cleanupAndExit() {
        registeredForLiveStreamEndNotification = false
        self.player = nil
        NotificationCenter.default.removeObserver(self, name: liveStreamEndNotification, object: nil)
        guard let tabBarController = tabBarController as? FPTabBarController else {
            logger.error("LivePlayerViewController's tabBarController is not the FPTabBarController")
            return
        }
        tabBarController.updateLiveTab(online: false)
    }
}
