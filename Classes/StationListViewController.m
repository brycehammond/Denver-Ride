//
//  StationListViewController.m
//  RTD
//
//  Created by bryce.hammond on 8/13/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import "StationListViewController.h"
#import "StationViewController.h"
#import "Station.h"
#import "RTDAppDelegate.h"
#import "NSDate+TimeInMinutes.h"
#import "UIColorCategories.h"

#define kRecentlyUsedStationsKey @"RecentlyUsedStations"

@implementation StationListViewController
@synthesize stationListSearchBar = _stationListSearchBar;

@synthesize fetchedResultsController = _fetchedResultsController,
			managedObjectContext = _managedObjectContext;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _recentlyUsedStations = [[NSMutableArray alloc] init];
		_recentlyUsedStationsToDisplay = nil;
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setTitle:@"All Stations"];
	
	RTDAppDelegate *appDelegate = (RTDAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *dayType = [[NSDate date] dayType];
	[appDelegate setCurrentDayType:dayType];
    
    self.stationListSearchBar.tintColor = [UIColor colorFromHex:kNavBarColor withAlpha:1];
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Handle the error...
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self populateRecentlyUsed];
	[_stationsTableView reloadData];
	[_stationsTableView setContentOffset:CGPointMake(0, 0)];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [self setStationListSearchBar:nil];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(void)populateRecentlyUsed
{
	[_recentlyUsedStations removeAllObjects];
	NSArray *recentlyUsedStations = [[NSUserDefaults standardUserDefaults] objectForKey:kRecentlyUsedStationsKey];
	if(recentlyUsedStations)
	{
		NSPredicate *searchPredicate =[NSPredicate predicateWithFormat:@"name IN %@ AND direction in %@",recentlyUsedStations,
									   [NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentDirection"], @"B",nil]];
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Station" inManagedObjectContext:[self managedObjectContext]];
		[request setEntity:entity];
		[request setPredicate:searchPredicate];

		// Execute the fetch -- create a mutable copy of the result.
		NSError *error = nil;
		NSMutableArray *mutableFetchResults = [[[self managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];
		if (mutableFetchResults == nil) {
			// Handle the error.
		}
		
		for(NSString *stationName in recentlyUsedStations)
		{
			for(Station *station in mutableFetchResults)
			{
				if([[station name] isEqualToString:stationName])
				{
					[_recentlyUsedStations addObject:station];
					break;
				}
			}
		}
		
		
	}
	
}

-(void)addStationToRecentlyUsed:(Station *)station
{
	NSInteger stationIndex = NSNotFound;
	
	//Go through all stations and compare names since northbound/southbound
	//stations are actually different
	for(NSUInteger stationIdx = 0; stationIdx < [_recentlyUsedStations count] ; ++stationIdx)
	{
		Station *usedStation = [_recentlyUsedStations objectAtIndex:stationIdx];
		if([[usedStation name] isEqualToString:[station name]])
		{
			stationIndex = stationIdx;
			break;
		}
	}
	
	if(stationIndex != NSNotFound)
	{
		//we already have this station so put it to the top of the list
		Station *movingStation = [_recentlyUsedStations objectAtIndex:stationIndex];
		[_recentlyUsedStations removeObjectAtIndex:stationIndex];
		[_recentlyUsedStations insertObject:movingStation atIndex:0];
	}
	else {
		//we don't have this station yet, so add it to the front and remove the last one
		if([_recentlyUsedStations count] >= 5)
		{
			[_recentlyUsedStations removeLastObject];
		}
		
		[_recentlyUsedStations insertObject:station atIndex:0];
	}
		 
	NSMutableArray *orderingToSaveArray = [NSMutableArray arrayWithCapacity:[_recentlyUsedStations count]];
	for(Station *stationToSave in _recentlyUsedStations)
	{
		[orderingToSaveArray addObject:[stationToSave name]];
	}
		 
	[[NSUserDefaults standardUserDefaults] setObject:orderingToSaveArray forKey:kRecentlyUsedStationsKey];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if(section == 0) //recently used
	{
		if(nil != _recentlyUsedStationsToDisplay)
		{
			return [_recentlyUsedStationsToDisplay count];
		}
		else {
			return [_recentlyUsedStations count];
		}
	}
	else if(section == 1) //full list
	{
		NSArray *sections = [[self fetchedResultsController] sections];
		
		NSUInteger count = 0;
		
		if ([sections count]) {
			
			id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:0];
			
			count = [sectionInfo numberOfObjects];
			
		}
		
		return count;
	}
	
	return 0;
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	Station *station = nil;
	if(indexPath.section == 0) //recently used
	{
		if(nil != _recentlyUsedStationsToDisplay)
		{
			station = [_recentlyUsedStationsToDisplay objectAtIndex:indexPath.row];
		}
		else {
			station = [_recentlyUsedStations objectAtIndex:indexPath.row];
		}
	}
	else if(indexPath.section == 1) //full list
	{
		
		// Configure the cell.
		station = (Station *)[[self fetchedResultsController] objectAtIndexPath:
							  [NSIndexPath indexPathForRow:indexPath.row inSection:0]];
	}
	
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	if(station)
	{
		cell.textLabel.text = station.name;
	}
	else {
		cell.textLabel.text = @"";
	}

	
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
	return cell;
	
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	Station *station = nil;
	//get the current hours and minutes to get stops that are in the future
	NSDate *now = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"H"];
	int hours = [[dateFormatter stringFromDate:now] intValue];
	[dateFormatter setDateFormat:@"m"];
	int minutes = [[dateFormatter stringFromDate:now] intValue];
	int timeInMinutes = hours * 60 + minutes;
	
	if(indexPath.section == 0) //recently viewed
	{
		if(nil != _recentlyUsedStationsToDisplay)
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
	
	StationViewController *stationController = [[StationViewController alloc] initWithStation:station withCurrentTimeInMinutes:timeInMinutes];
	[stationController setManagedObjectContext:[self managedObjectContext]];
	[[self navigationController] pushViewController:stationController animated:YES];
	
	[self addStationToRecentlyUsed:station];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([self tableView:tableView numberOfRowsInSection:section] > 0)
    {
        return 24;
    }
    else 
    {
        return 0;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	NSString *sectionTitle = @"";
	if(section == 0) //recently viewed
	{
		if(_recentlyUsedStationsToDisplay != nil && [_recentlyUsedStationsToDisplay count] == 0)
		{
			return nil;
		}
		else if([_recentlyUsedStations count] == 0)
		{
			return nil;
		}
		else {
			sectionTitle = @"  Recently Used";
		}

	}
	else if(section == 1) //all stations
	{
		sectionTitle = @"  All Stations";
	}
	
	UILabel *headerLabel = [[UILabel alloc] initWithFrame:
							CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width
									   , 24)];
	[headerLabel setTextColor:[UIColor whiteColor]];
	[headerLabel setText:sectionTitle];
	[headerLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
	[headerLabel setBackgroundColor:[UIColor colorFromHex:@"70A96A" withAlpha:1]];
	[headerLabel setShadowColor:[UIColor grayColor]];
	[headerLabel setShadowOffset:CGSizeMake(2, 1)];
	
	return headerLabel;

}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    /*
	 Set up the fetched results controller.
	 */
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Station" inManagedObjectContext:_managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"direction in %@",
								[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentDirection"], @"B",nil]]];
	
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	
	return _fetchedResultsController;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	NSPredicate *reduction = nil;
	if([searchText length] > 0)
	{
		reduction = [NSPredicate predicateWithFormat:@"name contains[cd] %@ AND direction in %@",searchText, 
					 [NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentDirection"], @"B",nil]];
	}
	else {
		_recentlyUsedStationsToDisplay = nil;
		[searchBar resignFirstResponder];
	}

	//Update all the stations
	[[[self fetchedResultsController] fetchRequest] setPredicate:reduction];
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Handle the error...
	}
	
	//Update all the recently used
	if(! [searchText isEqualToString:@""])
	{
		_recentlyUsedStationsToDisplay = [_recentlyUsedStations filteredArrayUsingPredicate:reduction];
	}
	
	[_stationsTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.stationListSearchBar resignFirstResponder];
    
}



@end
