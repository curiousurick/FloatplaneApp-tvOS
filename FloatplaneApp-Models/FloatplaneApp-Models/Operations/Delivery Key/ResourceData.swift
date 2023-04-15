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

/// Contains information about the resource. Provides the list of quality levels and information about each level.
public struct ResourceData: Codable, Equatable {
    private var qualityLevels: [DeliveryKeyQualityLevel: QualityLevelResourceData] = [:]
    public var options: [DeliveryKeyQualityLevel] = []

    public init(
        qualityLevels: [DeliveryKeyQualityLevel: QualityLevelResourceData],
        options: [DeliveryKeyQualityLevel]
    ) {
        self.qualityLevels = qualityLevels
        self.options = options
    }

    enum CodingKeys: CodingKey {
        case qualityLevelParams
        case qualityLevels
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ResourceData.CodingKeys.self)
        let qualityLevelParams = try container.decode(QualityLevelParams.self, forKey: .qualityLevelParams)
        let qualityLevels = try container.decode([DecodedQualityLevel].self, forKey: .qualityLevels)
        for level in qualityLevels {
            options.append(level.name)
            // There are some cases where qualityLevelParams are empty because there's one option
            // Like live streams
            if let param = qualityLevelParams.params[level.name.rawValue] {
                self.qualityLevels[level.name] = QualityLevelResourceData(
                    decodedQualityLevel: level,
                    fileName: param.filename,
                    accessToken: param.accessToken
                )
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ResourceData.CodingKeys.self)
        var qualityLevelParamMap: [String: QualityLevelParams.QualityLevelParam] = [:]
        var decodedQualityLevels: [DecodedQualityLevel] = []
        for option in options {
            guard let qualityLevelResourceData = qualityLevels[option] else {
                continue
            }
            qualityLevelParamMap[option.rawValue] = QualityLevelParams.QualityLevelParam(
                filename: qualityLevelResourceData.fileName,
                accessToken: qualityLevelResourceData.accessToken
            )
            decodedQualityLevels.append(qualityLevelResourceData as DecodedQualityLevel)
        }
        let qualityLevelParams = QualityLevelParams(params: qualityLevelParamMap)
        try container.encode(qualityLevelParams, forKey: .qualityLevelParams)
        try container.encode(decodedQualityLevels, forKey: .qualityLevels)
    }
}

/// Getter helpers.
public extension ResourceData {
    func getResource(qualitylevelName: DeliveryKeyQualityLevel?) -> QualityLevelResourceData? {
        guard let qualitylevelName = qualitylevelName else {
            return nil
        }
        return qualityLevels[qualitylevelName]
    }

    func highestQuality() -> QualityLevelResourceData {
        guard let last = options.last,
              let lastLevel = qualityLevels[last] else {
            fatalError("ResourceData cannot be implemented without at least one level of quality")
        }
        return lastLevel
    }

    func lowestQuality() -> QualityLevelResourceData {
        guard let first = options.first,
              let firstLevel = qualityLevels[first] else {
            fatalError("ResourceData cannot be implemented without at least one level of quality")
        }
        return firstLevel
    }
}
