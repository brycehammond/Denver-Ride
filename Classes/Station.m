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
#import "RTDAppDelegate.h"

@implementation Station

@dynamic latitude;
@dynamic name;
@dynamic longitude;
@dynamic hasWestbound;
@dynamic hasEastbound;
@dynamic hasNorthbound;
@dynamic hasSouthbound;
@dynamic stops;
@dynamic lines;


@synthesize currentDistance = _currentDistance,
location = _location;

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



+ (NSPredicate *)filterPredicateForCurrentDirection
{
    NSString *currentDirection = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentDirectionKey];
    return [Station filterPredicateForDirection:currentDirection];
}

+ (NSPredicate *)filterPredicateForDirection:(NSString *)direction
{
    NSPredicate *directionPredicate = nil;
    if([direction isEqualToString:@"N"])
    {
        directionPredicate = [NSPredicate predicateWithFormat:@"hasNorthbound == 1"];
    }
    else if([direction isEqualToString:@"S"])
    {
        directionPredicate = [NSPredicate predicateWithFormat:@"hasSouthbound == 1"];
    }
    else if([direction isEqualToString:@"W"])
    {
        directionPredicate = [NSPredicate predicateWithFormat:@"hasWestbound == 1"];
    }
    else if([direction isEqualToString:@"E"])
    {
        directionPredicate = [NSPredicate predicateWithFormat:@"hasEastbound == 1"];
    }
    
    return directionPredicate;
}

+ (Station *)stationWithName:(NSString *)name
{
    RTDAppDelegate *appDelegate = (RTDAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Station" inManagedObjectContext:[appDelegate managedObjectContext]];
	request.entity = entity;

    request.predicate = [NSPredicate predicateWithFormat:@"name = %@",name];
	
	NSError *error = nil;
	NSArray *stations = [[appDelegate managedObjectContext] executeFetchRequest:request error:&error];
	if(stations.count > 0)
    {
        return stations[0];
    }
    
    return nil;
}

- (NSString *)noStopTextForDirection:(NSString *)direction
{
    return [self noStopTextForDirection:direction withTimeDirection:FORWARD];
}

- (NSString *)noStopTextForDirection:(NSString *)direction withTimeDirection:(DRTimeDirection)timeDirection
{
    NSString *noStopText = @"";
    NSString *sentinal = (timeDirection == BACKWARD) ? @"Start" : @"End";
    
    
    if([direction isEqualToString:@"N"])
    {
        noStopText = (self.hasNorthbound.boolValue == YES) ? [NSString stringWithFormat:@"%@ of line for Northbound transit",sentinal] : @"No Northbound transit";
    }
    else if([direction isEqualToString:@"S"])
    {
        noStopText = (self.hasSouthbound.boolValue == YES) ? [NSString stringWithFormat:@"%@ of line for Southbound transit",sentinal] : @"No Southbound transit";
    }
    else if([direction isEqualToString:@"W"])
    {
        noStopText = (self.hasWestbound.boolValue == YES) ? [NSString stringWithFormat:@"%@ of line for Westbound transit",sentinal] : @"No Westbound transit";
    }
    else if([direction isEqualToString:@"E"])
    {
        noStopText = (self.hasEastbound.boolValue == YES) ? [NSString stringWithFormat:@"%@ of line for Eastbound transit",sentinal] : @"No Eastbound transit";
    }
    
    return noStopText;
}

@end
