//
//  DatabaseLoader.m
//  RTD
//
//  Created by bryce.hammond on 11/24/10.
//  Copyright 2010 Fluidvision Design. All rights reserved.
//

#import "DatabaseLoader.h"
#import "RTDAppDelegate.h"
#import "Line.h"
#import "Station.h"
#import "Stop.h"

@interface DatabaseLoader (Private)

- (NSInteger)timeInMinutesForTimeString:(NSString *)timeString;

@end


@implementation DatabaseLoader

- (void)loadItUp
{
	NSError *error = nil;
	//read in the lines that we are interested in
	//don't load up information about things not related to this line
	NSArray *linesToProcess = [[NSString stringWithContentsOfFile:
								[[NSBundle mainBundle] pathForResource:@"linesToProcess" ofType:@"txt"] encoding:NSUTF8StringEncoding
															error:&error]
							   componentsSeparatedByString:@"\n"];
	
	
	
	RTDAppDelegate *appDelegate = (RTDAppDelegate *)[[UIApplication sharedApplication] delegate];
	
    NSMutableDictionary *dayTypeByTrip = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *lineByTrip = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *directionByTrip = [[NSMutableDictionary alloc] init];
    //get the trip info in for reference
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	NSMutableSet *relevantTrips = [[NSMutableSet alloc] init];
    
    NSString *trips = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"trips" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
    NSArray *fileLines = [trips componentsSeparatedByString:@"\n"];
    [trips release];
    trips = nil;
    
    for(NSUInteger lineIdx = 1; lineIdx < [fileLines count]; ++lineIdx)
    {
        NSArray *fields = [[fileLines objectAtIndex:lineIdx] componentsSeparatedByString:@","];
		if([linesToProcess containsObject:[fields objectAtIndex:0]])
		{
			NSString *tripId = [fields objectAtIndex:2];
			[dayTypeByTrip setObject:[fields objectAtIndex:1] forKey:tripId];
			[lineByTrip setObject:[fields objectAtIndex:0] forKey:tripId];
			[directionByTrip setObject:[fields objectAtIndex:4] forKey:tripId];
			[relevantTrips addObject:tripId];
		}
    }
         
    [pool release];
	
	//read in the lines (we currently only care about light rail)
	pool = [[NSAutoreleasePool alloc] init];
    
	NSMutableDictionary *linesById = [[NSMutableDictionary alloc] init];
	
    NSString *allLines = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"routes" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
    fileLines = [allLines componentsSeparatedByString:@"\n"];
    [allLines release];
    allLines = nil;
    for(NSUInteger lineIdx = 1; lineIdx < [fileLines count]; ++lineIdx)
    {
        NSArray *fields = [[fileLines objectAtIndex:lineIdx] componentsSeparatedByString:@","];
		if([linesToProcess containsObject:[fields objectAtIndex:0]])
		{
			Line *line = [NSEntityDescription insertNewObjectForEntityForName:@"Line"
													   inManagedObjectContext:[appDelegate managedObjectContext]];
			
			NSString *lineName = [fields objectAtIndex:0];
			
			[line setName:[lineName stringByReplacingOccurrencesOfString:@"101" withString:@""]];
			if([lineName hasPrefix:@"101"]) // is lightrail
			{
				[line setType:@"LR"];
			}
			else 
			{
				[line setType:@"B"];
			}

			[line setColor:[fields objectAtIndex:6]];
			
			[linesById setObject:line forKey:lineName];
		}
		
    }
	
	[[appDelegate managedObjectContext] save:&error];
	
    [pool release];
	
	pool = [[NSAutoreleasePool alloc] init];
	
	
	//Read in all the stations but don't create objects for them
	//only create Core Data objects for those that are needed for the routes we want
	NSMutableDictionary *stationFieldsByStationId = [[NSMutableDictionary alloc] init];
	
	
	NSString *allStations = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"stops" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
    fileLines = [allStations componentsSeparatedByString:@"\n"];
    [allStations release];
    allStations = nil;
    
    for(NSUInteger lineIdx = 1; lineIdx < [fileLines count]; ++lineIdx)
    {
        NSArray *fields = [[fileLines objectAtIndex:lineIdx] componentsSeparatedByString:@","];
		[stationFieldsByStationId setObject:fields forKey:[fields objectAtIndex:0]];
    }
	
	[pool release];
	
	pool = [[NSAutoreleasePool alloc] init];
	
	NSMutableDictionary *stationsById = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *stopsByTrip = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *directionsByStationId = [[NSMutableDictionary alloc] init];
	
	//now read in the stop times and create the stops and 
    NSString *allStopTimes = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"stop_times" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
	fileLines = [allStopTimes componentsSeparatedByString:@"\n"];
    [allStopTimes release];
    allStopTimes = nil;
	
	for(NSUInteger lineIdx = 1; lineIdx < [fileLines count]; ++lineIdx)
    {
        NSArray *fields = [[fileLines objectAtIndex:lineIdx] componentsSeparatedByString:@","];
		
		//we read the following in to an dictionary where the keys are the trip ids and the values
		//are the stops in order
		
		NSString *tripId = [fields objectAtIndex:0];
		//we only care about trips associted with the lines we want
		if([relevantTrips containsObject:tripId])
		{
			//see if we have a station for this stop
			NSString *stationId = [fields objectAtIndex:3];
			NSArray *stationFields = [stationFieldsByStationId objectForKey:stationId];
			
			NSString *stationName = [stationFields objectAtIndex:1];
			
			if([stationName hasSuffix:@" Station"])
			{
				stationName = [stationName stringByReplacingOccurrencesOfString:@" Station" withString:@""];
			}
			
			if([stationName hasSuffix:@" Stn"])
			{
				stationName = [stationName stringByReplacingOccurrencesOfString:@" Stn" withString:@""];
			}
			
			if([stationName hasSuffix:@" LRT NB"])
			{
				stationName = [stationName stringByReplacingOccurrencesOfString:@" LRT NB"
																	 withString:@""];
			}
			
			if([stationName hasSuffix:@" LRT SB"])
			{
				stationName = [stationName stringByReplacingOccurrencesOfString:@" LRT SB"
																	 withString:@""];
			}
			
			Station *station = [stationsById objectForKey:stationId];
			if(nil == station)
			{
				station = [NSEntityDescription insertNewObjectForEntityForName:@"Station"
														inManagedObjectContext:[appDelegate managedObjectContext]];
				
				
				[station setName:stationName];
				[station setLongitude:[NSNumber numberWithDouble:[[stationFields objectAtIndex:4] doubleValue]]];
				[station setLatitude:[NSNumber numberWithDouble:[[stationFields objectAtIndex:3] doubleValue]]];
				
				[stationsById setObject:station forKey:stationId];
				
			}
			
			NSMutableSet *stationDirections = [directionsByStationId objectForKey:stationId];
			if(nil == stationDirections)
			{
				stationDirections = [NSMutableSet set];
				[directionsByStationId setObject:stationDirections forKey:stationId];
			}
			
			[stationDirections addObject:[directionByTrip objectForKey:tripId]];
			
			//let's create the stop and add it to our array
			Stop *stop = [NSEntityDescription insertNewObjectForEntityForName:@"Stop"
													   inManagedObjectContext:[appDelegate managedObjectContext]];
			
			[stop setStation:station];
			[stop setRun:[NSNumber numberWithInt:[tripId intValue]]];
			[stop setDepartureTimeInMinutes:[NSNumber numberWithInt:[self timeInMinutesForTimeString:[fields objectAtIndex:2]]]];
			[stop setArrivalTimeInMinutes:[NSNumber numberWithInt:[self timeInMinutesForTimeString:[fields objectAtIndex:1]]]];
			[stop setStopSequence:[NSNumber numberWithInt:[[fields objectAtIndex:4] intValue]]];
			[stop setLine:[linesById objectForKey:[lineByTrip objectForKey:tripId]]];
			[stop setDayType:[dayTypeByTrip objectForKey:tripId]];
			
			NSString *direction = [directionByTrip objectForKey:tripId];
			if([direction isEqualToString:@"1"])
			{
				[stop setDirection:@"S"];
			}
			else 
			{
				[stop setDirection:@"N"];
			}

			
			NSMutableArray *stopsArray = [stopsByTrip objectForKey:tripId];
			if(nil == stopsArray)
			{
				stopsArray = [NSMutableArray array];
				[stopsByTrip setObject:stopsArray forKey:tripId];
			}
			
			[stopsArray addObject:stop];
		}

    }
	
	//go through and assign the direction to the station based to the 
	//directions of the trips for each station
	
	for(NSString *stationId in [directionsByStationId allKeys])
	{
		Station *station = [stationsById objectForKey:stationId];
		if(nil != station)
		{
			NSMutableSet *directions = [directionsByStationId objectForKey:stationId];
			if([directions count] > 0)
			{
				if([directions count] >= 2) //have more than one direction
				{
					[station setDirection:@"B"];
				}
				else
				{
					NSString *direction = [[directions allObjects] objectAtIndex:0];
					if([direction isEqualToString:@"1"])
					{
						[station setDirection:@"S"];
					}
					else 
					{
						[station setDirection:@"N"];
					}

				}
			}
		}
	}
	
	//assign the start and terminal stations based on the first
	//and last of the sequence
	for(NSMutableArray *stops in [stopsByTrip allValues])
	{
		[stops sortUsingSelector:@selector(sortBySequence:)];
		if([stops count] > 0)
		{
			Station *startStation = [[stops objectAtIndex:0] station];
			Station *stopStation = [[stops lastObject] station];
			
			for(Stop *stop in stops)
			{
				[stop setStartStation:startStation];
				[stop setTerminalStation:stopStation];
			}
		}
		
		
	}
    
    
	
	[pool release];
    
    [dayTypeByTrip release];
    [lineByTrip release];
	[directionByTrip release];
    [stationFieldsByStationId release];
    [stopsByTrip release];
    [directionsByStationId release];
    [stationsById release];
    [linesById release];
    [relevantTrips release];
	
	
	[[appDelegate managedObjectContext] save:&error];
	
}

@end
			 
@implementation DatabaseLoader (Private)

- (NSInteger)timeInMinutesForTimeString:(NSString *)timeString
{
	NSInteger timeInMinutes = 0;
	NSArray *components = [timeString componentsSeparatedByString:@":"];
	timeInMinutes += [[components objectAtIndex:0] intValue] * 60;
	timeInMinutes += [[components objectAtIndex:1] intValue];
	
	return timeInMinutes;
}

@end
