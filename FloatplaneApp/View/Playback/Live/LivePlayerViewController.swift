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

class LivePlayerViewController: AVPlayerViewController {
    private let logger = Log4S()
    private var menuPressRecognizer: UITapGestureRecognizer?
    
    private var timeObserverToken: Any?
    
    var creator: Creator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        menuPressRecognizer = UITapGestureRecognizer()
        if let menuPressRecognizer = menuPressRecognizer {
            menuPressRecognizer.addTarget(self, action: #selector(menuButtonAction(recognizer:)))
            menuPressRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
            self.parent?.view.addGestureRecognizer(menuPressRecognizer)
        }
        
    }

    @objc func menuButtonAction(recognizer: UITapGestureRecognizer) {
        let tabBarController = parent as! FPTabBarController
        tabBarController.selectedIndex = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let player = player {
            player.play()
        }
        else {
            startVideo()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let menuPressRecognizer = menuPressRecognizer {
            self.parent?.view.removeGestureRecognizer(menuPressRecognizer)
        }
        self.tabBarController?.tabBar.isHidden = false
        stopObservingPlayer()
        if let player = player {
            player.pause()
        }
    }
    
    private func startObservingPlayer() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let updateInterval = CMTime(seconds: 10, preferredTimescale: timeScale)

        timeObserverToken = player?.addPeriodicTimeObserver(
            forInterval: updateInterval,
            queue: .main
        ) { time in
        }
    }


    private func stopObservingPlayer() {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    private func startVideo() {
        guard let video = creator?.liveStream else {
            logger.error("Cannot start live stream because liveSream is nil")
            return
        }
        let request = LiveDeliveryKeyRequest(creator: video.owner, type: .live)
        LiveDeliveryKeyOperation().get(request: request) { deliveryKey, error in
            guard error == nil, let deliveryKey = deliveryKey else {
                self.logger.error("Unable to get live delivery key for owner \(video.owner).")
                return
            }
            DispatchQueue.main.async {
                self.startVideo(deliveryKey: deliveryKey)
            }
        }
    }
    
    private func startVideo(deliveryKey: LiveDeliveryKey) {
        let url = StreamUrl(deliveryKey: deliveryKey).url
        let player = AVPlayer(url: url)
        self.player = player
        player.play()
        self.startObservingPlayer()
        logger.debug("Started playing video \(url)")
    }
}
