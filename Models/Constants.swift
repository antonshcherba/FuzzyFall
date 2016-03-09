//
//  Constants.swift
//  FuzzyFall
//
//  Created by Admin on 12/01/16.
//  Copyright © 2016 antonShcherba. All rights reserved.
//

import Foundation

struct kNotification {
    
    static let userActive = "UserActiveNotification"
    
    static let userNotActive = "UserNotActiveNotification"
    
    static let userCalls = "UserCallsNotification"
    
    static let foundLocation = "FoundLocationNotification"
    
    static let fallDetected = "FallDetectedNotification"
    
    static let falseFall = "FalseFallNotification"
    
    static let trueFall = "TrueFallNotification"
}

struct kApplication {
    
    private static var configs: NSDictionary {
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let configsPath = NSBundle.mainBundle().pathForResource("Configs", ofType: "plist")!
        
        return NSDictionary(contentsOfFile: configsPath)!
    }
    
    static let phone = String(configs["phone"] as! NSString)
    
    static let email = String(configs["email"] as! NSString)
    
    static let password = String(configs["password"] as! NSString)
    
    static let host = String(configs["host"] as! NSString)
}