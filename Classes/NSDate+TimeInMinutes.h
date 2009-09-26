//
//  NSDate+TimeInMinutes.h
//  RTD
//
//  Created by bryce.hammond on 8/18/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (TimeInMinutes)
-(NSInteger)minutesIntoCurrentDay;
-(NSInteger)weekdayNumber;
-(NSString *)dayType;

+(NSArray *)fullDayTypes;
+(NSDictionary *)fullDayTypesByCode;
+(NSDictionary *)codesByfullDayTypes;
@end

