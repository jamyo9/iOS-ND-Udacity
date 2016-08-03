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
    
    init(latitude: Double, longitude: Double, createdAt: NSDate, context: NSManagedObjectContext){
        
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.latitude = latitude as NSNumber
        self.longitude = longitude as NSNumber
        self.createdAt = createdAt
        self.photos = nil
    }
    
    init(latitude: Double, longitude: Double, createdAt: NSDate, photos: Set<Photo>, context: NSManagedObjectContext){
        
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.latitude = latitude as NSNumber
        self.longitude = longitude as NSNumber
        self.createdAt = createdAt
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

//extension Pin {
//    
//    func addPhotoToPin(photo:Photo) {
//        var photosM = self.mutableSetValueForKey("photos")
//        photosM.addObject(photo)
//    }
//    
//    func getNumberOfPhotos() -> Int {
//        return self.photos!.count;
//    }
//    
//    func getPhotos() -> [Photo] {
//        var photo: [Photo]
//        photo = self.photos!.allObjects as! [Photo]
//        photo = self.photos!.allObjects as! [Photo]
//        
//        return photo
//    }
//    
//}
