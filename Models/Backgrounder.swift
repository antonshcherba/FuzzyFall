//
//  Backgrounder.swift
//  FuzzyFall
//
//  Created by Admin on 12/01/16.
//  Copyright © 2016 antonShcherba. All rights reserved.
//

import Foundation
import CoreTelephony
import CoreLocation
import AVFoundation

class Backgounder: NSObject {
    
    static let sharedInstance = Backgounder()
    
    private var callCenter = CTCallCenter()
    
    private var player: AVAudioPlayer?
    
    private var locationManager = CLLocationManager()
    
    override init() {
    
        super.init()
        
        callCenter.callEventHandler = block
    }
    
    func start() {
        runAudio()
    }
    
    func stop() {
        stopAudio()
    }
    
    func block (call:CTCall!) {
        
        switch call.callState {
            
        case CTCallStateDialing,CTCallStateIncoming:
            let app = UIApplication.sharedApplication()
            var background_task = UIBackgroundTaskInvalid
            
            background_task = app.beginBackgroundTaskWithExpirationHandler {
                self.locationManager.startUpdatingLocation()
                while true {
                    NSThread.sleepForTimeInterval(1)
                }
                app.endBackgroundTask(background_task)
            }
            
        case CTCallStateDisconnected:
            locationManager.stopUpdatingLocation()
            
        default:
            break
        }
    }
    
    func runAudio() {
        do {
            try AVAudioSession.sharedInstance()
                .setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: .MixWithOthers)
        } catch let error {
            print("Error occured: \(error)")
        }
        
        do {
            player = try AVAudioPlayer(contentsOfURL: NSBundle.mainBundle().URLForResource("1min", withExtension: "mp3")!)
        } catch let error {
            print("Error: \(error)")
        }
        
        player?.numberOfLoops = -1
        player?.play()
    }
    
    func stopAudio() {
        player?.stop()
    }
    
    func audioInterrupted(notification: NSNotification) {
        let type = notification.userInfo![AVAudioSessionInterruptionTypeKey] as! AVAudioSessionInterruptionType
        
        switch type {
        case .Began:
            player?.stop()
        case .Ended:
            player?.play()
        }
    }
}