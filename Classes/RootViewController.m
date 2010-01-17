//
//  RootViewController.m
//  RTD
//
//  Created by bryce.hammond on 8/2/09.
//  Copyright Fluidvision Design 2009. All rights reserved.
//

#import "RootViewController.h"
#import "ClosestSelectViewController.h"
#import "ManualSelectViewController.h"
#import "FlurryAPI.h"


@implementation RootViewController

@synthesize  managedObjectContext = _managedObjectContext,
			closestViewController = _closestViewController,
			manualViewController = _manualViewController;

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFinished) 
												 name:@"UpdateFinishedNotification" object:nil];

	
	NSString *direction = [[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentDirection"];
	if([direction isEqualToString:@"N"])
	{
		[_northOrSouthControl setSelectedSegmentIndex:0];
	}
	else
	{
		[_northOrSouthControl setSelectedSegmentIndex:1];
	}
	
	NSString *lastTypeUsed = [[NSUserDefaults standardUserDefaults] stringForKey:@"LastTypeUsed"];
	if(! lastTypeUsed)
	{
		if([[[UIDevice currentDevice] name] hasPrefix:@"iPod"])
		{
			lastTypeUsed = @"Manual";
		}
		else {
			lastTypeUsed = @"Closest";
		}
		
		[[NSUserDefaults standardUserDefaults] setObject:lastTypeUsed forKey:@"LastTypeUsed"];
	}
	
	
	NSString *buttonTitle = nil;
	if([lastTypeUsed isEqualToString:@"Closest"])
	{
		_activeViewController = [self closestViewController];
		[FlurryAPI logEvent:@"Launch" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"Closest",@"Mode",direction,@"Direction",nil]];
		buttonTitle = @"Manual";
		[self setTitle:@"Closest Stations"];
	}
	else {
		_activeViewController = [self manualViewController];
		[FlurryAPI logEvent:@"Launch" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"Manual",@"Mode",direction,@"Direction",nil]];
		buttonTitle = @"Closest";
		[self setTitle:@"Manual Mode"];
	}
	
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:buttonTitle
														style:UIBarButtonItemStylePlain 
																   target:self action:@selector(topRightButtonClicked:)];
	[rightButton setPossibleTitles:[NSSet setWithObjects:@"Manual",@"Closest",nil]];
	[[self navigationItem] setRightBarButtonItem:rightButton];
	[rightButton release];
	
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain 
													target:self action:@selector(topLeftButtonClicked:)];
	[[self navigationItem] setLeftBarButtonItem:leftButton];
	[leftButton release];
	
	[_containerView addSubview:[_activeViewController view]];
}

-(void)updateFinished
{
	NSString *direction = [[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentDirection"];
	
	if([[self navigationController] topViewController] != self)
	{
		[[self navigationController] popToRootViewControllerAnimated:NO];
	}
	
	[_activeViewController retrieveStopsDirection:direction];
	
}

-(void)topRightButtonClicked:(UIBarButtonItem *)sender
{
	if([[sender title] isEqualToString:@"Manual"])
	{
		//Set the manual mode
		[self setTitle:@"Manual Mode"];
		[[NSUserDefaults standardUserDefaults] setObject:@"Manual" forKey:@"LastTypeUsed"];
		[sender setTitle:@"Closest"];
		[UIView beginAnimations:nil context:nil];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:_containerView cache:YES];
		[UIView setAnimationDuration:0.75];
        [[[self closestViewController] view] removeFromSuperview];
		_activeViewController = [self manualViewController];
        [_containerView addSubview:[[self manualViewController] view]];
        [UIView commitAnimations];
		[[self manualViewController] viewWillAppear:YES];
		[[self manualViewController] viewDidAppear:YES];
		
	}
	else {
		
		//set to closest mode
		
		[sender setTitle:@"Manual"];
		[[NSUserDefaults standardUserDefaults] setObject:@"Closest" forKey:@"LastTypeUsed"];
		[self setTitle:@"Closest Stations"];
		
		[UIView beginAnimations:nil context:nil];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:_containerView cache:YES];
		[UIView setAnimationDuration:0.75];
        [[[self manualViewController] view] removeFromSuperview];
		_activeViewController = [self closestViewController];
        [_containerView addSubview:[[self closestViewController] view]];
        [UIView commitAnimations];
		[[self closestViewController] viewWillAppear:YES];
		[[self closestViewController] viewDidAppear:YES];
	}

}

-(void)topLeftButtonClicked:(UIBarButtonItem *)sender
{
	if(! _mapViewController)
	{
		_mapViewController = [[RTDMapViewController alloc] initWithNibName:@"RTDMapViewController" bundle:nil];
		[_mapViewController setDelegate:self];
	}
	[self presentModalViewController:_mapViewController animated:YES];
}

-(void)RTDMapVieControllerDoneButtonWasClicked:(RTDMapViewController *)mapViewController
{
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)changeDirection:(UISegmentedControl *)sender
{
	
	NSLog(@"%i",[sender selectedSegmentIndex]);
	NSString *direction = [[[sender titleForSegmentAtIndex:[sender selectedSegmentIndex]]
							substringToIndex:1] uppercaseString];
	[[NSUserDefaults standardUserDefaults] setObject:direction forKey:@"CurrentDirection"];
	[FlurryAPI logEvent:@"Switch Direction" withParameters:[NSDictionary dictionaryWithObject:direction forKey:@"Direction"]];
	[_activeViewController changeDirectionTo:direction];
}

- (ClosestSelectViewController *)closestViewController
{
	if(! _closestViewController)
	{
		_closestViewController = [[ClosestSelectViewController alloc] initWithNibName:@"ClosestSelectViewController"
																			   bundle:nil];
		[_closestViewController setManagedObjectContext:[self managedObjectContext]];
		[_closestViewController setNavigationController:[self navigationController]];
	}
	
	return _closestViewController;
}

- (ManualSelectViewController *)manualViewController
{
	if(! _manualViewController)
	{
		_manualViewController = [[ManualSelectViewController alloc] initWithNibName:@"ManualSelectViewController" 
																			 bundle:nil];
		[_manualViewController setManagedObjectContext:[self managedObjectContext]];
		[_manualViewController setNavigationController:[self navigationController]];
	}
	
	return _manualViewController;
}

@end

