//
//  ViewController.swift
//  Click Counter
//
//  Created by Juan Alvarez on 10/6/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var count = 0
    @IBOutlet var label:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        //Label
//        let label = UILabel()
//        label.frame = CGRectMake(150, 150, 60, 60)
//        label.text = "0"
//        self.view.addSubview(label)
//        
//        self.label = label
//        
//        //Button
//        let button = UIButton()
//        button.frame = CGRectMake(150, 250, 60, 60)
//        button.setTitle("Click", forState: .Normal)
//        button.setTitleColor(UIColor.blueColor(), forState: .Normal)
//        self.view.addSubview(button)
//        
//        button.addTarget(self, action: "incrementCount", forControlEvents: UIControlEvents.TouchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func incrementCount() {
        self.count += 1
        self.label.text = "\(self.count)"
    }

}

