//
//  StationViewController.h
//  RTD
//
//  Created by bryce.hammond on 8/9/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RunViewController.h"

@class Station;

@interface StationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {

	NSMutableArray *_stopsArray;
	NSManagedObjectContext *_managedObjectContext;
	Station *_station;
	
	IBOutlet UISegmentedControl *_northOrSouthControl;
	IBOutlet UITableView *_stopsTableView;
	
	NSInteger _currentTimeInMinutes;
	
	TimeDirection _timeDirection;
	
}

@property (nonatomic, retain) NSMutableArray *stopsArray;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Station *station;
@property (assign) NSInteger currentTimeInMinutes;

-(id)initWithStation:(Station *)station withCurrentTimeInMinutes:(NSInteger)currentTimeInMinutes;
-(id)initWithStation:(Station *)station withCurrentTimeInMinutes:(NSInteger)currentTimeInMinutes 
				andTimeDirection:(TimeDirection)timeDirection;

-(IBAction)changeDirection:(id)sender;

@end
