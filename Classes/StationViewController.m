//
//  StationViewController.m
//  RTD
//
//  Created by bryce.hammond on 8/9/09.
//  Copyright 2009 Wall Street On Demand, Inc.. All rights reserved.
//

#import "StationViewController.h"
#import "Station.h"
#import "Stop.h"
#import "Line.h"

@interface StationViewController (Private)
-(void)retrieveStopsInDirection:(NSString *)direction;
@end


@implementation StationViewController

@synthesize managedObjectContext = _managedObjectContext, station = _station, stopsArray = _stopsArray, runsArray = _runsArray;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	CGRect frame = [[self view] frame];
	_stopsTableView = [[UITableView alloc] initWithFrame:frame];
	[_stopsTableView setDelegate:self];
	[_stopsTableView setDataSource:self];
	[[self view] addSubview:_stopsTableView];
	[self retrieveStopsInDirection:@"N"];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(id)initWithStation:(Station *)station
{
	if(self = [self init])
	{
		[self setStation:station];
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
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Get the event corresponding to the current index path and configure the table view cell.
	Stop *stop = (Stop *)[[self stopsArray] objectAtIndex:indexPath.row];
	
	int hours = [[stop timeInMinutes] intValue] / 60;
	int minutes = [[stop timeInMinutes] intValue] % 60;
	NSString *formatedMinutes =(minutes < 10) ? [NSString stringWithFormat:@"0%i",minutes] : [NSString stringWithFormat:@"%i",minutes];
	
	cell.textLabel.text = [NSString stringWithFormat:@"%i:%@",hours,formatedMinutes];
	
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ Line (%@)",[[stop line] name],
								 [[[[[self runsArray] objectAtIndex:indexPath.row] lastObject] station] name]];
    
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}


/*
 // NSFetchedResultsControllerDelegate method to notify the delegate that all section and object changes have been processed. 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
 [self.tableView reloadData];
 }
 */  


-(void)retrieveStopsInDirection:(NSString *)direction
{
	//get the current hours and minutes to get stops that are in the future
	NSDate *now = [NSDate date];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
	[dateFormatter setDateFormat:@"H"];
	int hours = [[dateFormatter stringFromDate:now] intValue];
	[dateFormatter setDateFormat:@"m"];
	int minutes = [[dateFormatter stringFromDate:now] intValue];
	int timeInMinutes = hours * 60 + minutes;
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timeInMinutes > %i AND station.name == %@ AND direction = %@",
							  timeInMinutes,[[self station] name],direction];
	
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
	
	
	//Go through and get the run times for each stop that we list
	[_runsArray release];
	_runsArray = [[NSMutableArray alloc] initWithCapacity:[[self stopsArray] count]];
	for(Stop *stop in [self stopsArray])
	{		
		NSString *lineName = [[stop line] name];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timeInMinutes > %i AND direction == %@ AND run == %i AND line.name == %@",
								  timeInMinutes,direction,[[stop run] intValue],lineName];
		
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
		[[self runsArray] addObject:mutableFetchResults];
		[mutableFetchResults release];
		[request release];
	}
	
	[_stopsTableView reloadData];
}

- (void)dealloc {
	[_stopsArray release];
	[_runsArray release];
	[_managedObjectContext release];
	[_stopsTableView release];
	[_northOrSouthControl release];
	[_station release];
    [super dealloc];
}


@end
