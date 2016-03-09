//
//  UserSettings+CoreDataProperties.swift
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

extension UserSettings {

    @NSManaged var lastName: String?
    @NSManaged var firstName: String?
    @NSManaged var user: User?

}
