//
//  NSDate+TimeInMinutes.m
//  RTD
//
//  Created by bryce.hammond on 8/18/09.
//  Copyright 2009 Wall Street On Demand, Inc.. All rights reserved.
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
			returnDay = @"Saturday";
			break;
		case 1:
			returnDay = @"Sunday";
			break;
		default:
			returnDay = @"Weekday";
			break;
	}
	
	return returnDay;
}

@end