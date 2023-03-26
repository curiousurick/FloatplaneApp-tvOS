//
//  QualityLevel.swift
//  FloatplaneApp
//
//  Created by George Urick on 3/26/23.
//

import Foundation

enum QualityLevelName: String, Decodable {
    case ql360p = "360-avc1"
    case ql480p = "480-avc1"
    case ql720p = "720-avc1"
    case ql1080p = "1080-avc1"
    
    static let defaultLevel = ql720p
}
