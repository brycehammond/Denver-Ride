//
//  ManualSelectViewController.m
//  RTD
//
//  Created by bryce.hammond on 9/12/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import "DRManualSelectViewController.h"
#import "NSDate+TimeInMinutes.h"
#import "RTDAppDelegate.h"
#import "StationStopTableViewCell.h"

@interface DRManualSelectViewController (Private)
- (NSString *)formattedTimeInMinutes;
- (NSArray *)nextStopsInDirection:(NSString *)direction forTimeInMinutes:(NSInteger)timeInMinutes;

@end



@implementation DRManualSelectViewController

#define kTimeDirectionSection 0
#define kStationSection 1
#define kTimeSection 2
#define kScheduleTypeSection 3
#define kStopsSection 4


@synthesize navigationController = _navigationController,
			managedObjectContext = _managedObjectContext,
			timeInMinutes = _timeInMinutes,
			currentStops = _currentStops,
			currentDayType = _currentDayType;

- (void)loadView
{
	[super loadView];
	
	[[self view] setFrame:CGRectMake(0, 0, 
									 [[UIScreen mainScreen] bounds].size.width, [DenverRideConstants shortContainerHeight])];
	[[self view] setBackgroundColor:[UIColor colorWithHexString:kBackgroundColor]];
	_manualTableView = [[UITableView alloc] initWithFrame:[[self view] bounds]
														   style:UITableViewStyleGrouped];
	[_manualTableView setDelegate:self];
	[_manualTableView setDataSource:self];
	[_manualTableView setBackgroundColor:[UIColor colorWithHexString:kBackgroundColor]];
	[[self view] addSubview:_manualTableView];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTimeInMinutes:[[NSDate date] minutesIntoCurrentDay]];
	if(! [[NSUserDefaults standardUserDefaults] objectForKey:@"ManualStation"] )
	{
		[[NSUserDefaults standardUserDefaults] setObject:@"Union Station" forKey:@"ManualStation"];
	}
	
	RTDAppDelegate *appDelegate = (RTDAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *dayType = [[NSDate date] dayType];
	[self setCurrentDayType:dayType];
	[appDelegate setCurrentDayType:dayType];
	
	_timeDirection = FORWARD;
	
	[self viewWillAppear:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	RTDAppDelegate *appDelegate = (RTDAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate setCurrentDayType:[self currentDayType]];
	[self retrieveStopsDirection:[[NSUserDefaults standardUserDefaults] stringForKey:kCurrentDirectionKey]];
}

-(void)changeDirectionTo:(NSString *)direction
{
	[[NSUserDefaults standardUserDefaults] setObject:direction forKey:kCurrentDirectionKey];
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



#pragma mark -
#pragma mark Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 5;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == kTimeDirectionSection || section == kTimeSection ||
	   section == kStationSection || section == kScheduleTypeSection)
	{
		return 1;
	}
	else if(section == kStopsSection)
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
	
	if(indexPath.section == kTimeDirectionSection)
	{
		static NSString *CellIdentifier = @"TimeDirectionCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		[cell setAccessoryType:UITableViewCellAccessoryNone];
		if(_timeDirection == FORWARD)
		{
			cell.textLabel.text = @"Departing from";
		}
		else {
			cell.textLabel.text = @"Arriving at";
		}
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.textColor = [UIColor colorWithHexString:@"385487"];

		return cell;
	}
	if(indexPath.section == kTimeSection ||
	   indexPath.section == kStationSection || indexPath.section == kScheduleTypeSection)
	{
		static NSString *CellIdentifier = @"Cell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
		}
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		[cell setAccessoryType:UITableViewCellAccessoryNone];
		
		if(indexPath.section == kTimeSection)
		{
			cell.textLabel.text = @"Time";
			cell.detailTextLabel.text = [self formattedTimeInMinutes];
			
		}
		else if(indexPath.section == kStationSection)
		{
			cell.textLabel.text = @"Station";
			cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"ManualStation"];
		}
		else if(indexPath.section == kScheduleTypeSection)
		{
			cell.textLabel.text = @"Schedule Type";
			cell.detailTextLabel.text = [NSDate fullDayTypesByCode][[self currentDayType]];
		}
		
		return cell;
	}
	else if(indexPath.section == kStopsSection)
	{
		if([[self currentStops] count] == 0)
		{
			//There are no train in the direction from this station so say so
			static NSString *CellIdentifier = @"No Trains";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			}
			
			NSString *sentinal = (_timeDirection == BACKWARD) ? @"Start" : @"End";
			NSString *direction =  [RTDAppDelegate fullDirectionForDirection:[[NSUserDefaults standardUserDefaults] stringForKey:kCurrentDirectionKey]];
			
			cell.textLabel.text = [NSString stringWithFormat:@"%@ of line for %@bound transit",sentinal,direction];
			cell.textLabel.adjustsFontSizeToFitWidth = YES;
			[cell setAccessoryType:UITableViewCellAccessoryNone];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			
			return cell;
		}
		else {
			static NSString *CellIdentifier = @"StopCell";
			
			StationStopTableViewCell *cell = ( StationStopTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[StationStopTableViewCell alloc] initWithReuseIdentifier:CellIdentifier];
			}
			
			// Get the stop corresponding to the current index path and configure the table view cell.
			Stop *stop = [self currentStops][indexPath.row];
			
			if(_timeDirection == FORWARD)
			{
				[cell setEndOfLineStation:[stop terminalStation] withStartStop:stop];
			}
			else {
				[cell setEndOfLineStation:[stop startStation] withStartStop:stop];
			}

			
			
			return cell;
		}

		
		
	}
	
	return nil;
	
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(indexPath.section == kTimeDirectionSection)
	{
		if(_timeDirection == FORWARD)
		{
			_timeDirection = BACKWARD;
		}
		else {
			_timeDirection = FORWARD;
		}

		[self retrieveStopsDirection:[[NSUserDefaults standardUserDefaults] stringForKey:kCurrentDirectionKey]];
		[tableView reloadData];
	}
	else if(indexPath.section == kTimeSection)
	{
		if(! _timeChangeController)
		{
			_timeChangeController = [[DRTimeChangeViewController alloc] initWithNibName:@"TimeChangeViewController" bundle:nil];
			[_timeChangeController setDelegate:self];
		}
		
		CGRect frame = [[_timeChangeController view] frame];
		frame.origin.y = self.view.frame.size.height;
		_timeChangeController.view.frame = frame;
		
		[[[self view] window] addSubview:[_timeChangeController view]];
		[_timeChangeController setTimeInMinutes:[self timeInMinutes]];
		[_timeChangeController animateIn];
	}
	else if(indexPath.section == kStationSection)
	{
		if( ! _stationChangeController)
		{
			_stationChangeController = [[DRStationChangeViewController alloc] initWithNibName:@"StationChangeViewController" bundle:nil];
			[_stationChangeController setDelegate:self];
			[_stationChangeController setManagedObjectContext:[self managedObjectContext]];
		}
		
		[[self navigationController] presentModalViewController:_stationChangeController animated:YES];
	}
	else if(indexPath.section == kScheduleTypeSection)
	{
		if( ! _dayTypeChangeController)
		{
			_dayTypeChangeController = [[DRDayTypeChangeViewController alloc] initWithNibName:@"DayTypeChangeViewController" bundle:nil];
			[_dayTypeChangeController setDelegate:self];
		}
		
		CGRect frame = [[_dayTypeChangeController view] frame];
		frame.origin.y = self.view.frame.size.height;
		_dayTypeChangeController.view.frame = frame;
		
		[[[self view] window] addSubview:[_dayTypeChangeController view]];
		[_dayTypeChangeController setDayType:[self currentDayType]];
		[_dayTypeChangeController animateIn];
		
	}
	else if(indexPath.section == kStopsSection)
	{
		if([[self currentStops] count] == 0)
		{
			//Do nothing on a no train display
			return;
		}
		else
		{
			DRRunViewController *runController = [[DRRunViewController alloc] 
												initWithStop:[self currentStops][indexPath.row]
												withTimeDirection:_timeDirection];
			[runController setManagedObjectContext:[self managedObjectContext]];
			[[self navigationController] pushViewController:runController animated:YES];
			[tableView deselectRowAtIndexPath:indexPath animated:NO];
		}
	}
	
	
}

