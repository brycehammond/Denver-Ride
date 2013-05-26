//
//  Station.h
//  RTD
//
//  Created by Bryce Hammond on 5/26/13.
//  Copyright (c) 2013 Fluidvision Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Line, Stop;

@interface Station : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * latitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDecimalNumber * longitude;
@property (nonatomic) BOOL hasWestbound;
@property (nonatomic) BOOL hasEastbound;
@property (nonatomic) BOOL hasNorthbound;
@property (nonatomic) BOOL hasSouthbound;
@property (nonatomic, retain) NSSet *stops;
@property (nonatomic, retain) NSSet *lines;

@property (assign) CLLocationDistance currentDistance;
@property (nonatomic, strong) CLLocation *location;

@end

@interface Station (CoreDataGeneratedAccessors)

- (void)addStopsObject:(Stop *)value;
- (void)removeStopsObject:(Stop *)value;
- (void)addStops:(NSSet *)values;
- (void)removeStops:(NSSet *)values;

- (void)addLinesObject:(Line *)value;
- (void)removeLinesObject:(Line *)value;
- (void)addLines:(NSSet *)values;
- (void)removeLines:(NSSet *)values;

@end
