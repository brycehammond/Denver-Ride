//
//  StationViewController.m
//  RTD
//
//  Created by bryce.hammond on 8/9/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import "DRStationViewController.h"
#import "Station.h"
#import "Stop.h"
#import "Line.h"
#import "StationStopTableViewCell.h"
#import "RTDAppDelegate.h"
#import "Flurry.h"

@interface DRStationViewController ()

@property (weak, nonatomic) IBOutlet UITableView *stopsTableView;

@end


@implementation DRStationViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:[[self station] name]];
	[self.stopsTableView setBackgroundColor:[UIColor clearColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *direction = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentDirectionKey];
    [Flurry logEvent:@"Station View" withParameters:@{@"Station": self.station.name}];
	[self retrieveStopsInDirection:direction];
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
			cell = [[StationStopTableViewCell alloc] initWithReuseIdentifier:CellIdentifier];
		}
		
		// Get the event corresponding to the current index path and configure the table view cell.
		Stop *stop = [self stopsArray][indexPath.row];
		
		if(self.timeDirection == FORWARD)
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
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
		}
		
		NSString *direction = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentDirectionKey];
		
		cell.textLabel.text = [self.station noStopTextForDirection:direction withTimeDirection:self.timeDirection];
		
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
		Stop *stop = [self stopsArray][indexPath.row];
		DRRunViewController *runController = [[DRRunViewController alloc] initWithStop:stop withTimeDirection:self.timeDirection];
		[runController setManagedObjectContext:[self managedObjectContext]];
		[[self navigationController] pushViewController:runController animated:YES];
		
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

-(void)retrieveStopsInDirection:(NSString *)direction
{	
	
	NSPredicate *predicate = nil;
	
	if(self.timeDirection == FORWARD)
	{
		predicate = [NSPredicate predicateWithFormat:@"departureTimeInMinutes > %i AND station = %@ AND direction = %@ AND dayType = %@ AND terminalStation != %@",
		 [self currentTimeInMinutes],[self station], direction, [self dayType], [self station]];
	}
	else {
		predicate = [NSPredicate predicateWithFormat:@"departureTimeInMinutes < %i AND station = %@ AND direction = %@ AND dayType = %@ AND startStation != %@",
		 [self currentTimeInMinutes],[self station], direction, [self dayType], [self station]];
	}

	
	DLog(@"predicate format: %@",[predicate predicateFormat]);
	
	/*
	 Fetch existing events.
	 Create a fetch request; find the Event entity and assign it to the request; add a sort descriptor; then execute the fetch.
	 */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:[self managedObjectContext]];
	[request setEntity:entity];
	
	// Order the events by creation date, most recent first.
	BOOL ascending = (self.timeDirection == FORWARD);
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"departureTimeInMinutes" ascending:ascending];
	NSArray *sortDescriptors = @[sortDescriptor];
	[request setSortDescriptors:sortDescriptors];
	[request setFetchLimit:5];
	[request setPredicate:predicate];
	
	// Execute the fetch -- create a mutable copy of the result.
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[[self managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
	}
	
	// Set self's events array to the mutable array, then clean up.
	[self setStopsArray:mutableFetchResults];
	
	[self.stopsTableView reloadData];
}

#pragma mark DenverRideBaseViewController overrides

- (void)directionSelected:(NSString *)direction
{
	[super directionSelected:direction];
	[self setTitle:[[self station] name]];
	[self retrieveStopsInDirection:direction];
	[self.stopsTableView reloadData];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
}


@end
