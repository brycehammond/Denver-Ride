//
//  StationListViewController.h
//  RTD
//
//  Created by bryce.hammond on 8/13/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StationListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate> {
	NSFetchedResultsController *_fetchedResultsController;
	NSManagedObjectContext *_managedObjectContext;
	
	IBOutlet UITableView *_stationsTableView;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
