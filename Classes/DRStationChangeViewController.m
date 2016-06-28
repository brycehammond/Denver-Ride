//
//  StationChangeViewController.m
//  RTD
//
//  Created by bryce.hammond on 9/26/09.
//  Copyright 2009 Fluidvisiong Design. All rights reserved.
//

#import "DRStationChangeViewController.h"
#import "Station.h"

@implementation DRStationChangeViewController

@synthesize delegate;
@synthesize stationChangeToolbar;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.stationChangeToolbar.tintColor = [UIColor colorWithHexString:kNavBarColor];
    [self.stationChangeToolbar.items.firstObject setTintColor:[UIColor whiteColor]];
}

-(IBAction)cancelButtonClicked
{
	[delegate viewWasCancelled];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	[cell setAccessoryType:UITableViewCellAccessoryNone];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	Station *station = nil;
	if(indexPath.section == 0) //recently used
	{
		if(_recentlyUsedStationsToDisplay)
		{
			station = _recentlyUsedStationsToDisplay[indexPath.row];
		}
		else {
			station = _recentlyUsedStations[indexPath.row];
		}

	}
	else {
		station = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];

	}
	
	[delegate stationWasSelected:station];
	
	[self addStationToRecentlyUsed:station];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
}


@end
