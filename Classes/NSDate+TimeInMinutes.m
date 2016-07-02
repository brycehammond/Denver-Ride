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
							 initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDateComponents *weekDayComponents = [gregorian 
										   components:NSCalendarUnitWeekday fromDate:self];
	NSInteger weekday = [weekDayComponents weekday];
	
	
	return weekday;
}

-(BOOL)isHoliday
{
	if(! _holidays)
	{
		_holidays = [[NSSet alloc] initWithObjects:
                     @"7/4/2013",
                     @"9/2/2013",
                     @"11/28/2013",
                     @"12/25/2013",
                     @"1/1/2014",
                     @"5/26/2014",
                     @"7/4/2014",
                     @"9/1/2014",
                     @"11/27/2014",
                     @"12/25/2014",
                     @"1/1/2015",
                     @"5/25/2015",
                     @"7/4/2015",
                     @"9/7/2015",
                     @"11/26/2015",
                     @"12/25/2015",
                     @"1/1/2016",
                     @"5/30/2016",
                     @"7/4/2016",
                     @"9/5/2016",
                     @"11/24/2016",
                     @"12/26/2016",
                     @"1/2/2017",
                     @"5/29/2017",
                     @"7/4/2017",
                     @"9/4/2017",
                     @"11/23/2017",
                     @"12/25/2017",
                     @"1/1/2018",
                     @"5/28/2018",
                     @"7/4/2018",
                     @"9/3/2018",
                     @"11/22/2018",
                     @"12/25/2018",
                     @"1/1/2019",
                     @"5/27/2019",
                     @"7/4/2019",
                     @"9/2/2019",
                     @"11/28/2019",
                     @"12/25/2019",
                     @"1/1/2020",
                     @"5/25/2020",
                     @"7/4/2020",
                     @"9/7/2020",
                     @"11/26/2020",
                     @"12/25/2020",
					  nil];
	}
	
	NSCalendar *gregorian = [[NSCalendar alloc] 
							 initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDateComponents *dayComponents = [gregorian 
									   components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:self];

	NSInteger day = [dayComponents day];
	NSInteger month = [dayComponents month];
	NSInteger year = [dayComponents year];
	
	
	return [_holidays containsObject:[NSString stringWithFormat:@"%li/%li/%li",month,day,year]];
						
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
        case 6:
            returnDay = @"FR";
            break;
		case 1:
			returnDay = @"SU";
			break;
		default:
			returnDay = @"MT";
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
	if(nil == _fullDayTypes)
	{
		_fullDayTypes = @[@"Monday to Thursday",@"Friday",@"Saturday",@"Sunday/Holiday"];
	}
	
	return _fullDayTypes;
}

+(NSDictionary *)fullDayTypesByCode
{
	if(nil == _fullDayTypesByCode)
	{
		_fullDayTypesByCode = [[NSDictionary alloc] initWithObjects:[NSDate fullDayTypes] 
															forKeys:@[@"MT",@"FR",@"SA",@"SU"]];
	}
	
	return _fullDayTypesByCode;
}

+(NSDictionary *)codesByfullDayTypes
{
	if(nil == _codesByfullDayTypes)
	{
		_codesByfullDayTypes = [[NSDictionary alloc] initWithObjects:@[@"MT",@"FR",@"SA",@"SU"]
															 forKeys:[NSDate fullDayTypes]];
	}
	
	return _codesByfullDayTypes;
}

@end