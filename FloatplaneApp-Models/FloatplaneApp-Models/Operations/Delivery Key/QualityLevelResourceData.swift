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

public class DecodedQualityLevel: Decodable {
    public let codecs: String?
    public let height: UInt64?
    public let label: String?
    public let mimeType: String
    public let name: DeliveryKeyQualityLevel
    public let order: UInt64
    public let width: UInt64?
    
    init(
        codecs: String?,
        height: UInt64?,
        label: String,
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
    
    public init(original: DecodedQualityLevel) {
        self.codecs = original.codecs
        self.height = original.height
        self.label = original.label
        self.mimeType = original.mimeType
        self.name = original.name
        self.order = original.order
        self.width = original.width
    }
}
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
        super.init(original: decodedQualityLevel)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
