//
//  CallChecker.swift
//  Motions
//
//  Created by Admin on 27/10/15.
//  Copyright © 2015 antonShcherba. All rights reserved.
//

import Foundation
import CoreTelephony

class CallChecker {
    
    let callCenter: CTCallCenter
    
    var userTalks = false
    
    var isChecking = false
    
    init() {
        callCenter = CTCallCenter()
    }
    
    func startChecking() {
        if isChecking {
            return
        }
        
        isChecking = true
        callCenter.callEventHandler = {[unowned self] (call: CTCall!) in
            switch call.callState {
            case CTCallStateIncoming, CTCallStateConnected:
                self.userTalks = true
            case CTCallStateDisconnected:
                self.userTalks = false
            default:
                break
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(kNotification.userCalls, object: call!)
            
        }
    }
    
    func stopChecking() {
        isChecking = false
        callCenter.callEventHandler = nil
    }
}