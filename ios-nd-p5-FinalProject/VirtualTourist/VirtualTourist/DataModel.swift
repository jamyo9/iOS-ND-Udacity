//
//  DataModel.swift
//  Virtual Tourist
//
//  Created by Patrick Bellot on 3/27/16.
//  Copyright © 2016 Bell OS, LLC. All rights reserved.
//

import UIKit
import CoreData

class DataModel: NSObject {
    
    private class var defaultCenter: NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }
    
    private class var context: NSManagedObjectContext {
        return CoreDataStack.sharedInstance().context
    }
    
    private class func saveContext() {
        CoreDataStack.sharedInstance().saveContext()
    }
    
//    class func searchPhotos(pin: Pin) {
//        defaultCenter.postNotificationName("SearchPhotos", object: nil)
//        
//        if pin.photos == nil || pin.photos?.count == 0 {
//            RestClient.sharedInstance().taskForPhotosSearch(pin) { (result, errorString) in
//                guard let photos = result as? [String:AnyObject] else {
//                    print(errorString)
//                    return
//                }
//            
//                guard let photosArray = photos["photo"] as? [[String:AnyObject]] else {
//                    print(errorString)
//                    return
//                }
//            
//                // Store the photos in the pin
//                let _ = photosArray.map() {(dictionary: [String:AnyObject]) -> Photo in
//                    let photo = Photo(dictionary: dictionary, context: context)
//                    photo.pin = pin
//                    return photo
//                }
//                
//                saveContext()
//                
//                //Post a notification that the photos search has completed.
//                defaultCenter.postNotificationName("SearchPhotosCompleted", object: nil)
//            
//                // Download the photos for this pin
////                downloadPhotos(pin)
//            }
//        }
//    }
//    
//    private class func downloadPhotos(pin: Pin) {
//        
//        let photos = pin.photos as! Set<Photo>
//        var total = pin.photos!.count
//        var count = 0
//        
//        for photo in photos {
//            // Don't download photos that have already been downloaded
//            if photo.image != nil {
//                // Decrement the total since there is one less photo to download
//                total -= 1
//                continue
//            }
//            
//            if let photoURL = photo.url {
//                
//                RestClient.sharedInstance().taskForImageDownload(photoURL) {(imageData, errorString) in
//                
//                    guard let imageData = imageData else {
//                        print(errorString)
//                        return
//                    }
//                    
//                    photo.image = imageData
//                    saveContext()
//                    
//                    //Post a notification that a photo download has completed
//                    defaultCenter.postNotificationName("PhotoDownloadCompleted", object: nil)
//                    
//                    count += 1
//                    if count == total {
//                        //post a notification that all photo downloads have completed
//                        defaultCenter.postNotificationName("AllPhotoDownloadsCompleted", object: nil)
//                    }
//                }
//            }
//        }
//    }
//    
//    class func downloadImage(photo: Photo) {
//        
//        if photo.image == nil {
//            if let photoURL = photo.url {
//                RestClient.sharedInstance().taskForImageDownload(photoURL) {(imageData, errorString) in
//                    
//                    guard let imageData = imageData else {
//                        print(errorString)
//                        return
//                    }
//                    
//                    photo.image = imageData
//                    saveContext()
//                    
//                    //Post a notification that a photo download has completed
//                    defaultCenter.postNotificationName("PhotoDownloadCompleted", object: nil)
//                }
//            }
//        }
//    }
    
}// End of Class
