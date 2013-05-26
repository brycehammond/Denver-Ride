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
@property (nonatomic) int16_t arrivalTimeInMinutes;
@property (nonatomic) int32_t run;
@property (nonatomic) int16_t departureTimeInMinutes;
@property (nonatomic) int16_t stopSequence;
@property (nonatomic) BOOL hasEastbound;
@property (nonatomic) BOOL hasNorthbound;
@property (nonatomic) BOOL hasSouthbound;
@property (nonatomic) BOOL hasWestbound;
@property (nonatomic, retain) Station *startStation;
@property (nonatomic, retain) Station *station;
@property (nonatomic, retain) Line *line;
@property (nonatomic, retain) Station *terminalStation;

@end
