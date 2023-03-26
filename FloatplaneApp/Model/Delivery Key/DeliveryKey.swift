//
//  DeliveryKey.swift
//  FloatplaneApp
//
//  Created by George Urick on 3/25/23.
//

import Foundation

struct DeliveryKey: Decodable {
    struct QualityLevelParams: Decodable {
        struct Constants {
            static let FileNameKey = "{qualityLevelParams.2}"
            static let AccessTokenKey = "{qualityLevelParams.4}"
        }
        
        struct QualityLevelParam {
            let filename: String
            let accessToken: String
        }
        let params: [String: QualityLevelParam]
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: ParamsKey.self)
            
            var params: [String: QualityLevelParam] = [:]
            for key in container.allKeys {
                let nested = try container.nestedContainer(keyedBy: ParamsKey.self, forKey: key)
                let fileName = try nested.decode(String.self, forKey: .fileName)
                let accessToken = try nested.decode(String.self, forKey: .accessToken)
                params[key.stringValue] = QualityLevelParam(filename: fileName, accessToken: accessToken)
            }
            self.params = params
        }
        
        struct ParamsKey: CodingKey {
            var stringValue: String
            init?(stringValue: String) {
                self.stringValue = stringValue
            }
            var intValue: Int? { return nil }
            init?(intValue: Int) { return nil }
            
            static let fileName = ParamsKey(stringValue: "2")!
            static let accessToken = ParamsKey(stringValue: "4")!
        }
    }
    struct QualityLevel: Decodable {
        let codecs: String
        let height: UInt64
        let label: String
        let mimeType: String
        let name: QualityLevelName
        let order: UInt64
        let width: UInt64
    }
    struct ResourceData: Decodable {
        let qualityLevelParams: QualityLevelParams
        let qualityLevels: [QualityLevel]
    }
    struct Resource: Decodable {
        let data: ResourceData
        let uri: String
    }
    let cdn: String
    let resource: Resource
    let strategy: String
}
