//
//  RunViewController.h
//  RTD
//
//  Created by bryce.hammond on 8/12/09.
//  Copyright 2009 Wall Street On Demand, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RunViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	NSArray *_runArray;
	IBOutlet UITableView *_runTableView;
}

@property (nonatomic, retain) NSArray *runArray;


-(id)initWithRunArray:(NSArray *)runArray;

@end
