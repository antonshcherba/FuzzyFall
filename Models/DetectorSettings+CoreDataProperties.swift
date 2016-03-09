//
//  DetectorSettings+CoreDataProperties.swift
//  
//
//  Created by Admin on 29/02/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension DetectorSettings {

    @NSManaged var activityDuration: Int64
    @NSManaged var activityUnits: String?
    @NSManaged var emergencyEmail: String?
    @NSManaged var emergencyPhone: String?
    @NSManaged var userAlertEnabled: Bool
    @NSManaged var userAlertSound: Bool
    @NSManaged var userAlertVibration: Bool
    @NSManaged var user: User?

}
