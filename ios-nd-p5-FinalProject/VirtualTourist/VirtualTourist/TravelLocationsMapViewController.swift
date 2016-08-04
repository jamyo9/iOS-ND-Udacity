//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Juan Alvarez on 20/7/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var longPressGestureRecognizer: UILongPressGestureRecognizer? = nil
    var currentPin: Pin? = nil
    
    var context: NSManagedObjectContext {
        return CoreDataStack.sharedInstance().context
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(TravelLocationsMapViewController.addPin(_:)))
        mapView.addGestureRecognizer(longPressGestureRecognizer!)
        mapView.delegate = self
        
        getPins()
        getLastRegion()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PhotoAlbumSegue" {
            // Configure the VTPhotoAlbumViewController
            let photoAlbumViewController = segue.destinationViewController as! PhotoAlbumViewController
            let pin = sender as! Pin
            photoAlbumViewController.pin = pin
        }
    }
    
    // MARK: - MKMapViewDelegate methods
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            // create pinView and initialize
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = MKPinAnnotationView.redPinColor()
            pinView!.draggable = true
            pinView!.animatesDrop = true
        } else {
            // Reuse an existing pin view and set the annotation
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        currentPin = getPinByAnnotation(view.annotation!)
        self.performSegueWithIdentifier("PhotoAlbumSegue", sender: currentPin)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let region = [
            "latitude": mapView.region.center.latitude,
            "longitude": mapView.region.center.longitude,
            "latitudeDelta": mapView.region.span.latitudeDelta,
            "longitudeDelta": mapView.region.span.longitudeDelta
        ]
        NSUserDefaults.standardUserDefaults().setObject(region, forKey: "region")
    }
    
    func addPin(recognizer: UILongPressGestureRecognizer) {
        let touchPoint = recognizer.locationInView(mapView)
        let coordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        
        switch recognizer.state {
        case .Began:
            annotation.coordinate = coordinates
            mapView.addAnnotation(annotation)
            let _ = Pin(latitude: coordinates.latitude, longitude: coordinates.longitude, createdAt: NSDate(), totalPages: 0, context: context)
        case .Ended:
            CoreDataStack.sharedInstance().saveContext()
        default:
            return
        }
        
    }
    
    func getPins() {
        let request = NSFetchRequest(entityName: "Pin")
        request.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        var pins: [Pin]? = nil
        do {
            try pins = context.executeFetchRequest(request) as? [Pin]
        } catch {}
        
        if let pins = pins {
            var annotations = [MKPointAnnotation]()
            for pin in pins {
                // The lat and long are used to create a CLLocationCoordinates2D instance
                let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude!), longitude: CLLocationDegrees(pin.longitude!))
                
                // Create the annotation and set its properties
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                
                // Place the annotation in an array of annotations
                annotations.append(annotation)
            }
            mapView.addAnnotations(annotations)
        }
    }
    
    func getLastRegion() {
        guard let storedRegion = NSUserDefaults.standardUserDefaults().objectForKey("region") as? [String:AnyObject] else {
            print("No region stored in user defaults")
            return
        }
        
        let latitude = storedRegion["latitude"] as! CLLocationDegrees
        let longitude = storedRegion["longitude"] as! CLLocationDegrees
        let latitudeDelta = storedRegion["latitudeDelta"] as! CLLocationDegrees
        let longitudeDelta = storedRegion["longitudeDelta"] as! CLLocationDegrees
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.region = region
        mapView.setCenterCoordinate(center, animated: true)
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    func getPinByAnnotation(annotation: MKAnnotation) -> Pin? {
        
        let latitude = annotation.coordinate.latitude
        let longitude = annotation.coordinate.longitude
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        let pins = fetchedResultsController.fetchedObjects! as? [Pin]
        let pinArray = pins?.filter {
            $0.latitude == latitude && $0.longitude == longitude
        }
        return pinArray![0]
        
    }
}

