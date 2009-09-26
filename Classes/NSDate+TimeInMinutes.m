//
//  NSDate+TimeInMinutes.m
//  RTD
//
//  Created by bryce.hammond on 8/18/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import "NSDate+TimeInMinutes.h"


@implementation NSDate (TimeInMinutes)

static NSArray *_fullDayTypes;
static NSDictionary *_fullDayTypesByCode;
static NSDictionary *_codesByfullDayTypes;

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

+(NSArray *)fullDayTypes
{
	if(! _fullDayTypes)
	{
		_fullDayTypes = [[NSArray alloc] initWithObjects:@"Weekday",@"Saturday",@"Sunday/Holiday",nil];
	}
	
	return _fullDayTypes;
}

+(NSDictionary *)fullDayTypesByCode
{
	if( ! _fullDayTypesByCode)
	{
		_fullDayTypesByCode = [[NSDictionary alloc] initWithObjects:[NSDate fullDayTypes] 
															forKeys:[NSArray arrayWithObjects:@"W",@"S",@"H",nil]];
	}
	
	return _fullDayTypesByCode;
}

+(NSDictionary *)codesByfullDayTypes
{
	if( ! _codesByfullDayTypes)
	{
		_codesByfullDayTypes = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"W",@"S",@"H",nil]
															 forKeys:[NSDate fullDayTypes]];
	}
	
	return _codesByfullDayTypes;
}

@end