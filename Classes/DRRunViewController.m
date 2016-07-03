//
//  RunViewController.m
//  RTD
//
//  Created by bryce.hammond on 8/12/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import "DRRunViewController.h"
#import "Stop+Convenience.h"
#import "Line.h"
#import "Station+Convenience.h"
#import "DRStationViewController.h"
#import "RTDAppDelegate.h"

@implementation DRRunViewController

@synthesize runArray = _runArray, stop = _stop, managedObjectContext = _managedObjectContext;

-(id)initWithStop:(Stop *)stop
{
	return [self initWithStop:stop withTimeDirection:FORWARD];
}

-(id)initWithStop:(Stop *)stop withTimeDirection:(DRTimeDirection)timeDirection
{
	if((self = [[UIStoryboard stationStoryboard] instantiateViewControllerWithIdentifier:@"DRRunViewController"]))
	{
		[self setStop:stop];
		_timeDirection = timeDirection;
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[[self view] setBackgroundColor:[UIColor colorWithHexString:kBackgroundColor]];
	[_runTableView setBackgroundColor:[UIColor clearColor]];
    
    if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
	//get the run array from the stop
	Stop *stop = [self stop];
	NSString *lineName = [[stop line] name];
	NSString *direction = [stop fullDirection];
	
	if(_timeDirection == FORWARD)
	{
		[_topLine setText:[NSString stringWithFormat:@"Arrival times of %@ %@ Line", direction, lineName]];
		[_middleLine setText:[NSString stringWithFormat:@"leaving from %@",[[stop station] name]]];
		
	}
	else {
		[_topLine setText:[NSString stringWithFormat:@"Departure times of %@ %@ Line", direction, lineName]];
		[_middleLine setText:[NSString stringWithFormat:@"arriving at %@",[[stop station] name]]];
	}

	
	[_bottomLine setText:[NSString stringWithFormat:@"at %@",[stop formattedTime]]];
	
	NSPredicate *predicate = nil;
	
	if(_timeDirection == FORWARD)
	{
		predicate = [NSPredicate predicateWithFormat:@"arrivalTimeInMinutes > %i AND run == %@ AND line.name == %@ AND dayType = %@ AND direction == %@",
			[[stop departureTimeInMinutes] intValue],[stop run],lineName,[[self stop] dayType], stop.direction];
	}
	else {
		predicate = [NSPredicate predicateWithFormat:@"departureTimeInMinutes < %i AND run == %@ AND line.name == %@ AND dayType = %@ AND direction == %@",
					 [[stop departureTimeInMinutes] intValue],[stop run],lineName,[[self stop] dayType], stop.direction];
		
	}
    
	DLog(@"Request predicate: %@",predicate);
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:[self managedObjectContext]];
	[request setEntity:entity];
	
	// Order the events by creation date, most recent first.
	BOOL ascending = (_timeDirection == FORWARD);
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:(ascending) ? @"departureTimeInMinutes" : @"arrivalTimeInMinutes" ascending:ascending];
	NSArray *sortDescriptors = @[sortDescriptor];
	[request setSortDescriptors:sortDescriptors];
	NSArray *prefetchKeys = @[@"station",@"line"];
	[request setRelationshipKeyPathsForPrefetching:prefetchKeys];
	[request setPredicate:predicate];
	
	// Execute the fetch -- create a mutable copy of the result.
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[[self managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
	}
	
	[self setRunArray:mutableFetchResults];
	
	if(_timeDirection == FORWARD)
	{
		[self setTitle:@"Arrivals"];
	}
	else {
		[self setTitle:@"Departures"];
	}

	
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
    return [[self runArray] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
    static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
	// Get the event corresponding to the current index path and configure the table view cell.
	Stop *stop = (Stop *)[self runArray][indexPath.row];
	
	CGRect currentFrame = cell.detailTextLabel.frame;
	cell.detailTextLabel.frame = currentFrame;
	cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
	cell.textLabel.text = [stop formattedTime];
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	
    cell.detailTextLabel.text =  [[stop station] name];
	
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Stop *stop = (Stop *)[self runArray][indexPath.row];
    
    DRStationViewController *stationController = (DRStationViewController *)[[UIStoryboard stationStoryboard] instantiateViewControllerWithIdentifier:@"StationController"];
    stationController.currentTimeInMinutes = (_timeDirection == FORWARD) ? [[stop arrivalTimeInMinutes] intValue] : [[stop departureTimeInMinutes] intValue];
    stationController.timeDirection = _timeDirection;
    stationController.dayType = stop.dayType;
    stationController.station = stop.station;
    stationController.managedObjectContext = self.managedObjectContext;
	[[self navigationController] pushViewController:stationController animated:YES];
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}



@end
