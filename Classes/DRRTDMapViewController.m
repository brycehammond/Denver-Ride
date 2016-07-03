//
//  RTDMapViewController.m
//  RTD
//
//  Created by bryce.hammond on 12/6/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import "DRRTDMapViewController.h"
#import "Flurry.h"

@implementation DRRTDMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView.scalesPageToFit = YES;
    
    NSString *pdfLocation = [[NSBundle mainBundle] pathForResource:@"light-rail-map" ofType:@"pdf"];
    
    NSURL *url = [NSURL fileURLWithPath:pdfLocation];
    [self.mapView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[Flurry logEvent:@"Map View shown"];
}

@end
