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
		[request setFetchLimit:5];
		[request setPredicate:predicate];
		[sortDescriptor release];
		[sortDescriptors release];
		
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
		for(Stop *stop in stopsArray)
		{		
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
			[request setPredicate:predicate];
			[sortDescriptor release];
			[sortDescriptors release];
			
			// Execute the fetch -- create a mutable copy of the result.
			NSError *error = nil;
			NSMutableArray *mutableFetchResults = [[[self managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];
			if (mutableFetchResults == nil) {
				// Handle the error.
			}
			
			// Set self's events array to the mutable array, then clean up.
			[runsArray addObject:mutableFetchResults];
			[mutableFetchResults release];
			[request release];
		}
		
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
	return stationCount;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger stopsCount = [[[self closestStationsStopsArray] objectAtIndex:section] count];
	return stopsCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
	
    StationStopTableViewCell *cell = ( StationStopTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[StationStopTableViewCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Get the event corresponding to the current index path and configure the table view cell.
	Stop *stop = [[[self closestStationsStopsArray] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	[cell setStop:stop];
	
	Stop *endStop = [[[[self closestStationsRunsArray] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] lastObject];
	[cell setEndOfLineStop:endStop];
    
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UILabel *header = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 40)] autorelease];
	[header setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
	[header setText:[[[self closestStationsArray] objectAtIndex:section] name]];
	return header;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *runArray = [[[self closestStationsRunsArray] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	RunViewController *runController = [[RunViewController alloc] initWithRunArray:runArray];
	[runController setTitle:[[[self closestStationsArray] objectAtIndex:indexPath.section] name]];
	[[self navigationController] pushViewController:runController animated:YES];
	[runController release];
}


@end

