//
//  RTDMapViewController.m
//  RTD
//
//  Created by bryce.hammond on 12/6/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import "RTDMapViewController.h"
#import "FlurryAPI.h"

@implementation RTDMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		
	}
	
	return self;
}

- (void)loadView
{
	[super loadView];
	
	[[self view] setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 355)];
	
	[[self view] setBackgroundColor:[UIColor colorFromHex:kBackgroundColor withAlpha:1]];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:[[self view] bounds]];
	
	_scrollView.contentMode = (UIViewContentModeScaleAspectFit);
    _scrollView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _scrollView.maximumZoomScale = 2.5;
    _scrollView.minimumZoomScale = 1;
    _scrollView.clipsToBounds = YES;
    _scrollView.delegate = self;
	
	[[self view] addSubview:_scrollView];
	
	_mapView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Map.png"]];
	[_scrollView setContentSize:_mapView.frame.size];
	[_scrollView addSubview:_mapView];
}

- (void)viewDidAppear:(BOOL)animated
{
	[FlurryAPI logEvent:@"Map View shown"];
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
