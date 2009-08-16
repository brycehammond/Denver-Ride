//
//  RootViewController.m
//  RTD
//
//  Created by bryce.hammond on 8/2/09.
//  Copyright Wall Street On Demand, Inc. 2009. All rights reserved.
//

#import "RootViewController.h"
#import "StationViewController.h"
#import "Station.h"
#import "Stop.h"
#import "StationStopTableViewCell.h"
#import "RunViewController.h"
#import "StationListViewController.h"

@interface RootViewController (Private)
-(void)retrieveStopsForClosestStationsInDirection:(NSString *)direction;
@end


@implementation RootViewController

@synthesize  managedObjectContext = _managedObjectContext, 
			stationsArray = _stationsArray,
			locationManager = _locationManager,
			closestStationsArray = _closestStationsArray,
			closestStationsStopsArray = _closestStationsStopsArray,
			closestStationsRunsArray = _closestStationsRunsArray;

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Closest Stations"];
	
	NSString *direction = [[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentDirection"];
	if([direction isEqualToString:@"N"])
	{
		[_northOrSouthControl setSelectedSegmentIndex:0];
	}
	else
	{
		[_northOrSouthControl setSelectedSegmentIndex:1];
	}
	
	//We haven't gotten a closest location yet so set the
	//closest location array to empty
	[self setClosestStationsArray:[NSArray array]];
	[self setClosestStationsStopsArray:[NSMutableArray array]];
	[self setClosestStationsRunsArray:[NSMutableArray array]];
	
	/*
	 Fetch existing stations.
	 Create a fetch request; find the Station entity and assign it to the request; add a sort descriptor; then execute the fetch.
	 */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Station" inManagedObjectContext:[self managedObjectContext]];
	[request setEntity:entity];
	
	// Execute the fetch -- create a mutable copy of the result.
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[[self managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
	}
	
	// Set the station array to the mutable array, then clean up.
	[self setStationsArray:mutableFetchResults];
	[mutableFetchResults release];
	[request release];
	
	// Start the location manager.
	[[self locationManager] startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[_managedObjectContext release];
    [super dealloc];
}

-(IBAction)changeDirection:(UISegmentedControl *)sender
{
	NSLog(@"%i",[sender selectedSegmentIndex]);
	NSString *direction = [[[sender titleForSegmentAtIndex:[sender selectedSegmentIndex]]
							substringToIndex:1] uppercaseString];
	[[NSUserDefaults standardUserDefaults] setObject:direction forKey:@"CurrentDirection"];
	[self retrieveStopsForClosestStationsInDirection:direction];
	[_closeStationsTableView reloadData];
}

-(NSInteger)currentTimeInMinutes
{
	//get the current hours and minutes to get stops that are in the future
	NSDate *now = [NSDate date];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
	[dateFormatter setDateFormat:@"H"];
	int hours = [[dateFormatter stringFromDate:now] intValue];
	[dateFormatter setDateFormat:@"m"];
	int minutes = [[dateFormatter stringFromDate:now] intValue];
	int timeInMinutes = hours * 60 + minutes;
	
	return timeInMinutes;
}

-(void)retrieveStopsForClosestStationsInDirection:(NSString *)direction
{
	[[self closestStationsStopsArray] removeAllObjects];
	[[self closestStationsRunsArray] removeAllObjects];
	for(Station *station in [self closestStationsArray])
	{
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timeInMinutes > %i AND station.name = %@ AND direction = %@",
								  [self currentTimeInMinutes],[station name],direction];
		NSLog(@"predicate format: %@",[predicate predicateFormat]);
		
		/*
		 Fetch existing events.
		 Create a fetch request; find the Event entity and assign it to the request; add a sort descriptor; then execute the fetch.
		 */
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:[self managedObjectContext]];
		[request setEntity:entity];
		
		// Order the events by creation date, most recent first.
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeInMinutes" ascending:YES];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[request setSortDescriptors:sortDescriptors];
		NSArray *prefetchKeys = [[NSArray alloc] initWithObjects:@"station",@"line",nil];
		[request setRelationshipKeyPathsForPrefetching:prefetchKeys];
		[request setFetchLimit:5];
		[request setPredicate:predicate];
		[sortDescriptor release];
		[sortDescriptors release];
		[prefetchKeys release];
		
		// Execute the fetch -- create a mutable copy of the result.
		NSError *error = nil;
		NSMutableArray *stopsArray = [[[self managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];
		if (stopsArray == nil) {
			// Handle the error.
		}
	
		[request release];
		
		
		[_closestStationsStopsArray addObject:stopsArray];
		
		//Go through and get the run times for each stop that we list
		NSMutableArray *runsArray = [[NSMutableArray alloc] initWithCapacity:[stopsArray count]];
		
		//keep an index set so if we need to delete a stop due to an endline run we can
		NSMutableIndexSet *deleteIndexes = [NSMutableIndexSet indexSet];
		
		for(NSUInteger stopIdx = 0; stopIdx < [stopsArray count]; ++stopIdx)
		{	
			Stop *stop = [stopsArray objectAtIndex:stopIdx];
			
			NSString *lineName = [[stop line] name];
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timeInMinutes >= %i AND direction == %@ AND run == %i AND line.name == %@",
									  [[stop timeInMinutes] intValue],direction,[[stop run] intValue],lineName];
			
			NSFetchRequest *request = [[NSFetchRequest alloc] init];
			NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:[self managedObjectContext]];
			[request setEntity:entity];
			
			// Order the events by creation date, most recent first.
			NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeInMinutes" ascending:YES];
			NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
			[request setSortDescriptors:sortDescriptors];
			NSArray *prefetchKeys = [[NSArray alloc] initWithObjects:@"station",@"line",nil];
			[request setRelationshipKeyPathsForPrefetching:prefetchKeys];
			[request setPredicate:predicate];
			[sortDescriptor release];
			[sortDescriptors release];
			[prefetchKeys release];
			
			// Execute the fetch -- create a mutable copy of the result.
			NSError *error = nil;
			NSMutableArray *mutableFetchResults = [[[self managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];
			if (mutableFetchResults == nil) {
				// Handle the error.
			}
			
			//if there is only one stop in the array then it is the end of the line so don't add it and 
			if([mutableFetchResults count] == 1)
			{
				[deleteIndexes addIndex:stopIdx];
			}
			else
			{
				// Set self's runs array to the mutable array.
				[runsArray addObject:mutableFetchResults];
			}
			
			//cleanup
			[mutableFetchResults release];
			[request release];
		}
		
		//remove any stops that were end of lines
		[stopsArray removeObjectsAtIndexes:deleteIndexes];
		
		//Add the runs array
		[_closestStationsRunsArray addObject:runsArray];
		[runsArray release];
		[stopsArray release];
	}
		
	[_closeStationsTableView reloadData];
}

#pragma mark -
#pragma mark Location manager

/**
 Return a location manager -- create one if necessary.
 */
- (CLLocationManager *)locationManager {
	
    if (_locationManager != nil) {
		return _locationManager;
	}
	
	_locationManager = [[CLLocationManager alloc] init];
	[_locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
	[_locationManager setDistanceFilter:100.0];  //The user must move 100 meters before we update
	[_locationManager setDelegate:self];
	
	return _locationManager;
}


/**
 Conditionally enable the Add button:
 If the location manager is generating updates, then enable the button;
 If the location manager is failing, then disable the button.
 */
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
	
	//we have a location so resort the closest array and display the first three
	for(Station *station in [self stationsArray])
	{
		NSLog(@"newLocation long: %f lat: %f",[newLocation coordinate].longitude,[newLocation coordinate].latitude);
		NSLog(@"station lcoation long: %f lat: %f",[[station location] coordinate].longitude,
													[[station location] coordinate].latitude);
		[station setCurrentDistance:[newLocation getDistanceFrom:[station location]]];
	}
	
	[[self stationsArray] sortUsingSelector:@selector(compareAscending:)];
	
	[self setClosestStationsArray:[[self stationsArray] subarrayWithRange:NSMakeRange(0, 4)]];
	[self retrieveStopsForClosestStationsInDirection:[[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentDirection"]];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    
}

#pragma mark -
#pragma mark Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger stationCount = [[self closestStationsArray] count];
	if(stationCount == 0)
	{
		return 0;
	}
	
	return stationCount + 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == [[self closestStationsArray] count])
	{
		return 1;
	}
	else
	{
		NSInteger stopsCount = [[[self closestStationsStopsArray] objectAtIndex:section] count];
		if(stopsCount == 0)
		{
			stopsCount = 1;
		}
		return stopsCount;
	}
	
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(indexPath.section == [[self closestStationsArray] count])
	{
		//show the show more stations row
		static NSString *CellIdentifier = @"ShowMoreStationsCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		
		cell.textLabel.text = @"All Stations";
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		
		return cell;
		
	}
	else if([[[self closestStationsStopsArray] objectAtIndex:indexPath.section] count] == 0)
	{
		//There are no train in the direction from this station so say so
		static NSString *CellIdentifier = @"No Trains";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		
		NSString *direction = nil;
		if([[[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentDirection"] isEqualToString:@"N"])
		{
			direction = @"Northbound";
		}
		else
		{
			direction = @"Southbound";
		}

		cell.textLabel.text = [NSString stringWithFormat:@"No %@ Transit",direction];
		[cell setAccessoryType:UITableViewCellAccessoryNone];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		
		return cell;
	}
	else
	{
		static NSString *CellIdentifier = @"Cell";
		
		StationStopTableViewCell *cell = ( StationStopTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[StationStopTableViewCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
		}
		
		// Get the stop corresponding to the current index path and configure the table view cell.
		Stop *stop = [[[self closestStationsStopsArray] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		[cell setStop:stop];
		
		Stop *endStop = [[[[self closestStationsRunsArray] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] lastObject];
		[cell setEndOfLineStop:endStop];
		
		return cell;
	}
	
	return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if(section == [[self closestStationsArray] count])
	{
		//no header for the show more stations row
		return nil;
	}
	
	UILabel *header = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 40)] autorelease];
	[header setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
	[header setTextAlignment:UITextAlignmentCenter];
	[header setText:[[[self closestStationsArray] objectAtIndex:section] name]];
	[header setBackgroundColor:[UIColor clearColor]];
	return header;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(indexPath.section == [[self closestStationsArray] count])
	{
		StationListViewController *listController = [[StationListViewController alloc] initWithNibName:@"StationListViewController" bundle:nil];
		[listController setManagedObjectContext:[self managedObjectContext]];
		[[self navigationController] pushViewController:listController animated:YES];
		[listController release];
	}
	else if([[[self closestStationsStopsArray] objectAtIndex:indexPath.section] count] == 0)
	{
		//Do nothing on a no train display
		return;
	}
	else
	{
		NSArray *runArray = [[[self closestStationsRunsArray] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		RunViewController *runController = [[RunViewController alloc] initWithRunArray:runArray];
		[runController setTitle:[[[self closestStationsArray] objectAtIndex:indexPath.section] name]];
		[[self navigationController] pushViewController:runController animated:YES];
		[runController release];
	}
	
}


@end

