//
//  StationListViewController.h
//  RTD
//
//  Created by bryce.hammond on 8/13/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Station;

@interface StationListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, 
NSFetchedResultsControllerDelegate, UISearchBarDelegate> {
	NSFetchedResultsController *_fetchedResultsController;
	NSManagedObjectContext *_managedObjectContext;
	
	NSMutableArray *_recentlyUsedStations;
	NSArray *_recentlyUsedStationsToDisplay; //These can be different due to filtering
	
	IBOutlet UITableView *_stationsTableView;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

-(void)populateRecentlyUsed;
-(void)addStationToRecentlyUsed:(Station *)station;

@end
