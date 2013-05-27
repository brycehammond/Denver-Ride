//
//  RootViewController.m
//  RTD
//
//  Created by bryce.hammond on 8/2/09.
//  Copyright Fluidvision Design 2009. All rights reserved.
//

#import "DRRootViewController.h"
#import "DRClosestSelectViewController.h"
#import "DRManualSelectViewController.h"
#import "Flurry.h"

@interface DRRootViewController ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *typeSwitchButton;
@property (nonatomic, weak) UIViewController<DRChangeDirectionProtocol> *activeViewController;
@property (nonatomic, strong) DRClosestSelectViewController *closestViewController;
@property (nonatomic, strong) DRManualSelectViewController *manualViewController;
@property (nonatomic, strong) DRRTDMapViewController *mapViewController;
@property (nonatomic, strong) BCycleViewController *bcycleViewController;

@end

@implementation DRRootViewController

@synthesize  managedObjectContext = _managedObjectContext,
			closestViewController = _closestViewController,
			manualViewController = _manualViewController,
            mapViewController = _mapViewController,
            bcycleViewController = _bcycleViewController;

-(void)viewDidLoad
{
	[super viewDidLoad];
	
    [self.containerView setBackgroundColor:[UIColor colorWithHexString:kBackgroundColor]];
    
	[[[self navigationController] navigationBar] setTintColor:
	 [UIColor colorWithHexString:kNavBarColor]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFinished) 
												 name:@"UpdateFinishedNotification" object:nil];

	
	NSString *direction = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentDirectionKey];
	/*if([direction isEqualToString:@"N"])
	{
		[_sectionSelectorView setToNorthbound];
	}
	else
	{
		[_sectionSelectorView setToSouthbound];
	}*/
	
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
		self.activeViewController = [self closestViewController];
		[Flurry logEvent:@"Launch" withParameters:@{@"Mode": @"Closest",@"Direction": direction}];
		buttonTitle = @"Manual";
		[self setTitle:@"Closest Stations"];
	}
	else {
		self.activeViewController = [self manualViewController];
		[Flurry logEvent:@"Launch" withParameters:@{@"Mode": @"Manual",@"Direction": direction}];
		buttonTitle = @"Closest";
		[self setTitle:@"Manual Mode"];
	}
    
    self.typeSwitchButton.title = buttonTitle;
}

-(void)updateFinished
{
	NSString *direction = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentDirectionKey];
	
	if([[self navigationController] topViewController] != self)
	{
		[[self navigationController] popToRootViewControllerAnimated:NO];
	}
	
	[self.activeViewController retrieveStopsDirection:direction];
	
}

-(IBAction)topRightButtonClicked:(UIBarButtonItem *)sender
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
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.containerView cache:YES];
		[UIView setAnimationDuration:0.75];
        [[[self closestViewController] view] removeFromSuperview];
		self.activeViewController = [self manualViewController];
        [self.containerView addSubview:[[self manualViewController] view]];
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
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.containerView cache:YES];
		[UIView setAnimationDuration:0.75];
        [[[self manualViewController] view] removeFromSuperview];
		self.activeViewController = [self closestViewController];
        [self.containerView addSubview:[[self closestViewController] view]];
        [UIView commitAnimations];
		[[self closestViewController] viewWillAppear:YES];
		[[self closestViewController] viewDidAppear:YES];
	}

}

- (DRClosestSelectViewController *)closestViewController
{
	if(! _closestViewController)
	{
		_closestViewController = [[DRClosestSelectViewController alloc] initWithNibName:nil
																			   bundle:nil];
		[_closestViewController setManagedObjectContext:[self managedObjectContext]];
		[_closestViewController setNavigationController:[self navigationController]];
	}
	
	return _closestViewController;
}

- (DRManualSelectViewController *)manualViewController
{
	if(! _manualViewController)
	{
		_manualViewController = [[DRManualSelectViewController alloc] initWithNibName:nil 
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
	[[self.mapViewController view] removeFromSuperview];
	[[self.bcycleViewController view] removeFromSuperview];
	
	if(self.activeViewController == _manualViewController)
	{
		[self setTitle:@"Manual Mode"];
	}
	else 
	{
		[self setTitle:@"Closest Stations"];
	}
	[self.activeViewController changeDirectionTo:direction];
}

- (void)southboundWasSelected
{
	NSString *direction = @"S";
	[[NSUserDefaults standardUserDefaults] setObject:direction forKey:kCurrentDirectionKey];
	[Flurry logEvent:@"Switch Direction" withParameters:@{@"Direction": direction}];
	[[_mapViewController view] removeFromSuperview];
	[[_bcycleViewController view] removeFromSuperview];
	
	if(self.activeViewController == _manualViewController)
	{
		[self setTitle:@"Manual Mode"];
	}
	else 
	{
		[self setTitle:@"Closest Stations"];
	}
	[self.activeViewController changeDirectionTo:direction];
}

- (void)mapWasSelected
{
	
	if(nil == _mapViewController)
	{
		_mapViewController = [[DRRTDMapViewController alloc] initWithNibName:nil bundle:nil];
	}

	
    [self.containerView setFrameHeight:[DenverRideConstants tallContainerHeight]];
	[[_bcycleViewController view] removeFromSuperview];
    [_mapViewController viewWillAppear:NO];
	[self.containerView addSubview:[_mapViewController view]];
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
	
    [self.containerView setFrameHeight:[DenverRideConstants tallContainerHeight]];
	[[_mapViewController view] removeFromSuperview];
    [_bcycleViewController viewWillAppear:NO];
	[self.containerView addSubview:[_bcycleViewController view]];
    [_bcycleViewController viewDidAppear:NO];
	[self setTitle:@"BCycle"];
	[[self navigationController] setNavigationBarHidden:YES animated:NO];
}


@end

