//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Juan Alvarez on 5/7/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import Foundation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var appDelegate: AppDelegate!
    
    let positions = Positions.sharedInstance()
    
    @IBOutlet weak var mapView: MKMapView!
    
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50)) as UIActivityIndicatorView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get a reference to the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // set the mapView delegate to this view controller
        mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a notification observer for updates to position data from Parse.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.onPositionsUpdate), name: "positionsUpdateNotificationKey", object: nil)
        
        // Clear any existing pins before redrawing them (e.g. if navigating back to the map view from the InfoPosting view.)
        removeAllPins()
        
        // Draw the pins now (as it is conceivable that the notification arrived prior to the observer being registered.)
        createPins()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // If not logged in present the LoginViewController.
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if delegate.loggedIn == false {
            displayLoginViewController()
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.setNeedsDisplay()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove observer for the studentLocations update notification.
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: button handlers
    
    /* Pin button was selected. */
    @IBAction func onPinButtonTap() {
        displayInfoPostingViewController()
    }
    
    /* Refresh button was selected. */
    @IBAction func onRefreshButtonTap() {
        // refresh the collection of position from Parse
        positions.reset()
        positions.getPositions(0) { success, errorString in
            if success == false {
                //if let errorString = errorString {
                if errorString != nil {
                    print("ERROR")
                    //OTMError(viewController:self).displayErrorAlertView("Error retrieving Locations", message: errorString)
                } else {
                    print("ERROR")
                    //OTMError(viewController:self).displayErrorAlertView("Error retrieving Locations", message: "Unknown error")
                }
            } else {
                self.removeAllPins()
                self.createPins()
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.setNeedsDisplay()
        }
    }
    
    // MARK: Manage map annotations
    
    /* Create an annotation for each studentLocation and display them on the map */
    func createPins() {
        
        // A collection of point annotations to be displayed on the map view
        var pins = [MKPointAnnotation]()
        
        // Create an annotation for each location dictionary in studentLocations
        for position in positions.positions {
            
            // get latitude and longitude from studentLocation and save as CCLocationDegree type (a Double type)
            let lat = CLLocationDegrees(position.latitude as Double)
            let long = CLLocationDegrees(position.longitude as Double)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // extract the student name and url from the dictionary
            let firstName = position.firstName
            let lastName = position.lastName
            let url = position.mediaURL
            
            // Create the annotation, setting the coordinate, title, and subtitle properties
            let pin = MKPointAnnotation()
            pin.coordinate = coordinate
            pin.title = "\(firstName) \(lastName)"
            pin.subtitle = url
            
            // Add annotation to the annotations collection.
            pins.append(pin)
        }
        
        // Add the annotations to the map.
        self.mapView.addAnnotations(pins)
        
        self.mapView.setNeedsDisplay()
    }
    
    /*
     @brief - Remove all annotations from the MKMapView.
     Acknowledgement:  nielsbot, SO for filter technique to remove all but users current location.
     */
    func removeAllPins() {
        let annotationsToRemove = self.mapView.annotations.filter { $0 !== self.mapView.userLocation }
        self.mapView.removeAnnotations( annotationsToRemove )
    }
    
    
    // MARK: MKMapViewDelegate
    
    // Create an accessory view for the pin annotation callout when it is added to the map view
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)  // DetailDisclosure, InfoLight, InfoDark, ContactAdd
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            if let urlString = annotationView.annotation!.subtitle {
                showUrlInExternalWebKitBrowser(urlString!)
            }
        }
    }
    
    
    // MARK: Helper functions
    
    /* Received a notification that studentLocations have been updated with new data from Parse. Recreate the pins for all locations. */
    func onPositionsUpdate() {
        // clear the pins
        removeAllPins()
        
        // redraw the pins
        createPins()
        
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.setNeedsDisplay()
        }
    }
    
    /* Modally present the Login view controller. */
    func displayLoginViewController() {
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("LoginStoryboardID") as! LoginViewController
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
    /* Modally present the InfoPosting view controller. */
    func displayInfoPostingViewController() {
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("NewPositionStep1StoryboardID") as! NewPositionStep1ViewController
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
    /* show activity indicator */
//    func startActivityIndicator() {
//        activityIndicator.center = self.view.center
//        activityIndicator.hidesWhenStopped = true
//        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
//        view.addSubview(activityIndicator)
//        activityIndicator.startAnimating()
//    }
    
    /* hide acitivity indicator */
//    func stopActivityIndicator() {
//        activityIndicator.stopAnimating()
//    }
    
    /* Display url in external Safari browser. */
    func showUrlInExternalWebKitBrowser(url: String) {
        if let url = NSURL(string: url) {
            if UIApplication.sharedApplication().openURL(url) {
                print("url successfully opened")
            }
        } else {
            print("invalid url")
        }
    }
}