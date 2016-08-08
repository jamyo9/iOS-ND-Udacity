//
//  Photo.swift
//  VirtualTourist
//

import UIKit
import Foundation
import CoreData


class Photo: NSManagedObject {

    struct Keys {
        static let ID = "id"
        static let Title = "title"
        static let URL = "url_m"
        static let Height = "height_m"
        static let Width = "width_m"
        static let Owner = "owner"
        static let TotalPages = "pages"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        ImageCache.sharedInstance.deleteImage(id!)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        id = dictionary[Keys.ID] as? String
        title = dictionary[Keys.Title] as? String
        url = dictionary[Keys.URL] as? String
        height = dictionary[Keys.Height] as? String
        width = dictionary[Keys.Width] as? String
        owner = dictionary[Keys.Owner] as? String
    }
}
