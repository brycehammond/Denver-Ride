//
//  RunViewController.h
//  RTD
//
//  Created by bryce.hammond on 8/12/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Stop;

@interface RunViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	NSArray *_runArray;
	Stop *_stop;
	NSManagedObjectContext *_managedObjectContext;
	IBOutlet UITableView *_runTableView;
	
	IBOutlet UILabel *_topLine;
	IBOutlet UILabel *_middleLine;
	IBOutlet UILabel *_bottomLine;
}

@property (nonatomic, retain) NSArray *runArray;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


-(id)initWithStop:(Stop *)stop;

@end
