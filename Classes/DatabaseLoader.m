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

@implementation DatabaseLoader

- (void)loadItUp
{
	//read in the lines that we are interested in
	//don't load up information about things not related to this line
	NSArray *linesToProcess = [[NSString stringWithContentsOfFile:
								[[NSBundle mainBundle] pathForResource:@"linesToProcess" ofType:@"txt"]]
							   componentsSeparatedByString:@"\n"];
	
	
	
	RTDAppDelegate *appDelegate = (RTDAppDelegate *)[[UIApplication sharedApplication] delegate];
	
    NSMutableDictionary *dayTypeByTrip = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *lineByTrip = [[NSMutableDictionary alloc] init];
    //get the trip info in for reference
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	NSMutableSet *relevantTrips = [[NSMutableSet alloc] init].
	
    NSString *trips = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"trips" ofType:@"txt"]];
    NSArray *fileLines = [trips componentsSeparatedByString:@"\n"];
    for(NSUInteger lineIdx = 1; lineIdx < [fileLines count]; ++lineIdx)
    {
        NSArray *fields = [[fileLines objectAtIndex:lineIdx] componentsSeparatedByString:@","];
		if([linesToProcess containsObject:[fields objectAtIndex:0]])
		{
			[dayTypeByTrip setObject:[fields objectAtIndex:1] forKey:[fields objectAtIndex:2]];
			[lineByTrip setObject:[fields objectAtIndex:0] forKey:[fields objectAtIndex:1]];
		}
    }
         
    [pool drain];
    [pool release];
	
	//read in the lines (we currently only care about light rail)
	pool = [[NSAutoreleasePool alloc] init];
    
    NSString *allLines = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"routes" ofType:@"txt"]];
    NSArray *fileLines = [trips componentsSeparatedByString:@"\n"];
    for(NSUInteger lineIdx = 1; lineIdx < [fileLines count]; ++lineIdx)
    {
        NSArray *fields = [[fileLines objectAtIndex:lineIdx] componentsSeparatedByString:@","];
		Line *
        
    }
	
    [pool drain];
    [pool release];
    
}

@end
