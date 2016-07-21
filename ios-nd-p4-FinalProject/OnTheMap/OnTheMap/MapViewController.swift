//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Juan Alvarez on 7/7/16.
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
        
        print(appDelegate.loggedInPosition)
        
        if self.appDelegate.loggedInPosition == nil {
            let fbToken = FBSDKAccessToken.currentAccessToken()
            let userId = fbToken.userID
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if error != nil {
                    self.showAlert("Error", alertMessage: error.localizedDescription, actionTitle: "OK")
                } else if let userData = result as? [String:AnyObject] {
                    self.appDelegate.loggedInPosition = StudentInformation()
                    // Access user data
                    if let lastName = userData["last_name"] as? String {
                        self.appDelegate.loggedInPosition!.lastName = lastName
                    }
                    if let firstName = userData["first_name"] as? String {
                        self.appDelegate.loggedInPosition!.firstName = firstName
                    }
                    self.appDelegate.loggedInPosition!.mediaURL = "http://www.facebook.com/\(userId)/"
                    
                    self.appDelegate.loggedInPosition!.uniqueKey = userId
                }
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a notification observer for updates to position data from Parse.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.onPositionsUpdate), name: "positionsUpdateNotificationKey", object: nil)
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
        
        // Remove observer for the positions update notification.
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: button handlers
    
    /* Pin button was selected. */
    @IBAction func onPinButtonTap() {
        self.startActivityIndicator()
        displayInfoPostingViewController()
    }
    
    /* Refresh button was selected. */
    @IBAction func onRefreshButtonTap() {
        // refresh the collection of position from Parse
        self.startActivityIndicator()
        
        positions.reset()
        positions.getPositions(0) { success, errorString in
            if success == false {
                //if let errorString = errorString {
                self.showAlert("Error", alertMessage: errorString!, actionTitle: "OK")
            } else {
                self.removeAllPins()
                self.createPins()
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.stopActivityIndicator()
        }
    }
    
    @IBAction func logoutAction(sender: AnyObject) {
        self.startActivityIndicator()
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            // User is logged in with Facebook. Log user out of Facebook.
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            if (FBSDKAccessToken.currentAccessToken() == nil) {
                self.stopActivityIndicator()
                self.appDelegate.loggedIn = false
                self.displayLoginViewController()
            } else {
                self.showAlert("ERROR", alertMessage: "Facebook logout failed", actionTitle: "OK")
            }
        } else {
            UdacityClient.sharedInstance().logoutUdacity() {result, error in
                self.stopActivityIndicator()
                if error == nil {
                    // successfully logged out
                    self.appDelegate.loggedIn = false
                    self.displayLoginViewController()
                } else {
                    self.showAlert("ERROR", alertMessage: "Udacity logout failed", actionTitle: "OK")
                }
            }
        }
    }
    
    // MARK: Manage map annotations
    
    /* Create an annotation for each position and display them on the map */
    func createPins() {
        
        // A collection of point annotations to be displayed on the map view
        var pins = [MKPointAnnotation]()
        
        // Create an annotation for each location dictionary in positions
        for position in positions.positions {
            
            // get latitude and longitude from position and save as CCLocationDegree type (a Double type)
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
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.showAnnotations(pins, animated: true)
        }
    }
    
    /*
     @brief - Remove all annotations from the MKMapView.
     */
    func removeAllPins() {
        self.mapView.removeAnnotations( self.mapView.annotations )
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
        } else {
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
    
    /* Received a notification that positions have been updated with new data from Parse. Recreate the pins for all locations. */
    func onPositionsUpdate() {
        self.startActivityIndicator()
        
        // clear the pins
        self.removeAllPins()
        // redraw the pins
        self.createPins()
        
        dispatch_async(dispatch_get_main_queue()) {
            self.stopActivityIndicator()
        }
    }
    
    /* Modally present the Login view controller. */
    func displayLoginViewController() {
        self.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* Modally present the InfoPosting view controller. */
    func displayInfoPostingViewController() {
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("NewPositionStep1StoryboardID") as! NewPositionStep1ViewController
        dispatch_async(dispatch_get_main_queue()) {
            self.stopActivityIndicator()
        }
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
    /* Display url in external Safari browser. */
    func showUrlInExternalWebKitBrowser(url: String) {
        if let url = NSURL(string: url) {
            if UIApplication.sharedApplication().openURL(url) {
                print("url successfully opened")
            }
        } else {
            self.showAlert("Error", alertMessage: "URL Cannot be opened", actionTitle: "OK")
        }
    }
    
    func showAlert(alertTitle: String, alertMessage: String, actionTitle: String){
        
        /* Configure the alert view to display the error */
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .Default, handler: nil))
        
        /* Present the alert view */
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    /* show activity indicator */
    func startActivityIndicator() {
        print("startActivityIndicator")
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    /* hide acitivity indicator */
    func stopActivityIndicator() {
        print("stopActivityIndicator")
        activityIndicator.stopAnimating()
    }
}