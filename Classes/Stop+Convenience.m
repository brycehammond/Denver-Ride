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
	if(self.stopSequence == otherStop.stopSequence)
    {
        return NSOrderedSame;
    }
    else if(self.stopSequence < otherStop.stopSequence)
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
	int hours = self.departureTimeInMinutes / 60;
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
	
	int minutes = [self departureTimeInMinutes] % 60;
	NSString *formattedTime = (minutes < 10) ? [NSString stringWithFormat:@"%i:0%i%@",hours,minutes,amOrPm] : [NSString stringWithFormat:@"%i:%i%@",hours,minutes,amOrPm];
	
	return formattedTime;
}

@end
