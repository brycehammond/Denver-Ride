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
#import "Flurry.h"


@implementation RootViewController

@synthesize  managedObjectContext = _managedObjectContext,
			closestViewController = _closestViewController,
			manualViewController = _manualViewController;

- (void)loadView
{
	[super loadView];
	_containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[self view] frame].size.width,
															  [DenverRideConstants shortContainerHeight])];
    [_containerView setClipsToBounds:YES];

	[_containerView setBackgroundColor:[UIColor colorFromHex:kBackgroundColor withAlpha:1.0]];
	[[self view] addSubview:_containerView];
}

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	[[[self navigationController] navigationBar] setTintColor:
	 [UIColor colorFromHex:kNavBarColor withAlpha:1]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFinished) 
												 name:@"UpdateFinishedNotification" object:nil];

	
	NSString *direction = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentDirectionKey];
	if([direction isEqualToString:@"N"])
	{
		[_sectionSelectorView setToNorthbound];
	}
	else
	{
		[_sectionSelectorView setToSouthbound];
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
		[Flurry logEvent:@"Launch" withParameters:@{@"Mode": @"Closest",@"Direction": direction}];
		buttonTitle = @"Manual";
		[self setTitle:@"Closest Stations"];
	}
	else {
		_activeViewController = [self manualViewController];
		[Flurry logEvent:@"Launch" withParameters:@{@"Mode": @"Manual",@"Direction": direction}];
		buttonTitle = @"Closest";
		[self setTitle:@"Manual Mode"];
	}
	
	_typeSwitchButton = [[UIBarButtonItem alloc] initWithTitle:buttonTitle
														style:UIBarButtonItemStylePlain 
																   target:self action:@selector(topRightButtonClicked:)];
	[_typeSwitchButton setPossibleTitles:[NSSet setWithObjects:@"Manual",@"Closest",nil]];
	[[self navigationItem] setRightBarButtonItem:_typeSwitchButton];
	
	[_containerView addSubview:[_activeViewController view]];
}

-(void)updateFinished
{
	NSString *direction = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentDirectionKey];
	
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
		NSString *direction = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentDirectionKey];
		[Flurry logEvent:@"Switch Mode" withParameters:
			@{@"Mode": @"Manual",@"Direction": direction}];
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
		
		NSString *direction = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentDirectionKey];
		[Flurry logEvent:@"Switch Mode" withParameters:
			@{@"Mode": @"Closest",@"Direction": direction}];
		
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

- (ClosestSelectViewController *)closestViewController
{
	if(! _closestViewController)
	{
		_closestViewController = [[ClosestSelectViewController alloc] initWithNibName:nil
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
		_manualViewController = [[ManualSelectViewController alloc] initWithNibName:nil 
																			 bundle:nil];
		[_manualViewController setManagedObjectContext:[self managedObjectContext]];
		[_manualViewController setNavigationController:[self navigationController]];
	}
	
	return _manualViewController;
}

#pragma mark MainSectionSelectorViewDelegate methods

- (void)nortboundWasSelected
{
	NSString *direction = @"N";
	[[NSUserDefaults standardUserDefaults] setObject:direction forKey:kCurrentDirectionKey];
	[Flurry logEvent:@"Switch Direction" withParameters:@{@"Direction": direction}];
	[[_mapViewController view] removeFromSuperview];
	[[_bcycleViewController view] removeFromSuperview];
	
	if(_activeViewController == _manualViewController)
	{
		[self setTitle:@"Manual Mode"];
	}
	else 
	{
		[self setTitle:@"Closest Stations"];
	}

    [_containerView setFrameHeight:[DenverRideConstants shortContainerHeight]];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
	[[self navigationItem] setRightBarButtonItem:_typeSwitchButton]; 
	[_activeViewController changeDirectionTo:direction];
}

- (void)southboundWasSelected
{
	NSString *direction = @"S";
	[[NSUserDefaults standardUserDefaults] setObject:direction forKey:kCurrentDirectionKey];
	[Flurry logEvent:@"Switch Direction" withParameters:@{@"Direction": direction}];
	[[_mapViewController view] removeFromSuperview];
	[[_bcycleViewController view] removeFromSuperview];
	
	if(_activeViewController == _manualViewController)
	{
		[self setTitle:@"Manual Mode"];
	}
	else 
	{
		[self setTitle:@"Closest Stations"];
	}
	
    [_containerView setFrameHeight:[DenverRideConstants shortContainerHeight]];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
	[[self navigationItem] setRightBarButtonItem:_typeSwitchButton]; 
	[_activeViewController changeDirectionTo:direction];
}

- (void)mapWasSelected
{
	
	if(nil == _mapViewController)
	{
		_mapViewController = [[RTDMapViewController alloc] initWithNibName:nil bundle:nil];
	}

	
    [_containerView setFrameHeight:[DenverRideConstants tallContainerHeight]];
	[[_bcycleViewController view] removeFromSuperview];
    [_mapViewController viewWillAppear:NO];
	[_containerView addSubview:[_mapViewController view]];
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
	
    [_containerView setFrameHeight:[DenverRideConstants tallContainerHeight]];
	[[_mapViewController view] removeFromSuperview];
    [_bcycleViewController viewWillAppear:NO];
	[_containerView addSubview:[_bcycleViewController view]];
    [_bcycleViewController viewDidAppear:NO];
	[self setTitle:@"BCycle"];
	[[self navigationController] setNavigationBarHidden:YES animated:NO];
}


@end

