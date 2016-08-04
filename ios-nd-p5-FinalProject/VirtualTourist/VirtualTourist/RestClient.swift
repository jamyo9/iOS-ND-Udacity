//
//  RestClient.swift
//  Virtual Tourist
//

import Foundation
import MapKit

class RestClient: NSObject {
    
    func taskForPhotosSearch(pin: Pin, completionHandler: (result: AnyObject?, errorString: String?) -> Void) {
        
        // Specify the header fields and query parameters
        let headerFields = [String:String]()
        
        var page = 1
        
        if pin.totalPages as! Int > 0 {
            page = Int(arc4random_uniform(UInt32(min(40,pin.totalPages as! Int)))) + 1
        }
        
        let queryParameters: [String:AnyObject] = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.Lat: pin.getLatitude(),
            Constants.FlickrParameterKeys.Lon: pin.getLongitude(),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.PerPage: Constants.FlickrParameterValues.PerPage,
            Constants.FlickrParameterKeys.Page: page
        ]
        
        let urlString = Constants.Flickr.APIScheme + "://" + Constants.Flickr.APIHost + "/" + Constants.Flickr.APIPath
        
        VTClient.sharedInstance().taskForGetMethod(urlString, headerFields: headerFields, queryParameters: queryParameters) { (data, error) in
            
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
                
                if let totalPages = photos["pages"] as? Int {
                    CoreDataStack.sharedInstance().context.performBlock {
                        pin.totalPages = totalPages
                        CoreDataStack.sharedInstance().saveContext()
                    }
                } else {
                    completionHandler(result : nil, errorString: "Cannot find key 'pages' in \(photos)")
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