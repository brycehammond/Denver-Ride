//
//  RunViewController.m
//  RTD
//
//  Created by bryce.hammond on 8/12/09.
//  Copyright 2009 Wall Street On Demand, Inc.. All rights reserved.
//

#import "RunViewController.h"
#import "Stop.h"
#import "StationViewController.h"
#import "RTDAppDelegate.h"

@implementation RunViewController

@synthesize runArray = _runArray, stop = _stop, managedObjectContext = _managedObjectContext;

-(id)initWithStop:(Stop *)stop
{
	if(self = [self initWithNibName:@"RunViewController" bundle:nil])
	{
		[self setStop:stop];
	}
	return self;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//get the run array from the stop
	Stop *stop = [self stop];
	NSString *lineName = [[stop line] name];
	NSString *direction = ([[stop direction] isEqualToString:@"N"]) ? @"Northbound" : @"Southbound";
						   
	[_topLine setText:[NSString stringWithFormat:@"Arrival times of %@ %@ Line", direction, lineName]];
	[_middleLine setText:[NSString stringWithFormat:@"leaving from %@",[[stop station] name]]];
	[_bottomLine setText:[NSString stringWithFormat:@"at %@",[stop formattedTime]]];
	
	RTDAppDelegate *appDelegate = (RTDAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timeInMinutes > %i AND direction == %@ AND run == %i AND line.name == %@ AND dayType = %@",
							  [[stop timeInMinutes] intValue],[stop direction],[[stop run] intValue],lineName,[appDelegate currentDayType]];
	
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
	
	[self setRunArray:mutableFetchResults];
	[mutableFetchResults release];
	
	[self setTitle:@"Arrivals"];
	
}

-(void)dealloc
{
	[_runArray release];
	[_stop release];
	[_managedObjectContext release];
	[_runTableView release];
	
	[_topLine release];
	[_middleLine release];
	[_bottomLine release];
	[super dealloc];
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Get the event corresponding to the current index path and configure the table view cell.
	Stop *stop = (Stop *)[[self runArray] objectAtIndex:indexPath.row];
	
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
	Stop *stop = (Stop *)[[self runArray] objectAtIndex:indexPath.row];
	StationViewController *stationController = [[StationViewController alloc] initWithStation:[stop station] withCurrentTimeInMinutes:[[stop timeInMinutes] intValue]];
	[stationController setManagedObjectContext:[self managedObjectContext]];
	[[self navigationController] pushViewController:stationController animated:YES];
	[stationController release];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}



@end