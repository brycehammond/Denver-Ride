//
//  Station.m
//  RTD
//
//  Created by Bryce Hammond on 5/26/13.
//  Copyright (c) 2013 Fluidvision Design. All rights reserved.
//

#import "Station.h"
#import "Line.h"
#import "Stop.h"


@implementation Station

@synthesize currentDistance = _currentDistance,
    location = _location;

@dynamic latitude;
@dynamic name;
@dynamic longitude;
@dynamic hasWestbound;
@dynamic hasEastbound;
@dynamic hasNorthbound;
@dynamic hasSouthbound;
@dynamic stops;
@dynamic lines;

-(CLLocation *)location
{
    if(! _location)
    {
        _location = [[CLLocation alloc] initWithLatitude:[[self latitude] doubleValue] longitude:[[self longitude] doubleValue]];
    }
    
    return _location;
}

-(NSComparisonResult)compareAscending:(Station *)station
{
    if([self currentDistance] < [station currentDistance])
    {
        return NSOrderedAscending;
    }
    else if([self currentDistance] > [station currentDistance])
    {
        return NSOrderedDescending;
    }
    
    return NSOrderedSame;
}

@end
