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
    return [[UIScreen mainScreen] bounds].size.height - kNavBarHeight - kSelectorHeight - kStatusBarHeight;
}

+ (NSInteger)tallContainerHeight
{
    return [[UIScreen mainScreen] bounds].size.height - kSelectorHeight - kStatusBarHeight;

}

@end
