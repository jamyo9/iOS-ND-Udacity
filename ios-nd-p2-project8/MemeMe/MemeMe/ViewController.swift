//
//  ViewController.swift
//  MemeMe
//
//  Created by Juan Alvarez on 13/6/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var libraryButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var topToolBar: UINavigationBar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    
//    var priorKeyboardHeight = CGFloat()
    
    var textFieldDelegate = TextFieldDelegate()
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 20)!,
        NSStrokeWidthAttributeName : 0
    ]
    
    // Override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Picture selectors
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        libraryButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
        
        // Text fild init
        self.topTextField.delegate = textFieldDelegate
        self.bottomTextField.delegate = textFieldDelegate
        self.topTextField.defaultTextAttributes = memeTextAttributes
        self.bottomTextField.defaultTextAttributes = memeTextAttributes
        self.topTextField.textAlignment = .Center
        self.bottomTextField.textAlignment = .Center
        
        // Subscribe Notifications
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Unsubscribe Notifications
        unsubscribeFromKeyboardNotifications()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.AllButUpsideDown]
    }
    
    
    //Image Picker
    
    @IBAction func selectPicture(sender: AnyObject) {
        pickAnImage(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        pickAnImage(UIImagePickerControllerSourceType.Camera)
    }
    
    func pickAnImage(source: UIImagePickerControllerSourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = source
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.contentMode = .ScaleAspectFit
            imagePickerView.image = pickedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //KeyBoard
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder(){
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // Save Action
    
    @IBAction func saveMeme() {
        //Create the meme
        let meme = MemeObject( topText: topTextField.text!, bottomText: bottomTextField.text!, image: imagePickerView.image, memedImage: generateMemedImage())
        dismissViewControllerAnimated(true, completion: nil)
        
        let alert = UIAlertController(title: "Confirmation", message: "Do you want to save the Meme", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: {action in self.save(meme)}))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func save(meme: MemeObject) {
        MemePhotoAlbum.sharedInstance.saveImage(meme.memedImage)
    }
    
    func generateMemedImage() -> UIImage {
        
        showHideBars(true, hideBottom: true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        showHideBars(false, hideBottom: false)
        
        return memedImage
    }
    
    func showHideBars(hideTop: Bool, hideBottom: Bool) {
        topToolBar.hidden = hideTop
        bottomToolBar.hidden = hideBottom
    }
    
    // Share Action
    @IBAction func shareMeme() {
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (type: String?, returnedItem: Bool, items: [AnyObject]?, error: NSError?) -> Void in
//            if returnedItem {
//                self.saveMeme()
//            } else
            if error != nil {
                print("\(error)")
            } else {
                print("Unknown cancel -- user likely clicked \"cancel\" to dismiss activity view.")
            }
        }
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
}

