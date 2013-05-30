    //
//  DenverRideBaseViewController.m
//  RTD
//
//  Created by bryce.hammond on 9/6/10.
//  Copyright 2010 Fluidvision Design. All rights reserved.
//

#import "DenverRideBaseViewController.h"
#import "Flurry.h"

@implementation DenverRideBaseViewController
@synthesize currentDirectionHand;


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [self setCurrentDirectionHand:nil];
    [super viewDidUnload];
}



- (IBAction)northboundSelected:(UIButton *)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        self.currentDirectionHand.transform = CGAffineTransformIdentity;
    }];
}

- (IBAction)southboundSelected:(UIButton *)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        self.currentDirectionHand.transform = CGAffineTransformMakeRotation(M_PI);
    }];
}

- (IBAction)westboundSelected:(UIButton *)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        self.currentDirectionHand.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }];
}

- (IBAction)eastboundSelected:(UIButton *)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        self.currentDirectionHand.transform = CGAffineTransformMakeRotation(M_PI_2);
    }];
}

- (IBAction)mapSelected:(UIButton *)sender
{
    if(nil == self.mapViewController)
	{
		self.mapViewController = [[DRRTDMapViewController alloc] initWithNibName:nil bundle:nil];
	}
    
	self.mapButton.enabled = NO;
    self.bcycleButton.enabled = YES;
    [self.containerView setFrameHeight:[DenverRideConstants tallContainerHeight]];
	[[self.bcycleViewController view] removeFromSuperview];
    [self addChildViewController:self.mapViewController];
	[self.containerView addSubview:self.mapViewController.view];
	[self setTitle:@"Route Map"];
	[[self navigationController] setNavigationBarHidden:YES animated:NO];
}

- (IBAction)bcycleSelected:(UIButton *)sender
{
    if(nil == self.bcycleViewController)
	{
		self.bcycleViewController = [[BCycleViewController alloc] initWithNibName:nil bundle:nil];
	}
	else
	{
		[self.bcycleViewController updateAnnotations];
	}
	
    self.mapButton.enabled = YES;
    self.bcycleButton.enabled = NO;
    [self.containerView setFrameHeight:[DenverRideConstants tallContainerHeight]];
	[[self.mapViewController view] removeFromSuperview];
    [self addChildViewController:self.bcycleViewController];
	[self.containerView addSubview:[self.bcycleViewController view]];
	[self setTitle:@"BCycle"];
	[[self navigationController] setNavigationBarHidden:YES animated:NO];
}

- (void)directionSelected:(NSString *)direction
{
    [[NSUserDefaults standardUserDefaults] setObject:direction forKey:kCurrentDirectionKey];
	[Flurry logEvent:@"Switch Direction" withParameters:@{@"Direction": direction}];
    [self.mapViewController.view removeFromSuperview];
	[self.bcycleViewController.view removeFromSuperview];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
}

@end
