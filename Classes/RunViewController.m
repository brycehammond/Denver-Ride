//
//  RunViewController.m
//  RTD
//
//  Created by bryce.hammond on 8/12/09.
//  Copyright 2009 Wall Street On Demand, Inc.. All rights reserved.
//

#import "RunViewController.h"
#import "Stop.h"
#import "RTDAppDelegate.h"
#import "StationViewController.h"

@implementation RunViewController

@synthesize runArray = _runArray;

-(id)initWithRunArray:(NSArray *)runArray
{
	if(self = [self initWithNibName:@"RunViewController" bundle:nil])
	{
		[self setRunArray:runArray];
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
	[_runTableView release];
	[_runArray release];
    [super dealloc];
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
	
	
	NSString *amOrPm = @"A";
	int hours = [[stop timeInMinutes] intValue] / 60;
	if(hours > 12)
	{
		hours -= 12;
		amOrPm = @"P";
	}	
	int minutes = [[stop timeInMinutes] intValue] % 60;
	NSString *formatedMinutes =(minutes < 10) ? [NSString stringWithFormat:@"0%i",minutes] : [NSString stringWithFormat:@"%i",minutes];
	
	CGRect currentFrame = cell.detailTextLabel.frame;
	cell.detailTextLabel.frame = currentFrame;
	cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
	cell.textLabel.text = [NSString stringWithFormat:@"%i:%@%@",hours,formatedMinutes,amOrPm];
	
    cell.detailTextLabel.text =  [[stop station] name];
    
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Stop *stop = (Stop *)[[self runArray] objectAtIndex:indexPath.row];
	StationViewController *stationController = [[StationViewController alloc] initWithStation:[stop station] withCurrentTimeInMinutes:[[stop timeInMinutes] intValue]];
	[stationController setManagedObjectContext:[(RTDAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]];
	[stationController setTitle:[[stop station] name]];
	[[self navigationController] pushViewController:stationController animated:YES];
	[stationController release];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}



@end
