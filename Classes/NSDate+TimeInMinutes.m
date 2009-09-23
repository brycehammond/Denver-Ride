//
//  NSDate+TimeInMinutes.m
//  RTD
//
//  Created by bryce.hammond on 8/18/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import "NSDate+TimeInMinutes.h"


@implementation NSDate (TimeInMinutes)

-(NSInteger)minutesIntoCurrentDay
{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
	[dateFormatter setDateFormat:@"H"];
	int hours = [[dateFormatter stringFromDate:self] intValue];
	[dateFormatter setDateFormat:@"m"];
	int minutes = [[dateFormatter stringFromDate:self] intValue];
	int timeInMinutes = hours * 60 + minutes;
	
	return timeInMinutes;
}

-(NSInteger)weekdayNumber
{
	NSCalendar *gregorian = [[NSCalendar alloc] 
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *weekDayComponents = [gregorian 
										   components:NSWeekdayCalendarUnit fromDate:self];
	NSInteger weekday = [weekDayComponents weekday];
	
	[gregorian release];
	
	return weekday;
}

-(NSString *)dayType
{
	NSInteger weekdayNum = [self weekdayNumber];
	NSString *returnDay;
	
	switch(weekdayNum)
	{
		case 7:
			returnDay = @"S";
			break;
		case 1:
			returnDay = @"H";
			break;
		default:
			returnDay = @"W";
			break;
	}
	
	return returnDay;
}

@end