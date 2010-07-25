//
//  StationViewController.h
//  RTD
//
//  Created by bryce.hammond on 8/9/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RunViewController.h"
#import "RTDMapViewController.h"

@class Station;

@interface StationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, RTDMapViewControllerDelegate> {

	NSMutableArray *_stopsArray;
	NSManagedObjectContext *_managedObjectContext;
	Station *_station;
	
	IBOutlet UISegmentedControl *_northOrSouthControl;
	IBOutlet UITableView *_stopsTableView;
	
	NSInteger _currentTimeInMinutes;
	
	TimeDirection _timeDirection;
	NSString *_dayType;
	
	RTDMapViewController *_mapController;
	
}

@property (nonatomic, retain) NSMutableArray *stopsArray;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Station *station;
@property (assign) NSInteger currentTimeInMinutes;
@property (nonatomic, retain) NSString *dayType;

-(id)initWithStation:(Station *)station withCurrentTimeInMinutes:(NSInteger)currentTimeInMinutes;
-(id)initWithStation:(Station *)station withCurrentTimeInMinutes:(NSInteger)currentTimeInMinutes 
	andTimeDirection:(TimeDirection)timeDirection andDayType:(NSString *)dayType;

-(IBAction)changeDirection:(id)sender;

@end
