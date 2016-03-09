//
//  MotionManager.swift
//  Motions
//
//  Created by Admin on 21/10/15.
//  Copyright © 2015 antonShcherba. All rights reserved.
//

import Foundation
import CoreMotion
import CoreData



class MotionManager: CMMotionManager {
        
    /// represents device motion frequency
    let motionFrequency = 0.05

    /// represent device motion measures
    var measures = [Measure]()
    
    /// represents records count
//    var recordsCount = 0
    
    /// represents windows size for fuzzy logic
    let window = 20
    
    /// represent SMA for fuzzy logic
    var movingAverage: MovingAverage
    
    private var offset: NSTimeInterval? = nil
    
    static let sharedInstance = MotionManager()
    
    override init() {
        
        if self.offset == nil {
            let bootTime = NSProcessInfo.processInfo().systemUptime
            self.offset = NSDate().timeIntervalSince1970 - bootTime
        }
        
        movingAverage = MovingAverage(period: UInt32(self.window))
//        showsDeviceMovementDisplay = true
        super.init()
    }

    func startDeviceUpdates() {
        deviceMotionUpdateInterval = motionFrequency
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .UserInitiated
        
        startDeviceMotionUpdatesUsingReferenceFrame(.XMagneticNorthZVertical, toQueue: queue,
            withHandler: { [unowned self](device: CMDeviceMotion?, error: NSError?) -> Void in
                
            guard let deviceMotion = device else {
                return
            }
                
            let context = DatabaseManager.sharedInstance.context
            let entity = NSEntityDescription.entityForName("Measure", inManagedObjectContext: context)
            let measure = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: nil) as! Measure
            
            measure.time = deviceMotion.timestamp + self.offset!
            measure.xAccel = deviceMotion.userAcceleration.x
            measure.yAccel = deviceMotion.userAcceleration.y
            measure.zAccel = deviceMotion.userAcceleration.z
            
            measure.xRot = deviceMotion.rotationRate.x
            measure.yRot = deviceMotion.rotationRate.y
            measure.zRot = deviceMotion.rotationRate.z
            
            measure.roll = deviceMotion.attitude.roll
            measure.pitch = deviceMotion.attitude.pitch
            measure.yaw = deviceMotion.attitude.yaw
            
            let avgAccel = sqrt(measure.xAccel * measure.xAccel +
                measure.yAccel * measure.yAccel +
                measure.zAccel * measure.zAccel)
            self.movingAverage.add(avgAccel)
            measure.avgAccel = self.movingAverage.avg()
            
            let measuresCount = self.measures.count
            let prevIndex = measuresCount - self.window
            if prevIndex > 0 {
                let prevMeasure = self.measures[prevIndex]
                measure.pitchDiff = -prevMeasure.pitch
                prevMeasure.pitchDiff += measure.pitch
            }
            
            self.measures.append(measure)
//            self.recordsCount++
            })
    }
}