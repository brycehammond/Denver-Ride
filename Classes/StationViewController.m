//
//  StationViewController.m
//  RTD
//
//  Created by bryce.hammond on 8/9/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import "StationViewController.h"
#import "Station.h"
#import "Stop.h"
#import "Line.h"
#import "StationStopTableViewCell.h"
#import "RTDAppDelegate.h"

@interface StationViewController (Private)
-(void)retrieveStopsInDirection:(NSString *)direction;
@end


@implementation StationViewController

@synthesize managedObjectContext = _managedObjectContext, station = _station, 
			stopsArray = _stopsArray, currentTimeInMinutes = _currentTimeInMinutes;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:[[self station] name]];
	[_stopsTableView setBackgroundColor:[UIColor clearColor]];
	
	NSString *direction = [[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentDirection"];
	if([direction isEqualToString:@"N"])
	{
		[_northOrSouthControl setSelectedSegmentIndex:0];
	}
	else
	{
		[_northOrSouthControl setSelectedSegmentIndex:1];
	}
	
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain 
																  target:self action:@selector(topRightButtonClicked:)];
	[[self navigationItem] setRightBarButtonItem:rightButton];
	[rightButton release];
	
	[self retrieveStopsInDirection:direction];
}

-(id)initWithStation:(Station *)station withCurrentTimeInMinutes:(NSInteger)currentTimeInMinutes
{
	return [self initWithStation:station withCurrentTimeInMinutes:currentTimeInMinutes andTimeDirection:FORWARD];
}

-(id)initWithStation:(Station *)station withCurrentTimeInMinutes:(NSInteger)currentTimeInMinutes 
	andTimeDirection:(TimeDirection)timeDirection
{
	if(self = [self initWithNibName:@"StationViewController" bundle:nil])
	{
		[self setStation:station];
		[self setCurrentTimeInMinutes:currentTimeInMinutes];
		_timeDirection = timeDirection;
	}
	return self;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(IBAction)changeDirection:(UISegmentedControl *)sender
{
	NSLog(@"%i",[sender selectedSegmentIndex]);
	NSString *direction = [[[sender titleForSegmentAtIndex:[sender selectedSegmentIndex]]
							substringToIndex:1] uppercaseString];
	[[NSUserDefaults standardUserDefaults] setObject:direction forKey:@"CurrentDirection"];
	[self retrieveStopsInDirection:direction];
	[_stopsTableView reloadData];
}

-(void)topRightButtonClicked:(UIBarButtonItem *)sender
{
	if(! _mapController)
	{
		_mapController = [[RTDMapViewController alloc] initWithNibName:@"RTDMapViewController" bundle:nil];
		[_mapController setDelegate:self];
	}
	[self presentModalViewController:_mapController animated:YES];
}

-(void)RTDMapVieControllerDoneButtonWasClicked:(RTDMapViewController *)mapViewController
{
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Only one section.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// As many rows as there are obects in the events array.
	
	if([[self stopsArray] count] > 0)
	{
		return [[self stopsArray] count];
	}
    
	return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
	
   
    
	if([[self stopsArray] count] > 0)
	{
		StationStopTableViewCell *cell = ( StationStopTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[StationStopTableViewCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
		}
		
		// Get the event corresponding to the current index path and configure the table view cell.
		Stop *stop = [[self stopsArray] objectAtIndex:indexPath.row];
		
		if(_timeDirection == FORWARD)
		{
			[cell setEndOfLineStation:[stop terminalStation] withStartStop:stop];
		}
		else
		{
			[cell setEndOfLineStation:[stop startStation] withStartStop:stop];
		}
		
		return cell;
	}
	else
	{
		static NSString *CellIdentifier = @"NoTransitCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		}
		
		
		NSString *sentinal = (_timeDirection == BACKWARD) ? @"Start" : @"End";
		NSString *direction = ([[[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentDirection"] isEqualToString:@"N"]) ? @"Northbound" : @"Southbound";
		
		cell.textLabel.text = [NSString stringWithFormat:@"%@ of line for %@ transit",sentinal,direction];
		
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		[cell setAccessoryType:UITableViewCellAccessoryNone];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		
		return cell;
	}
	
    
	return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if([[self stopsArray] count] > 0)
	{
		Stop *stop = [[self stopsArray] objectAtIndex:indexPath.row];
		RunViewController *runController = [[RunViewController alloc] initWithStop:stop withTimeDirection:_timeDirection];
		[runController setManagedObjectContext:[self managedObjectContext]];
		[[self navigationController] pushViewController:runController animated:YES];
		[runController release];
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

-(void)retrieveStopsInDirection:(NSString *)direction
{	
	RTDAppDelegate *appDelegate = (RTDAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSPredicate *predicate = nil;
	
	if(_timeDirection == FORWARD)
	{
		predicate = [NSPredicate predicateWithFormat:@"timeInMinutes > %i AND station.name = %@ AND direction = %@ AND dayType = %@ AND terminalStation.name != station.name",
		 [self currentTimeInMinutes],[[self station] name], direction, [appDelegate currentDayType]];
	}
	else {
		predicate = [NSPredicate predicateWithFormat:@"timeInMinutes < %i AND station.name = %@ AND direction = %@ AND dayType = %@ AND startStation.name != station.name",
		 [self currentTimeInMinutes],[[self station] name], direction, [appDelegate currentDayType]];
	}

	
	NSLog(@"predicate format: %@",[predicate predicateFormat]);
	
	/*
	 Fetch existing events.
	 Create a fetch request; find the Event entity and assign it to the request; add a sort descriptor; then execute the fetch.
	 */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:[self managedObjectContext]];
	[request setEntity:entity];
	
	// Order the events by creation date, most recent first.
	BOOL ascending = (_timeDirection == FORWARD);
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeInMinutes" ascending:ascending];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[request setFetchLimit:5];
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
	[self setStopsArray:mutableFetchResults];
	[mutableFetchResults release];
	[request release];
	
	[_stopsTableView reloadData];
}

- (void)dealloc {
	[_stopsArray release];
	[_managedObjectContext release];
	[_stopsTableView release];
	[_northOrSouthControl release];
	[_mapController release];
	[_station release];
    [super dealloc];
}


@end
