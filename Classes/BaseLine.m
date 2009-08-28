//
//  BaseLine.m
//  RTD
//
//  Created by bryce.hammond on 8/10/09.
//  Copyright 2009 Wall Street On Demand, Inc.. All rights reserved.
//

#import "BaseLine.h"
#import "Stop.h"

@implementation BaseLine

+(void)createStopswithLines:(NSDictionary *)linesByName andStations:(NSDictionary *)stationsByName inContext:(NSManagedObjectContext *)context
{
	NSArray *newStops = [[self class] newStops];
	for(NSArray *stopArray in newStops)
	{
		Stop *stop = (Stop *)[NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:context];
		[stop setTimeInMinutes:[NSNumber numberWithInt:[[stopArray objectAtIndex:0] intValue]]];
		[stop setDirection:[stopArray objectAtIndex:1]];
		[stop setDayType:[stopArray objectAtIndex:2]];
		[stop setLine:[linesByName objectForKey:[stopArray objectAtIndex:3]]];
		[stop setStation:[stationsByName objectForKey:[stopArray objectAtIndex:4]]];
		[stop setRun:[NSNumber numberWithInt:[[stopArray objectAtIndex:5] intValue]]];
		[stop setTerminalStation:[stationsByName objectForKey:[stopArray objectAtIndex:6]]];
	}
	[newStops release];
}

+(NSArray *)newStops
{
	return [[NSArray alloc] init];
}

@end
