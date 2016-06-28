//
//  DenverRideConstants.h
//  RTD
//
//  Created by Bryce Hammond on 10/25/12.
//  Copyright (c) 2012 Fluidvision Design. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBackgroundColor @"D7D7D7"
#define kBasePath @"http://denverride.s3.amazonaws.com/3.1/"
#define kLastUpdateDateKey	@"LastUpdateDateKey"
#define kLastUpdateDate @"20160626"
#define kSelectorHeight 61
#define kNavBarColor @"70A96A"
#define kCurrentDirectionKey @"CurrentDirection"

typedef enum {
	FORWARD = 0,
	BACKWARD = 1
} DRTimeDirection;

@interface DenverRideConstants : NSObject

@end
