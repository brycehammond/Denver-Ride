//
//  UIStoryboard+DenverRide.m
//  RTD
//
//  Created by Bryce Hammond on 5/29/13.
//  Copyright (c) 2013 Fluidvision Design. All rights reserved.
//

#import "UIStoryboard+DenverRide.h"

@implementation UIStoryboard (DenverRide)

+ (UIStoryboard *)mainStoryboard
{
    return [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
}

+ (UIStoryboard *)stationStoryboard
{
    return [UIStoryboard storyboardWithName:@"StationStoryboard" bundle:nil];
}

@end
