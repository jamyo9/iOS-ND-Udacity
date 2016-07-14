//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Juan Alvarez on 11/7/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    struct UdacityConstants {
        // MARK: API Keys
        static let ParseApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ParseAppID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        
        // MARK: URLs
        static let udacityBaseURL : String = "https://www.udacity.com/"
        static let parseBaseURL : String = "https://api.parse.com/"
        
        // MARK: Methods
        
        /* Udacity methods */
        static let udacitySessionMethod : String = "api/session"
        static let udacitySignupMethod : String = "account/auth#!/signup"
        static let udacityGetUserMethod : String = "api/users/"
        
        /* Parse methods */
        static let parseGetPositions : String = "1/classes/StudentLocation"
        
    }
    
}