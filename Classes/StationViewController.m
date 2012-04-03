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
#import "FlurryAnalytics.h"

@interface StationViewController (Private)
-(void)retrieveStopsInDirection:(NSString *)direction;
@end


@implementation StationViewController

@synthesize managedObjectContext = _managedObjectContext, station = _station, 
			stopsArray = _stopsArray, currentTimeInMinutes = _currentTimeInMinutes,
			dayType = _dayType;



- (void)loadView
{
	[super loadView];
	[[self view] setBackgroundColor:[UIColor colorFromHex:kBackgroundColor withAlpha:1.0]];
	_stopsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[self view] frame].size.width,
															  kShortContainerHeight)
												   style:UITableViewStyleGrouped];
	[_stopsTableView setDelegate:self];
	[_stopsTableView setDataSource:self];
	
	[[self view] addSubview:_stopsTableView];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:[[self station] name]];
	[_stopsTableView setBackgroundColor:[UIColor clearColor]];
	
	NSString *direction = [[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentDirection"];
	if([direction isEqualToString:@"N"])
	{
		[_sectionSelectorView setToNorthbound];
	}
	else
	{
		[_sectionSelectorView setToSouthbound];
	}
	
	[FlurryAnalytics logEvent:@"Station View" withParameters:[NSDictionary dictionaryWithObject:[_station name] forKey:@"Station"]];
	[self retrieveStopsInDirection:direction];
}

-(id)initWithStation:(Station *)station withCurrentTimeInMinutes:(NSInteger)currentTimeInMinutes
{
	RTDAppDelegate *appDelegate = (RTDAppDelegate *)[[UIApplication sharedApplication] delegate];
	return [self initWithStation:station withCurrentTimeInMinutes:currentTimeInMinutes andTimeDirection:FORWARD andDayType:[appDelegate currentDayType]];
}

-(id)initWithStation:(Station *)station withCurrentTimeInMinutes:(NSInteger)currentTimeInMinutes 
	andTimeDirection:(TimeDirection)timeDirection andDayType:(NSString *)dayType
{
	if((self = [self initWithNibName:nil bundle:nil]))
	{
		[self setStation:station];
		[self setCurrentTimeInMinutes:currentTimeInMinutes];
		_timeDirection = timeDirection;
		[self setDayType:dayType];
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
	
	if(_timeDirection == FORWARD)
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
	BOOL ascending = (_timeDirection == FORWARD);
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"departureTimeInMinutes" ascending:ascending];
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
	[_mapViewController release];
	[_bcycleViewController release];
	[_station release];
    [super dealloc];
}

#pragma mark MainSectionSelectorViewDelegate methods

- (void)nortboundWasSelected
{
	NSString *direction = @"N";
	[[NSUserDefaults standardUserDefaults] setObject:direction forKey:@"CurrentDirection"];
	[FlurryAnalytics logEvent:@"Switch Direction" withParameters:[NSDictionary dictionaryWithObject:direction forKey:@"Direction"]];
	
	[[_mapViewController view] removeFromSuperview];
	[[_bcycleViewController view] removeFromSuperview];
	
    [_stopsTableView setFrameHeight:kShortContainerHeight];
	[self setTitle:[[self station] name]];
	[self retrieveStopsInDirection:direction];
	[_stopsTableView reloadData];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
}

- (void)southboundWasSelected
{
	NSString *direction = @"S";
	[[NSUserDefaults standardUserDefaults] setObject:direction forKey:@"CurrentDirection"];
	[FlurryAnalytics logEvent:@"Switch Direction" withParameters:[NSDictionary dictionaryWithObject:direction forKey:@"Direction"]];
	
	[[_mapViewController view] removeFromSuperview];
	[[_bcycleViewController view] removeFromSuperview];
	
    [_stopsTableView setFrameHeight:kShortContainerHeight];
	[self setTitle:[[self station] name]];
	[self retrieveStopsInDirection:direction];
	[_stopsTableView reloadData];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
}

- (void)mapWasSelected
{
	
	if(nil == _mapViewController)
	{
		_mapViewController = [[RTDMapViewController alloc] initWithNibName:nil bundle:nil];
	}
	
	[_stopsTableView setFrameHeight:kTallContainerHeight];
	[[_bcycleViewController view] removeFromSuperview];
    [_mapViewController viewWillAppear:NO];
	[_stopsTableView addSubview:[_mapViewController view]];
    [_mapViewController viewDidAppear:NO];
	[self setTitle:@"Route Map"]; 
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}

- (void)bcycleWasSelected
{
	if(nil == _bcycleViewController)
	{
		_bcycleViewController = [[BCycleViewController alloc] initWithNibName:nil bundle:nil];
	}
	else 
	{
		[_bcycleViewController updateAnnotations]; 
	}
	
    [_stopsTableView setFrameHeight:kTallContainerHeight];
	[[_mapViewController view] removeFromSuperview];
    [_bcycleViewController viewWillAppear:NO];
	[_stopsTableView addSubview:[_bcycleViewController view]];
    [_bcycleViewController viewDidAppear:NO];
	[self setTitle:@"BCycle"];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}

@end
