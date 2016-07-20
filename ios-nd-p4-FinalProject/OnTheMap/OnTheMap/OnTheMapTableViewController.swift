//
//  Created by Juan Alvarez.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit

class OnTheMapTableViewController: UITableViewController {
    
    /* a reference to the positions singleton */
    let positions = Positions.sharedInstance()
    
    var appDelegate: AppDelegate!
    
    @IBOutlet var table: UITableView!
    
    // Override functions
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.hidden = false
        tableView.reloadData()
        tabBarController?.tabBar.hidden = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OnTheMapTableViewController.reloadTable), name: "", object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
                } else {
                    print("ERROR")
                }
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func logoutAction(sender: AnyObject) {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            // User is logged in with Facebook. Log user out of Facebook.
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            if (FBSDKAccessToken.currentAccessToken() == nil) {
                self.appDelegate.loggedIn = false
            }
        }
        self.displayLoginViewController()
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
    
    func displayLoginViewController() {
        self.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
