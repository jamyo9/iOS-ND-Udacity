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
    
    var appDelegate: AppDelegate!
//    var positionCreated: Bool = false
    
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
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("NewPositionStep2StoryboardID") as! NewPositionStep2ViewController
        let pos = createPosition(self.positionTextField.text!)
        controller.position = pos
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
    func createPosition(mapString: String) -> Position {
        var pos = Position()
        pos.uniqueKey = self.appDelegate.loggedInPosition!.uniqueKey
        pos.firstName = self.appDelegate.loggedInPosition!.firstName
        pos.lastName = self.appDelegate.loggedInPosition!.lastName
        pos.mediaURL = ""
        pos.mapString = mapString
        pos.createdAt = NSDate()
        pos.updatedAt = NSDate()
        return pos
    }
}
