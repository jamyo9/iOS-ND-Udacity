//
//  ViewController.swift
//  ImageRequest
//
//  Created by Jarrod Parkes on 11/3/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - ViewController: UIViewController

class ViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Add all the networking code here!
        
        //let imageURL = NSURL(string: "https://upload.wikimedia.org/wikipedia/commons/b/b2/LeBron_James_%2815662939969%29.jpg")!
        let imageURL = NSURL(string: "http://files.tycsports.com/eventos/2596/placa%20streamings%20copa%20am%C3%A9rica_c320_c320.jpg")!
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(imageURL) {
            (data, response, error) in
            if (error == nil) {
                print("error == nil")
                let downloadedImage = UIImage(data: data!)
                performUIUpdatesOnMain{
                    self.imageView.image = downloadedImage
                }
            }
        }
        task.resume()
    }
}
