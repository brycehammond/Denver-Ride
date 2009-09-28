//
//  ManualSelectViewController.m
//  RTD
//
//  Created by bryce.hammond on 9/12/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import "ManualSelectViewController.h"
#import "NSDate+TimeInMinutes.h"
#import "RTDAppDelegate.h"
#import "StationStopTableViewCell.h"
#import "RunViewController.h"

@interface ManualSelectViewController (Private)
-(NSString *)formattedTimeInMinutes;

@end



@implementation ManualSelectViewController

@synthesize navigationController = _navigationController,
			managedObjectContext = _managedObjectContext,
			timeInMinutes = _timeInMinutes,
			currentStops = _currentStops,
			currentDayType = _currentDayType;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[_manualTableView setBackgroundColor:[UIColor clearColor]];
	[self setTimeInMinutes:[[NSDate date] minutesIntoCurrentDay]];
	if(! [[NSUserDefaults standardUserDefaults] objectForKey:@"ManualStation"] )
	{
		[[NSUserDefaults standardUserDefaults] setObject:@"Union Station" forKey:@"ManualStation"];
	}
	
	RTDAppDelegate *appDelegate = (RTDAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *dayType = [[NSDate date] dayType];
	[self setCurrentDayType:dayType];
	[appDelegate setCurrentDayType:dayType];
	[self retrieveStopsDirection:[[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentDirection"]];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	RTDAppDelegate *appDelegate = (RTDAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate setCurrentDayType:[self currentDayType]];
}

-(void)changeDirectionTo:(NSString *)direction
{
	[[NSUserDefaults standardUserDefaults] setObject:direction forKey:@"CurrentDirection"];
	[self retrieveStopsDirection:direction];
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


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 0)
	{
		return 1;
	}
	else if(section == 1)
	{
		return 1;
	}
	else if(section == 2)
	{
		return 1;
	}
	else if(section == 3)
	{
		NSInteger stopCount = [[self currentStops] count];
		if(stopCount == 0)
		{
			return 1;
		}
		return stopCount;
	}
	
	return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2)
	{
		static NSString *CellIdentifier = @"Cell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		}
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		[cell setAccessoryType:UITableViewCellAccessoryNone];
		
		if(indexPath.section == 0)
		{
			cell.textLabel.text = @"Time";
			cell.detailTextLabel.text = [self formattedTimeInMinutes];
			
		}
		else if(indexPath.section == 1)
		{
			cell.textLabel.text = @"Station";
			cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"ManualStation"];
		}
		else if(indexPath.section == 2)
		{
			cell.textLabel.text = @"Schedule Type";
			cell.detailTextLabel.text = [[NSDate fullDayTypesByCode] objectForKey:[self currentDayType]];
		}
		
		return cell;
	}
	else if(indexPath.section == 3)
	{
		if([[self currentStops] count] == 0)
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
		else {
			static NSString *CellIdentifier = @"StopCell";
			
			StationStopTableViewCell *cell = ( StationStopTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[StationStopTableViewCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
			}
			
			// Get the stop corresponding to the current index path and configure the table view cell.
			Stop *stop = [[self currentStops] objectAtIndex:indexPath.row];
			
			[cell setEndOfLineStation:[stop terminalStation] withStartStop:stop];
			
			
			return cell;
		}

		
		
	}
	
	return nil;
	
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(indexPath.section == 0)
	{
		if(! _timeChangeController)
		{
			_timeChangeController = [[TimeChangeViewController alloc] initWithNibName:@"TimeChangeViewController" bundle:nil];
			[_timeChangeController setDelegate:self];
		}
		
		CGRect frame = [[_timeChangeController view] frame];
		frame.origin.y = self.view.frame.size.height;
		_timeChangeController.view.frame = frame;
		
		[[[self view] window] addSubview:[_timeChangeController view]];
		[_timeChangeController setTimeInMinutes:[self timeInMinutes]];
		[_timeChangeController animateIn];
	}
	else if(indexPath.section == 1)
	{
		if( ! _stationChangeController)
		{
			_stationChangeController = [[StationChangeViewController alloc] initWithNibName:@"StationChangeViewController" bundle:nil];
			[_stationChangeController setDelegate:self];
			[_stationChangeController setManagedObjectContext:[self managedObjectContext]];
		}
		
		[[self navigationController] presentModalViewController:_stationChangeController animated:YES];
	}
	else if(indexPath.section == 2)
	{
		if( ! _dayTypeChangeController)
		{
			_dayTypeChangeController = [[DayTypeChangeViewController alloc] initWithNibName:@"DayTypeChangeViewController" bundle:nil];
			[_dayTypeChangeController setDelegate:self];
		}
		
		CGRect frame = [[_dayTypeChangeController view] frame];
		frame.origin.y = self.view.frame.size.height;
		_dayTypeChangeController.view.frame = frame;
		
		[[[self view] window] addSubview:[_dayTypeChangeController view]];
		[_dayTypeChangeController setDayType:[self currentDayType]];
		[_dayTypeChangeController animateIn];
		
	}
	else if(indexPath.section == 3)
	{
		if([[self currentStops] count] == 0)
		{
			//Do nothing on a no train display
			return;
		}
		else
		{
			RunViewController *runController = [[RunViewController alloc] initWithStop:[[self currentStops] objectAtIndex:indexPath.row]];
			[runController setManagedObjectContext:[self managedObjectContext]];
			[[self navigationController] pushViewController:runController animated:YES];
			[runController release];
		}
	}
	
	
}

-(void)retrieveStopsDirection:(NSString *)direction
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"timeInMinutes > %i AND station.name = %@ AND direction = %@ AND terminalStation.name != station.name AND dayType = %@",
							  [self timeInMinutes],
							  [[NSUserDefaults standardUserDefaults] stringForKey:@"ManualStation"],
							  direction,
							  [self currentDayType]];
	
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
	
	[self setCurrentStops:stopsArray];
	[stopsArray release];
	
	[_manualTableView reloadData];
}

