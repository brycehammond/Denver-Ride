// 
//  Stop.m
//  RTD
//
//  Created by bryce.hammond on 7/31/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import "Stop.h"

#import "Station.h"
#import "Line.h"

@implementation Stop 

@dynamic timeInMinutes;
@dynamic run;
@dynamic direction;
@dynamic dayType;
@dynamic station;
@dynamic terminalStation;
@dynamic line;

- (NSString *)formattedTime
{
	NSString *amOrPm = @"A";
	int hours = [[self timeInMinutes] intValue] / 60;
	if(hours > 24)
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
	int minutes = [[self timeInMinutes] intValue] % 60;
	NSString *formattedTime = (minutes < 10) ? [NSString stringWithFormat:@"%i:0%i%@",hours,minutes,amOrPm] : [NSString stringWithFormat:@"%i:%i%@",hours,minutes,amOrPm];
	
	return formattedTime;
}

@end
