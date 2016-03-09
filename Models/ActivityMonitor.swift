//
//  File.swift
//  Motions
//
//  Created by Admin on 05/01/16.
//  Copyright © 2016 antonShcherba. All rights reserved.
//

import Foundation
import CoreTelephony
import CoreFoundation

class ActivityMonitor: NSObject {
    
    var monitorTimer: NSTimer = NSTimer()
    
    let motionManager = MotionManager.sharedInstance
    
    let callChecker = CallChecker()
    
    var duration = 0
    
    var isActive = false
    
    private var startIndex = 0
    
    private var stopIndex = 0
    
    private var lockObserver: UnsafePointer<Void>!
    
    private let accelThreshold = 0.2
    
    private let rollThreshold = 0.2
    
    private let pitchThreshold = 0.2
    
    private let yawThreshold = 0.2
    
    static let sharedInstance = ActivityMonitor()
    
    private let activityQueue = dispatch_queue_create(
        "com.antonShcherba.Fall.activityQueue", DISPATCH_QUEUE_SERIAL)
    
    override init() {
        
        super.init()
    }
    
    func startMonitoring(fromIndex index:Int) {
        if isActive {
            return
        } else {
            isActive = true
        }
        
        let settings = SettingsManager.sharedInstance.detectorSettings
        duration = Int(settings.activityDuration)
        let units = TimeUnits(string: settings.activityUnits!)
        duration = duration.toSeconds(units!)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userCalled:", name: kNotification.userCalls, object: nil)
        
        callChecker.startChecking()
        startLockMonitoring()
        startMotionMonitoring(index)
    }
    
    func stopMonitoring(msg: String=kNotification.userActive) {
        if isActive == false {
            return
        }
        
        isActive = false
        monitorTimer.invalidate()
        
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().postNotificationName(msg, object: nil)
        }
        NSNotificationCenter.defaultCenter().removeObserver(self)
        CFNotificationCenterRemoveEveryObserver(CFNotificationCenterGetDarwinNotifyCenter(), lockObserver)
    }
    
    private func startMotionMonitoring(fromIndex:Int) {
        startIndex = fromIndex+10
        dispatch_async(dispatch_get_main_queue()) {
            self.monitorTimer = NSTimer.scheduledTimerWithTimeInterval(Double(self.duration),
                target: self, selector: Selector("stopMotionMonitoring"), userInfo: nil, repeats: false)
        }
        
        
    }
    
    func stopMotionMonitoring() {
        
        stopIndex = motionManager.measures.count
        let arr = Array(motionManager.measures[startIndex...stopIndex-1])
        
        dispatch_async(self.activityQueue) { [unowned self] () -> Void in
            let sdAccel = self.standardDeviation(arr.map {
                pow($0.xAccel,2) +
                    pow($0.yAccel,2) +
                    pow($0.zAccel,2)
                })
            let sdRoll = self.standardDeviation(arr.map { $0.roll })
            let sdPitch = self.standardDeviation(arr.map { $0.pitch })
            let sdYaw = self.standardDeviation(arr.map { $0.yaw })
            
            print("accel: \(sdAccel)\nroll: \(sdRoll)\npitch: \(sdPitch)\nsdYaw: \(sdYaw)")
            if sdAccel < self.accelThreshold &&
                sdRoll < self.rollThreshold &&
                sdPitch < self.pitchThreshold &&
                sdYaw < self.yawThreshold {
                    self.stopMonitoring(kNotification.userNotActive)
            } else {
                self.stopMonitoring(kNotification.userActive)
            }
        }
    }
    
    func userCalled(notification: NSNotification) {
        let callState = notification.object as! String
        
        switch callState {
            
        case CTCallStateDialing,
        CTCallStateConnected,
        CTCallStateDisconnected:
            monitorTimer.invalidate()
            stopMonitoring(kNotification.userActive)
            
        default:
            break
        }
    }
    
    func startLockMonitoring() {
        lockObserver = UnsafePointer<Void>(Unmanaged.passUnretained(self).toOpaque())
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
            lockObserver,
            { (_, lockObserver, name, _, _) -> Void in
                let mySelf = Unmanaged<ActivityMonitor>.fromOpaque(COpaquePointer(lockObserver)).takeUnretainedValue()
                mySelf.stopMonitoring()
            },
            "com.apple.iokit.hid.displayStatus",
            nil,
            .DeliverImmediately)
    }
    
    func standardDeviation(arr : [Double]) -> Double {
        let length = Double(arr.count)
        let avg = arr.reduce(0, combine: {$0 + $1}) / length
        let sumOfSquaredAvgDiff = arr.map { pow($0 - avg, 2.0)}.reduce(0, combine: {$0 + $1})
        return sqrt(sumOfSquaredAvgDiff / length)
    }
}