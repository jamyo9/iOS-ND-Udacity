//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Juan Alvarez on 11/7/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import Foundation

class UdacityClient {
    
    /* Shared session */
    var session: NSURLSession
    
    // MARK: - Shared Instance
    
    /* Instantiate a single instance of the UdacityClient. */
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
    
    /* default initializer */
    init() {
        session = NSURLSession.sharedSession()
    }
    
    func loginUdacity(username: String, password: String, completionHandler: (result: Bool, accountKey: String, error: NSError?) -> Void) {
        /* 1. Specify parameters */
        // specify base URL
        let baseURL = UdacityConstants.udacityBaseURL
        
        // specify HTTP body (for POST method)
        let credentials: Dictionary = ["username" : username, "password" : password]
        let jsonBody : [String:AnyObject] = [
            "udacity" : credentials
        ]
        
        /* 2. Make the request */
        taskForPOSTMethod(UdacityConstants.ParseApiKey, baseUrl: baseURL, method: UdacityConstants.udacitySessionMethod, headerParameters: nil, queryParameters: nil, jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                /* Note: If the internet connection is offline, the system generates an NSError and the function returns here. */
                completionHandler(result: false, accountKey:"", error: error)
            } else {
                // parse the json response which looks like the following:
                if let account = JSONResult.valueForKey("account") as? [String : AnyObject] {
                    var registered = false
                    var key = ""
                    if let _registered = account["registered"] as? Bool {
                        registered = _registered
                        if let _key = account["key"] as? String {
                            key = _key
                        }
                    }
                    completionHandler(result: registered, accountKey:key, error: nil)
                } else {
                    var description = "Login error."
                    var code = 0
                    if let error = JSONResult.valueForKey("error") as? String {
                        description = error
                    }
                    if let resultCode = JSONResult.valueForKey("status") as? Int {
                        code = resultCode
                    }
                    completionHandler(result: false, accountKey:"", error: NSError(domain: "Udacity Login", code: code, userInfo: [NSLocalizedDescriptionKey: description]))
                }
            }
        }
    }
    
    /* Create a task to send an HTTP Post request */
    func taskForPOSTMethod(apiKey: String, baseUrl: String, method: String, headerParameters: [String : AnyObject]?, queryParameters: [String : AnyObject]?, jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = [String : AnyObject]()
        if let params = queryParameters {
            mutableParameters = params
        }
        if apiKey != "" {
            mutableParameters["api_key"] = apiKey
        }
        
        /* 2/3. Build the URL and configure the request */
        var urlString = baseUrl + method
        if mutableParameters.count > 0 {
            urlString += UdacityClient.escapedParameters(mutableParameters)
        }
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        // configure http header
        var jsonifyError: NSError? = nil
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let headerParameters = headerParameters {
            for (key,value) in headerParameters {
                request.addValue(key, forHTTPHeaderField: value as! String)
            }
        }
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
        } catch let error as NSError {
            jsonifyError = error
            request.HTTPBody = nil
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                jsonifyError = UdacityClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                // success
                var returnData = data
                
                // ignore first 5 characters for Udacity responses
                if baseUrl == UdacityConstants.udacityBaseURL {
                    returnData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                }
                
                UdacityClient.parseJSONWithCompletionHandler(returnData!, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    func taskForGETMethod(baseUrl: String, method: String, headerParameters: [String : AnyObject], queryParameters: [String : AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = [String : AnyObject]()
        if let params = queryParameters {
            mutableParameters = params
        }
        
        /* 2/3. Build the URL and configure the request */
        var urlString = baseUrl + method
        if mutableParameters.count > 0 {
            urlString += UdacityClient.escapedParameters(mutableParameters)
        }
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        // configure http header
        for (key,value) in headerParameters {
            request.addValue(key, forHTTPHeaderField: value as! String)
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                let newError = UdacityClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                // success
                var returnData = data
                
                // ignore first 5 characters for Udacity responses
                if baseUrl == UdacityConstants.udacityBaseURL {
                    returnData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                }
                
                UdacityClient.parseJSONWithCompletionHandler(returnData!, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
//        if let parsedResult = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? [String : AnyObject] {
//            
//            if let errorMessage = parsedResult["status_message"] as? String {
//                
//                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
//                
//                return NSError(domain: "REST service Error", code: 1, userInfo: userInfo)
//            }
//        }
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    func getUdacityUser(userID: String, completionHandler: (result: Bool, position: Position?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters */
        // none
        
        // set up http header parameters
        let headerParms = [
            UdacityConstants.ParseAppID : "X-Parse-Application-Id",
            UdacityConstants.ParseApiKey : "X-Parse-REST-API-Key"
        ]
        
        /* 2. Make the request */
        taskForGETMethod(UdacityConstants.udacityBaseURL, method: UdacityConstants.udacityGetUserMethod + userID, headerParameters: headerParms, queryParameters: nil) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                // didn't work. bubble up error.
                completionHandler(result: false, position: nil, error: error)
            } else {
                // parse the json response which looks like the following:
                var pos = Position()
                if let userDictionary = JSONResult.valueForKey("user") as? [String: AnyObject] {
                    if let lastName = userDictionary["last_name"] as? String {
                        pos.lastName = lastName
                    }
                    if let firstName = userDictionary["first_name"] as? String {
                        pos.firstName = firstName
                    }
                    if let url = userDictionary["website_url"] as? String{
                        pos.mediaURL = url
                    }
                    if let key = userDictionary["key"] as? String {
                        pos.uniqueKey = key
                    } else {
                        pos.uniqueKey = userID
                    }
                    completionHandler(result: true, position: pos, error: nil)
                } else {
                    completionHandler(result: false, position: nil, error: error)
                }
            }
        }
    }
    
    func postPosition(pos: Position, completionHandler: (result: Bool, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}) */
        // none
        
        // specify base URL
        let baseURL = UdacityConstants.parseBaseURL
        
        // set up http header parameters
        let headerParms = [
            UdacityConstants.ParseAppID : "X-Parse-Application-Id",
            UdacityConstants.ParseApiKey : "X-Parse-REST-API-Key"
        ]
        
        // create the HTTP body
        // enable parameterized values.
        let jsonBody : [String: AnyObject] = [
            "uniqueKey" : pos.uniqueKey,
            "firstName" : pos.firstName,
            "lastName" : pos.lastName,
            "mediaURL" : pos.mediaURL,
            "latitude" : pos.latitude,
            "longitude" : pos.longitude,
//            "createdAt" : self.parseDate(pos.createdAt),
//            "updatedAt" : pos.updatedAt,
            "mapString" : pos.mapString
        ]
        
        /* 2. Make the request */
        taskForPOSTMethod("", baseUrl: baseURL, method: UdacityConstants.parseGetPositions, headerParameters: headerParms, queryParameters: nil, jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(result: false, error: error)
            } else {
                // parse the json response which looks like the following:
                if let errorString = JSONResult.valueForKey("error") as? String {
                    // a valid response was received from the service, but the response contains an error code like the following:
                    let error = NSError(domain: "Parse POST response", code: 0, userInfo: [NSLocalizedDescriptionKey: errorString])
                    completionHandler(result: false, error: error)
                } else {
                    if (JSONResult.valueForKey("objectId") as? String) != nil {
                        completionHandler(result: true, error: nil)
                    } else {
                        completionHandler(result: false, error: NSError(domain: "parsing Parse POST response", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postToFavoritesList"]))
                    }
                }
            }
        }
    }
    
    func getPositions(skip: Int, limit: Int, completionHandler: (success: Bool, arrayOfPositionsDictionaries: [AnyObject]?, errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}) */
        let parameters = [
            "limit" : String(limit),
            "skip" : String(skip)
        ]
        
        // set up http header parameters
        let headerParms = [
            UdacityConstants.ParseAppID : "X-Parse-Application-Id",
            UdacityConstants.ParseApiKey : "X-Parse-REST-API-Key"
        ]
        
        /* 2. Make the request */
        taskForGETMethod(UdacityClient.UdacityConstants.parseBaseURL, method: UdacityClient.UdacityConstants.parseGetPositions, headerParameters: headerParms, queryParameters: parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                // Set error string to localizedDescription in error
                completionHandler(success: false, arrayOfPositionsDictionaries: nil, errorString: error.localizedDescription)
            } else {
                // parse the json response which looks like the following:
                if let arrayOfLocationDicts = JSONResult.valueForKey("results") as? [AnyObject] {
                    completionHandler(success: true, arrayOfPositionsDictionaries: arrayOfLocationDicts, errorString: nil)
                } else {
                    completionHandler(success: false, arrayOfPositionsDictionaries: nil, errorString: "No results from server.")
                }
            }
        }
    }
    
    func parseDate(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateStr = dateFormatter.stringFromDate(date)
        return dateStr
    }
}