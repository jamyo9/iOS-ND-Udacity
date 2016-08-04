//
//  House.h
//  House
//
//  Created by Juan Alvarez on 20/7/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface House : NSObject

@property (nonatomic, copy) NSString *address;
@property (nonatomic, readonly) int numberOfBedrooms;
@property (nonatomic) BOOL hasHotTub;

@end
