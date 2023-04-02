//
//  QualityLevelParams.swift
//  FloatplaneApp-Models
//
//  Created by George Urick on 4/1/23.
//

import Foundation

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
