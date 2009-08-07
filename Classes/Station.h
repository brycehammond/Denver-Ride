//
//  Station.h
//  RTD
//
//  Created by bryce.hammond on 7/31/09.
//  Copyright 2009 Wall Street On Demand, Inc.. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Line;
@class Stop;

@interface Station :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSSet* lines;
@property (nonatomic, retain) NSSet* stops;

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

