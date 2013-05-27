//
//  Stop.h
//  RTD
//
//  Created by Bryce Hammond on 5/26/13.
//  Copyright (c) 2013 Fluidvision Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Line, Station;

@interface Stop : NSManagedObject

@property (nonatomic, retain) NSString * dayType;
@property (nonatomic, retain) NSNumber * arrivalTimeInMinutes;
@property (nonatomic, retain) NSNumber * run;
@property (nonatomic, retain) NSNumber * departureTimeInMinutes;
@property (nonatomic, retain) NSNumber * stopSequence;
@property (nonatomic, retain) NSString * direction;
@property (nonatomic, retain) Station *startStation;
@property (nonatomic, retain) Station *station;
@property (nonatomic, retain) Line *line;
@property (nonatomic, retain) Station *terminalStation;

@end
