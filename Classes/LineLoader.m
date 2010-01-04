//
//  LineLoader.m
//  RTD
//
//  Created by bryce.hammond on 9/21/09.
//  Copyright 2009 Fluidvisiong Design. All rights reserved.
//

#import "LineLoader.h"
#import "Stop.h"
#import "Station.h"
#import "Line.h"


@implementation LineLoader

+(void)loadStopData:(NSString *)stopData withLinesByName:(NSDictionary *)linesByName 
	andStationsByID:(NSDictionary *)stationsByID inManagedObjectContext:(NSManagedObjectContext *)context
{
	
	BOOL haveDeletedCurrentData = NO;
	
	NSArray *stops = [stopData componentsSeparatedByString:@"\n"];
	for(NSString *stopEntry in stops)
	{
		NSArray *stopArray = [stopEntry componentsSeparatedByString:@","];
		
		if([stopArray count] >= 7)
		{
			Stop *stop = (Stop *)[NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:context];
			[stop setTimeInMinutes:[NSNumber numberWithInt:[[stopArray objectAtIndex:0] intValue]]];
			[stop setDirection:[stopArray objectAtIndex:1]];
			[stop setDayType:[stopArray objectAtIndex:2]];
			[stop setLine:[linesByName objectForKey:[stopArray objectAtIndex:3]]];
			[stop setStation:[stationsByID objectForKey:[NSNumber numberWithInt:[[stopArray objectAtIndex:4] intValue]]]];
			[stop setRun:[NSNumber numberWithInt:[[stopArray objectAtIndex:5] intValue]]];
			[stop setTerminalStation:[stationsByID objectForKey:[NSNumber numberWithInt:[[stopArray objectAtIndex:6] intValue]]]];
			[stop setStartStation:[stationsByID objectForKey:[NSNumber numberWithInt:[[stopArray objectAtIndex:7] intValue]]]];
			
			if(! haveDeletedCurrentData)
			{
				//Delete any current schedule information
				NSFetchRequest *request = [[NSFetchRequest alloc] init];
				NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:context];
				[request setEntity:entity];
				
				NSPredicate *predicate = [NSPredicate predicateWithFormat:@"direction == %@ AND line.name == %@ AND dayType = %@",
							[stop direction],[[stop line] name],[stop dayType]];
				[request setPredicate:predicate];
				
				// Execute the fetch -- create a mutable copy of the result.
				NSError *error = nil;
				NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
				if (mutableFetchResults == nil) {
					NSLog(@"%@",[error description]);
					// Handle the error.
				}
				
				for(Stop *stop in mutableFetchResults)
				{
					[context deleteObject:stop];
				}
				
				[mutableFetchResults release];
				[request release];
				
				haveDeletedCurrentData = YES;
			}
			
		}
	}
}

@end
