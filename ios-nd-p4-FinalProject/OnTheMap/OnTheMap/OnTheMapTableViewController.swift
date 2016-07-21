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
    
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50)) as UIActivityIndicatorView
    
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
        
        if self.appDelegate.loggedInPosition == nil {
            if let fbToken = FBSDKAccessToken.currentAccessToken() {
                let userId = fbToken.userID
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                    if error != nil {
                        self.showAlert("Error", alertMessage: error.localizedDescription, actionTitle: "OK")
                    } else if let userData = result as? [String:AnyObject] {
                        self.appDelegate.loggedInPosition = StudentInformation()
                        // Access user data
                        if let lastName = userData["last_name"] as? String {
                            self.appDelegate.loggedInPosition!.lastName = lastName
                        }
                        if let firstName = userData["first_name"] as? String {
                            self.appDelegate.loggedInPosition!.firstName = firstName
                        }
                        self.appDelegate.loggedInPosition!.mediaURL = "http://www.facebook.com/\(userId)/"
                        
                        self.appDelegate.loggedInPosition!.uniqueKey = userId
                    }
                })
            }
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.AllButUpsideDown]
    }
    
    @IBAction func onPinButtonTap() {
        displayInfoPostingViewController()
    }
    
    /* Refresh button was selected. */
    @IBAction func onRefreshButtonTap() {
        self.startActivityIndicator()
        
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
                dispatch_async(dispatch_get_main_queue()) {
                    self.stopActivityIndicator()
                }
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func logoutAction(sender: AnyObject) {
        self.startActivityIndicator()
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            // User is logged in with Facebook. Log user out of Facebook.
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            if (FBSDKAccessToken.currentAccessToken() == nil) {
                self.appDelegate.loggedIn = false
                self.displayLoginViewController()
            }
        } else {
            UdacityClient.sharedInstance().logoutUdacity() {result, error in
                self.stopActivityIndicator()
                if error == nil {
                    // successfully logged out
                    self.appDelegate.loggedIn = false
                    self.displayLoginViewController()
                } else {
                    self.stopActivityIndicator()
                    print("Udacity logout failed")
                }
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
            self.showAlert("Error", alertMessage: "URL Cannot be opened", actionTitle: "OK")
        }
    }
    
    func showAlert(alertTitle: String, alertMessage: String, actionTitle: String){
        
        /* Configure the alert view to display the error */
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .Default, handler: nil))
        
        /* Present the alert view */
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayLoginViewController() {
        self.stopActivityIndicator()
        self.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
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
