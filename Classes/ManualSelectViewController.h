//
//  ManualSelectViewController.h
//  RTD
//
//  Created by bryce.hammond on 9/12/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChangeDirectionProtocol.h"
#import "TimeChangeViewController.h"
#import "DayTypeChangeViewController.h"
#import "StationChangeViewController.h"

@interface ManualSelectViewController : UIViewController <ChangeDirectionProtocol, 
UITableViewDelegate, UITableViewDataSource, TimeChangeViewControllerDelegate, DayTypeChangeViewControllerDelegate,
StationChangeViewControllerDelegate> {
	UINavigationController *_navigationController;
	NSManagedObjectContext *_managedObjectContext;
	
	IBOutlet UITableView *_manualTableView;
	NSInteger _timeInMinutes;
	
	NSArray *_currentStops;
	NSString *_currentDayType;
	
	TimeChangeViewController *_timeChangeController;
	DayTypeChangeViewController *_dayTypeChangeController;
	StationChangeViewController *_stationChangeController;
	
	
}

@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (assign) NSInteger timeInMinutes;
@property (nonatomic, retain) NSArray *currentStops;
@property (nonatomic, retain) NSString *currentDayType;

@end
