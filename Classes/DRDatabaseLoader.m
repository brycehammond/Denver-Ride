//
//  DatabaseLoader.m
//  RTD
//
//  Created by bryce.hammond on 11/24/10.
//  Copyright 2010 Fluidvision Design. All rights reserved.
//

#import "DRDatabaseLoader.h"
#import "RTDAppDelegate.h"
#import "Line.h"
#import "Station.h"
#import "Stop.h"

@interface DRDatabaseLoader (Private)

- (NSInteger)timeInMinutesForTimeString:(NSString *)timeString;

@end


@implementation DRDatabaseLoader

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
        NSString *lineName = fields[0];
		if([linesToProcess containsObject:lineName])
		{
			NSString *tripId = fields[2];
            
			dayTypeByTrip[tripId] = fields[1];
			lineByTrip[tripId] = fields[0];
            
            NSString *direction = @"";
            if([lineName hasPrefix:@"101"] || [lineName hasPrefix:@"113"])
            {
                //North/Southbound
                direction = [fields[4] isEqualToString:@"1"] ? @"S" : @"N";
            }
            else
            {
                //West/Eastbound
                direction = [fields[4] isEqualToString:@"1"] ? @"W" : @"E";
            }
            
            
            if([lineName hasPrefix:@"113"]) {
                NSLog(@"Trip ID: %@", tripId);
            }
            
			directionByTrip[tripId] = direction;
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
			
            NSString *commonName = [lineName copy];
            
            commonName = [commonName stringByReplacingOccurrencesOfString:@"101" withString:@""];
            commonName = [commonName stringByReplacingOccurrencesOfString:@"103" withString:@""];
            commonName = [commonName stringByReplacingOccurrencesOfString:@"113" withString:@""];
            
			[line setName:commonName];
			if([lineName hasPrefix:@"101"] || [lineName hasPrefix:@"103"] || [@[@"A",@"113B"] containsObject:lineName] ) // is lightrail
			{
				[line setType:@"LR"];
			}
			else 
			{
				[line setType:@"B"];
			}
            
            if([lineName isEqualToString:@"103W"])
            {
                [line setColor:@"00B9B0"];
            }
            else if([lineName isEqualToString:@"A"])
            {
                [line setColor:@"57C1E9"];
            }
            else
            {
               [line setColor:fields[6]];
            }

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
	
	NSMutableDictionary *stationsByName = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *stopsByTrip = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *directionsByStationName = [[NSMutableDictionary alloc] init];
	
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
			
			NSString *stationName = stationFields[2];
			
			if([stationName hasSuffix:@" Station"])
			{
				stationName = [stationName stringByReplacingOccurrencesOfString:@" Station" withString:@""];
			}
            else if([stationName hasSuffix:@" Track 1"])
            {
                stationName = [stationName stringByReplacingOccurrencesOfString:@" Track 1" withString:@""];
            }
            else if([stationName hasSuffix:@" Track 2"])
            {
                stationName = [stationName stringByReplacingOccurrencesOfString:@" Track 2" withString:@""];
            }
            else if([stationName hasSuffix:@" Track 3"])
            {
                stationName = [stationName stringByReplacingOccurrencesOfString:@" Track 3" withString:@""];
            }
            else if([stationName hasSuffix:@" Track 8"])
            {
                stationName = [stationName stringByReplacingOccurrencesOfString:@" Track 8" withString:@""];
            }
            else if([stationName hasSuffix:@" Stn"])
			{
				stationName = [stationName stringByReplacingOccurrencesOfString:@" Stn" withString:@""];
			}
			else if([stationName hasSuffix:@" LRT NB"] || [stationName hasSuffix:@" LRT Nb"] || [stationName hasSuffix:@" N-Bound"])
			{
				stationName = [stationName stringByReplacingOccurrencesOfString:@" LRT NB"
																	 withString:@""];
                
                stationName = [stationName stringByReplacingOccurrencesOfString:@" LRT Nb"
																	 withString:@""];
                
                stationName = [stationName stringByReplacingOccurrencesOfString:@" N-Bound"
                                                                     withString:@""];
                
			}
            else if([stationName hasSuffix:@" LRT SB"] || [stationName hasSuffix:@"LRT Sb"] || [stationName hasSuffix:@" S-Bound"])
			{
				stationName = [stationName stringByReplacingOccurrencesOfString:@" LRT SB"
																	 withString:@""];
                stationName = [stationName stringByReplacingOccurrencesOfString:@" LRT Sb"
																	 withString:@""];
                stationName = [stationName stringByReplacingOccurrencesOfString:@" S-Bound"
                                                                     withString:@""];
			}
            
            if([stationName isEqualToString:@"Union"])
            {
                stationName = @"Union Station";
            }
            
            NSRange seperatorRange = [stationName rangeOfString:@" -"];
            if(seperatorRange.location != NSNotFound)
            {
                stationName = [stationName substringToIndex:seperatorRange.location];
            }
			
			Station *station = stationsByName[stationName];
			if(nil == station)
			{
				station = [NSEntityDescription insertNewObjectForEntityForName:@"Station"
														inManagedObjectContext:[appDelegate managedObjectContext]];
				
				
				[station setName:stationName];
				[station setLongitude:[NSDecimalNumber decimalNumberWithString:stationFields[5]]];
				[station setLatitude:[NSDecimalNumber decimalNumberWithString:stationFields[4]]];
				
				stationsByName[stationName] = station;
				
			}
			
			NSMutableSet *stationDirections = directionsByStationName[stationName];
			if(nil == stationDirections)
			{
				stationDirections = [NSMutableSet set];
				directionsByStationName[stationName] = stationDirections;
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
            stop.direction = directionByTrip[tripId];

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
	
	for(NSString *stationName in [directionsByStationName allKeys])
	{
		Station *station = stationsByName[stationName];
		if(nil != station)
		{
			NSMutableSet *directions = directionsByStationName[stationName];
            
            if([directions containsObject:@"S"])
            {
                station.hasSouthbound = [NSNumber numberWithBool:YES];
            }
            
            if([directions containsObject:@"W"])
            {
                station.hasWestbound = [NSNumber numberWithBool:YES];
            }
            
            if([directions containsObject:@"N"])
            {
                station.hasNorthbound = [NSNumber numberWithBool:YES];
            }
            
            if([directions containsObject:@"E"])
            {
                station.hasEastbound = [NSNumber numberWithBool:YES];
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
			Station *startStation = [stops.firstObject station];
			Station *stopStation = [stops.lastObject station];
			
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
			 
@implementation DRDatabaseLoader (Private)

- (NSInteger)timeInMinutesForTimeString:(NSString *)timeString
{
	NSInteger timeInMinutes = 0;
	NSArray *components = [timeString componentsSeparatedByString:@":"];
	timeInMinutes += [components[0] intValue] * 60;
	timeInMinutes += [components[1] intValue];
	
	return timeInMinutes;
}

@end
