//
//  ResourceData.swift
//  FloatplaneApp-Models
//
//  Created by George Urick on 4/1/23.
//

import Foundation

public struct ResourceData: Decodable {
    private var qualityLevels: [DeliveryKeyQualityLevel : QualityLevelResourceData] = [:]
    public var options: [DeliveryKeyQualityLevel] = []
    
    enum CodingKeys: CodingKey {
        case qualityLevelParams
        case qualityLevels
    }
    
    public func getResource(qualitylevelName: DeliveryKeyQualityLevel?) -> QualityLevelResourceData? {
        guard let qualitylevelName = qualitylevelName else {
            return nil
        }
        return qualityLevels[qualitylevelName]
    }
    
    public func highestQuality() -> QualityLevelResourceData {
        guard let last = options.last,
              let lastLevel = qualityLevels[last] else {
            fatalError("ResourceData cannot be implemented without at least one level of quality")
        }
        return lastLevel
    }
    
    public func lowestQuality() -> QualityLevelResourceData {
        guard let first = options.first,
              let firstLevel = qualityLevels[first] else {
            fatalError("ResourceData cannot be implemented without at least one level of quality")
        }
        return firstLevel
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ResourceData.CodingKeys.self)
        let qualityLevelParams = try container.decode(QualityLevelParams.self, forKey: ResourceData.CodingKeys.qualityLevelParams)
        let qualityLevels = try container.decode([DecodedQualityLevel].self, forKey: ResourceData.CodingKeys.qualityLevels)
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
}
