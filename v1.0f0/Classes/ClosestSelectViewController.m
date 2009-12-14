//
//  ClosestSelectViewController.m
//  RTD
//
//  Created by bryce.hammond on 9/12/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import "ClosestSelectViewController.h"
#import "StationViewController.h"
#import "Station.h"
#import "Stop.h"
#import "StationStopTableViewCell.h"
#import "RunViewController.h"
#import "StationListViewController.h"
#import "NSDate+TimeInMinutes.h"
#import "RTDAppDelegate.h"

@interface ClosestSelectViewController (Private)
-(void)updateDirection:(NSString *)direction;
@end


@implementation ClosestSelectViewController

@synthesize  managedObjectContext = _managedObjectContext, 
stationsArray = _stationsArray,
locationManager = _locationManager,
closestStationsArray = _closestStationsArray,
closestStationsStopsArray = _closestStationsStopsArray,
navigationController = _navigationController;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[_closeStationsTableView setBackgroundColor:[UIColor colorWithWhite:0.750 alpha:1.000]];
	_loadingView = [[LoadingView alloc] initWithFrame:[_closeStationsTableView frame]];
	
	//We haven't gotten a closest location yet so set the
	//closest location array to empty
	[self setClosestStationsArray:[NSArray array]];
	[self setClosestStationsStopsArray:[NSMutableArray array]];
	
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
	
	if(! [_loadingView superview])
	{
		[_loadingView setMessage:@"Finding Closest Stations"];
		[[self view] addSubview:_loadingView];
	}
	
	
	if([[self locationManager] locationServicesEnabled])
	{
		// Start the location manager.
		[[self locationManager] startUpdatingLocation];
	}
	else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location services unavailable" 
															message:@"You will need to turn on location services in your settings to find the closest stations."
														   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}

	
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	NSDate *currentDate = [NSDate date];
	NSString *dayType = [currentDate dayType];
	RTDAppDelegate *appDelegate = (RTDAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate setCurrentDayType:dayType];
	
	[self updateDirection:[[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentDirection"]];

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

-(void)updateDirection:(NSString *)direction
{
	[self retrieveStopsDirection:direction];
}

-(void)changeDirectionTo:(NSString *)direction
{
	if(! [_loadingView superview])
	{
		[_loadingView setMessage:@"Loading"];
		[[self view] addSubview:_loadingView];
	}
	
	[self performSelector:@selector(updateDirection:) withObject:direction afterDelay:0.1];
}



-(void)retrieveStopsDirection:(NSString *)direction
{
	RTDAppDelegate *appDelegate = (RTDAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSDate *currentDate = [NSDate date];
	NSInteger minutesIntoCurrentDay = [currentDate minutesIntoCurrentDay] - 2;
	NSString *dayType = [currentDate dayType];
	[appDelegate setCurrentDayType:dayType];
	
	[[self closestStationsStopsArray] removeAllObjects];
	for(Station *station in [self closestStationsArray])
	{
		NSPredicate *predicate = [NSPredicate predicateWithFormat:
								  @"timeInMinutes > %i AND station.name = %@ AND direction = %@ AND terminalStation.name != station.name AND dayType = %@",
								  minutesIntoCurrentDay,[station name],direction,dayType];
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
		[stopsArray release];
	}
	
	[_closeStationsTableView reloadData];
	if([_loadingView superview])
	{
		[_loadingView removeFromSuperview];
	}
	
	
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
	
	[_delayTimer invalidate];
	[_delayTimer release];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(processUpdate:)]];
	[invocation setTarget:self];
	[invocation setSelector:@selector(processUpdate:)];
	[invocation setArgument:&newLocation atIndex:2];
	_delayTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5 invocation:invocation repeats:NO] retain];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
	
	static BOOL haveShownError = NO;
	
	if(! haveShownError)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unable to find location" 
															message:@"The app is unable to find your current location.  Make sure that your location services are turned on."
														   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		
		haveShownError = YES;
	}
	
    
}

- (void)processUpdate:(CLLocation *)location
{
	//we have a location so resort the closest array and display the first three
	for(Station *station in [self stationsArray])
	{
		[station setCurrentDistance:[location getDistanceFrom:[station location]]];
	}
	
	[[self stationsArray] sortUsingSelector:@selector(compareAscending:)];
	
	if([[self stationsArray] count] >= 4)
	{
		[self setClosestStationsArray:[[self stationsArray] subarrayWithRange:NSMakeRange(0, 4)]];
	}
	else {
		[self setClosestStationsArray:[self stationsArray]];
	}

	
	[self retrieveStopsDirection:[[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentDirection"]];
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
		
		NSString *direction = ([[[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentDirection"] isEqualToString:@"N"]) ? @"Northbound" : @"Southbound";
		
		cell.textLabel.text = [NSString stringWithFormat:@"End of line for %@ transit",direction];
		
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
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
		
		[cell setEndOfLineStation:[stop terminalStation] withStartStop:stop];
		
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
	[header setAdjustsFontSizeToFitWidth:YES];
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
		RunViewController *runController = [[RunViewController alloc] initWithStop:[[[self closestStationsStopsArray] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
		[runController setManagedObjectContext:[self managedObjectContext]];
		[[self navigationController] pushViewController:runController animated:YES];
		[runController release];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
}

@end
