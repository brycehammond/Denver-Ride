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
static NSSet *_holidays;

-(NSInteger)minutesIntoCurrentDay
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
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
	
	
	return weekday;
}

-(BOOL)isHoliday
{
	if(! _holidays)
	{
		_holidays = [[NSSet alloc] initWithObjects:
					  @"11/26/2009",
					  @"12/25/2009",
					  
					  @"1/1/2010",
					  @"5/31/2010",
					  @"7/5/2010",
					  @"9/6/2010",
					  @"11/25/2010",
					  @"12/25/2010",
					  
					  @"1/1/2011",
					  @"5/31/2011",
					  @"7/4/2011",
					  @"9/5/2011",
					  @"11/24/2011",
					  @"12/26/2011",
					  
					  @"1/2/2012",
					  @"5/28/2012",
					  @"7/4/2012",
					  @"9/3/2012",
					  @"11/22/2012",
					  @"12/25/2012",
					  nil];
	}
	
	NSCalendar *gregorian = [[NSCalendar alloc] 
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dayComponents = [gregorian 
									   components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:self];

	NSInteger day = [dayComponents day];
	NSInteger month = [dayComponents month];
	NSInteger year = [dayComponents year];
	
	
	return [_holidays containsObject:[NSString stringWithFormat:@"%i/%i/%i",month,day,year]];				 
						
}

-(NSString *)dayType
{
	if([self isHoliday])
	{
		return @"SU";
	}
	
	NSInteger weekdayNum = [self weekdayNumber];
	
	NSString *returnDay;
	
	switch(weekdayNum)
	{
		case 7:
			returnDay = @"SA";
			break;
		case 1:
			returnDay = @"SU";
			break;
		default:
			returnDay = @"WK";
			break;
	}
	
	return returnDay;
}

+(NSDate *)previousDateFrom:(NSDate *)date
{
	//there are 86400 seconds in a day
	return [[NSDate alloc] initWithTimeInterval:-86400 sinceDate:date];
}

+(NSDate *)nextDateFrom:(NSDate *)date
{
	//there are 86400 seconds in a day
	return [[NSDate alloc] initWithTimeInterval:86400 sinceDate:date];
}

+(NSArray *)fullDayTypes
{
	if(! _fullDayTypes)
	{
		_fullDayTypes = @[@"Weekday",@"Saturday",@"Sunday/Holiday"];
	}
	
	return _fullDayTypes;
}

+(NSDictionary *)fullDayTypesByCode
{
	if( ! _fullDayTypesByCode)
	{
		_fullDayTypesByCode = [[NSDictionary alloc] initWithObjects:[NSDate fullDayTypes] 
															forKeys:@[@"WK",@"SA",@"SU"]];
	}
	
	return _fullDayTypesByCode;
}

+(NSDictionary *)codesByfullDayTypes
{
	if( ! _codesByfullDayTypes)
	{
		_codesByfullDayTypes = [[NSDictionary alloc] initWithObjects:@[@"WK",@"SA",@"SU"]
															 forKeys:[NSDate fullDayTypes]];
	}
	
	return _codesByfullDayTypes;
}

@end