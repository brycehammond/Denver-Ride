//
//  RTDMapViewController.m
//  RTD
//
//  Created by bryce.hammond on 12/6/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import "RTDMapViewController.h"
#import "Flurry.h"

@implementation RTDMapViewController


- (void)loadView
{
	[super loadView];
	
	[[self view] setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [DenverRideConstants tallContainerHeight])];
	
	[[self view] setBackgroundColor:[UIColor colorFromHex:kBackgroundColor withAlpha:1]];
    
    _mapView = [[UIWebView alloc] initWithFrame:[[self view] bounds]];
    [_mapView setScalesPageToFit:YES];
    
    NSString *pdfLocation = [[NSBundle mainBundle] pathForResource:@"light-rail-map" ofType:@"pdf"];
    
    NSURL *url = [NSURL fileURLWithPath:pdfLocation];
    [_mapView loadRequest:[NSURLRequest requestWithURL:url]];
	
	[[self view] addSubview:_mapView];
}

- (void)viewDidAppear:(BOOL)animated
{
	[Flurry logEvent:@"Map View shown"];
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    [_mapView release];
    _mapView = nil;
}

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _mapView;
}

- (void)dealloc {
	[_mapView release];
    [super dealloc];
}


@end
