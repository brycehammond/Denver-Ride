//
//  NSDate+TimeInMinutes.h
//  RTD
//
//  Created by bryce.hammond on 8/18/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMinutesInDay 1440

@interface NSDate (TimeInMinutes)
-(NSInteger)minutesIntoCurrentDay;
-(NSInteger)weekdayNumber;
-(BOOL)isHoliday;
-(NSString *)dayType;

+(NSDate *)previousDateFrom:(NSDate *)date;
+(NSDate *)nextDateFrom:(NSDate *)date;

+(NSArray *)fullDayTypes;
+(NSDictionary *)fullDayTypesByCode;
+(NSDictionary *)codesByfullDayTypes;
@end

