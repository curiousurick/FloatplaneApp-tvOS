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
import AlamofireImage
import SwiftDate

class VODPlayerViewController: AVPlayerViewController {
    private let logger = Log4S()
    private let progressStore = ProgressStore.instance
    private let vodDeliveryKeyOperation = OperationManager.instance.vodDeliveryKeyOperation
    
    private var timeObserverToken: Any?
    
    var video: FeedItem!
    
    var videoGuid: String {
        get {
            return video.videoAttachments[0]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        let updateInterval = CMTime(seconds: ProgressStore.updateInterval, preferredTimescale: timeScale)

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
        let request = VodDeliveryKeyRequest(guid: videoGuid, type: .vod)
        vodDeliveryKeyOperation.get(request: request) { deliveryKey, error in
            guard error == nil, let deliveryKey = deliveryKey else {
                self.logger.error("Unable to get delivery key for video \(self.videoGuid).")
                return
            }
            DispatchQueue.main.async {
                self.startVideo(deliveryKey: deliveryKey)
            }
        }
    }
    
    private func startVideo(deliveryKey: VodDeliveryKey) {
        let url = StreamUrl(deliveryKey: deliveryKey, qualityLevelName: UserSettings.instance.qualitySettings).url
        let player = AVPlayer(url: url)
        self.player = player
        if let progress = progressStore.getProgress(for: videoGuid) {
            let seekPosition = CMTime(seconds: progress, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            player.currentItem?.seek(to: seekPosition, completionHandler: { success in
                self.logger.debug("Started at position \(player.currentTime())")
            })
        }
        DispatchQueue.main.async {
            player.currentItem?.externalMetadata = self.createMetadataItems()
            player.play()
            self.startObservingPlayer()
            self.logger.debug("Started playing video \(url)")
        }
    }
    
    func createMetadataItems() -> [AVMetadataItem] {
        let channelName = video.channel.title
        // Small optimization to avoid channel name sitting just above title prefix.
        let title = video.title.replacing("\(channelName): ", with: "")
        let description = video.text.html2String
        let channelArt = video.channel.icon.path
        let image = try? Data(contentsOf: channelArt)
            
        let mapping: [AVMetadataIdentifier: Any] = [
            .commonIdentifierTitle: title,
            .iTunesMetadataTrackSubTitle: channelName,
            .commonIdentifierDescription: description,
            .commonIdentifierArtwork: image as Any
        ]
        return mapping.compactMap { createMetadataItem(for:$0, value:$1) }
    }


    private func createMetadataItem(for identifier: AVMetadataIdentifier,
                                    value: Any) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.identifier = identifier
        item.value = value as? NSCopying & NSObjectProtocol
        // Specify "und" to indicate an undefined language.
        item.extendedLanguageTag = "und"
        return item.copy() as! AVMetadataItem
    }
}
