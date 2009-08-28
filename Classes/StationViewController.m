//
//  StationViewController.m
//  RTD
//
//  Created by bryce.hammond on 8/9/09.
//  Copyright 2009 Wall Street On Demand, Inc.. All rights reserved.
//

#import "StationViewController.h"
#import "RunViewController.h"
#import "Station.h"
#import "Stop.h"
#import "Line.h"
#import "StationStopTableViewCell.h"

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
	
	NSString *direction = [[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentDirection"];
	if([direction isEqualToString:@"N"])
	{
		[_northOrSouthControl setSelectedSegmentIndex:0];
	}
	else
	{
		[_northOrSouthControl setSelectedSegmentIndex:1];
	}
	
	[self retrieveStopsInDirection:direction];
}

-(id)initWithStation:(Station *)station withCurrentTimeInMinutes:(NSInteger)currentTimeInMinutes
{
	if(self = [self initWithNibName:@"StationViewController" bundle:nil])
	{
		[self setStation:station];
		[self setCurrentTimeInMinutes:currentTimeInMinutes];
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

#pragma mark -
#pragma mark Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Only one section.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// As many rows as there are obects in the events array.
    return [[self stopsArray] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
	
    StationStopTableViewCell *cell = ( StationStopTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[StationStopTableViewCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Get the event corresponding to the current index path and configure the table view cell.
	Stop *stop = [[self stopsArray] objectAtIndex:indexPath.row];
	[cell setEndOfLineStation:[stop terminalStation] withStartStop:stop];
    
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Stop *stop = [[self stopsArray] objectAtIndex:indexPath.row];
	RunViewController *runController = [[RunViewController alloc] initWithStop:stop];
	[runController setManagedObjectContext:[self managedObjectContext]];
	[[self navigationController] pushViewController:runController animated:YES];
	[runController release];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

-(void)retrieveStopsInDirection:(NSString *)direction
{	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timeInMinutes > %i AND station.name = %@ AND direction = %@",
							  [self currentTimeInMinutes],[[self station] name],direction];
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
	[_station release];
    [super dealloc];
}


@end
