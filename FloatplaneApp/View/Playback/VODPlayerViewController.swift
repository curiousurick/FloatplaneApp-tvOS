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

import AVKit

class VODPlayerViewController: AVPlayerViewController {
    private let logger = Log4S()
    private let progressStore = ProgressStore.instance
    
    private var timeObserverToken: Any?
    
    var video: FeedItem!
    
    var videoGuid: String {
        get {
            return video.videoAttachments[0]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        startVideo(video: video)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingPlayer()
        if let player = player {
            let seconds = player.currentTime().seconds
            progressStore.setProgress(for: videoGuid, progress: seconds)
        }
    }
    
    private func startObservingPlayer() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let updateInterval = CMTime(seconds: 10, preferredTimescale: timeScale)

        timeObserverToken = player?.addPeriodicTimeObserver(
            forInterval: updateInterval,
            queue: .main
        ) { [weak self] time in
            if let self = self {
                let seconds = time.seconds
                self.progressStore.setProgress(for: self.videoGuid, progress: seconds)
            }
        }
    }


    private func stopObservingPlayer() {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    private func startVideo(video: FeedItem) {
        guard video.videoAttachments.count > 0 else {
            return
        }
        let request = DeliveryKeyRequest(guid: videoGuid, type: .vod)
        DeliveryKeyOperation().get(request: request) { deliveryKey, error in
            guard error == nil, let deliveryKey = deliveryKey else {
                self.logger.error("Unable to get delivery key for video \(self.videoGuid).")
                return
            }
            DispatchQueue.main.async {
                self.startVideo(deliveryKey: deliveryKey)
            }
        }
    }
    
    private func startVideo(deliveryKey: DeliveryKey) {
        let url = StreamUrl(deliveryKey: deliveryKey, qualityLevelName: UserSettings.instance.qualitySettings).url
        let player = AVPlayer(url: url)
        self.player = player
        if let progress = progressStore.getProgress(for: videoGuid) {
            let seekPosition = CMTime(seconds: progress, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            player.currentItem?.seek(to: seekPosition, completionHandler: { success in
                self.logger.debug("Started at position \(player.currentTime())")
            })
        }
        player.play()
        self.startObservingPlayer()
        logger.debug("Started playing video \(url)")
    }
}