-(NSString *)formattedTimeInMinutes
{
	NSString *amOrPm = @"A";
	int hours = [self timeInMinutes] / 60;
	if(hours > 24)
	{
		hours -= 24;
	}
	else if(hours > 12)
	{
		hours -= 12;
		amOrPm = @"P";
	}
	else if(hours == 12)
	{
		amOrPm = @"P";
	}
	int minutes = [self timeInMinutes] % 60;
	NSString *formattedTime = (minutes < 10) ? [NSString stringWithFormat:@"%i:0%i%@",hours,minutes,amOrPm] : [NSString stringWithFormat:@"%i:%i%@",hours,minutes,amOrPm];
	
	return formattedTime;
}

#pragma mark -
#pragma mark TimeChangeViewControllerDelegate

-(void)doneButtonClickedOnTimeChangeViewController:(TimeChangeViewController *)viewController
{
	[self setTimeInMinutes:[viewController timeInMinutes]];
	[viewController animateOut];
	[self retrieveStopsDirection:[[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentDirection"]];
}

-(void)cancelButtonClickedOnTimeChangeViewController:(TimeChangeViewController *)viewController
{
	[viewController animateOut];
}

#pragma mark -
#pragma mark DayTypeChangeViewControllerDelegate

-(void)doneButtonClickedOnDayTypeChangeViewController:(DayTypeChangeViewController *)viewController
{
	[self setCurrentDayType:[viewController dayType]];
	RTDAppDelegate *appDelegate = (RTDAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate setCurrentDayType:[self currentDayType]];
	[viewController animateOut];
	[self retrieveStopsDirection:[[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentDirection"]];
}

-(void)cancelButtonClickedOnDayTypeChangeViewController:(DayTypeChangeViewController *)viewController
{
	[viewController animateOut];
}

#pragma mark -
#pragma mark StationChangeViewControllerDelegate

-(void)stationWasSelected:(NSString *)station
{
	[[NSUserDefaults standardUserDefaults] setObject:station forKey:@"ManualStation"];
	[[self navigationController] dismissModalViewControllerAnimated:YES];
	[self retrieveStopsDirection:[[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentDirection"]];
}

-(void)viewWasCancelled
{
	[[self navigationController] dismissModalViewControllerAnimated:YES];
}



@end
