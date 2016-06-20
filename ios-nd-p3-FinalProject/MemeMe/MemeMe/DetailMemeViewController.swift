//
//  DetailMemeViewController.swift
//  MemeMe
//
//  Created by Juan Alvarez on 17/6/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit

class DetailMemeViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var meme: Meme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = meme.memedImage
        tabBarController?.tabBar.hidden = true
        imageView.contentMode = .ScaleAspectFit
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.hidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

