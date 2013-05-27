//
//  RTDAppDelegate.h
//  RTD
//
//  Created by bryce.hammond on 8/2/09.
//  Copyright Fluidvision Design 2009. All rights reserved.
//

#import "DRDatabaseUpdater.h"

@class  DRRootViewController;

@interface RTDAppDelegate : NSObject <UIApplicationDelegate, DatabaseUpdaterDelegate> {
    
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

    UIWindow *window;
    UINavigationController *navigationController;
	
	BOOL defaultDataNeedsFilling;
	
	NSString *_currentDirection;
	
	NSDictionary *_linesToColors;
	
	NSString *currentDayType;
	
	DRDatabaseUpdater *_databaseUpdater;
	
	UIImageView *_defaultPngToFade;
	
	NSString *_currentDatabaseVersion;
	
	NSString *_updatingDatabaseVersion;
}

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSString *currentDirection;
@property (readonly) NSDictionary *linesToColors;

@property (nonatomic, strong) NSString *currentDayType;

@property (weak, nonatomic, readonly) NSString *applicationDocumentsDirectory;

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UINavigationController *navigationController;
 

@end

