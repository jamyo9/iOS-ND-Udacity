//
//  TextFieldDelegate.swift
//  MemeMe
//
//  Created by Juan Alvarez on 14/6/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import Foundation
import UIKit

class TextFieldDelegate: NSObject, UITextFieldDelegate {
    
    //var previousText: String! = ""
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // Construct the text that will be in the field if this change is accepted
        var newText = textField.text! as NSString
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        return newText.length <= 50
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        //previousText = textField.text!
        if ((textField.text == "TOP") || textField.text == "BOTTOM" ) {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.text = textField.text?.uppercaseString
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
}