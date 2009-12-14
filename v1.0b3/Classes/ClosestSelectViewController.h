//
//  ClosestSelectViewController.h
//  RTD
//
//  Created by bryce.hammond on 9/12/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LoadingView.h"
#import "ChangeDirectionProtocol.h"

@interface ClosestSelectViewController : UIViewController <CLLocationManagerDelegate, UITableViewDelegate, 
														UITableViewDataSource, ChangeDirectionProtocol> {
	
	NSManagedObjectContext *_managedObjectContext;
	CLLocationManager *_locationManager;
	
	NSMutableArray *_stationsArray;
	NSArray *_closestStationsArray;  //This is the first three stations of the sorted stationsArray by distance
	NSMutableArray *_closestStationsStopsArray;
	
	IBOutlet UITableView *_closeStationsTableView;
	LoadingView *_loadingView;
	
	NSTimer *_delayTimer;
	
	UINavigationController *_navigationController;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *stationsArray;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSArray *closestStationsArray;
@property (nonatomic, retain) NSMutableArray *closestStationsStopsArray;

@property (nonatomic, retain) UINavigationController *navigationController;

-(void)retrieveStopsForClosestStationsInDirection:(NSString *)direction;

@end
