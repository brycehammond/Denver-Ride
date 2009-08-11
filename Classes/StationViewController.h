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
	NSMutableArray *_runsArray;
	NSManagedObjectContext *_managedObjectContext;
	Station *_station;
	
	UISegmentedControl *_northOrSouthControl;
	UITableView *_stopsTableView;
	
}

@property (nonatomic, retain) NSMutableArray *stopsArray;
@property (nonatomic, retain) NSMutableArray *runsArray;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Station *station;


-(id)initWithStation:(Station *)station;

@end
