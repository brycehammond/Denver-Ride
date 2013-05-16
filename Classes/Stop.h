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

@property (nonatomic, strong) NSNumber * departureTimeInMinutes;
@property (nonatomic, strong) NSNumber * arrivalTimeInMinutes;
@property (nonatomic, strong) NSNumber * run;
@property (nonatomic, strong) NSString * direction;
@property (nonatomic, strong) NSString * dayType;
@property (nonatomic, strong) NSNumber * stopSequence;
@property (nonatomic, strong) Station * station;
@property (nonatomic, strong) Station *terminalStation;
@property (nonatomic, strong) Station *startStation;
@property (nonatomic, strong) Line * line;

- (NSString *)formattedTime;

- (NSComparisonResult)sortBySequence:(Stop *)otherStop;

@end



