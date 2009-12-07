//
//  RTDMapViewController.m
//  RTD
//
//  Created by bryce.hammond on 12/6/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import "RTDMapViewController.h"


@implementation RTDMapViewController

@synthesize delegate;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	_scrollView.contentMode = (UIViewContentModeScaleAspectFit);
    _scrollView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _scrollView.maximumZoomScale = 2.5;
    _scrollView.minimumZoomScale = 1;
    _scrollView.clipsToBounds = YES;
    _scrollView.delegate = self;
	
	_mapView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LightRail_mapfile.gif"]];
	[_scrollView setContentSize:_mapView.frame.size];
	[_scrollView addSubview:_mapView];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (IBAction)doneButtonClicked:(id)sender
{
	[delegate RTDMapVieControllerDoneButtonWasClicked:self];
}

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _mapView;
}

- (void)dealloc {
	[_mapView release];
	[_scrollView release];
    [super dealloc];
}


@end
