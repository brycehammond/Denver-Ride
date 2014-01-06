//
//  DenverRideConstants.m
//  RTD
//
//  Created by Bryce Hammond on 10/25/12.
//  Copyright (c) 2012 Fluidvision Design. All rights reserved.
//

#import "DenverRideConstants.h"

@implementation DenverRideConstants

+ (NSInteger)shortContainerHeight
{
    if(IS_OS_7_OR_LATER)
    {
        return [[UIScreen mainScreen] bounds].size.height - kNavBarHeight - kSelectorHeight;
    }
    else
    {
        return [[UIScreen mainScreen] bounds].size.height - kNavBarHeight - kSelectorHeight - kStatusBarHeight;
    }
}

+ (NSInteger)tallContainerHeight
{
    if(IS_OS_7_OR_LATER)
    {
        return [[UIScreen mainScreen] bounds].size.height - kSelectorHeight;
    }
    else
    {
        return [[UIScreen mainScreen] bounds].size.height - kSelectorHeight - kStatusBarHeight;
    }

}

@end
