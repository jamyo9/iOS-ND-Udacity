//
//  CashTextFieldDelegate.swift
//  TextFields
//
//  Created by Juan Alvarez on 13/6/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import UIKit

class CashTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // Figure out what the new text will be, if we return true
        let oldText = textField.text! as NSString
        var newText = oldText.stringByReplacingCharactersInRange(range, withString: string)
        var newTextString = String(newText)
        
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        var digitText = ""
        for c in newTextString.unicodeScalars {
            if digits.longCharacterIsMember(c.value) {
                digitText.append(c)
            }
        }
        
        if let pennies = Int(digitText) {
            newText = "$" + self.dollarStringFromInt(pennies) + "." + self.centsStringFromInt(pennies)
        } else {
            newText = "$0.00"
        }
        
        textField.text = newText
        
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text!.isEmpty {
            textField.text = "$0.00"
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
    
    func dollarStringFromInt(value: Int) -> String {
        return String(value / 100)
    }
    
    func centsStringFromInt(value: Int) -> String {
        
        let cents = value % 100
        var centsString = String(cents)
        
        if cents < 10 {
            centsString = "0" + centsString
        }
        
        return centsString
    }
}