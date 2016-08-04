//
//  Pin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Juan Alvarez on 4/8/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var createdAt: NSDate?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var totalPages: NSNumber?
    @NSManaged var photos: NSSet?

}
