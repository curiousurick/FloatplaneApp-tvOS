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

/// Quality level for the purpose of selecting video quality inside a video.
public struct QualityLevel: Codable, Equatable {
    public let name: String
    public let width: UInt
    public let height: UInt
    public let label: String
    public let order: UInt

    public init(name: String, width: UInt, height: UInt, label: String, order: UInt) {
        self.name = name
        self.width = width
        self.height = height
        self.label = label
        self.order = order
        QualityLevel.knownLevels[label] = self
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        width = try container.decode(UInt.self, forKey: .width)
        height = try container.decode(UInt.self, forKey: .height)
        label = try container.decode(String.self, forKey: .label)
        order = try container.decode(UInt.self, forKey: .order)
        QualityLevel.knownLevels[label] = self
    }

    public var resolution: CGSize {
        CGSize(width: CGFloat(width), height: CGFloat(height))
    }

    public static var knownLevels: [String: QualityLevel] = [:]
}
