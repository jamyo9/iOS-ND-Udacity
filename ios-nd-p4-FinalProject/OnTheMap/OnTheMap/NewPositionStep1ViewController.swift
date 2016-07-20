//
//  NewPositionViewController.swift
//  OnTheMap
//
//  Created by Juan Alvarez on 12/7/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit
import MapKit

class NewPositionStep1ViewController: UIViewController {
    
    @IBOutlet weak var whereLabel: UILabel!
    @IBOutlet weak var positionTextField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50)) as UIActivityIndicatorView
    
    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
    
    @IBAction func findLocation(sender: AnyObject) {
        self.startActivityIndicator()
        
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("NewPositionStep2StoryboardID") as! NewPositionStep2ViewController
        let pos = createPosition(self.positionTextField.text!)
        controller.position = pos
        dispatch_async(dispatch_get_main_queue()) {
            self.stopActivityIndicator()
        }
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
    func createPosition(mapString: String) -> StudentInformation {
        var pos = StudentInformation()
        pos.uniqueKey = self.appDelegate.loggedInPosition!.uniqueKey
        pos.firstName = self.appDelegate.loggedInPosition!.firstName
        pos.lastName = self.appDelegate.loggedInPosition!.lastName
        pos.mediaURL = ""
        pos.mapString = mapString
        pos.createdAt = NSDate()
        pos.updatedAt = NSDate()
        return pos
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
