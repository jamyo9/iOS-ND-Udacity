//
//  LoginViewController.swift
//  OnTheMap
//

import UIKit

// MARK: - LoginViewController: UIViewController

class LoginViewController: UIViewController {
    
    // MARK: Properties
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    
    // MARK: Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var debugTextLabel: UILabel!        
    
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50)) as UIActivityIndicatorView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate                        
        
        configureUI()
        
        subscribeToNotification(UIKeyboardWillShowNotification, selector: #selector(keyboardWillShow))
        subscribeToNotification(UIKeyboardWillHideNotification, selector: #selector(keyboardWillHide))
        subscribeToNotification(UIKeyboardDidShowNotification, selector: #selector(keyboardDidShow))
        subscribeToNotification(UIKeyboardDidHideNotification, selector: #selector(keyboardDidHide))
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    // MARK: Login
    @IBAction func loginPressed(sender: AnyObject) {
        if let username = usernameTextField.text, password = passwordTextField.text {
            UdacityClient.sharedInstance().loginUdacity(username, password: password) {result, accountKey, error in
                if error == nil {
                    self.appDelegate.loggedIn = true
                    // Get the logged in user's data from the Udacity service and store the relevant elements in a position variable for retrieval later when we post the user's data to Parse.
                    self.getLoggedInUserData(accountKey) { success, position, error in
                        if error == nil {
                            // got valid user data back, so save it
                            self.appDelegate.loggedInPosition = position
                        } else {
                            dispatch_async(dispatch_get_main_queue(),{
                                self.showError(error!.localizedDescription)
                            })
                        }
                    }
                    
                    // get position from Parse
                    
                    Positions.sharedInstance().positions.removeAll(keepCapacity: false)
                    Positions.sharedInstance().getPositions(0) { success, errorString in
                        if success == false {
                            //if let errorString = errorString {
                            if errorString != nil {
                                dispatch_async(dispatch_get_main_queue(),{
                                    self.showError(errorString!)
                                })
                            }
                        }
                    }
                    self.presentMapController()
                } else {
                    self.appDelegate.loggedIn = false
                    dispatch_async(dispatch_get_main_queue(),{
                        self.showError(error!.localizedDescription)
                    })
                }
            }
        }
    }
    
    @IBAction func signUpButton(sender: UIButton){
        UIApplication.sharedApplication().openURL(NSURL(string: UdacityClient.UdacityConstants.udacityBaseURL + UdacityClient.UdacityConstants.udacitySignupMethod)!)
    }
    
    func presentMapController() {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("LoginSuccessSegueID", sender: self)
        }
    }
    
    func getLoggedInUserData(userAccountKey: String, completion: (success: Bool, position: Position?, error: NSError?) -> Void) {
        UdacityClient.sharedInstance().getUdacityUser(userAccountKey) { result, pos, error in
            if error == nil {
                completion(success: true, position: pos, error: nil)
            }
            else {
                completion(success: false, position: nil, error: error)
            }
        }
    }
}

// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(notification: NSNotification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    private func resignIfFirstResponder(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(sender: AnyObject) {
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }
}

// MARK: - LoginViewController (Configure UI)

extension LoginViewController {
    
    private func setUIEnabled(enabled: Bool) {
        usernameTextField.enabled = enabled
        passwordTextField.enabled = enabled
        loginButton.enabled = enabled
        debugTextLabel.text = ""
        debugTextLabel.enabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    private func configureUI() {
        
        // configure background gradient
        let backgroundGradient = CAGradientLayer()
        //backgroundGradient.colors = [UdacityClientsConstants.UI.LoginColorTop, Constants.UI.LoginColorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, atIndex: 0)
        
        configureTextField(usernameTextField)
        configureTextField(passwordTextField)
    }
    
    private func configureTextField(textField: UITextField) {
        let textFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .Always
        //textField.backgroundColor = Constants.UI.GreyColor
        //textField.textColor = Constants.UI.BlueColor
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        //textField.tintColor = Constants.UI.BlueColor
        textField.delegate = self
    }
    
    // FROM https://github.com/pbellot77/On-The-Map
    func showError(errorString: String){
        let titleString = "Authentication failed!"
        var errorString = errorString
        
        if errorString.rangeOfString("400") != nil{
            errorString = "Please enter your email address and password."
        } else if errorString.rangeOfString("403")  != nil {
            errorString = "Wrong email address or password entered."
        } else if errorString.rangeOfString("1009") != nil {
            errorString = "Something is wrong with the network connection."
        }
        
        showAlert(titleString, alertMessage: errorString, actionTitle: "Try again")
    }
    
    //Function that configures and shows an alert
    func showAlert(alertTitle: String, alertMessage: String, actionTitle: String){
        
        /* Configure the alert view to display the error */
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .Default, handler: nil))
        
        /* Present the alert view */
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: - LoginViewController (Notifications)

extension LoginViewController {
    
    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}