//
//  CustomPhotoAlbum.swift
//  MemeMe
//
//  Created by Juan Alvarez on 14/6/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import Photos

class MemePhotoAlbum: NSObject {
    
    
//    //var image: UIImage!
    var albumFound : Bool = false
//    var photosAsset: PHFetchResult!
//    var assetThumbnailSize:CGSize!
//    var collection: PHAssetCollection!
    var assetCollectionPlaceholder: PHObjectPlaceholder!

    var assetCollection: PHAssetCollection!
    static let albumName = "Meme Me Album"
    static let sharedInstance = MemePhotoAlbum()
//    
//    func createAlbum() {
//        //Get PHFetch Options
//        let fetchOptions = PHFetchOptions()
//        fetchOptions.predicate = NSPredicate(format: "title = %@", MemePhotoAlbum.albumName)
//        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
//        //Check return value - If found, then get the first album out
//        if let _: AnyObject = collection.firstObject {
//            self.albumFound = true
//            assetCollection = collection.firstObject as! PHAssetCollection
//        } else {
//            //If not found - Then create a new album
//            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
//                let createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle("camcam")
//                self.assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
//                }, completionHandler: { success, error in
//                    self.albumFound = (success ? true: false)
//                    if (success) {
//                        let collectionFetchResult = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([self.assetCollectionPlaceholder.localIdentifier], options: nil)
//                        print(collectionFetchResult)
//                        self.assetCollection = collectionFetchResult.firstObject as! PHAssetCollection
//                    }
//            })
//        }
//    }
//    
//    func saveImage(image: UIImage){
//        
//        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//        
//        
//        self.createAlbum()
//        
//        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
//            let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
//            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection, assets: self.photosAsset)
//            albumChangeRequest!.addAssets([assetRequest.placeholderForCreatedAsset!])
//            }, completionHandler: nil)
//    }
//    
//    func showImages() {
//        //This will fetch all the assets in the collection
//        
//        let assets : PHFetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: nil)
//        print(assets)
//        
//        let imageManager = PHCachingImageManager()
//        //Enumerating objects to get a chached image - This is to save loading time
//        assets.enumerateObjectsUsingBlock{(object: AnyObject!,
//            count: Int,
//            stop: UnsafeMutablePointer<ObjCBool>) in
//            
//            if object is PHAsset {
//                let asset = object as! PHAsset
//                print(asset)
//                
//                let imageSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
//                
//                let options = PHImageRequestOptions()
//                options.deliveryMode = .FastFormat
//                
//                imageManager.requestImageForAsset(asset, targetSize: imageSize, contentMode: .AspectFill, options: options, resultHandler: {(image: UIImage?,
//                    info: [NSObject : AnyObject]?) in
//                    print(info)
//                    print(image)
//                })
//            }
//        }
//    }
    
    override init() {
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.Authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                status
            })
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.Authorized {
            self.createAlbum()
        } else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.Authorized {
            // ideally this ensures the creation of the photo album even if authorization wasn't prompted till after init was done
            print("trying again to create the album")
            self.createAlbum()
        } else {
            print("should really prompt the user to let them know it's failed")
        }
    }
    
    func createAlbum() {
        //Get PHFetch Options
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", MemePhotoAlbum.albumName)
        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        //Check return value - If found, then get the first album out
        if let _: AnyObject = collection.firstObject {
            self.albumFound = true
            assetCollection = collection.firstObject as! PHAssetCollection
        } else {
            //If not found - Then create a new album
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(MemePhotoAlbum.albumName)
                self.assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
            }, completionHandler: { success, error in
                    self.albumFound = (success ? true: false)
                    if (success) {
                        let collectionFetchResult = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([self.assetCollectionPlaceholder.localIdentifier], options: nil)
                        self.assetCollection = collectionFetchResult.firstObject as! PHAssetCollection
                    }
                }
            )
        }
    }
    
    func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", MemePhotoAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject as! PHAssetCollection
        }
        return nil
    }
    
    func saveImage(image: UIImage) {
        if self.assetCollection == nil {
            return
        }
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
            albumChangeRequest!.addAssets([assetPlaceHolder!])
        }, completionHandler: nil)
    }
}
