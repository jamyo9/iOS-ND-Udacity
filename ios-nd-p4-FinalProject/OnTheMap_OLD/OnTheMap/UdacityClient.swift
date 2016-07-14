//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Juan Alvarez on 5/7/16.
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
    
    /* Create a task to send an HTTP Get request */
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
                if baseUrl == Constants.udacityBaseURL {
                    returnData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                }
                
                UdacityClient.parseJSONWithCompletionHandler(returnData!, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    /* Create a task to send an HTTP Post request */
    func taskForPOSTMethod(apiKey: String, baseUrl: String, method: String, headerParameters: [String : AnyObject]?, queryParameters: [String : AnyObject]?, jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = [String : AnyObject]()
        if let params = queryParameters {
            mutableParameters = params
        }
        if apiKey != "" {
            mutableParameters["api_key"/*ParameterKeys.ApiKey*/] = apiKey
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
                if baseUrl == Constants.udacityBaseURL {
                    returnData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                }
                
                UdacityClient.parseJSONWithCompletionHandler(returnData!, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        print(data)
        print(error)
        print(response)
        if let parsedResult = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult["status_message"] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "REST service Error", code: 1, userInfo: userInfo)
            }
        }
        
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
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
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
    
    func loginUdacity(username: String, password: String, completionHandler: (result: Bool, accountKey: String, error: NSError?) -> Void) {
        
        /* 1. Specify parameters */
        // specify base URL
        let baseURL = Constants.udacityBaseURL
        
        // specify HTTP body (for POST method)
        let credentials: Dictionary = ["username" : username, "password" : password]
        let jsonBody : [String:AnyObject] = [
            "udacity" : credentials
        ]
        
        /* 2. Make the request */
        taskForPOSTMethod(UdacityClient.Constants.ParseApiKey, baseUrl: baseURL, method: UdacityClient.Constants.udacitySessionMethod, headerParameters: nil, queryParameters: nil, jsonBody: jsonBody) { JSONResult, error in
            
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
                    /* The Login request received a valid response, but the Login failed. The following are error responses from the Udacity service for typical failures:
                     
                     // On nonexistant account, or invalid credentials
                     {"status": 403, "error": "Account not found or invalid credentials."}
                     
                     // On missing username
                     {"status": 400, "parameter": "udacity.username", "error": "trails.Error 400: Missing parameter 'username'"}
                     
                     // On missing password
                     {"status": 400, "parameter": "udacity.password", "error": "trails.Error 400: Missing parameter 'password'"}
                     */
                    
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
    
    func getUdacityUser(userID: String, completionHandler: (result: Bool, studentLocation: StudentLocation?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters */
        // none
        
        // set up http header parameters
        let headerParms = [
            Constants.ParseAppID : "X-Parse-Application-Id",
            Constants.ParseApiKey : "X-Parse-REST-API-Key"
        ]
        
        /* 2. Make the request */
        taskForGETMethod(UdacityClient.Constants.udacityBaseURL, method: UdacityClient.Constants.udacityGetUserMethod + userID, headerParameters: headerParms, queryParameters: nil) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                // didn't work. bubble up error.
                completionHandler(result: false, studentLocation: nil, error: error)
            } else {
                // parse the json response which looks like the following:
                var userLocation = StudentLocation()
                userLocation.uniqueKey = userID
                if let userDictionary = JSONResult.valueForKey("user") as? [String: AnyObject] {
                    if let lastName = userDictionary["last_name"] as? String {
                        userLocation.lastName = lastName
                    }
                    if let firstName = userDictionary["first_name"] as? String {
                        userLocation.firstName = firstName
                    }
                    if let url = userDictionary["website_url"] as? String{
                        userLocation.mediaURL = url
                    }
                    if let key = userDictionary["key"] as? String {
                        userLocation.uniqueKey = key
                    }
                    completionHandler(result: true, studentLocation: userLocation, error: nil)
                } else {
                    completionHandler(result: false, studentLocation: nil, error: error)
                }
            }
        }
    }
    
    func getStudentLocations(skip: Int, limit: Int, completionHandler: (success: Bool, arrayOfLocationDictionaries: [AnyObject]?, errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}) */
        var parameters = [
            "limit" : String(limit),
            "skip" : String(skip)
        ]
        
        // set up http header parameters
        let headerParms = [
            Constants.ParseAppID : "X-Parse-Application-Id",
            Constants.ParseApiKey : "X-Parse-REST-API-Key"
        ]
        
        /* 2. Make the request */
        taskForGETMethod(UdacityClient.Constants.parseBaseURL, method: UdacityClient.Constants.parseGetStudentLocations, headerParameters: headerParms, queryParameters: parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                // Set error string to localizedDescription in error
                completionHandler(success: false, arrayOfLocationDictionaries: nil, errorString: error.localizedDescription)
            } else {
                // parse the json response which looks like the following:
                /*
                 {
                 "results":[
                 {
                 "createdAt": "2015-02-25T01:10:38.103Z",
                 "firstName": "Jarrod",
                 "lastName": "Parkes",
                 "latitude": 34.7303688,
                 "longitude": -86.5861037,
                 "mapString": "Huntsville, Alabama ",
                 "mediaURL": "https://www.linkedin.com/in/jarrodparkes",
                 "objectId": "JhOtcRkxsh",
                 "uniqueKey": "996618664",
                 "updatedAt": "2015-03-09T22:04:50.315Z"
                 },
                 ...
                 ]
                 }
                 */
                if let arrayOfLocationDicts = JSONResult.valueForKey("results") as? [AnyObject] {
                    completionHandler(success: true, arrayOfLocationDictionaries: arrayOfLocationDicts, errorString: nil)
                } else {
                    completionHandler(success: false, arrayOfLocationDictionaries: nil, errorString: "No results from server.")
                }
            }
        }
    }
}