-(void)retrieveStopsDirection:(NSString *)direction
{	
    NSInteger timeInMinutes = [self timeInMinutes];
    //If we are between midnight and 4 a.m. then search past midnight
    //since RTD times can go beyond midnight
    if(timeInMinutes < 60*4)
    {
        timeInMinutes += 60*24;
    }
    
    NSMutableArray *allStops = [[NSMutableArray alloc] initWithCapacity:5];
    
	NSArray *stopsArray = [self nextStopsInDirection:direction forTimeInMinutes:timeInMinutes];
    
    if(nil != stopsArray)
    {
        [allStops addObjectsFromArray:stopsArray];
        
    }
    
    if([allStops count] < 5 && timeInMinutes >= 60 * 24)
    {
        //We don't have many stops and we are passed midnight so go to the
        //morning of the next day
        timeInMinutes -= 60*24;
        stopsArray = [self nextStopsInDirection:direction forTimeInMinutes:timeInMinutes];
        if(nil != stopsArray)
        {
            [allStops addObjectsFromArray:stopsArray];
            
        }
        
        if([allStops count] > 5)
        {
            [allStops removeObjectsInRange:NSMakeRange(5, [allStops count] - 5)];
        }
    }
	
	[self setCurrentStops:allStops];
	
	[_manualTableView reloadData];
}

