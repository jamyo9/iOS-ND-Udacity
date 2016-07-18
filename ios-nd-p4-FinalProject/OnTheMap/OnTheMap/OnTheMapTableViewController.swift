//
//  Created by Juan Alvarez.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit

class OnTheMapTableViewController: UITableViewController {
    
    /* a reference to the studentLocations singleton */
    let positions = Positions.sharedInstance()
    
    @IBOutlet var table: UITableView!
    
    // Override functions
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.hidden = false
        tableView.reloadData()
        tabBarController?.tabBar.hidden = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadTable", name: "", object: nil)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.AllButUpsideDown]
    }
    
    @IBAction func onPinButtonTap() {
        displayInfoPostingViewController()
    }
    
    /* Refresh button was selected. */
    @IBAction func onRefreshButtonTap() {
        // refresh the collection of position from Parse
        positions.reset()
        positions.getPositions(0) { success, errorString in
            if success == false {
                //if let errorString = errorString {
                if errorString != nil {
                    print("ERROR")
                    //OTMError(viewController:self).displayErrorAlertView("Error retrieving Locations", message: errorString)
                } else {
                    print("ERROR")
                    //OTMError(viewController:self).displayErrorAlertView("Error retrieving Locations", message: "Unknown error")
                }
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    func reloadTable() {
        self.table.reloadData()
    }
    
    
    /* Modally present the InfoPosting view controller. */
    func displayInfoPostingViewController() {
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("NewPositionStep1StoryboardID") as! NewPositionStep1ViewController
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OnTheMapTableViewCell", forIndexPath: indexPath) as UITableViewCell!
        let pos = positions.positions[indexPath.row]
        cell.textLabel!.text = pos.firstName + " " + pos.lastName
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.positions.positions.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        showUrlInExternalWebKitBrowser(positions.positions[indexPath.row].mediaURL)
    }
    
    /* Display url in external Safari browser. */
    func showUrlInExternalWebKitBrowser(url: String) {
        if let url = NSURL(string: url) {
            if UIApplication.sharedApplication().openURL(url) {
                print("url successfully opened")
            }
        } else {
            print("invalid url")
        }
    }
    
}
