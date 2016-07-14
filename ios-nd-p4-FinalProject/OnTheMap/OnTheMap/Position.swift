//
//  Position.swift
//  OnTheMap
//
//  Created by Juan Alvarez on 14/6/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import Foundation
import UIKit

struct Position {
    var firstName = ""
    var lastName = ""
    var mediaURL = ""
    var latitude = 0.0
    var longitude = 0.0
    var date = NSDate()
    
    init () {
        self.firstName = ""
        self.lastName = ""
        self.mediaURL = ""
        self.latitude = 0.0
        self.longitude = 0.0
        self.date = NSDate()
    }
    
    init (dictionary: [String:AnyObject]) {
        if let firstName = dictionary["firstName"] as? String {
            self.firstName = firstName
        }
        
        if let lastName = dictionary["lastName"] as? String {
            self.lastName = lastName
        }
        
        if let mediaURL = dictionary["mediaURL"] as? String {
            self.mediaURL = mediaURL
        }
        
        if let latitude = dictionary["latitude"] as? Double {
            self.latitude = latitude
        }
        
        if let longitude = dictionary["longitude"] as? Double {
            self.longitude = longitude
        }
        
        if let date = dictionary["date"] as? NSDate {
            self.date = date
        }
    }
}