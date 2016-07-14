//
//  NewPositionViewController.swift
//  OnTheMap
//
//  Created by Juan Alvarez on 12/7/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit

class NewPositionStep1ViewController: UIViewController {
    
    @IBOutlet weak var whereLabel: UILabel!
    @IBOutlet weak var positionTextField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        controller.location = self.positionTextField.text
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
}
