//
//  Pin.swift
//  Virtual Tourist
//

import Foundation
import CoreData


class Pin: NSManagedObject {
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(latitude: Double, longitude: Double, createdAt: NSDate, totalPages: NSNumber, context: NSManagedObjectContext){
        
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.latitude = latitude as NSNumber
        self.longitude = longitude as NSNumber
        self.createdAt = createdAt
        self.totalPages = totalPages
        self.photos = nil
    }
    
    init(latitude: Double, longitude: Double, createdAt: NSDate, totalPages: NSNumber, photos: Set<Photo>, context: NSManagedObjectContext){
        
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.latitude = latitude as NSNumber
        self.longitude = longitude as NSNumber
        self.createdAt = createdAt
        self.totalPages = totalPages
        self.photos = photos
    }
    
    func getLatitude() -> Double {
        return Double(latitude!)
    }
    
    func getLongitude() -> Double {
        return Double(longitude!)
    }
    
    func hasAllPhotos() -> Bool {
        if photos!.count == 0 {
            return false
        }
        
        return true
    }
}
