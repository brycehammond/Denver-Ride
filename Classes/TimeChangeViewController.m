//
//  TimeChangeViewController.m
//  RTD
//
//  Created by bryce.hammond on 9/13/09.
//  Copyright 2009 Wall Street On Demand, Inc.. All rights reserved.
//

#import "TimeChangeViewController.h"


@implementation TimeChangeViewController

@synthesize delegate;

-(IBAction)doneButtonClicked
{
	[delegate doneButtonClickedOnTimeChangeViewController:self];
}

-(IBAction)cancelButtonClicked
{
	[delegate cancelButtonClickedOnTimeChangeViewController:self];
}

-(void)setTimeInMinutes:(NSInteger)timeInMinutes
{
	NSCalendar *gregorian = [NSCalendar currentCalendar];
	
	NSDate *currentDate = [NSDate date];
	//subtract the hours and minutes of the day to get the start of the day
	NSDateComponents *components = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:currentDate];
	[components setHour:-[components hour]];
	[components setMinute:-[components minute]];
	currentDate = [gregorian dateByAddingComponents:components toDate:currentDate options:0];
	int hours = timeInMinutes / 60;
	int minutes = timeInMinutes % 60;
	[components setHour:hours];
	[components setMinute:minutes];
	currentDate = [gregorian dateByAddingComponents:components toDate:currentDate options:0];
	
	[_timePicker setDate:currentDate];
	
}

-(NSInteger)timeInMinutes
{
	NSCalendar *gregorian = [NSCalendar currentCalendar];
	NSDateComponents *components = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[_timePicker date]];
	int hours = [components hour];
	int minutes = [components minute];
	
	return (hours * 60) + minutes;
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
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
    [super dealloc];
}


@end

