//
//  UserAlert.swift
//  Motions
//
//  Created by Admin on 08/01/16.
//  Copyright © 2016 antonShcherba. All rights reserved.
//

private let kSystemSoundID_Alarm: UInt32 = 1304

import Foundation
import AVFoundation

class UserAlert : NSObject {
    
    var enabled = true
    
    var soundEnabled = true
    
    var vibrationEnabled = true
    
    var vibrationTimer: NSTimer = NSTimer()
    
    var endVibrationTimer: NSTimer = NSTimer()
    
    var soundTimer: NSTimer = NSTimer()
    
    var endSoundTimer: NSTimer = NSTimer()
    
    var duration = 10
    
    var vibrationStep = 2
    
    var alertViewController: UIAlertController?
    
    func configure() {
        let settings = SettingsManager().detectorSettings
        
        enabled = settings.userAlertEnabled
        soundEnabled = settings.userAlertSound
        vibrationEnabled = settings.userAlertVibration
    }
    
    func fallAlert() {
        configure()
        
        if !enabled {
            NSNotificationCenter.defaultCenter().postNotificationName(kNotification.trueFall, object: nil)
        }
        
        let alertDate = NSDate()
        alertViewController = UIAlertController(title: "Fall Detected", message: "Fall detected \(alertDate)", preferredStyle: UIAlertControllerStyle.Alert)
        alertViewController!.addAction(UIAlertAction(title: "Dismis", style: .Cancel, handler: { (action) -> Void in
            self.stopTimers()
            
            NSNotificationCenter.defaultCenter().postNotificationName(kNotification.falseFall, object: nil)
        }))
        
        if vibrationEnabled {
            endVibrationTimer = NSTimer.scheduledTimerWithTimeInterval(Double(duration),
                target: self, selector: Selector("stopAlert"), userInfo: nil, repeats: false)
            vibrationTimer = NSTimer.scheduledTimerWithTimeInterval(Double(vibrationStep),
                target: self, selector: Selector("vibrate"), userInfo: nil, repeats: true)
        }
        
        if soundEnabled {
            endSoundTimer = NSTimer.scheduledTimerWithTimeInterval(Double(duration),
                target: self, selector: Selector("stopAlert"), userInfo: nil, repeats: false)
            soundTimer = NSTimer.scheduledTimerWithTimeInterval(Double(vibrationStep),
                target: self, selector: Selector("playSound"), userInfo: nil, repeats: true)
        }
        
        let windows = UIApplication.sharedApplication().windows
//        let active = windows.filter( {($0.rootViewController?.isBeingPresented())!})
//        active.first?.rootViewController?.presentViewController(alertViewController!, animated: true, completion: nil)
        let active = windows.filter {$0.rootViewController is UINavigationController}
        active.first?.rootViewController?.presentViewController(alertViewController!, animated: true, completion: nil)
    }
    
    func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    func  playSound() {
        AudioServicesPlaySystemSound(kSystemSoundID_Alarm)
    }
    
    func stopTimers() {
        endVibrationTimer.invalidate()
        endSoundTimer.invalidate()
        vibrationTimer.invalidate()
        soundTimer.invalidate()
    }
    
    func stopAlert() {
        stopTimers()
        if let alert = alertViewController {
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        NSNotificationCenter.defaultCenter().postNotificationName(kNotification.trueFall, object: nil)
    }
}