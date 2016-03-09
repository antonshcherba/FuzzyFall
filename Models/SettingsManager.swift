//
//  SettingsManager.swift
//  Motions
//
//  Created by Admin on 08/01/16.
//  Copyright © 2016 antonShcherba. All rights reserved.
//



import Foundation

enum TimeUnits: Int {
    case Seconds=0, Minutes
    
    func stringValue() -> String {
        switch self {
        case .Seconds:
            return "Seconds"
        case .Minutes:
            return "Minutes"
        }
    }
    
    init?(string: String) {
        switch string {
        case "Seconds":
            self = .Seconds
        case "Minutes":
            self = .Minutes
        default:
            return nil
        }
    }
}

enum UserAlertType: Int {
    case SoundAlert=1
    case VibroAlert
    
}

class SettingsManager {
    
    static let sharedInstance = SettingsManager()
    
    var detectorSettings: DetectorSettings {
        return user.detectorSettings!
    }
    
    var userSettings: UserSettings {
        return user.userSettings!
    }
    
    let context = DatabaseManager.sharedInstance.context
    
    var user: User!
    
    init() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let username = userDefaults.stringForKey("loggedUserName") {
            let database = DatabaseManager.sharedInstance
            
            if let user = database.fetchFirst(User.entity, query: "%K LIKE %@", args: ["username", username]) as? User {
                self.user = user
            }
        }
    }
    
    func setDefaultDetectorSettings() {
        let settings = detectorSettings
        
        settings.activityDuration = 10
        settings.activityUnits = "Seconds"
        settings.userAlertEnabled = true
        settings.userAlertSound = false
        settings.userAlertVibration = true
        settings.emergencyPhone = kApplication.phone
        settings.emergencyEmail = kApplication.email
    }
    
    func saveDetectorSettings() {
        DatabaseManager.sharedInstance.saveSettings(detectorSettings)
        NSNotificationCenter.defaultCenter().postNotificationName("settingsChangedNotification",
            object: self, userInfo: ["detectorSettings":detectorSettings])
    }
    
    func saveUserSettings() {
        DatabaseManager.sharedInstance.saveSettings(userSettings)
        NSNotificationCenter.defaultCenter().postNotificationName("settingsChangedNotification",
            object: self, userInfo: ["userSettings":userSettings])
    }
    
    func saveSettings() {
        saveUserSettings()
        saveDetectorSettings()
    }
}