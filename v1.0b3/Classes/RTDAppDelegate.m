//
//  RTDAppDelegate.m
//  RTD
//
//  Created by bryce.hammond on 8/2/09.
//  Copyright Fluidvision Design 2009. All rights reserved.
//

#import "RTDAppDelegate.h"
#import "RootViewController.h"
#import "Line.h"
#import "Station.h"
#import "Stop.h"
#import "UIColorCategories.h"
#import "LineLoader.h"
#import "LineScheduleUpdater.h"

@interface RTDAppDelegate (Private)

-(void)populateStore;
-(NSDictionary *)setupLines;
-(NSDictionary *)setupStationsWithLines:(NSDictionary *)linesByName;
-(void)setupStopsWithLines:(NSDictionary *)linesByName andStations:(NSDictionary *)stationsByName;
-(void)loadStopsFromPath:(NSString *)path withLines:(NSDictionary *)linesByName andStations:(NSDictionary *)stationsByName;

@end


@implementation RTDAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize currentDirection = _currentDirection;
@synthesize linesToColors = _linesToColors;
@synthesize currentDayType;


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
	
	_linesToColors = [[NSDictionary alloc] initWithObjectsAndKeys:
							[UIColor colorFromHex:@"F79238" withAlpha:1], @"C",
							[UIColor colorFromHex:@"038349" withAlpha:1], @"D",
							[UIColor colorFromHex:@"552485" withAlpha:1], @"E",
							[UIColor colorFromHex:@"EF3931" withAlpha:1], @"F",
							[UIColor colorFromHex:@"0073BD" withAlpha:1], @"H",nil];
	
	
	RootViewController *rootViewController = (RootViewController *)[navigationController topViewController];
	rootViewController.managedObjectContext = context;
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	
	_defaultPngToFade = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
	[window addSubview:_defaultPngToFade];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(completedFadingDefaultPng:finished:context:)];
	[UIView setAnimationDuration:.4];
	[_defaultPngToFade setAlpha:0];
	[UIView commitAnimations];
	
	NSString *currentDirection = [[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentDirection"];
	if(! currentDirection)
	{
		currentDirection = @"N";
		[[NSUserDefaults standardUserDefaults] setObject:currentDirection forKey:@"CurrentDirection"];
	}
	
	_lineUpdater = [[LineScheduleUpdater alloc] initWithMainWindow:window andManagedObjectContext:context];
	[_lineUpdater startUpdate];
	
}

- (void)completedFadingDefaultPng:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
	[_defaultPngToFade removeFromSuperview];
	[_defaultPngToFade release];
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
	
	NSError *error;
	
	NSString *filePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"RTD.sqlite"];
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if (fileHandle == nil) {
        NSString *defaultPath = [[NSBundle mainBundle] pathForResource:@"RTD" ofType:@"sqlite"];
        if (defaultPath) {
			NSError *error;
			[[NSFileManager defaultManager] copyItemAtPath:defaultPath
													toPath:filePath error:&error];
			
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
			persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
			if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:fileURL options:nil error:&error]){
				//handle error
            }
        }
        else {
			defaultDataNeedsFilling = YES;
			
            // create a store and file from scratch
            persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
            if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]){
                //handle error
            }
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
	 
}

