    //
//  DenverRideBaseViewController.m
//  RTD
//
//  Created by bryce.hammond on 9/6/10.
//  Copyright 2010 Fluidvision Design. All rights reserved.
//

#import "DenverRideBaseViewController.h"


@implementation DenverRideBaseViewController


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
    [super viewDidUnload];
}



- (IBAction)nortboundSelected:(UIButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"N" forKey:kCurrentDirectionKey];
}

- (IBAction)southboundSelected:(UIButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"S" forKey:kCurrentDirectionKey];
}

- (IBAction)westboundSelected:(UIButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"W" forKey:kCurrentDirectionKey];
}

- (IBAction)eastboundSelected:(UIButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"E" forKey:kCurrentDirectionKey];
}

- (IBAction)mapSelected:(UIButton *)sender
{
    
}

- (IBAction)bcycleSelected:(UIButton *)sender
{
    
}

@end
