//
//  Stop.h
//  RTD
//
//  Created by bryce.hammond on 7/31/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Station;
@class Line;

@interface Stop :  NSManagedObject  
{
	
}

@property (nonatomic, retain) NSNumber * timeInMinutes;
@property (nonatomic, retain) NSNumber * run;
@property (nonatomic, retain) NSString * direction;
@property (nonatomic, retain) NSString * dayType;
@property (nonatomic, retain) Station * station;
@property (nonatomic, retain) Station *terminalStation;
@property (nonatomic, retain) Line * line;

- (NSString *)formattedTime;

@end



