//
//  RTDAppDelegate.m
//  RTD
//
//  Created by bryce.hammond on 8/2/09.
//  Copyright Wall Street On Demand, Inc. 2009. All rights reserved.
//

#import "RTDAppDelegate.h"
#import "RootViewController.h"
#import "Line.h"
#import "Station.h"
#import "Stop.h"

@interface RTDAppDelegate (Private)

-(void)populateStore;
-(NSDictionary *)setupLines;
-(NSDictionary *)setupStationsWithLines:(NSDictionary *)linesByName;

@end


@implementation RTDAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
	defaultDataNeedsFilling = NO;
	
    // Override point for customization after app launch
    
	NSManagedObjectContext *context = self.managedObjectContext;
	
	if(defaultDataNeedsFilling)
	{
		[self populateStore];
	}

	RootViewController *rootViewController = (RootViewController *)[navigationController topViewController];
	rootViewController.managedObjectContext = context;
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
        } 
    }
}


#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction)saveAction:(id)sender {
	
    NSError *error;
    if (![[self managedObjectContext] save:&error]) {
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
	NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"RTD.sqlite"]];
	
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"RTD.sqlite"]];
    if (fileHandle == nil) {
		defaultDataNeedsFilling = YES;
	}
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Handle the error.
    }    
	
    return persistentStoreCoordinator;
	
	/*
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"RTD.sqlite"]];
	
	NSError *error;
	
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"RTD.sqlite"]];
    if (fileHandle == nil) {
        NSPersistentStoreCoordinator *defaultDataStoreCoordinator;
        NSString *defaultPath = [[NSBundle mainBundle] pathForResource:@"RTD" ofType:@"sqlite"];
        if (defaultPath) {
            NSURL *defaultURL = [NSURL fileURLWithPath:defaultPath];
            defaultDataStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
            if(![defaultDataStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:defaultURL options:nil error:&error]) {
                //Handle error
            }
            else {
                if (![defaultDataStoreCoordinator migratePersistentStore:[defaultDataStoreCoordinator persistentStoreForURL:defaultURL]
                                                                   toURL:storeUrl options:nil withType:NSSQLiteStoreType error:&error]) {
                   //handle error
                }
            }
        }
        else {
            // create a store and file from scratch
            persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
            if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]){
                //handle error
            }
			
			defaultDataNeedsFilling = YES;
        }
    }
    // load data from stored user support folder
    else {
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]){
            //handle error
        }
    }
	
	return persistentStoreCoordinator;
	 */
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


