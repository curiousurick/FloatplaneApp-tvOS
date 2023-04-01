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

struct LiveDeliveryKey: Decodable {
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
    class LiveDecodedQualityLevel: Decodable {
        let label: String?
        let mimeType: String
        let name: LiveDeliveryKeyQualityLevel
        let order: UInt64
        
        init(
            label: String,
            mimeType: String,
            name: LiveDeliveryKeyQualityLevel,
            order: UInt64
        ) {
            self.label = label
            self.mimeType = mimeType
            self.name = name
            self.order = order
        }
        
        init(original: LiveDecodedQualityLevel) {
            self.label = original.label
            self.mimeType = original.mimeType
            self.name = original.name
            self.order = original.order
        }
    }
    class LiveQualityLevelResourceData: LiveDecodedQualityLevel {
        let fileName: String
        let accessToken: String
        
        init(
            decodedQualityLevel: LiveDecodedQualityLevel,
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
    
    struct ResourceData: Decodable {
        private var qualityLevels: [LiveDeliveryKeyQualityLevel : LiveQualityLevelResourceData] = [:]
        private var options: [LiveDeliveryKeyQualityLevel] = []
        
        enum CodingKeys: CodingKey {
            case qualityLevelParams
            case qualityLevels
        }
        
        func getResource(qualitylevelName: LiveDeliveryKeyQualityLevel) -> LiveQualityLevelResourceData? {
            return qualityLevels[qualitylevelName]
        }
        
        func highestQuality() -> LiveQualityLevelResourceData {
            guard let last = options.last,
                  let lastLevel = qualityLevels[last] else {
                fatalError("ResourceData cannot be implemented without at least one level of quality")
            }
            return lastLevel
        }
        
        func lowestQuality() -> LiveQualityLevelResourceData {
            guard let first = options.first,
                  let firstLevel = qualityLevels[first] else {
                fatalError("ResourceData cannot be implemented without at least one level of quality")
            }
            return firstLevel
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<LiveDeliveryKey.ResourceData.CodingKeys> = try decoder.container(keyedBy: LiveDeliveryKey.ResourceData.CodingKeys.self)
            let qualityLevelParams = try container.decode(LiveDeliveryKey.QualityLevelParams.self, forKey: LiveDeliveryKey.ResourceData.CodingKeys.qualityLevelParams)
            let qualityLevels = try container.decode([LiveDeliveryKey.LiveDecodedQualityLevel].self, forKey: LiveDeliveryKey.ResourceData.CodingKeys.qualityLevels)
            for level in qualityLevels {
                options.append(level.name)
                // There are some cases where qualityLevelParams are empty because there's one option
                // Like live streams
                if let param = qualityLevelParams.params[level.name.rawValue] {
                    self.qualityLevels[level.name] = LiveQualityLevelResourceData(
                        decodedQualityLevel: level,
                        fileName: param.filename,
                        accessToken: param.accessToken
                    )
                }
            }
        }
    }
    struct Resource: Decodable {
        let data: ResourceData
        let uri: String
    }
    let cdn: String
    let resource: Resource
    let strategy: String
}
