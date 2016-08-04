//
//  PlaneTicket.h
//  PlaneTicket
//
//  Created by Gabrielle Miller-Messner on 4/12/16.
//  Copyright © 2016 Gabrielle Miller-Messner. All rights reserved.
//

@import Foundation;
#import "Passenger.h"

@interface PlaneTicket : NSObject

@property (nonatomic, copy, nullable) NSString *departureCity;
@property (nonatomic, copy, nullable) NSString *destination;
@property (nonatomic, nullable)       NSDate *departureDate;
@property (nonatomic, copy, nullable) NSString *seatAssignment;
@property (nonatomic, nullable) Passenger *passenger;

-(instancetype)initWithDestination:(NSString*)destination
                     departureCity:(NSString*)departureCity
                         passenger:(Passenger*)person
                              date:(NSDate*)departureDate;

@end
