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
import Kenmore_Models
import Kenmore_Utilities
import Kenmore_Operations

extension AVPlayer {
    func updateItemMetadata(video: VideoMetadata) {
        var channelArt: URL!
        var channelName: String!
        if let channel = video.channel {
            channelArt = channel.icon.path
            channelName = channel.title
        }
        else {
            channelArt = video.creator.cover.path
            channelName = video.creator.title
        }

        // Small optimization to avoid channel name sitting just above title prefix.
        let title = video.title.replacing("\(channelName!): ", with: "")
        let description = video.description.html2String
        var mapping: [AVMetadataIdentifier: Any] = [
            .commonIdentifierTitle: title,
            .iTunesMetadataTrackSubTitle: channelName!,
            .commonIdentifierDescription: description,
        ]
        let metadata = mapping.compactMap { self.createMetadataItem(for: $0, value: $1) }
        DispatchQueue.main.async {
            self.currentItem?.externalMetadata = metadata
        }
        ImageGrabber.instance.grab(url: channelArt) { data in
            mapping[.commonIdentifierArtwork] = data as Any
            let metadata = mapping.compactMap { self.createMetadataItem(for: $0, value: $1) }
            DispatchQueue.main.async {
                self.currentItem?.externalMetadata = metadata
            }
        }
    }

    private func createMetadataItem(
        for identifier: AVMetadataIdentifier,
        value: Any
    ) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.identifier = identifier
        item.value = value as? NSCopying & NSObjectProtocol
        item.extendedLanguageTag = Locale.current.language.languageCode?.identifier
        return item.copy() as! AVMetadataItem
    }
}
