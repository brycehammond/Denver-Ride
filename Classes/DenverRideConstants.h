//
//  DenverRideConstants.h
//  RTD
//
//  Created by Bryce Hammond on 10/25/12.
//  Copyright (c) 2012 Fluidvision Design. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBackgroundColor @"D7D7D7"
#define kBasePath @"http://www.improbabilitydrive.com/RTD/2.0/"
#define kLastUpdateDateKey	@"LastUpdateDateKey"
#define kLastUpdateDate @"20130526"
#define kNavBarHeight   44
#define kSelectorHeight 61
#define kStatusBarHeight    20
#define kNavBarColor @"70A96A"
#define kCurrentDirectionKey @"CurrentDirection"

@interface DenverRideConstants : NSObject

+ (NSInteger)shortContainerHeight;
+ (NSInteger)tallContainerHeight;

@end
