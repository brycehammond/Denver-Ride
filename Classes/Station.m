// 
//  Station.m
//  RTD
//
//  Created by bryce.hammond on 7/31/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import "Station.h"
#import "Line.h"
#import "Stop.h"


@implementation Station 

@synthesize currentDistance = _currentDistance,
			location = _location;

@dynamic longitude;
@dynamic name;
@dynamic latitude;
@dynamic lines;
@dynamic stops;
@dynamic direction;

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

- (void)dealloc
{
	[_location release];
	[super dealloc];
}

@end
