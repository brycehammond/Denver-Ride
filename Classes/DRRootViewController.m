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
#import "Masonry.h"

@interface DRRootViewController ()

@property (nonatomic, strong) IBOutlet UIBarButtonItem *typeSwitchButton;
@property (nonatomic, weak) UIViewController<DRChangeDirectionProtocol> *activeViewController;
@property (nonatomic, strong) DRClosestSelectViewController *closestViewController;
@property (nonatomic, strong) DRManualSelectViewController *manualViewController;


@end

@implementation DRRootViewController


static NSString *lastTypeUsedKey = @"LastTypeUsed";

-(void)viewDidLoad
{
	[super viewDidLoad];
	
    [self.containerView setBackgroundColor:[UIColor colorWithHexString:kBackgroundColor]];
    
    RTDAppDelegate *appDelegate = (RTDAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFinished) 
												 name:@"UpdateFinishedNotification" object:nil];

	
	NSString *direction = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentDirectionKey];
	
	NSString *lastTypeUsed = [[NSUserDefaults standardUserDefaults] stringForKey:lastTypeUsedKey];
	if(! lastTypeUsed)
	{
        lastTypeUsed = @"Closest";
		[[NSUserDefaults standardUserDefaults] setObject:lastTypeUsed forKey:lastTypeUsedKey];
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

- (void)setActiveViewController:(UIViewController<DRChangeDirectionProtocol> *)activeViewController
{
    if(_activeViewController == activeViewController)
    {
        return;
    }
    
    UIViewController *currentActiveController = self.activeViewController;
    [currentActiveController removeFromParentViewController];
    [[currentActiveController view] removeFromSuperview];
    
    [self addChildViewController:activeViewController];
    [self.containerView addSubview:[activeViewController view]];
    
    [[activeViewController view] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.containerView);
    }];
    
    _activeViewController = activeViewController;
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
		[[NSUserDefaults standardUserDefaults] setObject:@"Manual" forKey:lastTypeUsedKey];
		[sender setTitle:@"Closest"];
        
        [UIView transitionWithView:self.containerView duration:0.75 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
            self.activeViewController = [self manualViewController];
        } completion:^(BOOL finished) {
            
        }];
		
	}
	else {
		
		//set to closest mode
		
		NSString *direction = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentDirectionKey];
		[Flurry logEvent:@"Switch Mode" withParameters:
			@{@"Mode": @"Closest",@"Direction": direction}];
		
		[sender setTitle:@"Manual"];
		[[NSUserDefaults standardUserDefaults] setObject:@"Closest" forKey:lastTypeUsedKey];
		[self setTitle:@"Closest Stations"];
		
        [UIView transitionWithView:self.containerView duration:0.75 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
            self.activeViewController = [self closestViewController];
        } completion:^(BOOL finished) {
            
        }];
	}

}

- (DRClosestSelectViewController *)closestViewController
{
	if(! _closestViewController)
	{
		_closestViewController = [[DRClosestSelectViewController alloc] initWithNibName:nil
																			   bundle:nil];
        _closestViewController.managedObjectContext = self.managedObjectContext;
	}
	
	return _closestViewController;
}

- (DRManualSelectViewController *)manualViewController
{
	if(! _manualViewController)
	{
		_manualViewController = [[DRManualSelectViewController alloc] initWithNibName:nil 
																			 bundle:nil];
        _manualViewController.managedObjectContext = self.managedObjectContext;
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

