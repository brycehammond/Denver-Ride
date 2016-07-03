//
//  StationViewController.h
//  RTD
//
//  Created by bryce.hammond on 8/9/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRRunViewController.h"
#import "DRRTDMapViewController.h"
#import "DenverRideBaseViewController.h"
#import "DRBCycleViewController.h"

@class Station;

@interface DRStationViewController : DenverRideBaseViewController <UITableViewDelegate, UITableViewDataSource> 

@property (nonatomic, strong) NSMutableArray *stopsArray;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Station *station;
@property (assign) NSInteger currentTimeInMinutes;
@property (nonatomic, strong) NSString *dayType;
@property (assign, nonatomic) DRTimeDirection timeDirection;

@end
