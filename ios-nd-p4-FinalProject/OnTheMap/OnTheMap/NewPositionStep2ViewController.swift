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
        // CHECK VALID URL
        let stringWithPossibleURL: String = self.linkTextField.text! // Or another source of text
        let validURL: NSURL = NSURL(string: stringWithPossibleURL)!
        if UIApplication.sharedApplication().canOpenURL(validURL) {
            // Successfully constructed an NSURL; open it
            self.position.mediaURL = stringWithPossibleURL
            // SAVE POSITION
            // URL string is not empty
            if let pos = position {
                UdacityClient.sharedInstance().postPosition(pos) {result, error in
                    if error == nil {
                        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
                            let secondPresentingVC = self.presentingViewController?.presentingViewController;
                            secondPresentingVC?.dismissViewControllerAnimated(true, completion: {});
                        })
                        
                    } else {
                        // display error message to user
                        var errorMessage = "error"
                        if let errorString = error?.localizedDescription {
                            errorMessage = errorString
                        }
                        //OTMError(viewController:self).displayErrorAlertView("Submit Failed", message: errorMessage)
                        print(errorMessage)
                    }
                }
            }
            
            // RETURN TO MAP OR TABLE
            self.dismissViewControllerAnimated(true, completion: nil)
            
        } else {
            // Initialization failed; alert the user
            let controller: UIAlertController = UIAlertController(title: "Invalid URL", message: "Please try again. You may need to add the scheme (http:// or https://).", preferredStyle: .Alert)
            controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func findLocationFromStep1() {
        if let text = position.mapString {
            forwardGeoCodeLocation(text) { placemark, error in
                if error == nil {
                    if let placemark = placemark {
                        // place pin on map
                        self.map.addAnnotation(MKPlacemark(placemark: placemark))
                        
                        // initialize a position object
                        self.position = self.updatePosition(placemark)
                        
                        if let position = self.position {
                            self.showPinOnMap(position)
                        }
                        
                    } else {
                        print("ERROR")
                    }
                } else {
                    print(error?.description)
                }
            }
        }
    }
    
    func forwardGeoCodeLocation(location: String, completion: (placemark: CLPlacemark?, error: NSError?) -> Void) -> Void {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(location) { placemarks, error in
            if let placemark = placemarks?[0] as CLPlacemark! {
                completion(placemark: placemark, error: nil)
            } else {
                completion(placemark: nil, error: error)
            }
        }
    }
    
    func updatePosition(placemark: CLPlacemark) -> Position {
        self.position.firstName = self.appDelegate.loggedInPosition!.firstName
        self.position.lastName = self.appDelegate.loggedInPosition!.lastName
        self.position.mediaURL = ""
        self.position.latitude = placemark.location!.coordinate.latitude
        self.position.longitude = placemark.location!.coordinate.longitude
        self.position.createdAt = parseDate(NSDate())
        return position
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
    
    func parseDate(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateStr = dateFormatter.stringFromDate(date)
        return dateStr
    }
    
}
