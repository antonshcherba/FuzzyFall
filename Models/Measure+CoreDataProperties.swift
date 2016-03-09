//
//  Measure+CoreDataProperties.swift
//  
//
//  Created by Admin on 31/10/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Measure {

    @NSManaged var avgAccel: Double
    @NSManaged var pitchDiff: Double
    @NSManaged var pitch: Double
    @NSManaged var roll: Double
    @NSManaged var startTime: Double
    @NSManaged var time: Double
    @NSManaged var xAccel: Double
    @NSManaged var xRot: Double
    @NSManaged var yAccel: Double
    @NSManaged var yaw: Double
    @NSManaged var yRot: Double
    @NSManaged var zAccel: Double
    @NSManaged var zRot: Double
    @NSManaged var date: NSTimeInterval

}
