//
//  User+CoreDataProperties.swift
//  
//
//  Created by Admin on 28/02/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var username: String?
    @NSManaged var password: String?
    @NSManaged var userSettings: UserSettings?
    @NSManaged var detectorSettings: DetectorSettings?

}
