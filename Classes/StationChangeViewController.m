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
@synthesize toolbar;
@synthesize searchBar;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    self.toolbar.tintColor = [UIColor colorFromHex:kNavBarColor withAlpha:1];
    self.searchBar.tintColor = [UIColor colorFromHex:kNavBarColor withAlpha:1];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
    [self setSearchBar:nil];
    [self setToolbar:nil];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [toolbar release];
    [searchBar release];
    [super dealloc];
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
