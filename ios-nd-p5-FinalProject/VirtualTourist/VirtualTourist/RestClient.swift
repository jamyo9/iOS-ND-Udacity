//
//  RestClient.swift
//  Virtual Tourist
//
//  Created by Patrick Bellot on 3/28/16.
//  Copyright © 2016 Bell OS, LLC. All rights reserved.
//

import Foundation
import MapKit

class RestClient: NSObject {
    
    func taskForPhotosSearch(pin: Pin, completionHandler: (result: AnyObject?, errorString: String?) -> Void) {
        
        // Specify the header fields and query parameters
        let headerFields = [String:String]()
        
        let queryParameters: [String:AnyObject] = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.Lat: pin.getLatitude(),
            Constants.FlickrParameterKeys.Lon: pin.getLongitude(),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        
        let urlString = Constants.Flickr.APIScheme + "://" + Constants.Flickr.APIHost + "/" + Constants.Flickr.APIPath
        
        let restClient = VTClient.sharedInstance()
        restClient.taskForGetMethod(urlString, headerFields: headerFields, queryParameters: queryParameters) { (data, error) in
            
            if let _ = error {
                completionHandler(result: nil, errorString: "Failed to retrieve photos")
            } else {
                
                guard let JSONResult = VTClient.parseJSONWithCompletionHandler(data!) else {
                    completionHandler(result: nil, errorString: "Cannot parse data on JSON!")
                    return
                }
                
                guard let stat = JSONResult["stat"] as? String where stat == "ok" else {
                    let message = JSONResult["message"] as? String
                    completionHandler(result: nil, errorString: message)
                    return
                }
                
                guard let photos = JSONResult["photos"] as? [String:AnyObject] else {
                    completionHandler(result: nil, errorString: "Cannot find key 'photos' in JSON")
                    return
                }
                
                completionHandler(result: photos, errorString: nil)
            }
        }
    }
    
    func taskForImageDownload(photoURL: String, completionHandler: (imageData: NSData?, errorString: String?) -> Void) {
        
        VTClient.sharedInstance().taskForGetMethod(photoURL, headerFields: [String:String](), queryParameters: nil) { (data, error) in
            
            if let _ = error {
                completionHandler(imageData: nil, errorString: "Failed to download photo with url \(photoURL)")
            } else {
                completionHandler(imageData: data, errorString: nil)
            }
        }
    }
    
    class func sharedInstance() -> RestClient {
        
        struct Singleton {
            static var sharedInstance = RestClient()
        }
        
        return Singleton.sharedInstance
    }
    
}