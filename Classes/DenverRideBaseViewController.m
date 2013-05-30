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
    
}

- (IBAction)bcycleSelected:(UIButton *)sender
{
    
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