-(NSString *)formattedTimeInMinutes
{
	NSString *amOrPm = @"A";
	int hours = [self timeInMinutes] / 60;
	if(hours >= 24)
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
	
	if(hours == 0)
	{
		hours = 12;
	}
	
	int minutes = [self timeInMinutes] % 60;
	NSString *formattedTime = (minutes < 10) ? [NSString stringWithFormat:@"%i:0%i%@",hours,minutes,amOrPm] : [NSString stringWithFormat:@"%i:%i%@",hours,minutes,amOrPm];
	
	return formattedTime;
}

- (NSArray *)nextStopsInDirection:(NSString *)direction forTimeInMinutes:(NSInteger)timeInMinutes
{
    NSPredicate *predicate = nil;
    if(_timeDirection == FORWARD)
	{
		predicate = [NSPredicate predicateWithFormat:
					 @"departureTimeInMinutes >= %i AND station.name = %@ AND direction = %@ AND terminalStation.name != station.name AND dayType = %@",
					 timeInMinutes,
					 [[NSUserDefaults standardUserDefaults] stringForKey:@"ManualStation"],
					 direction,
					 [self currentDayType]];
        
	}
	else {
		predicate = [NSPredicate predicateWithFormat:
					 @"departureTimeInMinutes <= %i AND station.name = %@ AND direction = %@ AND startStation.name != station.name AND dayType = %@",
					 timeInMinutes,
					 [[NSUserDefaults standardUserDefaults] stringForKey:@"ManualStation"],
					 direction,
					 [self currentDayType]];
	}
    
    
	DLog(@"predicate: %@",predicate);
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
	NSArray *sortDescriptors = @[sortDescriptor];
	[request setSortDescriptors:sortDescriptors];
	NSArray *prefetchKeys = @[@"station",@"line"];
	[request setRelationshipKeyPathsForPrefetching:prefetchKeys];
	[request setFetchLimit:5];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *stopsArray = [[self managedObjectContext] executeFetchRequest:request error:&error];
	if (stopsArray == nil) {
		// Handle the error.
	}
	
    
    return  stopsArray;
}

#pragma mark -
#pragma mark TimeChangeViewControllerDelegate

-(void)doneButtonClickedOnTimeChangeViewController:(DRTimeChangeViewController *)viewController
{
	[self setTimeInMinutes:[viewController timeInMinutes]];
	[viewController animateOut];
	[self retrieveStopsDirection:[[NSUserDefaults standardUserDefaults] stringForKey:kCurrentDirectionKey]];
}

-(void)cancelButtonClickedOnTimeChangeViewController:(DRTimeChangeViewController *)viewController
{
	[viewController animateOut];
}

#pragma mark -
#pragma mark DayTypeChangeViewControllerDelegate

-(void)doneButtonClickedOnDayTypeChangeViewController:(DRDayTypeChangeViewController *)viewController
{
	[self setCurrentDayType:[viewController dayType]];
	RTDAppDelegate *appDelegate = (RTDAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate setCurrentDayType:[self currentDayType]];
	[viewController animateOut];
	[self retrieveStopsDirection:[[NSUserDefaults standardUserDefaults] stringForKey:kCurrentDirectionKey]];
}

-(void)cancelButtonClickedOnDayTypeChangeViewController:(DRDayTypeChangeViewController *)viewController
{
	[viewController animateOut];
}

#pragma mark -
#pragma mark StationChangeViewControllerDelegate

-(void)stationWasSelected:(NSString *)station
{
	[[NSUserDefaults standardUserDefaults] setObject:station forKey:@"ManualStation"];
	[[self navigationController] dismissModalViewControllerAnimated:YES];
	[self retrieveStopsDirection:[[NSUserDefaults standardUserDefaults] stringForKey:kCurrentDirectionKey]];
}

-(void)viewWasCancelled
{
	[[self navigationController] dismissModalViewControllerAnimated:YES];
}



@end
