//
//  StationChangeViewController.m
//  RTD
//
//  Created by bryce.hammond on 9/26/09.
//  Copyright 2009 Fluidvisiong Design. All rights reserved.
//

#import "StationChangeViewController.h"
#import "Station.h"

@implementation StationChangeViewController

@synthesize delegate;
@synthesize stationChangeToolbar;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setFrameHeight:[[UIScreen mainScreen] bounds].size.height - kStatusBarHeight];
    self.stationChangeToolbar.tintColor = [UIColor colorFromHex:kNavBarColor withAlpha:1];
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

- (void)viewDidUnload {
    [self setStationChangeToolbar:nil];
    [super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
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
			station = [_recentlyUsedStationsToDisplay objectAtIndex:indexPath.row];
		}
		else {
			station = [_recentlyUsedStations objectAtIndex:indexPath.row];
		}

	}
	else {
		station = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];

	}
	
	[delegate stationWasSelected:[station name]];
	
	[self addStationToRecentlyUsed:station];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
}


@end
