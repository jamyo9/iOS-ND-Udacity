
import Foundation

class Positions {
    
    /* An array of position objects where each describes the location of a student.*/
    var positions = [Position]()
    
    /* This class is instantiated as a Singleton. This function returns the singleton instance. */
    class func sharedInstance() -> Positions {
        
        struct Singleton {
            static var sharedInstance = Positions()
        }
        
        return Singleton.sharedInstance
    }
    
    /*
     @brief Empty this object's collection of position objects.
     */
    func reset() {
        positions.removeAll(keepCapacity: false)
    }
    
    /*
     @brief Get an array of position dictionaries from Parse and update this object's positions collection.
     @discussion This function will recursively call itself, retrieving a limitted number of records on each query, until all records have been acquired from the Parse service.
     @param (in) skip - The number of records to skip when reporting results of the query. To obtain all results use 0.
     */
    func getPositions(skip: Int, completion: (result: Bool, errorString: String?) -> Void) {
        
        var toSkip = skip   // number of records to skip when reporting results of the query
        let limit = 100     // maximum number of records to return from a query

        UdacityClient.sharedInstance().getPositions(toSkip, limit: limit) { success, arrayOfPositionDictionaries, errorString in
            if errorString == nil {
                if let array = arrayOfPositionDictionaries as? [[String: AnyObject]] {
                    
                    // Update collection of position with the new data from Parse.
                    for posDictionary in array {
                        // create a position object and add it to this object's collection.
                        let studentLoc = Position(dictionary: posDictionary)
                        self.positions.append(studentLoc)
                    }
                    
                    // Call this function recursively until it the count of retrieved objects < limit. Increment skip by limit each successive query.
                    if let count = arrayOfPositionDictionaries?.count {
                        if count == limit {
                            // There may be more items to retrieve. Query the next batch.
                            toSkip += limit
                            
                            // recursive call
                            self.getPositions(toSkip) { success, errorString in
                                if success == false {
                                    // sort the retrieved array
                                    self.sortList()
                                    
                                    // Send a notification indicating new position data has been obtained from Parse.
                                    NSNotificationCenter.defaultCenter().postNotificationName("positionsUpdateNotificationKey", object: self)
                                    
                                    // Fail gracefully by reporting the records that were successfully retrieved prior to the error.
                                    completion(result:true, errorString: nil)
                                } else {
                                    // successfully retrieved locations, and already added to self.positions.
                                    
                                    // sort the retrieved array
                                    self.sortList()
                                }
                            }
                        } else {
                            // All items have been retrieved. Now send notification and call completion handler.
                            
                            // sort the retrieved array
                            self.sortList()
                            
                            // Send a notification indicating new position data has been obtained from Parse.
                            NSNotificationCenter.defaultCenter().postNotificationName("positionsUpdateNotificationKey", object: self)
                            
                            completion(result:true, errorString: nil)
                        }
                    }
                    
                    print("Total positions: \(self.positions.count)")
                } else {
                    // Server responded with success, but a nil array. Do not update local positions.
                    print("new position data returned a nil array")
                    completion(result:true, errorString: nil)
                }
            }
            else {
                print("error getPositions()")
                completion(result:false, errorString: errorString)
            }
        }
    }
    
    /* sort list by date */
    func sortList() {
        self.positions.sortInPlace {
            $0.firstName.localizedCaseInsensitiveCompare($1.firstName) == NSComparisonResult.OrderedDescending
        }
    }
    
    /* debug helper function */
    func printList() {
        for pos in positions {
            print("\(pos.firstName) \(pos.lastName)")
        }
    }
}