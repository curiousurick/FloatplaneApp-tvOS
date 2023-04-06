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

public protocol Readable {
    var readable: String { get }
}

public enum DeliveryKeyQualityLevel: String, Codable, Equatable, Readable {
    // Used for vod
    case ql360p = "360-avc1"
    case ql480p = "480-avc1"
    case ql720p = "720-avc1"
    case ql1080p = "1080-avc1"
    // Used for live streams
    case liveAbr = "live-abr"
    
    public static let defaultLevel = ql720p
    
    public static let vodCases: [DeliveryKeyQualityLevel] = [
        .ql360p,
        .ql480p,
        .ql720p,
        .ql1080p
    ]
    static let liveCases: [DeliveryKeyQualityLevel] = [
        .liveAbr
    ]
    static let allCases: [DeliveryKeyQualityLevel] = [
        .ql360p,
        .ql480p,
        .ql720p,
        .ql1080p,
        .liveAbr
    ]
    
    public var toQualityLevel: QualityLevel {
        get {
            switch self {
            case .ql360p:
                return QualityLevel.Standard.ql360p
            case .ql480p:
                return QualityLevel.Standard.ql480p
            case .ql720p:
                return QualityLevel.Standard.ql720p
            case .ql1080p:
                return QualityLevel.Standard.ql1080p
            case .liveAbr:
                return QualityLevel.Standard.qlLive
            }
        }
    }
    
    public var index: Int {
        get {
            switch self {
            case .ql360p:
                return 0
            case .ql480p:
                return 1
            case .ql720p:
                return 2
            case .ql1080p:
                return 3
            case .liveAbr:
                return 4
            }
        }
    }
    
    public static func fromReadable(readable: String) -> DeliveryKeyQualityLevel? {
        vodCases.filter {
            $0.readable == readable
        }.first
    }
    
    public var readable: String {
        get {
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
}
