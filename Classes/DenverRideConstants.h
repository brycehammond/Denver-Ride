//
//  DenverRideConstants.h
//  RTD
//
//  Created by Bryce Hammond on 10/25/12.
//  Copyright (c) 2012 Fluidvision Design. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBackgroundColor @"D7D7D7"
#define kBasePath @"http://denverride.s3.amazonaws.com/3.0/"
#define kLastUpdateDateKey	@"LastUpdateDateKey"
#define kLastUpdateDate @"20140106"
#define kNavBarHeight   44
#define kSelectorHeight 61
#define kStatusBarHeight    20
#define kNavBarColor @"70A96A"
#define kCurrentDirectionKey @"CurrentDirection"
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

typedef enum {
	FORWARD = 0,
	BACKWARD = 1
} DRTimeDirection;

@interface DenverRideConstants : NSObject

+ (NSInteger)shortContainerHeight;
+ (NSInteger)tallContainerHeight;

@end