-(void)setCurrentDirection:(NSString *)direction
{
	if(_currentDirection != direction)
	{
		[_currentDirection release];
		_currentDirection = [direction retain];
	}
	
	if(_currentDirection)
	{
		[[NSUserDefaults standardUserDefaults] setObject:_currentDirection forKey:@"CurrentDirection"];
	}
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
	NSDictionary *stationsByName = [self setupStationsWithLines:linesByName];
	[self setupStopsWithLines:linesByName andStations:stationsByName];
	
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
	[station setLatitude:[NSNumber numberWithDouble:39.62763927680147]];
	[station setLongitude:[NSNumber numberWithDouble:-104.90442395210266]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"G"]];
	[station setStationID:[NSNumber numberWithInt:1]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Orchard"];
	[station setLatitude:[NSNumber numberWithDouble:39.613540462760014]];
	[station setLongitude:[NSNumber numberWithDouble:-104.89621102809907]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"G"]];
	[station setStationID:[NSNumber numberWithInt:2]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Arapahoe"];
	[station setLatitude:[NSNumber numberWithDouble:39.60022824942126]];
	[station setLongitude:[NSNumber numberWithDouble:-104.88846480846406]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"G"]];
	[station setStationID:[NSNumber numberWithInt:3]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Dry Creek"];
	[station setLatitude:[NSNumber numberWithDouble:39.57885144262927]];
	[station setLongitude:[NSNumber numberWithDouble:-104.87663626670839]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"G"]];
	[station setStationID:[NSNumber numberWithInt:4]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"County Line"];
	[station setLatitude:[NSNumber numberWithDouble:39.561967745633034]];
	[station setLongitude:[NSNumber numberWithDouble:-104.87229108810427]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"G"]];
	[station setStationID:[NSNumber numberWithInt:5]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Lincoln"];
	[station setLatitude:[NSNumber numberWithDouble:39.54596517069127]];
	[station setLongitude:[NSNumber numberWithDouble:-104.86963033676147]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"G"]];
	[station setStationID:[NSNumber numberWithInt:6]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Southmoor"];
	[station setLatitude:[NSNumber numberWithDouble:39.64859211162123]];
	[station setLongitude:[NSNumber numberWithDouble:-104.91627395153047]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[station setStationID:[NSNumber numberWithInt:7]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Dayton"];
	[station setLatitude:[NSNumber numberWithDouble:39.64297446642949]];
	[station setLongitude:[NSNumber numberWithDouble:-104.87793982028962]];
	[station addLinesObject:[linesByName objectForKey:@"G"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[station setStationID:[NSNumber numberWithInt:8]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Nine Mile"];
	[station setLatitude:[NSNumber numberWithDouble:39.65755461509736]];
	[station setLongitude:[NSNumber numberWithDouble:-104.84510958194734]];
	[station addLinesObject:[linesByName objectForKey:@"G"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[station setStationID:[NSNumber numberWithInt:9]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Yale"];
	[station setLatitude:[NSNumber numberWithDouble:39.66863842664354]];
	[station setLongitude:[NSNumber numberWithDouble:-104.9270886182785]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[station setStationID:[NSNumber numberWithInt:10]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Colorado"];
	[station setLatitude:[NSNumber numberWithDouble:39.67962137403389]];
	[station setLongitude:[NSNumber numberWithDouble:-104.93777990341188]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[station setStationID:[NSNumber numberWithInt:11]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"University of Denver"];
	[station setLatitude:[NSNumber numberWithDouble:39.68525668220506]];
	[station setLongitude:[NSNumber numberWithDouble:-104.96482193470002]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[station setStationID:[NSNumber numberWithInt:12]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Louisiana/Pearl"];
	[station setLatitude:[NSNumber numberWithDouble:39.69275732762653]];
	[station setLongitude:[NSNumber numberWithDouble:-104.97817397117615]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[station setStationID:[NSNumber numberWithInt:13]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"I-25/Broadway"];
	[station setLatitude:[NSNumber numberWithDouble:39.701396301610046]];
	[station setLongitude:[NSNumber numberWithDouble:-104.99018490314485]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[station setStationID:[NSNumber numberWithInt:14]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Alameda"];
	[station setLatitude:[NSNumber numberWithDouble:39.708402033193956]];
	[station setLongitude:[NSNumber numberWithDouble:-104.9929341673851]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[station setStationID:[NSNumber numberWithInt:15]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"10th & Osage"];
	[station setLatitude:[NSNumber numberWithDouble:39.73199342491363]];
	[station setLongitude:[NSNumber numberWithDouble:-105.00565320253373]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station addLinesObject:[linesByName objectForKey:@"E"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[station setStationID:[NSNumber numberWithInt:16]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Colfax at Auraria"];
	[station setLatitude:[NSNumber numberWithDouble:39.74030780179325]];
	[station setLongitude:[NSNumber numberWithDouble:-105.00194370746614]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[station setStationID:[NSNumber numberWithInt:17]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Convention Center"];
	[station setLatitude:[NSNumber numberWithDouble:39.743172533347014]];
	[station setLongitude:[NSNumber numberWithDouble:-104.99736249446872]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[station setStationID:[NSNumber numberWithInt:18]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"16th & California"];
	[station setLatitude:[NSNumber numberWithDouble:39.74497504636902]];
	[station setLongitude:[NSNumber numberWithDouble:-104.99235212802888]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[station setStationID:[NSNumber numberWithInt:19]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"18th & California"];
	[station setLatitude:[NSNumber numberWithDouble:39.74679813514468]];
	[station setLongitude:[NSNumber numberWithDouble:-104.99003201723099]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[station setStationID:[NSNumber numberWithInt:20]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"18th & Stout"];
	[station setLatitude:[NSNumber numberWithDouble:39.74792826097969]];
	[station setLongitude:[NSNumber numberWithDouble:-104.99052286148071]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[station setStationID:[NSNumber numberWithInt:21]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"16th & Stout"];
	[station setLatitude:[NSNumber numberWithDouble:39.74604333274745]];
	[station setLongitude:[NSNumber numberWithDouble:-104.99292880296706]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station addLinesObject:[linesByName objectForKey:@"F"]];
	[station addLinesObject:[linesByName objectForKey:@"H"]];
	[station setStationID:[NSNumber numberWithInt:22]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"20th & Welton"];
	[station setLatitude:[NSNumber numberWithDouble:39.74786433099829]];
	[station setLongitude:[NSNumber numberWithDouble:-104.98696625232695]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station setStationID:[NSNumber numberWithInt:23]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"25th & Welton"];
	[station setLatitude:[NSNumber numberWithDouble:39.75315382078058]];
	[station setLongitude:[NSNumber numberWithDouble:-104.98006761074067]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station setStationID:[NSNumber numberWithInt:24]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"29th & Welton"];
	[station setLatitude:[NSNumber numberWithDouble:39.757084071406425]];
	[station setLongitude:[NSNumber numberWithDouble:-104.9750304222107]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station setStationID:[NSNumber numberWithInt:25]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"30th & Downing"];
	[station setLatitude:[NSNumber numberWithDouble:39.758807867137385]];
	[station setLongitude:[NSNumber numberWithDouble:-104.9734452366829]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station setStationID:[NSNumber numberWithInt:26]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Auraria West Campus"];
	[station setLatitude:[NSNumber numberWithDouble:39.741285412555925]];
	[station setLongitude:[NSNumber numberWithDouble:-105.00901401042938]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station setStationID:[NSNumber numberWithInt:27]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Invesco Field at Mile High"];
	[station setLatitude:[NSNumber numberWithDouble:39.743446831848615]];
	[station setLongitude:[NSNumber numberWithDouble:-105.01322239637376]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station setStationID:[NSNumber numberWithInt:28]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Pepsi Center/Six Flags"];
	[station setLatitude:[NSNumber numberWithDouble:39.74860055332102]];
	[station setLongitude:[NSNumber numberWithDouble:-105.00974088907243]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station setStationID:[NSNumber numberWithInt:29]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Union Station"];
	[station setLatitude:[NSNumber numberWithDouble:39.753630164252605]];
	[station setLongitude:[NSNumber numberWithDouble:-105.00158697366714]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station setStationID:[NSNumber numberWithInt:30]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Evans"];
	[station setLatitude:[NSNumber numberWithDouble:39.677666454577476]];
	[station setLongitude:[NSNumber numberWithDouble:-104.99285370111467]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station setStationID:[NSNumber numberWithInt:31]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Englewood"];
	[station setLatitude:[NSNumber numberWithDouble:39.65560939625744]];
	[station setLongitude:[NSNumber numberWithDouble:-104.99995082616807]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station setStationID:[NSNumber numberWithInt:32]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Oxford"];
	[station setLatitude:[NSNumber numberWithDouble:39.64290011218291]];
	[station setLongitude:[NSNumber numberWithDouble:-105.00482439994812]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station setStationID:[NSNumber numberWithInt:33]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Littleton/Downtown"];
	[station setLatitude:[NSNumber numberWithDouble:39.611965944477035]];
	[station setLongitude:[NSNumber numberWithDouble:-105.01486659049989]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station setStationID:[NSNumber numberWithInt:34]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"Littleton/Mineral"];
	[station setLatitude:[NSNumber numberWithDouble:39.58011869115301]];
	[station setLongitude:[NSNumber numberWithDouble:-105.02493560314178]];
	[station addLinesObject:[linesByName objectForKey:@"C"]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station setStationID:[NSNumber numberWithInt:35]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	station = (Station *)[NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:managedObjectContext];
	[station setName:@"27th & Welton"];
	[station setLatitude:[NSNumber numberWithDouble:39.75525713075179]];
	[station setLongitude:[NSNumber numberWithDouble:-104.97734785079956]];
	[station addLinesObject:[linesByName objectForKey:@"D"]];
	[station setStationID:[NSNumber numberWithInt:36]];
	[stationsByName setObject:station forKey:[station stationID]];
	
	if(! [managedObjectContext save:&error])
	{
		NSLog(@"%@ %@",error,[error userInfo]);
		//handle error
	}
	
	return stationsByName;
}

-(void)setupStopsWithLines:(NSDictionary *)linesByName andStations:(NSDictionary *)stationsByName
{
	NSError *error = nil;
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"C_N_H" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"C_N_S" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"C_N_W" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"C_S_W" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"D_N_H" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"D_N_S" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"D_N_W" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"D_S_H" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"D_S_S" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"D_S_W" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"E_N_H" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"E_N_S" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"E_N_W" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"E_S_H" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"E_S_S" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"E_S_W" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"F_N_W" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"F_S_H" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"F_S_S" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"F_S_W" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"H_N_H" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"H_N_S" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"H_N_W" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"H_S_H" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"H_S_S" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	[self loadStopsFromPath:[[NSBundle mainBundle] pathForResource:@"H_S_W" ofType:@"txt"]
				  withLines:linesByName andStations:stationsByName];
	
	if(! [managedObjectContext save:&error])
	{
		NSLog(@"%@ %@",error,[error userInfo]);
		//handle error
	}
	
}

-(void)loadStopsFromPath:(NSString *)path withLines:(NSDictionary *)linesByName andStations:(NSDictionary *)stationsByName
{
	NSError *error = nil;
	NSString *fileString = [[NSString alloc] initWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
	[LineLoader loadStopData:fileString withLinesByName:linesByName andStationsByID:stationsByName inManagedObjectContext:[self managedObjectContext]];
	[fileString release];
}

#pragma mark -
#pragma mark Line updating



#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
	[_linesToColors release];
	[_currentDirection release];
    
	[navigationController release];
	[window release];
	[super dealloc];
}
\


@end

