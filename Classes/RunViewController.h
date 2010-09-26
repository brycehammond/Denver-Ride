//
//  RunViewController.h
//  RTD
//
//  Created by bryce.hammond on 8/12/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTDMapViewController.h"

typedef enum {
	FORWARD = 0,
	BACKWARD = 1
} TimeDirection;

@class Stop;

@interface RunViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	NSArray *_runArray;
	Stop *_stop;
	NSManagedObjectContext *_managedObjectContext;
	IBOutlet UITableView *_runTableView;
	
	IBOutlet UILabel *_topLine;
	IBOutlet UILabel *_middleLine;
	IBOutlet UILabel *_bottomLine;
	
	TimeDirection _timeDirection;
	
	RTDMapViewController *_mapController;
}

@property (nonatomic, retain) NSArray *runArray;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


-(id)initWithStop:(Stop *)stop;
-(id)initWithStop:(Stop *)stop withTimeDirection:(TimeDirection)timeDirection;

@end
