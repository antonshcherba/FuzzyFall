//
//  MainModel.swift
//  Motions
//
//  Created by Admin on 08/01/16.
//  Copyright © 2016 antonShcherba. All rights reserved.
//

import Foundation
import CoreLocation
import skpsmtpmessage

class MainModel: NSObject, CLLocationManagerDelegate {
    
    /// represents MainModel singleton
    static let sharedInstance = MainModel()
    
    /// represents motion device manager
    let motionManager = MotionManager.sharedInstance//MotionManager()
        
    let databaseManager = DatabaseManager.sharedInstance
        
    let fallDetector = FallDetector.sharedInstance
    
    let userAlert = UserAlert()
    
    var locationManager: LocationManager?
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationFound:", name: kNotification.foundLocation, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "fallDetected:", name: kNotification.fallDetected, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "falseFallDetected:", name: kNotification.falseFall, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "trueFallDetected:", name: kNotification.trueFall, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func deviceMotionAvailable() -> Bool {
        return motionManager.deviceMotionAvailable
    }
    
    func fallDetectorActive() -> Bool {
        return motionManager.deviceMotionActive
    }
    
    func startDetecting() {
        motionManager.startDeviceUpdates()
        fallDetector.startDetecting()
    }
    
    func stopDetecting() {
        motionManager.stopDeviceMotionUpdates()
        fallDetector.stopDetecting()
    }
    
    func fallDetected(notification: NSNotification) {
        userAlert.fallAlert()
    }
    
    func falseFallDetected(notification: NSNotification) {
        startDetecting()
    }
    
    func trueFallDetected(notification: NSNotification) {
        if locationManager == nil {
            locationManager = LocationManager()
        }
        
        stopDetecting()
        locationManager?.findCurrentLocation()
    }
    
    func locationFound(notification: NSNotification) {
        locationManager = nil
        
        guard let userInfo = notification.userInfo else {
            return
        }
        
        if let location = userInfo["location"] as? CLLocation {
        }
        
        if let locationString = userInfo["locationString"] as? String {
            let emergency = Emergency()
            let settings = SettingsManager().userSettings
            
            let message = "\(settings.firstName!) \(settings.lastName!) " +
                "is in the dangerous situation.\n" + locationString + "Sent via FuzzyFall"
            emergency.notifyWith(message)
        }
    }
}