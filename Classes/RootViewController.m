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


@implementation RootViewController

@synthesize  managedObjectContext = _managedObjectContext;

-(void)viewDidLoad
{
	[super viewDidLoad];
	[self setTitle:@"Closest Stations"];
	_closestViewController = [[ClosestSelectViewController alloc] initWithNibName:@"ClosestSelectViewController"
																		   bundle:nil];
	[_closestViewController setManagedObjectContext:[self managedObjectContext]];
	[_closestViewController setNavigationController:[self navigationController]];
	[_containerView addSubview:[_closestViewController view]];
}

@end

