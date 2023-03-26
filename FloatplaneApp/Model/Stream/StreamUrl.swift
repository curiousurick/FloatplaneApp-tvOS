//
//  StreamUrl.swift
//  FloatplaneApp
//
//  Created by George Urick on 3/26/23.
//

import Foundation

struct StreamUrl {
    let url: URL
    
    init(deliveryKey: DeliveryKey, qualityLevelName: QualityLevelName, useDefault: Bool = true) {
        // If none provided, use the last (highest quality)
        let resourceData = deliveryKey.resource.data
        let options = resourceData.qualityLevelParams.params
        var qualityLevel = options[qualityLevelName.rawValue] ?? options[resourceData.qualityLevels.last!.name.rawValue]!

        let fileName = qualityLevel.filename
        let token = qualityLevel.accessToken
        let cdn = deliveryKey.cdn
        let fileNameKey = DeliveryKey.QualityLevelParams.Constants.FileNameKey
        let accessTokenKey = DeliveryKey.QualityLevelParams.Constants.AccessTokenKey
        let path = deliveryKey.resource.uri
            .replacing(fileNameKey, with: fileName)
            .replacing(accessTokenKey, with: token)
        
        let video = "\(cdn)\(path)"
        url = URL(string: video)!
    }
    
    
}
