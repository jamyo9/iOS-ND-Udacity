//
//  CoreDataStack.swift
//  VirtualTourist
//
//  Created by Juan Alvarez on 1/8/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import CoreData

class CoreDataStack {
    
    // MARK:  - Properties
    private let model : NSManagedObjectModel
    private let coordinator : NSPersistentStoreCoordinator
    private let modelURL : NSURL
    private let dbURL : NSURL
    let context : NSManagedObjectContext
    
    class func sharedInstance() -> CoreDataStack {
        struct Static {
            static let instance = CoreDataStack(modelName: "VirtualTouristModel")
        }
        
        return Static.instance!
    }
    
    // MARK:  - Initializers
    init?(modelName: String){
        
        // Assumes the model is in the main bundle
        guard let modelURL = NSBundle.mainBundle().URLForResource(modelName, withExtension: "momd") else {
            print("Unable to find \(modelName)in the main bundle")
            return nil}
        
        self.modelURL = modelURL
        
        // Try to create the model from the URL
        guard let model = NSManagedObjectModel(contentsOfURL: modelURL) else{
            print("unable to create a model from \(modelURL)")
            return nil
        }
        self.model = model
        
        // Create the store coordinator
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // create a context and add connect it to the coordinator
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        
        
        
        // Add a SQLite store located in the documents folder
        let fm = NSFileManager.defaultManager()
        
        guard let  docUrl = fm.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first else{
            print("Unable to reach the documents folder")
            return nil
        }
        
        self.dbURL = docUrl.URLByAppendingPathComponent("VirtualTouristModel.sqlite")
        
        
        // Options for migration
        let options = [NSInferMappingModelAutomaticallyOption : true, NSMigratePersistentStoresAutomaticallyOption : true]
        
        do{
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: options)
            
        }catch{
            print("unable to add store at \(dbURL)")
        }
    }
    
    // MARK:  - Utils
    func addStoreCoordinator(storeType: String, configuration: String?, storeURL: NSURL, options : [NSObject : AnyObject]?) throws{
        try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: dbURL, options: nil)
    }
}


// MARK:  - Removing data
extension CoreDataStack  {
    
    func dropAllData() throws{
        // delete all the objects in the db. This won't delete the files, it will
        // just leave empty tables.
        try coordinator.destroyPersistentStoreAtURL(dbURL, withType:NSSQLiteStoreType , options: nil)
        
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
        
    }
}

// MARK:  - Save
extension CoreDataStack {
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func autoSave(delayInSeconds : Int){
        
        if delayInSeconds > 0 {
            do{
                try saveContext()
                print("Autosaving")
            }catch{
                print("Error while autosaving")
            }
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInNanoSeconds))
            
            dispatch_after(time, dispatch_get_main_queue(), {
                self.autoSave(delayInSeconds)
            })
            
        }
    }
}
