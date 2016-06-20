//
//  ViewController.swift
//  MemeMe
//
//  Created by Juan Alvarez on 13/6/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit

class MemesTableViewController: UITableViewController {
    
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    // Override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        //super.viewWillAppear(animated)
        tableView.hidden = false
        tableView.reloadData()
        tabBarController?.tabBar.hidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.AllButUpsideDown]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {        
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeTableCell", forIndexPath: indexPath) as! MemeTableViewCell
        let meme = self.memes[indexPath.row]
        // Set the name and image
        cell.memedImage!.image = meme.memedImage
        cell.label?.text = meme.topText + "-" + meme.bottomText
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memes.count
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //Grab the DetailVC from Storyboard
        let detailViewController = self.storyboard!.instantiateViewControllerWithIdentifier("DetailMemeViewController") as! DetailMemeViewController
        
        //Populate view controller with data from the selected item
        detailViewController.meme = self.memes[indexPath.row]
        
        //Present the view controller using navigation
        navigationController!.pushViewController(detailViewController, animated: true)
    }
    
}
