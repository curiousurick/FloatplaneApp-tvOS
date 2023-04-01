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

class LivePlayerViewController: BaseVideoPlayerViewController {
    private var menuPressRecognizer: UITapGestureRecognizer?
    private let liveDeliveryKeyOperation = OperationManager.instance.liveDeliveryKeyOperation
    
    private var timeObserverToken: Any?
    
    private var fpTabBarController: FPTabBarController? {
        get {
            return tabBarController as? FPTabBarController
        }
    }
    
    let liveStreamEndNotification = Notification.Name.AVPlayerItemDidPlayToEndTime
    var registeredForLiveStreamEndNotification: Bool = false
    var creator: Creator!
    var deliveryKey: LiveDeliveryKey?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
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
        let video = creator.liveStream
        Task {
            if let deliveryKey = await getDeliveryKey(video: video) {
                self.deliveryKey = deliveryKey
                DispatchQueue.main.async {
                    self.startVideo(deliveryKey: deliveryKey)
                }
            }
            else {
                self.logger.error("Unable to get live delivery key for owner \(video.owner).")
                self.fpTabBarController?.updateLiveTab(online: false)
            }
        }
    }
    
    private func startVideo(deliveryKey: LiveDeliveryKey) {
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
        fpTabBarController?.selectedIndex = 1
    }
}

// MARK: Get Delivery Key
extension LivePlayerViewController {
    
    func getDeliveryKey(video: LiveStream) async -> LiveDeliveryKey? {
        await withCheckedContinuation({ continuation in
            let request = LiveDeliveryKeyRequest(creator: video.owner)
            self.liveDeliveryKeyOperation.get(request: request) { deliveryKey, error in
                continuation.resume(returning: deliveryKey)
            }
        })
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
        fpTabBarController?.updateLiveTab(online: false)
    }
}
