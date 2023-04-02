//
//  QualityLevelResourceData.swift
//  FloatplaneApp-Models
//
//  Created by George Urick on 4/1/23.
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
