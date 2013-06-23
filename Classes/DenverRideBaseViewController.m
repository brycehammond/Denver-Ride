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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateViewForDirection:[[NSUserDefaults standardUserDefaults] stringForKey:kCurrentDirectionKey]];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [self setCurrentDirectionHand:nil];
    [self setCurrentDirectionButton:nil];
    [super viewDidUnload];
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundColor];
    self.containerView.backgroundColor = [UIColor colorWithHexString:kBackgroundColor];
}

- (IBAction)northboundSelected:(UIButton *)sender
{
    [self updateViewForDirection:@"N"];
    [self directionSelected:@"N"];
}

- (IBAction)southboundSelected:(UIButton *)sender
{
    [self updateViewForDirection:@"S"];
    [self directionSelected:@"S"];
}

- (IBAction)westboundSelected:(UIButton *)sender
{
    [self updateViewForDirection:@"W"];
    [self directionSelected:@"W"];
}

- (IBAction)eastboundSelected:(UIButton *)sender
{
    [self updateViewForDirection:@"E"];
    [self directionSelected:@"E"];
}

- (void)updateViewForDirection:(NSString *)direction
{
    NSString *directionText = @"";
    CGAffineTransform transform = CGAffineTransformIdentity;
    if([direction isEqualToString:@"N"])
    {
        directionText = @"Northbound";
    }
    else if([direction isEqualToString:@"S"])
    {
        directionText = @"Southbound";
        transform = CGAffineTransformMakeRotation(M_PI);
    }
    else if([direction isEqualToString:@"W"])
    {
        directionText = @"Westbound";
        transform = CGAffineTransformMakeRotation(-M_PI_2);
    }
    else if([direction isEqualToString:@"E"])
    {
        directionText = @"Eastbound";
        transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    
    self.currentDirectionLabel.text = directionText;
    [UIView animateWithDuration:0.3 animations:^{
        self.currentDirectionHand.transform = transform;
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
    self.mapButton.enabled = YES;
    self.bcycleButton.enabled = YES;
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
}

- (IBAction)moveToNextDirection:(id)sender
{
    NSString *currentDirection  = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentDirectionKey];
    if(self.mapButton.enabled && self.bcycleButton.enabled)
    {
        //we are in direction mode so just update the direction to the next one
        currentDirection = [self nextDirectionForDirection:currentDirection];
    }
    
    [self updateViewForDirection:currentDirection];
    [self directionSelected:currentDirection];
}

- (NSString *)nextDirectionForDirection:(NSString *)direction
{
    NSDictionary *nextDirections = @{@"N" : @"E",
                                     @"E" : @"S",
                                     @"S" : @"W",
                                     @"W" : @"N"};
    
    return nextDirections[direction];
}

@end
