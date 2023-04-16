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

import Foundation

/// Basic protocol to force the quality level to be readable.
public protocol Readable {
    var readable: String { get }
}

/// Known quality levels for vods and livestreams.
public enum DeliveryKeyQualityLevel: String, Codable, Equatable, Readable {
    /// Used for vod
    case ql360p = "360-avc1"
    case ql480p = "480-avc1"
    case ql720p = "720-avc1"
    case ql1080p = "1080-avc1"
    /// Used for live streams
    case liveAbr = "live-abr"

    public static let defaultLevel = ql720p

    /// Known vod quality levels
    public static let vodCases: [DeliveryKeyQualityLevel] = [
        .ql360p,
        .ql480p,
        .ql720p,
        .ql1080p,
    ]

    /// Known livestream quality levels
    static let liveCases: [DeliveryKeyQualityLevel] = [
        .liveAbr,
    ]
    static let allCases: [DeliveryKeyQualityLevel] = [
        .ql360p,
        .ql480p,
        .ql720p,
        .ql1080p,
        .liveAbr,
    ]

    /// Variable to get the struct for a QualityLevel including a label for it.
    public var toQualityLevel: QualityLevel? {
        QualityLevel.knownLevels[readable]
    }

    /// A readable text for the quality level
    public var readable: String {
        switch self {
        case .ql360p:
            return "360p"
        case .ql480p:
            return "480p"
        case .ql720p:
            return "720p"
        case .ql1080p:
            return "1080p"
        case .liveAbr:
            return "Live"
        }
    }
}
