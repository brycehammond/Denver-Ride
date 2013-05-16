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
#import "Flurry.h"
#import "DatabaseLoader.h"

@interface RTDAppDelegate (Private)

-(void)populateStore;
-(BOOL)rebuildCoreDataStackWithDatabasePath:(NSString *)path;

@end


@implementation RTDAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize currentDirection = _currentDirection;
@synthesize linesToColors = _linesToColors;
@synthesize currentDayType;


#define kDatabaseVersionKey	@"DatabaseVersionKey"
#define kInitialDatabaseVersion @"RTD2.0"

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
	defaultDataNeedsFilling = NO;
	
    [Flurry setSecureTransportEnabled:NO];
    [Flurry setSessionReportsOnCloseEnabled:NO];
    [Flurry setSessionReportsOnPauseEnabled:NO];
	[Flurry startSession:@"EVE2QD8JNU2R1QXVTAZQ"];

	_currentDatabaseVersion = [[NSUserDefaults standardUserDefaults] stringForKey:kDatabaseVersionKey];
	if(nil == _currentDatabaseVersion)
	{
		_currentDatabaseVersion = [[NSString alloc] initWithString:kInitialDatabaseVersion];
		[[NSUserDefaults standardUserDefaults] setObject:_currentDatabaseVersion forKey:kDatabaseVersionKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
    
	NSManagedObjectContext *context = self.managedObjectContext;
	
	if(defaultDataNeedsFilling)
	{
		[self populateStore];
	}
	
	_linesToColors = @{@"C": [UIColor colorFromHex:@"F79238" withAlpha:1],
							@"D": [UIColor colorFromHex:@"038349" withAlpha:1],
							@"E": [UIColor colorFromHex:@"552485" withAlpha:1],
							@"F": [UIColor colorFromHex:@"EF3931" withAlpha:1],
							@"H": [UIColor colorFromHex:@"0073BD" withAlpha:1]};
	
	
	RootViewController *rootViewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	rootViewController.managedObjectContext = context;
	
	navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
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

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if(nil == _databaseUpdater)
    {
        _databaseUpdater = [[DatabaseUpdater alloc] init];
        [_databaseUpdater setDelegate:self];        
    }
    
    [_databaseUpdater startUpdate];
}

- (void)completedFadingDefaultPng:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
	[_defaultPngToFade removeFromSuperview];
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle error.
			DLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];    
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
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent:
											   [_currentDatabaseVersion stringByAppendingString:@".sqlite"]]];
    
    NSError *error;
    
	NSString *filePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[_currentDatabaseVersion stringByAppendingString:@".sqlite"]];
    
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if (fileHandle == nil) {
        NSString *defaultPath = [[NSBundle mainBundle] pathForResource:kInitialDatabaseVersion ofType:@"sqlite"];
        if (defaultPath) {
			NSError *error;
            
			[[NSFileManager defaultManager] copyItemAtPath:defaultPath
													toPath:filePath error:&error];
			
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            
            BOOL iCloudExclusionAvailable = (&NSURLIsExcludedFromBackupKey != NULL);
            
            if(iCloudExclusionAvailable)
            {
                [fileURL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
            }
            
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
            DLog(@"Error opening database with URL: %@", storeUrl);
        }
    }
	
	return persistentStoreCoordinator;
	 
}

-(void)setCurrentDirection:(NSString *)direction
{
	if(_currentDirection != direction)
	{
		_currentDirection = direction;
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
    NSString *basePath = ([paths count] > 0) ? paths[0] : nil;
    return basePath;
}


-(void)populateStore
{
	
	DatabaseLoader *loader = [[DatabaseLoader alloc] init];
	[loader loadItUp];
}

-(BOOL)rebuildCoreDataStackWithDatabaseFile:(NSString *)file
{
	//deconstruct the stack
	
	managedObjectContext = nil;
	persistentStoreCoordinator = nil;
	
	//check to see if the new store is valid

	
	NSString *filePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:file];
	NSURL *storeUrl = [NSURL fileURLWithPath:filePath];
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
	
    if (fileHandle == nil) 
	{
		return NO;
	}
	else 
	{
		NSError *error = nil;
		persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
		if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]){
			persistentStoreCoordinator = nil;
			return NO;
		}
	}
	
	[self managedObjectContext]; //build context on top of new store
	
	return YES;
	
}

#pragma mark -
#pragma mark DatabaseUpdaterDelegate methods

- (void)databaseUpdateStarted
{
    [[navigationController view] removeFromSuperview];
    navigationController = nil;
}

- (void)databaseUpdateFinished
{
    RootViewController *rootViewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	rootViewController.managedObjectContext = [self managedObjectContext];
	
	navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    
    
    [window addSubview:[navigationController view]];
}

- (void)newDatabaseAvailableWithFilename:(NSString *)filename andDate:(NSString *)date
{
    
    
	if([self rebuildCoreDataStackWithDatabaseFile:filename])
	{ 
		[[NSUserDefaults standardUserDefaults] setObject:[filename stringByDeletingPathExtension]
												  forKey:kDatabaseVersionKey];
        [[NSUserDefaults standardUserDefaults] setObject:date forKey:kLastUpdateDateKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //go through and remove old databases
        NSError *error = nil;
        
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self applicationDocumentsDirectory] error:&error];
        
        if(nil == error)
        {
            for(NSString *file in files)
            {
                if([file hasSuffix:@".sqlite"] && NO == [file isEqualToString:filename])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:file] error:&error];
                }
            }
        }
        
        
	}
	else 
	{
		[Flurry logError:@"UpdateError" message:[NSString stringWithFormat:@"error updating to %@",filename]
					  error:nil];
		[self managedObjectContext];
	}
}


#pragma mark -
#pragma mark Memory management




@end

