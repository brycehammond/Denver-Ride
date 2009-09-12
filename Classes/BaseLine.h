//
//  BaseLine.h
//  RTD
//
//  Created by bryce.hammond on 8/10/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BaseLine : NSObject {

}

+(void)createStopswithLines:(NSDictionary *)linesByName andStations:(NSDictionary *)stationsByName inContext:(NSManagedObjectContext *)context;
+(NSArray *)newStops;

@end
