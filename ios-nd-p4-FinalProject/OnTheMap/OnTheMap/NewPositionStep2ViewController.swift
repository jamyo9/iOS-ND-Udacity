//
//  NewPositionStep2ViewController.swift
//  OnTheMap
//
//  Created by Juan Alvarez on 14/7/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit
import MapKit

class NewPositionStep2ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    var appDelegate: AppDelegate!
    var position: StudentInformation!
    
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50)) as UIActivityIndicatorView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.linkTextField.delegate = self
        self.findLocationFromStep1()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func cancelNewPosition(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func editingDidEnd(sender: AnyObject) {
        self.editing = false
    }
    
    @IBAction func submitPosition(sender: AnyObject) {
        self.startActivityIndicator()
        
        // CHECK VALID URL
        let stringWithPossibleURL: String = self.linkTextField.text! // Or another source of text
        let validURL: NSURL = NSURL(string: stringWithPossibleURL)!
        if stringWithPossibleURL.isEmpty {
            dispatch_async(dispatch_get_main_queue(),{
                self.stopActivityIndicator()
                self.showError("02", errorMessage: "")
            })
        } else {
            if UIApplication.sharedApplication().canOpenURL(validURL) {
                // Successfully constructed an NSURL; open it
                self.position.mediaURL = stringWithPossibleURL
                // SAVE POSITION
                // URL string is not empty
                if let pos = position {
                    UdacityClient.sharedInstance().postPosition(pos) {result, error in
                        if error != nil {
                            print(error)
                            // display error message to user
                            var errorMessage = "error"
                            if let errorString = error?.localizedDescription {
                                errorMessage = errorString
                            }
                            dispatch_async(dispatch_get_main_queue(),{
                                self.stopActivityIndicator()
                                self.showError("03", errorMessage: errorMessage)
                            })
                        } else {
//                            NSOperationQueue.mainQueue().addOperationWithBlock {
                            dispatch_async(dispatch_get_main_queue(),{
                                self.stopActivityIndicator()
                                // RETURN TO MAP OR TABLE
                                self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                            })
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(),{
                        self.stopActivityIndicator()
                        self.showError("03", errorMessage: "Error with the position.")
                    })
                }
            } else {
                dispatch_async(dispatch_get_main_queue(),{
                    self.stopActivityIndicator()
                    // Initialization failed; alert the user
                    self.showError("01", errorMessage: "")
                })
            }
        }
    }
    
    func findLocationFromStep1() {
        self.stopActivityIndicator()
        
        if let text = position.mapString {
            forwardGeoCodeLocation(text) { placemark, error in
                if error == nil {
                    if let placemark = placemark {
                        // place pin on map
                        self.map.addAnnotation(MKPlacemark(placemark: placemark))
                        
                        // initialize a position object
                        self.position = self.updatePosition(placemark)
                        
                        if let position = self.position {
                            dispatch_async(dispatch_get_main_queue(),{
                                self.stopActivityIndicator()
                            })
                            self.showPinOnMap(position)
                        }
                        
                    } else {
                        dispatch_async(dispatch_get_main_queue(),{
                            self.stopActivityIndicator()
                        })
                        self.showAlert("Error", alertMessage: "Unable to find the location.", actionTitle: "Try again")
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(),{
                        self.stopActivityIndicator()
                    })
                    self.showAlert("Error", alertMessage: (error?.description)!, actionTitle: "Try again")
                }
            }
        }
    }
    
    func forwardGeoCodeLocation(location: String, completion: (placemark: CLPlacemark?, error: NSError?) -> Void) -> Void {
        print("forwardGeoCodeLocation")
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(location) { placemarks, error in
            if let placemark = placemarks?[0] as CLPlacemark! {
                completion(placemark: placemark, error: nil)
            } else {
                completion(placemark: nil, error: error)
            }
        }
    }
    
    func updatePosition(placemark: CLPlacemark) -> StudentInformation {
        print("updatePosition")
        self.position.firstName = self.appDelegate.loggedInPosition!.firstName
        self.position.lastName = self.appDelegate.loggedInPosition!.lastName
        self.position.mediaURL = ""
        self.position.latitude = placemark.location!.coordinate.latitude
        self.position.longitude = placemark.location!.coordinate.longitude
        self.position.updatedAt = NSDate()
        return position
    }
    
    func showPinOnMap(pos: StudentInformation) {
        print("showPinOnMap")
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
    
    func showError(errorCode: String, errorMessage: String?){
        let titleString = "Error"
        var errorString = ""
        
        if errorCode.rangeOfString("01") != nil{
            errorString = "Please try again. You may need to add the scheme (http:// or https://)."
        } else if errorCode.rangeOfString("02")  != nil {
            errorString = "Please try again. The URL is empty."
        } else if errorCode.rangeOfString("03") != nil {
            errorString = errorMessage!
        }
        
        showAlert(titleString, alertMessage: errorString, actionTitle: "Try again")
    }
    
    //Function that configures and shows an alert
    func showAlert(alertTitle: String, alertMessage: String, actionTitle: String){
        
        /* Configure the alert view to display the error */
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .Default, handler: nil))
        
        /* Present the alert view */
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    /* show activity indicator */
    func startActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    /* hide acitivity indicator */
    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
    }
}
