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

public struct PlaybackSpeed: Equatable {
    public let value: Float
    public let readable: String

    public static let zeroPoint5 = PlaybackSpeed(value: 0.5, readable: "0.5x")
    public static let zeroPoint75 = PlaybackSpeed(value: 0.75, readable: "0.75x")
    public static let normal = PlaybackSpeed(value: 1.0, readable: "1x")
    public static let onePoint25 = PlaybackSpeed(value: 1.25, readable: "1.25x")
    public static let onePoint5 = PlaybackSpeed(value: 1.5, readable: "1.5x")
    public static let onePoint75 = PlaybackSpeed(value: 1.75, readable: "1.75x")
    public static let twoPoint0 = PlaybackSpeed(value: 2.0, readable: "2x")

    public static let allCases: [PlaybackSpeed] = [
        .zeroPoint5,
        .zeroPoint75,
        .normal,
        .onePoint25,
        .onePoint5,
        .onePoint75,
        .twoPoint0,
    ]
}
