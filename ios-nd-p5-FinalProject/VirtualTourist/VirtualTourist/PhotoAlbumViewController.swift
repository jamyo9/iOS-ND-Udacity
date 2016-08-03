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
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var noImageText: UITextField!
    
    var pin: Pin! = nil
    var imagesToRemove: [NSIndexPath] = []
    var context: NSManagedObjectContext {
        return CoreDataStack.sharedInstance().context
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
            
            if pin.photos?.count == 0 {
                DataModel.searchPhotos(self.pin)
            }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "url", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
}

extension PhotoAlbumViewController {
    
    @IBAction func okAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func newCollectionAction(sender: AnyObject) {
        
        self.newCollectionButton.enabled = false
        
        if self.pin.photos?.count > 0 {
            for item in self.collectionView!.visibleCells() as! [PhotoCollectionViewCell] {
                self.imagesToRemove.append(self.collectionView!.indexPathForCell(item as PhotoCollectionViewCell)!)
            }
            self.deleteAction(sender)
            
            DataModel.searchPhotos(self.pin)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            if (self.pin.photos?.count == 0) {
                self.noImageText.hidden = false
            } else {
                self.noImageText.hidden = true
            }
            
            self.newCollectionButton.enabled = true
        }
    }
    
    @IBAction func deleteAction(sender: AnyObject) {
        
        for index in self.imagesToRemove {
            self.context.deleteObject(self.fetchedResultsController.objectAtIndexPath(index) as! NSManagedObject)
        }
        CoreDataStack.sharedInstance().saveContext()
        self.imagesToRemove.removeAll()
        
        // Invoke fetchedResultsController.performFetch(nil) here
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionView.reloadData()
        }
        
        self.deleteButton.enabled = false
        
        if (self.pin.photos?.count == 0) {
            self.noImageText.hidden = false
        } else {
            self.noImageText.hidden = true
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
        var image = UIImage(named: "placeholder")
        
        //Set the Photo Image
        if photo.url == nil || photo.url == "" || photo.image == nil {
            // if the photo doesn´t have an image, we remove it from the collection
            self.context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
            CoreDataStack.sharedInstance().saveContext()
            
            // Invoke fetchedResultsController.performFetch(nil) here
            do {
                try fetchedResultsController.performFetch()
            } catch {}
            
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView.reloadData()
            }
            
        } else if photo.image != nil {
            image = UIImage(data: photo.image!)
        }
        
        cell.photoView!.image = image
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell!.alpha = 0.5
        self.imagesToRemove.append(indexPath)
        
        if imagesToRemove.count > 0 {
            self.deleteButton.enabled = true
        } else {
            self.deleteButton.enabled = false
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell!.alpha = 1.0
        self.imagesToRemove.removeAtIndex(imagesToRemove.indexOf(indexPath)!)
        
        if imagesToRemove.count > 0 {
            self.deleteButton.enabled = true
        } else {
            self.deleteButton.enabled = false
        }
    }
}