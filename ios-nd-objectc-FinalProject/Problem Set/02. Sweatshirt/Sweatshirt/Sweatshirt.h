//
//  Sweatshirt.h
//  Sweatshirt
//
//  Created by Gabrielle Miller-Messner on 4/12/16.
//  Copyright © 2016 Gabrielle Miller-Messner. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ShirtSize) {
    XSmall,
    Small,
    Medium,
    Large,
    XLarge
};

@interface Sweatshirt : NSObject

@property (nonatomic) BOOL * _Nonnull hasHood;
@property (nonatomic) BOOL * _Nonnull clean;
@property (nonatomic) ShirtSize * _Nonnull size;
@property (nonatomic) NSUInteger * _Nonnull softness;


-(instancetype _Nonnull)initWithSize:(ShirtSize * _Nonnull)size
                    hasHood:(BOOL)hoody;

@end
