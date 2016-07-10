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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked:)];
}

-(void)cancelButtonClicked:(UIBarButtonItem *)item
{
	[self.delegate viewWasCancelled];
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
	
	[self.delegate stationWasSelected:station];
	
	[self addStationToRecentlyUsed:station];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
}


@end
