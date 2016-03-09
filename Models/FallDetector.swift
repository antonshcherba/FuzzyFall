//
//  FallDetector.swift
//  Motions
//
//  Created by Admin on 30/11/15.
//  Copyright © 2015 antonShcherba. All rights reserved.
//

import Foundation
import CoreData

class FallDetector: NSObject {
    
    var detectorTimer: NSTimer = NSTimer()
    
    let fuzzySolver = FuzzySolver()
    
    var context: NSManagedObjectContext!
    
    let motionManager = MotionManager.sharedInstance
    
    let activityMonitor = ActivityMonitor.sharedInstance
    
    var detectedTime = 0.0
    
    var currentIndex = 0
    
    var firtsLoop = true
    
    let window = 20
    
    private let detectorQueue = dispatch_queue_create(
        "com.antonShcherba.Fall.detectQueue", DISPATCH_QUEUE_SERIAL)
    
    static let sharedInstance = FallDetector()
    
    override init() {
        
        super.init()
    }
    
    func startDetecting() {
        
        let frequency = MotionManager.sharedInstance.motionFrequency
        if firtsLoop {
            detectorTimer = NSTimer.scheduledTimerWithTimeInterval(frequency * Double(window) * 2.0,
                target: self, selector: Selector("startDetecting"), userInfo: nil, repeats: false)
        } else {
            detectorTimer = NSTimer.scheduledTimerWithTimeInterval(frequency,
                target: self, selector: Selector("detectFalls"), userInfo: nil, repeats: true)
        }
        firtsLoop = !firtsLoop
    }
    
    func stopDetecting() {
       
        detectorTimer.invalidate()
    }
    
    func detectFalls() {
        
        if motionManager.measures.count < window * 2 {
            return
        }
        
        if activityMonitor.isActive {
            return
        }
        
        dispatch_async(detectorQueue) {
            let currentIndex = self.currentIndex
            let measure = self.motionManager.measures[currentIndex]
            
            self.motionManager.measures.removeAtIndex(currentIndex)
            if round(measure.time) == self.detectedTime {
                return
            }
            
            if self.activityMonitor.isActive {
                return
            }
            
            let userFell = self.fuzzySolver.solve(measure)
            if userFell {
                
                self.stopDetecting()
                print("fall detected with fuzzy logic")
                self.detectedTime = round(measure.time)
                NSNotificationCenter.defaultCenter().addObserver(self,
                    selector: "activityDetected:", name: kNotification.userActive, object: nil)
                NSNotificationCenter.defaultCenter().addObserver(self,
                    selector: "activityDetected:", name: kNotification.userNotActive, object: nil)

                self.activityMonitor.startMonitoring(fromIndex: self.currentIndex)
            }
        }
    }
    
    func activityDetected(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        switch notification.name {
            
        case kNotification.userActive:
            print("Fall not deteceted after active")
            startDetecting()
            
        case kNotification.userNotActive:
            print("Fall deteceted after active")
            NSNotificationCenter.defaultCenter().postNotificationName(
                kNotification.fallDetected, object: nil)
            stopDetecting()
            
        default:
            break
        }
        
        self.currentIndex = self.motionManager.measures.count-window
        return
    }
    
    func falseFallDetected(notification: NSNotification) {
        startDetecting()
    }
}