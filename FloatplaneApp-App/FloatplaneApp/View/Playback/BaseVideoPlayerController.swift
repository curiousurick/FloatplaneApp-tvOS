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
import FloatplaneApp_Utilities
import FloatplaneApp_DataStores

class BaseVideoPlayerViewController: AVPlayerViewController, AVPlayerViewControllerDelegate {
    let logger = Log4S()
    private var timeObserverToken: Any?

    override var player: AVPlayer? {
        willSet {
            stopObservingPlayer(player)
        }
        didSet {
            startObservingPlayer(player)
        }
    }

    func progressUpdate(time _: CMTime) {}
    func playbackFailed() {}

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingPlayer(player)
    }

    private func startObservingPlayer(_ player: AVPlayer?) {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let updateInterval = CMTime(seconds: ProgressStore.updateInterval, preferredTimescale: timeScale)

        player?.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        timeObserverToken = player?.addPeriodicTimeObserver(
            forInterval: updateInterval,
            queue: .main
        ) { [weak self] time in
            if let self = self {
                self.progressUpdate(time: time)
            }
        }
    }

    private func stopObservingPlayer(_ player: AVPlayer?) {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change _: [NSKeyValueChangeKey: Any]?,
        context _: UnsafeMutableRawPointer?
    ) {
        let playerItem = object as! AVPlayerItem
        if keyPath == "status", playerItem.status == .failed {
            playbackFailed()
        }
    }
}
