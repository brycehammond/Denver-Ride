//
//  LineLoader.h
//  RTD
//
//  Created by bryce.hammond on 9/21/09.
//  Copyright 2009 Fluidvisiong Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface LineLoader : NSObject {

}

+(void)loadStopData:(NSString *)stopData withLinesByName:(NSDictionary *)linesByName 
	andStationsByID:(NSDictionary *)stationsByID inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;


@end
