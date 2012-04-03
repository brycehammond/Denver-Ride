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
@synthesize toolbar = _toolbar;

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

-(void)animateIn
{
	[_fadeView setAlpha:0.0];
	[UIView beginAnimations:@"animateIn" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	CGRect frame = [[self view] frame];
	frame.origin.y = 20;
	frame.origin.x = 0;
	[[self view] setFrame:frame];
	[UIView commitAnimations];
}

-(void)animateOut
{
	[UIView beginAnimations:@"animateOutFade" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView setAnimationDuration:0.1];
	[_fadeView setAlpha:0.0];
	[UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if([animationID isEqualToString:@"animateOutFade"])
	{
		[UIView beginAnimations:@"animateOut" context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		CGRect frame = [[self view] frame];
		frame.origin.y = [[[self view] superview] bounds].size.height;
		frame.origin.x = 0;
		[[self view] setFrame:frame];
		[UIView commitAnimations];
		
	}
	else if([animationID isEqualToString:@"animateOut"])
	{
		[[self view] removeFromSuperview];
	}
	else if([animationID isEqualToString:@"animateIn"])
	{
		[UIView beginAnimations:@"animateInFade" context:nil];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[_fadeView setAlpha:0.7];
		[UIView commitAnimations];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];

   self.toolbar.tintColor = [UIColor colorFromHex:kNavBarColor withAlpha:1];
}


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
    [self setToolbar:nil];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [_toolbar release];
    [super dealloc];
}


@end

