//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Juan Alvarez on 2/8/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var height: String?
    @NSManaged var id: String?
    @NSManaged var owner: String?
    @NSManaged var title: String?
    @NSManaged var url: String?
    @NSManaged var width: String?
    @NSManaged var image: NSData?
    @NSManaged var pin: Pin?

}
