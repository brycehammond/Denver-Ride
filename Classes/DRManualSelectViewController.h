//
//  ManualSelectViewController.h
//  RTD
//
//  Created by bryce.hammond on 9/12/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChangeDirectionProtocol.h"
#import "DRTimeChangeViewController.h"
#import "DRDayTypeChangeViewController.h"
#import "DRStationChangeViewController.h"
#import "DRRunViewController.h"

@interface DRManualSelectViewController : UIViewController <DRChangeDirectionProtocol, 
UITableViewDelegate, UITableViewDataSource, TimeChangeViewControllerDelegate, DayTypeChangeViewControllerDelegate,
StationChangeViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (assign) NSInteger timeInMinutes;
@property (nonatomic, strong) NSArray *currentStops;
@property (nonatomic, strong) NSString *currentDayType;

-(void)retrieveStopsDirection:(NSString *)direction;

@end
