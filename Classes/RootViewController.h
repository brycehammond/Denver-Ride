//
//  RootViewController.h
//  RTD
//
//  Created by bryce.hammond on 8/2/09.
//  Copyright Wall Street On Demand, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LoadingView.h"

@interface RootViewController : UIViewController <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource> {
	
	NSManagedObjectContext *_managedObjectContext;
	CLLocationManager *_locationManager;
	
	NSMutableArray *_stationsArray;
	NSArray *_closestStationsArray;  //This is the first three stations of the sorted stationsArray by distance
	NSMutableArray *_closestStationsStopsArray;
	NSMutableArray *_closestStationsRunsArray;
	
	IBOutlet UITableView *_closeStationsTableView;
	IBOutlet UISegmentedControl *_northOrSouthControl;
	LoadingView *_loadingView;
	
	
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *stationsArray;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSArray *closestStationsArray;
@property (nonatomic, retain) NSMutableArray *closestStationsStopsArray;
@property (nonatomic, retain) NSMutableArray *closestStationsRunsArray;

-(NSInteger)currentTimeInMinutes;

-(IBAction)changeDirection:(id)sender;

@end