-(void)populateStore
{
	NSError *error;
	
	NSDictionary *linesByName = [self setupLines];
	
	Station *station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Union Station"];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station setLongitude:[NSNumber numberWithDouble:0]];
	[station setLatitude:[NSNumber numberWithDouble:0]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Invesco Field"];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station setLongitude:[NSNumber numberWithDouble:1]];
	[station setLatitude:[NSNumber numberWithDouble:1]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Auraria West"];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[[linesByName objectForKey:@"C"] addStationsObject:station];
	[[linesByName objectForKey:@"D"] addStationsObject:station];
	[station setLongitude:[NSNumber numberWithDouble:2]];
	[station setLatitude:[NSNumber numberWithDouble:2]];

	Stop *stop = (Stop *)[NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:managedObjectContext];
	[stop setTimeInMinutes:[NSNumber numberWithDouble:0]];
	[stop setDirection:@"N"];
	[stop setLine:[linesByName objectForKey:@"C"]];
	[stop setStation:station];
	[stop setRun:[NSNumber numberWithInt:1]];
	
	if(! [managedObjectContext save:&error])
	{
		NSLog(@"%@ %@",error,[error userInfo]);
		//handle error
	}
	
	
	
}

-(NSDictionary *)setupLines
{
	NSError *error;
	NSArray *lines = [NSArray arrayWithObjects:@"C",@"D",@"E",@"H",@"G",@"F",nil];
	NSMutableDictionary *linesByName = [NSMutableDictionary dictionaryWithCapacity:[lines count]];
	
	for(NSString *lineName in lines)
	{
		Line *line = (Line *)[NSEntityDescription insertNewObjectForEntityForName:@"Line" inManagedObjectContext:managedObjectContext];
		[line setName:lineName];
		[line setType:@"LR"];
		[linesByName setObject:line forKey:[line name]];
	}
	
	if(! [managedObjectContext save:&error])
	{
		NSLog(@"%@ %@",error,[error userInfo]);
		//handle error
	}
	
	return linesByName;
}

-(NSDictionary *)setupStationsWithLines:(NSDictionary *)linesByName
{
	NSError *error;
	NSMutableDictionary *stationsByName = [NSMutableDictionary dictionary];
	
	Station *station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Belleview"];
	[station setLongitude:[NSNumber numberWithDouble:39.62763927680147]];
	[station setLatitude:[NSNumber numberWithDouble:-104.90442395210266]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"G"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Orchard"];
	[station setLongitude:[NSNumber numberWithDouble:39.613540462760014]];
	[station setLatitude:[NSNumber numberWithDouble:-104.89621102809907]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"G"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Arapahoe at Village Center"];
	[station setLongitude:[NSNumber numberWithDouble:39.60022824942126]];
	[station setLatitude:[NSNumber numberWithDouble:-104.88846480846406]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"G"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Dry Creek"];
	[station setLongitude:[NSNumber numberWithDouble:39.57885144262927]];
	[station setLatitude:[NSNumber numberWithDouble:-104.87663626670839]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"G"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"County Line"];
	[station setLongitude:[NSNumber numberWithDouble:39.561967745633034]];
	[station setLatitude:[NSNumber numberWithDouble:-104.87229108810427]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"G"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Lincoln"];
	[station setLongitude:[NSNumber numberWithDouble:39.54596517069127]];
	[station setLatitude:[NSNumber numberWithDouble:-104.86963033676147]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"G"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Southmoor"];
	[station setLongitude:[NSNumber numberWithDouble:39.64859211162123]];
	[station setLatitude:[NSNumber numberWithDouble:-104.91627395153047]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Dayton"];
	[station setLongitude:[NSNumber numberWithDouble:39.64297446642949]];
	[station setLatitude:[NSNumber numberWithDouble:-104.87793982028962]];
	[station addLinesObject:[linesByName objectForKey:@"G"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Nine Mile"];
	[station setLongitude:[NSNumber numberWithDouble:39.65755461509736]];
	[station setLatitude:[NSNumber numberWithDouble:-104.84510958194734]];
	[station addLinesObject:[linesByName objectForKey:@"G"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Yale"];
	[station setLongitude:[NSNumber numberWithDouble:39.66863842664354]];
	[station setLatitude:[NSNumber numberWithDouble:-104.9270886182785]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Colorado"];
	[station setLongitude:[NSNumber numberWithDouble:39.67962137403389]];
	[station setLatitude:[NSNumber numberWithDouble:-104.93777990341188]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"University of Denver"];
	[station setLongitude:[NSNumber numberWithDouble:39.68525668220506]];
	[station setLatitude:[NSNumber numberWithDouble:-104.96482193470002]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Louisiana/Pearl"];
	[station setLongitude:[NSNumber numberWithDouble:39.69275732762653]];
	[station setLatitude:[NSNumber numberWithDouble:-104.97817397117615]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"I-25/Broadway"];
	[station setLongitude:[NSNumber numberWithDouble:39.701396301610046]];
	[station setLatitude:[NSNumber numberWithDouble:-104.99018490314485]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Alameda"];
	[station setLongitude:[NSNumber numberWithDouble:39.708402033193956]];
	[station setLatitude:[NSNumber numberWithDouble:-104.9929341673851]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"10th & Osage"];
	[station setLongitude:[NSNumber numberWithDouble:39.73199342491363]];
	[station setLatitude:[NSNumber numberWithDouble:-105.00565320253373]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Colfax at Auraria"];
	[station setLongitude:[NSNumber numberWithDouble:39.74030780179325]];
	[station setLatitude:[NSNumber numberWithDouble:-105.00194370746614]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Convention Center/Performing Arts"];
	[station setLongitude:[NSNumber numberWithDouble:39.743172533347014]];
	[station setLatitude:[NSNumber numberWithDouble:-104.99736249446872]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"16th & California"];
	[station setLongitude:[NSNumber numberWithDouble:39.74497504636902]];
	[station setLatitude:[NSNumber numberWithDouble:-104.99235212802888]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"18th & California"];
	[station setLongitude:[NSNumber numberWithDouble:39.74679813514468]];
	[station setLatitude:[NSNumber numberWithDouble:-104.99003201723099]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"18th & Stout"];
	[station setLongitude:[NSNumber numberWithDouble:39.74792826097969]];
	[station setLatitude:[NSNumber numberWithDouble:-104.99052286148071]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"16th & Stout"];
	[station setLongitude:[NSNumber numberWithDouble:39.74604333274745]];
	[station setLatitude:[NSNumber numberWithDouble:-104.99292880296706]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"20th & Welton"];
	[station setLongitude:[NSNumber numberWithDouble:39.74786433099829]];
	[station setLatitude:[NSNumber numberWithDouble:-104.98696625232695]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"25th & Welton"];
	[station setLongitude:[NSNumber numberWithDouble:39.75315382078058]];
	[station setLatitude:[NSNumber numberWithDouble:-104.98006761074067]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"27th & Welton"];
	[station setLongitude:[NSNumber numberWithDouble:39.75525713075179]];
	[station setLatitude:[NSNumber numberWithDouble:-104.97734785079956]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"29th & Welton"];
	[station setLongitude:[NSNumber numberWithDouble:39.757084071406425]];
	[station setLatitude:[NSNumber numberWithDouble:-104.9750304222107]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"30th & Downing"];
	[station setLongitude:[NSNumber numberWithDouble:39.758807867137385]];
	[station setLatitude:[NSNumber numberWithDouble:-104.9734452366829]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Auraria West Campus"];
	[station setLongitude:[NSNumber numberWithDouble:39.741285412555925]];
	[station setLatitude:[NSNumber numberWithDouble:-105.00901401042938]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Invesco Field at Mile High"];
	[station setLongitude:[NSNumber numberWithDouble:39.743446831848615]];
	[station setLatitude:[NSNumber numberWithDouble:-105.01322239637376]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Pepsi Center/Six Flags"];
	[station setLongitude:[NSNumber numberWithDouble:39.74860055332102]];
	[station setLatitude:[NSNumber numberWithDouble:-105.00974088907243]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Union"];
	[station setLongitude:[NSNumber numberWithDouble:39.753630164252605]];
	[station setLatitude:[NSNumber numberWithDouble:-105.00158697366714]];
	[station addLinesObject:[linesByName objectForKey:@"Mall"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Evans"];
	[station setLongitude:[NSNumber numberWithDouble:39.677666454577476]];
	[station setLatitude:[NSNumber numberWithDouble:-104.99285370111467]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Englewood"];
	[station setLongitude:[NSNumber numberWithDouble:39.65560939625744]];
	[station setLatitude:[NSNumber numberWithDouble:-104.99995082616807]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Oxford – City of Sheridan"];
	[station setLongitude:[NSNumber numberWithDouble:39.64290011218291]];
	[station setLatitude:[NSNumber numberWithDouble:-105.00482439994812]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Littleton/Downtown"];
	[station setLongitude:[NSNumber numberWithDouble:39.611965944477035]];
	[station setLatitude:[NSNumber numberWithDouble:-105.01486659049989]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[stationsByName setObject:station forKey:[station name]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Littleton/Mineral"];
	[station setLongitude:[NSNumber numberWithDouble:39.58011869115301]];
	[station setLatitude:[NSNumber numberWithDouble:-105.02493560314178]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[stationsByName setObject:station forKey:[station name]];
	
	if(! [managedObjectContext save:&error])
	{
		NSLog(@"%@ %@",error,[error userInfo]);
		//handle error
	}
	
	return stationsByName;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

