//
//  UserSettings.swift
//  FloatplaneApp
//
//  Created by George Urick on 3/26/23.
//

import Foundation

class UserSettings {
    
    private let QualitySettingsKey = "com.georgie.floatplane.QualitySettings"
    private let userDefaults = UserDefaults.standard
    
    static let instance = UserSettings()
    
    private init() { }
    
    var qualitySettings: QualityLevelName {
        get {
            if let savedValue = userDefaults.value(forKey: QualitySettingsKey) as? QualityLevelName {
                return savedValue
            }
            // First time use default
            return QualityLevelName.defaultLevel
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: QualitySettingsKey)
        }
    }
    
    
}
