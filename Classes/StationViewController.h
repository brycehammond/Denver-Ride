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
#import "DenverRideBaseViewController.h"
#import "BCycleViewController.h"

@class Station;

@interface StationViewController : DenverRideBaseViewController <UITableViewDelegate, UITableViewDataSource> {

	NSMutableArray *_stopsArray;
	NSManagedObjectContext *_managedObjectContext;
	Station *_station;
	
	UITableView *_stopsTableView;
	
	NSInteger _currentTimeInMinutes;
	
	TimeDirection _timeDirection;
	NSString *_dayType;
	
	RTDMapViewController *_mapViewController;
	BCycleViewController *_bcycleViewController;
	
}

@property (nonatomic, strong) NSMutableArray *stopsArray;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Station *station;
@property (assign) NSInteger currentTimeInMinutes;
@property (nonatomic, strong) NSString *dayType;

-(id)initWithStation:(Station *)station withCurrentTimeInMinutes:(NSInteger)currentTimeInMinutes;
-(id)initWithStation:(Station *)station withCurrentTimeInMinutes:(NSInteger)currentTimeInMinutes 
	andTimeDirection:(TimeDirection)timeDirection andDayType:(NSString *)dayType;

@end
