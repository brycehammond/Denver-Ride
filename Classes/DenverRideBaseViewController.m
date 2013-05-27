    //
//  DenverRideBaseViewController.m
//  RTD
//
//  Created by bryce.hammond on 9/6/10.
//  Copyright 2010 Fluidvision Design. All rights reserved.
//

#import "DenverRideBaseViewController.h"


@implementation DenverRideBaseViewController


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	[[self view] setFrameHeight:416];
	_sectionSelectorView = [[MainSectionSelectorView alloc] initWithDefaultFrame];
	CGRect frame = _sectionSelectorView.frame;
	frame.origin = CGPointMake(0, [self view].frame.size.height
							   - _sectionSelectorView.frame.size.height);
	[_sectionSelectorView setFrame:frame];
	[_sectionSelectorView setDelegate:self];
    [_sectionSelectorView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
	
	[[self view] addSubview:_sectionSelectorView];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	_sectionSelectorView = nil;
}



#pragma mark MainSectionSelectorViewDelegate methods

- (void)nortboundWasSelected
{
	
}

- (void)southboundWasSelected
{
	
}

- (void)mapWasSelected
{
	
}

- (void)bcycleWasSelected
{
	
}


@end
