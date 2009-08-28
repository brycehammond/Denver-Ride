//
//  StationViewController.h
//  RTD
//
//  Created by bryce.hammond on 8/9/09.
//  Copyright 2009 Wall Street On Demand, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Station;

@interface StationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {

	NSMutableArray *_stopsArray;
	NSManagedObjectContext *_managedObjectContext;
	Station *_station;
	
	IBOutlet UISegmentedControl *_northOrSouthControl;
	IBOutlet UITableView *_stopsTableView;
	
	NSInteger _currentTimeInMinutes;
	
}

@property (nonatomic, retain) NSMutableArray *stopsArray;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Station *station;
@property (assign) NSInteger currentTimeInMinutes;

-(id)initWithStation:(Station *)station withCurrentTimeInMinutes:(NSInteger)currentTimeInMinutes;

-(IBAction)changeDirection:(id)sender;

@end
