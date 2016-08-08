//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Juan Alvarez on 20/7/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var noImageText: UITextField!
    
    var pin: Pin! = nil
//    var imagesToRemove: [NSIndexPath] = []
    var context: NSManagedObjectContext {
        return CoreDataStack.sharedInstance.context
    }
    
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if pin != nil && pin.photos?.count == 0 {
            searchPhotos(self.pin)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        
        // Set the fetchedResultsController.delegate = self
        fetchedResultsController.delegate = self
        
        if pin != nil {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: Double(pin.latitude!), longitude: Double(pin.longitude!))
            
            //Setup the region
            let span = MKCoordinateSpanMake(0.5, 0.5)
            let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
            mapView.addAnnotation(annotation)
        }
        
        // Invoke fetchedResultsController.performFetch(nil) here
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        dispatch_async(dispatch_get_main_queue()) {
            if (self.pin.photos?.count == 0) {
                self.noImageText.hidden = false
            } else {
                self.noImageText.hidden = true
            }
            
            self.newCollectionButton.enabled = true
        }
    }
    
    
    // MARK: - NSFetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: - Fetched Results Controller Delegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
    }
}

extension PhotoAlbumViewController {
    
    @IBAction func okAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func newCollectionAction(sender: AnyObject) {
        self.newCollectionButton.enabled = false
        
        if self.pin.photos?.count > 0 {
            for photo in fetchedResultsController.fetchedObjects as! [Photo] {
                self.context.deleteObject(photo)
            }
            
            self.noImageText.hidden = false
            
            searchPhotos(self.pin)
        }
    }
    
    func searchPhotos(pin: Pin) {
        
        RestClient.sharedInstance.taskForPhotosSearch(pin) { result, error in
            if let error = error {
                print(error)
            } else {
                guard let photos = result as? [String:AnyObject] else {
                    print(error)
                    return
                }
                
                guard let photosArray = photos["photo"] as? [[String:AnyObject]] else {
                    print(error)
                    return
                }
                
                // Store the photos in the pin
                self.context.performBlock {
                    let _ = photosArray.map() {(dictionary: [String:AnyObject]) -> Photo in
                        let photo = Photo(dictionary: dictionary, context: self.context)
                        photo.pin = pin
                        return photo
                    }
                    CoreDataStack.sharedInstance.saveContext()
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.collectionView.reloadData()
                    if (self.pin.photos?.count == 0) {
                        self.noImageText.hidden = false
                    } else {
                        self.noImageText.hidden = true
                    }
                    self.newCollectionButton.enabled = true
                }
            }
        }
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCellID", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        //Set the Photo Image
        if photo.url == nil || photo.url == "" {
            // if the photo doesn´t have an image, we remove it from the collection
            self.context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
            CoreDataStack.sharedInstance.saveContext()
            
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView.reloadData()
            }
        } else {
            
            if photo.image == nil {
                cell.activityIndicator.startAnimating()
                
                RestClient.sharedInstance.taskForImageDownload(photo.url!) { imageData, error in
                    
                    if let error = error {
                        print("Flickr Photo Download Error:\(error)")
                    }
                    
                    if let data = imageData {
                        
                        self.context.performBlock {
                            photo.image = data
                            CoreDataStack.sharedInstance.saveContext()
                        }
                        
                        //Update the cell later, on the main thread
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.photoView!.image = UIImage(data: data)
                            cell.activityIndicator.stopAnimating()
                        }
                    }
                }
            } else {
                cell.photoView!.image = UIImage(data: photo.image!)
            }
        }

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.context.deleteObject(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
    }
}