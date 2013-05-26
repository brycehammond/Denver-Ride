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
    
	NSMutableSet *relevantTrips = [[NSMutableSet alloc] init];
    
    NSString *trips = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"trips" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
    NSArray *fileLines = [trips componentsSeparatedByString:@"\n"];
    trips = nil;
    
    for(NSUInteger lineIdx = 1; lineIdx < [fileLines count]; ++lineIdx)
    {
        NSArray *fields = [fileLines[lineIdx] componentsSeparatedByString:@","];
		if([linesToProcess containsObject:fields[0]])
		{
			NSString *tripId = fields[2];
			dayTypeByTrip[tripId] = fields[1];
			lineByTrip[tripId] = fields[0];
			directionByTrip[tripId] = fields[4];
			[relevantTrips addObject:tripId];
		}
    }
	
	//read in the lines (we currently only care about light rail)
    
	NSMutableDictionary *linesById = [[NSMutableDictionary alloc] init];
	
    NSString *allLines = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"routes" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
    fileLines = [allLines componentsSeparatedByString:@"\n"];
    allLines = nil;
    for(NSUInteger lineIdx = 1; lineIdx < [fileLines count]; ++lineIdx)
    {
        NSArray *fields = [fileLines[lineIdx] componentsSeparatedByString:@","];
		if([linesToProcess containsObject:fields[0]])
		{
			Line *line = [NSEntityDescription insertNewObjectForEntityForName:@"Line"
													   inManagedObjectContext:[appDelegate managedObjectContext]];
			
			NSString *lineName = fields[0];
			
			[line setName:[[lineName stringByReplacingOccurrencesOfString:@"101" withString:@""] stringByReplacingOccurrencesOfString:@"103" withString:@""]];
			if([lineName hasPrefix:@"101"] || [lineName hasPrefix:@"103"]) // is lightrail
			{
				[line setType:@"LR"];
			}
			else 
			{
				[line setType:@"B"];
			}

			[line setColor:fields[6]];
			
			linesById[lineName] = line;
		}
		
    }
	
	[[appDelegate managedObjectContext] save:&error];
	
	
	
	//Read in all the stations but don't create objects for them
	//only create Core Data objects for those that are needed for the routes we want
	NSMutableDictionary *stationFieldsByStationId = [[NSMutableDictionary alloc] init];
	
	
	NSString *allStations = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"stops" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
    fileLines = [allStations componentsSeparatedByString:@"\n"];
    allStations = nil;
    
    for(NSUInteger lineIdx = 1; lineIdx < [fileLines count]; ++lineIdx)
    {
        NSArray *fields = [fileLines[lineIdx] componentsSeparatedByString:@","];
		stationFieldsByStationId[fields[0]] = fields;
    }
	
	NSMutableDictionary *stationsById = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *stopsByTrip = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *directionsByStationId = [[NSMutableDictionary alloc] init];
	
	//now read in the stop times and create the stops and 
    NSString *allStopTimes = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"stop_times" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
	fileLines = [allStopTimes componentsSeparatedByString:@"\n"];
    allStopTimes = nil;
	
	for(NSUInteger lineIdx = 1; lineIdx < [fileLines count]; ++lineIdx)
    {
        NSArray *fields = [fileLines[lineIdx] componentsSeparatedByString:@","];
		
		//we read the following in to an dictionary where the keys are the trip ids and the values
		//are the stops in order
		
		NSString *tripId = fields[0];
		//we only care about trips associted with the lines we want
		if([relevantTrips containsObject:tripId])
		{
			//see if we have a station for this stop
			NSString *stationId = fields[3];
			NSArray *stationFields = stationFieldsByStationId[stationId];
			
			NSString *stationName = stationFields[1];
			
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
			
			Station *station = stationsById[stationId];
			if(nil == station)
			{
				station = [NSEntityDescription insertNewObjectForEntityForName:@"Station"
														inManagedObjectContext:[appDelegate managedObjectContext]];
				
				
				[station setName:stationName];
				[station setLongitude:@([stationFields[4] doubleValue])];
				[station setLatitude:@([stationFields[3] doubleValue])];
				
				stationsById[stationId] = station;
				
			}
			
			NSMutableSet *stationDirections = directionsByStationId[stationId];
			if(nil == stationDirections)
			{
				stationDirections = [NSMutableSet set];
				directionsByStationId[stationId] = stationDirections;
			}
			
			[stationDirections addObject:directionByTrip[tripId]];
			
			//let's create the stop and add it to our array
			Stop *stop = [NSEntityDescription insertNewObjectForEntityForName:@"Stop"
													   inManagedObjectContext:[appDelegate managedObjectContext]];
			
			[stop setStation:station];
			[stop setRun:@([tripId intValue])];
			[stop setDepartureTimeInMinutes:@([self timeInMinutesForTimeString:fields[2]])];
			[stop setArrivalTimeInMinutes:@([self timeInMinutesForTimeString:fields[1]])];
			[stop setStopSequence:@([fields[4] intValue])];
			[stop setLine:linesById[lineByTrip[tripId]]];
			[stop setDayType:dayTypeByTrip[tripId]];
			
            //0 is East/North and 1 is West/South
            
			NSString *direction = directionByTrip[tripId];
			if([direction isEqualToString:@"1"])
			{
				[stop setDirection:@"S"];
			}
			else 
			{
				[stop setDirection:@"N"];
			}

			
			NSMutableArray *stopsArray = stopsByTrip[tripId];
			if(nil == stopsArray)
			{
				stopsArray = [NSMutableArray array];
				stopsByTrip[tripId] = stopsArray;
			}
			
			[stopsArray addObject:stop];
		}

    }
	
	//go through and assign the direction to the station based to the 
	//directions of the trips for each station
	
	for(NSString *stationId in [directionsByStationId allKeys])
	{
		Station *station = stationsById[stationId];
		if(nil != station)
		{
			NSMutableSet *directions = directionsByStationId[stationId];
			if([directions count] > 0)
			{
				if([directions count] >= 2) //have more than one direction
				{
					[station setDirection:@"B"];
				}
				else
				{
                    
                    //0 is East/North and 1 is West/South
                    
					NSString *direction = [directions allObjects][0];
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
			Station *startStation = [stops[0] station];
			Station *stopStation = [[stops lastObject] station];
			
			for(Stop *stop in stops)
			{
				[stop setStartStation:startStation];
				[stop setTerminalStation:stopStation];
			}
		}
	}
    
    
	
	[[appDelegate managedObjectContext] save:&error];
	
}

@end
			 
@implementation DatabaseLoader (Private)

- (NSInteger)timeInMinutesForTimeString:(NSString *)timeString
{
	NSInteger timeInMinutes = 0;
	NSArray *components = [timeString componentsSeparatedByString:@":"];
	timeInMinutes += [components[0] intValue] * 60;
	timeInMinutes += [components[1] intValue];
	
	return timeInMinutes;
}

@end
