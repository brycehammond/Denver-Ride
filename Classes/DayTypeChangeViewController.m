//
//  DayTypeChangeViewController.m
//  RTD
//
//  Created by bryce.hammond on 9/26/09.
//  Copyright 2009 Fluidvisiong Design. All rights reserved.
//

#import "DayTypeChangeViewController.h"
#import "NSDate+TimeInMinutes.h"

@implementation DayTypeChangeViewController


@synthesize delegate;
@synthesize dayTypeToolbar = _dayTypeToolbar;

-(IBAction)doneButtonClicked
{
	[delegate doneButtonClickedOnDayTypeChangeViewController:self];
}

-(IBAction)cancelButtonClicked
{
	[delegate cancelButtonClickedOnDayTypeChangeViewController:self];
}

-(void)setDayType:(NSString *)dayTypeCode
{
	NSUInteger row = [_dayTypes indexOfObject:[[NSDate fullDayTypesByCode] objectForKey:dayTypeCode]];
	[_picker selectRow:row inComponent:0 animated:NO];
}

-(NSString *)dayType
{
	return [[NSDate codesByfullDayTypes] objectForKey:[_dayTypes objectAtIndex:[_picker selectedRowInComponent:0]]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        _dayTypes = [[NSDate fullDayTypes] retain];
    }
    
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dayTypeToolbar.tintColor = [UIColor colorFromHex:kNavBarColor withAlpha:1];
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

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [self setDayTypeToolbar:nil];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [_dayTypeToolbar release];
    [super dealloc];
}

#pragma mark -
#pragma mark UIPickerView methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [_dayTypes count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [_dayTypes objectAtIndex:row];
}


@end

