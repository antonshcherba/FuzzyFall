//
//  DatabaseManager.swift
//  Motions
//
//  Created by Admin on 29/10/15.
//  Copyright © 2015 antonShcherba. All rights reserved.
//

import Foundation
import CoreData

class DatabaseManager {
    
    var context: NSManagedObjectContext
    
    init() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        context = appDelegate.managedObjectContext
    }
    
    static let sharedInstance = DatabaseManager()
    
//    func saveMeasures(measures: [Measure]) {
//        
//        for m in measures {
//            context.insertObject(m)
//        }
//        do {
//            try context.save()
//        } catch let error {
//            print("Database insert error: \(error)")
//        }
//    }
//    
//    func fetchMeasures() {
//        let fetchRequest = NSFetchRequest(entityName: "Measure")
//        
//        do {
//            let results = try context.executeFetchRequest(fetchRequest)
//            
//            for r in results as! [Measure] {
//                print(" \(r.time)")
//            }
//            
//        } catch let error {
//            print("Database select error: \(error)")
//        }
//    }
    
    func saveSettings(settings: DetectorSettings) {
        do {
            try settings.managedObjectContext?.save()
        } catch let error {
            print("Database save error: \(error)")
        }
    }
    
    func saveSettings(settings: UserSettings) {
        do {
            try settings.managedObjectContext?.save()
        } catch let error {
            print("Database save error: \(error)")
        }
    }
    
//    func fetchDetectorSettings() -> DetectorSettings? {
//        let fetchRequest = NSFetchRequest(entityName: "DetectorSettings")
//        do {
//            let results = try context.executeFetchRequest(fetchRequest)
//            return results.first as? DetectorSettings
//
//            
//        } catch let error {
//            print("Database select error: \(error)")
//        }
//        return nil
//    }
    
    func fetchFirst(entity: String) -> AnyObject? {
        let fetchRequest = NSFetchRequest(entityName: entity)
        do {
            let results = try context.executeFetchRequest(fetchRequest)
            return results.first
            
        } catch let error {
            print("Database select error: \(error)")
        }
        return nil
    }
    
    func fetchFirst(entity: String, query: String, args: [AnyObject]?) -> AnyObject? {
        let fetchRequest = NSFetchRequest(entityName: entity)
        fetchRequest.predicate = NSPredicate(format: query, argumentArray: args)
        
        do {
            let results = try context.executeFetchRequest(fetchRequest)
            
            return results.first
            
        } catch let error {
            print("Database select error: \(error)")
        }
        return nil
    }
    
    func createUser(username: String, password: String, first: String, last: String) -> User {
        let user = createUser(username, password: password)
        
        if let userSettings = user.userSettings {
            userSettings.firstName = first
            userSettings.lastName = last
        }
        
        return user
    }
    
    func createUser(username: String, password: String) -> User {
        let delegate =  UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext
        let entity = NSEntityDescription.entityForName(User.entity, inManagedObjectContext: context)
        
        let user = User(entity: entity!, insertIntoManagedObjectContext: context)
        user.username = username
        user.password = password
        
        return user
    }
    
    func createUserSettings(first: String, last: String) -> UserSettings {
        let delegate =  UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext
        let entity = NSEntityDescription.entityForName(UserSettings.entity, inManagedObjectContext: context)
        
        let settings = UserSettings(entity: entity!, insertIntoManagedObjectContext: context)
        settings.firstName = first
        settings.lastName = last
        
        return settings
    }
    
    func createDetectorSettings() -> DetectorSettings {
        let delegate =  UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext
        let entity = NSEntityDescription.entityForName(DetectorSettings.entity, inManagedObjectContext: context)
        let settings = DetectorSettings(entity: entity!, insertIntoManagedObjectContext: context)
        
        return settings
    }
}

