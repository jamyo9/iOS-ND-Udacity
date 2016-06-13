//
//  ZipCodeTextFieldDelegate.swift
//  TextFields
//
//  Created by Juan Alvarez on 13/6/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import UIKit

class ZipCodeTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // Figure out what the new text will be, if we return true
        var newText = textField.text! as NSString
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        
        return Int(newText as String) != nil && newText.length <= 5
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
    
}