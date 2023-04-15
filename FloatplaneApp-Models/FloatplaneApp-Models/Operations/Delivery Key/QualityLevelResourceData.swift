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

/// The object which is in the JSON result from the delivery key API.
/// Contains information about the stream.
public class DecodedQualityLevel: Codable, Equatable {
    public let codecs: String?
    public let height: UInt64?
    public let label: String?
    public let mimeType: String
    public let name: DeliveryKeyQualityLevel
    public let order: UInt64
    public let width: UInt64?

    public init(
        codecs: String?,
        height: UInt64?,
        label: String?,
        mimeType: String,
        name: DeliveryKeyQualityLevel,
        order: UInt64,
        width: UInt64?
    ) {
        self.codecs = codecs
        self.height = height
        self.label = label
        self.mimeType = mimeType
        self.name = name
        self.order = order
        self.width = width
    }

    public static func == (lhs: DecodedQualityLevel, rhs: DecodedQualityLevel) -> Bool {
        lhs.codecs == rhs.codecs &&
            lhs.height == rhs.height &&
            lhs.label == rhs.label &&
            lhs.mimeType == rhs.mimeType &&
            lhs.name == rhs.name &&
            lhs.order == rhs.order &&
            lhs.width == rhs.width
    }
}

/// Built on the Decoded QualityLevel, includes the filename and accessToken.
public class QualityLevelResourceData: DecodedQualityLevel {
    public let fileName: String
    public let accessToken: String

    public init(
        decodedQualityLevel: DecodedQualityLevel,
        fileName: String,
        accessToken: String
    ) {
        self.fileName = fileName
        self.accessToken = accessToken
        super.init(
            codecs: decodedQualityLevel.codecs,
            height: decodedQualityLevel.height,
            label: decodedQualityLevel.label,
            mimeType: decodedQualityLevel.mimeType,
            name: decodedQualityLevel.name,
            order: decodedQualityLevel.order,
            width: decodedQualityLevel.width
        )
    }

    public static func == (lhs: QualityLevelResourceData, rhs: QualityLevelResourceData) -> Bool {
        lhs.codecs == rhs.codecs &&
            lhs.height == rhs.height &&
            lhs.label == rhs.label &&
            lhs.mimeType == rhs.mimeType &&
            lhs.name == rhs.name &&
            lhs.order == rhs.order &&
            lhs.width == rhs.width &&
            lhs.fileName == rhs.fileName &&
            lhs.accessToken == rhs.accessToken
    }

    required init(from _: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
