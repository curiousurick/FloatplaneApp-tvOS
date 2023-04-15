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

/// The parameters for constructing a stream URL for a given quality level.
/// Maps a quality level to the filename and access token
public struct QualityLevelParams: Codable, Equatable {
    public enum Constants {
        public static let FileNameKey = "{qualityLevelParams.2}"
        public static let AccessTokenKey = "{qualityLevelParams.4}"
    }

    /// The filename and access token for a given quality level.
    struct QualityLevelParam: Equatable {
        let filename: String
        let accessToken: String
    }

    let params: [String: QualityLevelParam]

    init(params: [String: QualityLevelParam]) {
        self.params = params
    }

    public init(from decoder: Decoder) throws {
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

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ParamsKey.self)
        for param in params {
            let keyParamCodingKey = ParamsKey(stringValue: param.key)
            var nested = container.nestedContainer(keyedBy: ParamsKey.self, forKey: keyParamCodingKey)
            try nested.encode(param.value.filename, forKey: .fileName)
            try nested.encode(param.value.accessToken, forKey: .accessToken)
        }
    }

    struct ParamsKey: CodingKey {
        var stringValue: String
        init(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int? { nil }
        init?(intValue _: Int) { nil }

        static let fileName = ParamsKey(stringValue: "2")
        static let accessToken = ParamsKey(stringValue: "4")
    }
}
