//
//  ViewController.swift
//  Launch Image Picker And Activity View
//
//  Created by Juan Alvarez on 10/6/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var openButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func experiment(sender: UIButton) {
        //UIImagePickerController
//        let nextController = UIImagePickerController()
        
        //UIAlertController
//        let nextController = UIAlertController()
//        nextController.title = "Test Alert"
//        nextController.message = "This is a test"
//        
//        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default){
//            action in  self.dismissViewControllerAnimated(true, completion: nil)
//        }
//        nextController.addAction(okAction)
        
        //UIActivityViewController
        let image = UIImage()
        let nextController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        self.presentViewController(nextController, animated: true, completion: nil)
    }
}

