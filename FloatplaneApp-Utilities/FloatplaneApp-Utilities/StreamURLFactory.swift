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
import FloatplaneApp_Models

public protocol StreamURLFactory {
    func create(deliveryKey: DeliveryKey, qualityLevel: QualityLevel) -> URL
}

public class StreamURLFactoryImpl: StreamURLFactory {
    private let logger = Log4S()

    public init() {}

    public func create(deliveryKey: DeliveryKey, qualityLevel: QualityLevel) -> URL {
        // If none provided, use the last (highest quality)
        let resourceData = deliveryKey.resource.data
        let qualityLevelName = DeliveryKeyQualityLevel.vodCases.first { $0.readable == qualityLevel.label }
        var chosenQualityLevel: QualityLevelResourceData!
        if let foundQualityLevel = resourceData.getResource(qualitylevelName: qualityLevelName) {
            chosenQualityLevel = foundQualityLevel
        }
        else {
            logger
                .error(
                    "Did not find a valid quality level resource for the chosen quality level. \(qualityLevel.label)"
                )
            chosenQualityLevel = resourceData.lowestQuality()
        }

        let fileName = chosenQualityLevel.fileName
        let token = chosenQualityLevel.accessToken
        let cdn = deliveryKey.cdn
        let fileNameKey = QualityLevelParams.Constants.FileNameKey
        let accessTokenKey = QualityLevelParams.Constants.AccessTokenKey
        let path = deliveryKey.resource.uri
            .replacing(fileNameKey, with: fileName)
            .replacing(accessTokenKey, with: token)

        let video = "\(cdn)\(path)"
        return URL(string: video)!
    }

    public func create(deliveryKey: DeliveryKey) -> URL {
        let cdn = deliveryKey.cdn
        let path = deliveryKey.resource.uri
        let video = "\(cdn)\(path)"
        return URL(string: video)!
    }
}
