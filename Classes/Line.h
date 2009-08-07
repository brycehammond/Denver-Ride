//
//  Line.h
//  RTD
//
//  Created by bryce.hammond on 7/31/09.
//  Copyright 2009 Wall Street On Demand, Inc.. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Station;
@class Stop;

@interface Line :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* type;
@property (nonatomic, retain) NSSet* stations;
@property (nonatomic, retain) NSSet* stops;

@end


@interface Line (CoreDataGeneratedAccessors)
- (void)addStationsObject:(Station *)value;
- (void)removeStationsObject:(Station *)value;
- (void)addStations:(NSSet *)value;
- (void)removeStations:(NSSet *)value;

- (void)addStopsObject:(Stop *)value;
- (void)removeStopsObject:(Stop *)value;
- (void)addStops:(NSSet *)value;
- (void)removeStops:(NSSet *)value;

@end

