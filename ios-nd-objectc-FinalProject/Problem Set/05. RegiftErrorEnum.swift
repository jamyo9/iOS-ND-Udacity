//
//  RegiftErrorEnum.swift
//  
//
//  Created by Gabrielle Miller-Messner on 4/14/16.
//
//

import Foundation

// Errors thrown by Regift
@objc public enum RegiftError: Int, ErrorType {
    case DestinationNotFound = 996 //"The temp file destination could not be created or found"
    case AddFrameToDestination = 997 //"An error occurred when adding a frame to the destination"
    case DestinationFinalize = 998 //"An error occurred when finalizing the destination"
}
