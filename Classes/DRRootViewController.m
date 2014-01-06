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
#import "RTDAppDelegate.h"
#import "Station+Convenience.h"
#import "Flurry.h"

@interface DRRootViewController ()

@property (nonatomic, strong) IBOutlet UIBarButtonItem *typeSwitchButton;
@property (nonatomic, weak) UIViewController<DRChangeDirectionProtocol> *activeViewController;
@property (nonatomic, strong) DRClosestSelectViewController *closestViewController;
@property (nonatomic, strong) DRManualSelectViewController *manualViewController;


@end

@implementation DRRootViewController

@synthesize  managedObjectContext = _managedObjectContext,
			closestViewController = _closestViewController,
			manualViewController = _manualViewController;

-(void)viewDidLoad
{
	[super viewDidLoad];
	
    [self.containerView setBackgroundColor:[UIColor colorWithHexString:kBackgroundColor]];
    
    RTDAppDelegate *appDelegate = (RTDAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFinished) 
												 name:@"UpdateFinishedNotification" object:nil];

	
	NSString *direction = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentDirectionKey];
    //@TODO: set hand direction properly
	
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
    
    self.activeViewController.view.frame = self.containerView.bounds;
    [self addChildViewController:self.activeViewController];
    [self.containerView addSubview:self.activeViewController.view];
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

#pragma mark DenverRideBaseViewController overrides

- (void)directionSelected:(NSString *)direction
{
	[super directionSelected:direction];
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


@end

