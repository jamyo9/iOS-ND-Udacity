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
    var objectId = ""
    var uniqueKey = ""
    var firstName = ""
    var lastName = ""
    var mediaURL = ""
    var latitude = 0.0
    var longitude = 0.0
    var createdAt = NSDate()
    var mapString: String! = ""
    var updatedAt = NSDate()
    
    init () {
        self.objectId = ""
        self.uniqueKey = ""
        self.firstName = ""
        self.lastName = ""
        self.mediaURL = ""
        self.latitude = 0.0
        self.longitude = 0.0
        self.createdAt = NSDate()
        self.mapString = ""
        self.updatedAt = NSDate()
    }
    
    init (dictionary: [String:AnyObject]) {
        if let objectId = dictionary["objectId"] as? String {
            self.objectId = objectId
        }
        
        if let uniqueKey = dictionary["uniqueKey"] as? String {
            self.uniqueKey = uniqueKey
        }
        
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
        
        if let createdAt = dictionary["createdAt"] as? NSDate {
            self.createdAt = createdAt
        }
        
        if let mapString = dictionary["mapString"] as? String {
            self.mapString = mapString
        }
        
        if let updatedAt = dictionary["updatedAt"] as? NSDate {
            self.updatedAt = updatedAt
        }
    }
}