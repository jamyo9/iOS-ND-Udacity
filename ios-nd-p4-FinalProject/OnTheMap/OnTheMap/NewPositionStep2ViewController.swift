//
//  NewPositionStep2ViewController.swift
//  OnTheMap
//
//  Created by Juan Alvarez on 14/7/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit
import MapKit

class NewPositionStep2ViewController: UIViewController {
    
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    var appDelegate: AppDelegate!
    var location: String!
    var position: Position!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.findLocationFromStep1()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelNewPosition(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitPosition(sender: AnyObject) {
        self.position.mediaURL = self.linkTextField.text!
        
        // SAVE POSITION
        // URL string is not empty
        if let pos = position {
            UdacityClient.sharedInstance().postPosition(pos) {result, error in
                if error == nil {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    // display error message to user
                    var errorMessage = "error"
                    if let errorString = error?.localizedDescription {
                        errorMessage = errorString
                    }
                    //OTMError(viewController:self).displayErrorAlertView("Submit Failed", message: errorMessage)
                    print("ERROR")
                }
            }
        }
        
        // RETURN TO MAP OR TABLE
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func findLocationFromStep1() {
        if let text = location {
            forwardGeoCodeLocation(text) { placemark, error in
                if error == nil {
                    if let placemark = placemark {
                        // place pin on map
                        self.map.addAnnotation(MKPlacemark(placemark: placemark))
                        
                        // initialize a student location object
                        self.position = self.createPosition(placemark)
                        
                        if let position = self.position {
                            self.showPinOnMap(position)
                        }
                        
                    } else {
                        print("ERROR")
                    }
                } else {
                    print("ERROR")
                }
            }
        }
    }
    
    func forwardGeoCodeLocation(location: String, completion: (placemark: CLPlacemark?, error: NSError?) -> Void) -> Void {
        var geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(location) { placemarks, error in
            if let placemark = placemarks?[0] as CLPlacemark! {
                completion(placemark: placemark, error: nil)
            } else {
                completion(placemark: nil, error: error)
            }
        }
    }
    
    func createPosition(placemark: CLPlacemark) -> Position {
        var pos = Position()
        
        pos.firstName = self.appDelegate.loggedInPosition!.firstName
        pos.lastName = self.appDelegate.loggedInPosition!.lastName
        pos.mediaURL = ""
        //pos.image = nil
        pos.latitude = placemark.location!.coordinate.latitude
        pos.longitude = placemark.location!.coordinate.longitude
        pos.date = NSDate()
        
        return pos
    }
    
    func showPinOnMap(pos: Position) {
        
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinate = CLLocationCoordinate2D(latitude: pos.latitude, longitude: pos.longitude )
        
        // Here we create the annotation and set its coordiate, title, and subtitle properties
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(pos.firstName) \(pos.lastName)"
        annotation.subtitle = pos.mediaURL
        
        
        // Add the annotation to an array of annotations.
        var annotations = [MKPointAnnotation]()
        annotations.append(annotation)
        
        // Add the annotations to the map.
        self.map.addAnnotations(annotations)
        
        // Set the center of the map.
        self.map.setCenterCoordinate(coordinate, animated: true)
        
        // Tell the OS that the mapView needs to be refreshed.
        self.map.setNeedsDisplay()
    }
}
