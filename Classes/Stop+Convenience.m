//
//  Stop+Convenience.m
//  RTD
//
//  Created by Bryce Hammond on 5/26/13.
//  Copyright (c) 2013 Fluidvision Design. All rights reserved.
//

#import "Stop+Convenience.h"

@implementation Stop (Convenience)

- (NSComparisonResult)sortBySequence:(Stop *)otherStop
{
	if(self.stopSequence.intValue == otherStop.stopSequence.intValue)
    {
        return NSOrderedSame;
    }
    else if(self.stopSequence.intValue < otherStop.stopSequence.intValue)
    {
        return NSOrderedAscending;
    }
    else
    {
        return NSOrderedDescending;
    }
}

- (NSString *)formattedTime
{
	NSString *amOrPm = @"A";
	int hours = self.departureTimeInMinutes.intValue / 60;
	if(hours >= 24)
	{
		hours -= 24;
	}
	else if(hours > 12)
	{
		hours -= 12;
		amOrPm = @"P";
	}
	else if(hours == 12)
	{
		amOrPm = @"P";
	}
	
	if(hours == 0)
	{
		hours = 12;
	}
	
	int minutes = self.departureTimeInMinutes.intValue % 60;
	NSString *formattedTime = (minutes < 10) ? [NSString stringWithFormat:@"%i:0%i%@",hours,minutes,amOrPm] : [NSString stringWithFormat:@"%i:%i%@",hours,minutes,amOrPm];
	
	return formattedTime;
}

- (NSString *)fullDirection
{
    NSString *directionString = @"";
    if([self.direction isEqualToString:@"N"])
    {
        directionString = @"Nothbound";
    }
    else if([self.direction isEqualToString:@"W"])
    {
        directionString = @"Westbound";
    }
    else if([self.direction isEqualToString:@"E"])
    {
        directionString = @"Eastbound";
    }
    else if([self.direction isEqualToString:@"S"])
    {
        directionString = @"Southbound";
    }
    
    return directionString;
}

@end
