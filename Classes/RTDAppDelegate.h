//
//  RTDAppDelegate.h
//  RTD
//
//  Created by bryce.hammond on 8/2/09.
//  Copyright Wall Street On Demand, Inc. 2009. All rights reserved.
//

@interface RTDAppDelegate : NSObject <UIApplicationDelegate> {
    
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

    UIWindow *window;
    UINavigationController *navigationController;
	
	BOOL defaultDataNeedsFilling;
	
	NSString *_currentDirection;
	
	NSDictionary *_linesToColors;
	
	NSString *currentDayType;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSString *currentDirection;
@property (readonly) NSDictionary *linesToColors;

@property (nonatomic, retain) NSString *currentDayType;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
 

@end

