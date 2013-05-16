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
	
	UITableView *_closeStationsTableView;
	LoadingView *_loadingView;
	
	NSTimer *_delayTimer;
	
	UINavigationController *_navigationController;
															
	NSString *_currentDirection;														
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *stationsArray;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *closestStationsArray;
@property (nonatomic, strong) NSString *currentDirection;
@property (nonatomic, strong) NSMutableArray *closestStationsStopsArray;

@property (nonatomic, strong) UINavigationController *navigationController;

-(void)retrieveStopsDirection:(NSString *)direction;

@end
