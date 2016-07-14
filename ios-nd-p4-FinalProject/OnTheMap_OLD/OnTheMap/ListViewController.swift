//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Juan Alvarez on 5/7/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    
    var appDelegate: AppDelegate!
    
    /* a reference to the studentLocations singleton */
    let studentLocations = StudentLocations.sharedInstance()
    
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50)) as UIActivityIndicatorView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Additional bar button items
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(ListViewController.onRefreshButtonTap))
        let pinButton = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: #selector(ListViewController.onPinButtonTap))
        navigationItem.setRightBarButtonItems([refreshButton, pinButton], animated: true)
        
        // get a reference to the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    }
  
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a notification observer for updates to student location data from Parse.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ListViewController.onStudentLocationsUpdate), name: studentLocationsUpdateNotificationKey, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove observer for the studentLocations update notification.
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: button handlers
    
    /* The Pin button was selected. */
    func onPinButtonTap() {
        //displayInfoPostingViewController()
    }
    
    /* The Refresh button was selected. */
//    func onRefreshButtonTap() {
//        // refresh the collection of student locations from Parse
//        studentLocations.reset()
//        studentLocations.getStudentLocations(0) { success, errorString in
//            if success == false {
//                if let errorString = errorString {
//                    OTMError(viewController:self).displayErrorAlertView("Error retrieving Locations", message: errorString)
//                } else {
//                    OTMError(viewController:self).displayErrorAlertView("Error retrieving Locations", message: "Unknown error")
//                }
//            }
//        }
//    }
//    
//    /* logout of Facebook else logout of Udacity session */
//    @IBAction func onLogoutButtonTap(sender: AnyObject) {
//        startActivityIndicator()
//        
//        // Facebook logout
//        if (FBSDKAccessToken.currentAccessToken() != nil)
//        {
//            // User is logged in with Facebook. Log user out of Facebook.
//            let loginManager = FBSDKLoginManager()
//            loginManager.logOut()
//            if (FBSDKAccessToken.currentAccessToken() == nil)
//            {
//                self.appDelegate.loggedIn = false
//            }
//            self.stopActivityIndicator()
//            self.displayLoginViewController()
//        } else {
//            // Udacity logout
//            RESTClient.sharedInstance().logoutUdacity() {result, error in
//                self.stopActivityIndicator()
//                if error == nil {
//                    // successfully logged out
//                    self.appDelegate.loggedIn = false
//                    self.displayLoginViewController()
//                } else {
//                    print("Udacity logout failed")
//                    // no display to user
//                }
//            }
//        }
//    }
    
    
    // MARK: Table View Data Source
    
    /* return the row count */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocations.studentLocations.count
    }
    
//    /* return a cell for the requested row */
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        
//        let cell = tableView.dequeueReusableCellWithIdentifier("ListViewCellID") as! UITableViewCell
//        
//        let studentLocation = studentLocations.studentLocations[indexPath.row]
//        
//        // set the cell text
//        var firstName = studentLocation.firstName
//        var lastName = studentLocation.lastName
//        cell.textLabel!.text = firstName + " " + lastName
//        
//        return cell
//    }
    
    
    // MARK: Table View Delegate
    
    /* User selected a row. Open the associated url stored in studentLocation in the Safari browser. */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // open student's url in Safari browser
        let studentLocation = studentLocations.studentLocations[indexPath.row]
        let url = studentLocation.mediaURL
        
        showUrlInEmbeddedBrowser(url)
    }
    
    
    // MARK: helper functions
    
    /* Modally present the Login view controller */
    func displayLoginViewController() {
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("LoginStoryboardID") as! LoginViewController
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
    /* Modally present the InfoPosting view controller */
//    func displayInfoPostingViewController() {
//        let storyboard = UIStoryboard (name: "Main", bundle: nil)
//        let controller = storyboard.instantiateViewControllerWithIdentifier("InfoPostingProvideLocationStoryboardID") as! InfoPostingProvideLocationViewController
//        self.presentViewController(controller, animated: true, completion: nil);
//    }
    
    /* Received a notification that studentLocations have been updated with new data from Parse. Update the rows in the list. */
    func onStudentLocationsUpdate() {
        self.tableView.reloadData()
    }
    
    /* Display url in external Safari browser. */
    func showUrlInExternalWebKitBrowser(url: String) {
        if let requestUrl = NSURL(string: url) {
            UIApplication.sharedApplication().openURL(requestUrl)
        }
    }
    
    /* Display url in an embeded webkit browser in the navigation controller. */
//    func showUrlInEmbeddedBrowser(url: String) {
//        let storyboard = UIStoryboard (name: "Main", bundle: nil)
//        let controller = storyboard.instantiateViewControllerWithIdentifier("WebViewStoryboardID") as! WebViewController
//        controller.url = url
//        self.navigationController?.pushViewController(controller, animated: true)
//        
//    }
    
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