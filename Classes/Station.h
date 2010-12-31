//
//  Station.h
//  RTD
//
//  Created by bryce.hammond on 7/31/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class Line;
@class Stop;

@interface Station :  NSManagedObject  
{
	CLLocationDistance _currentDistance;
	CLLocation *_location; //have the longitude/latitude stored in a CLLocation  so we can make quick distance comparisons
}

@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * direction;

@property (nonatomic, retain) NSSet* lines;
@property (nonatomic, retain) NSSet* stops;
@property (assign) CLLocationDistance currentDistance;
@property (nonatomic, retain) CLLocation *location;

-(NSComparisonResult)compareAscending:(Station *)station;

@end


@interface Station (CoreDataGeneratedAccessors)
- (void)addLinesObject:(Line *)value;
- (void)removeLinesObject:(Line *)value;
- (void)addLines:(NSSet *)value;
- (void)removeLines:(NSSet *)value;

- (void)addStopsObject:(Stop *)value;
- (void)removeStopsObject:(Stop *)value;
- (void)addStops:(NSSet *)value;
- (void)removeStops:(NSSet *)value;

@end

