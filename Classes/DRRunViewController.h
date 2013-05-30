//
//  RunViewController.h
//  RTD
//
//  Created by bryce.hammond on 8/12/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRRTDMapViewController.h"

@class Stop;

@interface DRRunViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	NSArray *_runArray;
	Stop *_stop;
	NSManagedObjectContext *_managedObjectContext;
	IBOutlet UITableView *_runTableView;
	
	IBOutlet UILabel *_topLine;
	IBOutlet UILabel *_middleLine;
	IBOutlet UILabel *_bottomLine;
	
	DRTimeDirection _timeDirection;
	
	DRRTDMapViewController *_mapController;
}

@property (nonatomic, strong) NSArray *runArray;
@property (nonatomic, strong) Stop *stop;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;


-(id)initWithStop:(Stop *)stop;
-(id)initWithStop:(Stop *)stop withTimeDirection:(DRTimeDirection)timeDirection;

@end
