    //
//  DenverRideBaseViewController.m
//  RTD
//
//  Created by bryce.hammond on 9/6/10.
//  Copyright 2010 Fluidvision Design. All rights reserved.
//

#import "DenverRideBaseViewController.h"


@implementation DenverRideBaseViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	[[self view] setFrameHeight:416];
	_sectionSelectorView = [[MainSectionSelectorView alloc] initWithDefaultFrame];
	CGRect frame = _sectionSelectorView.frame;
	frame.origin = CGPointMake(0, [self view].frame.size.height
							   - _sectionSelectorView.frame.size.height);
	[_sectionSelectorView setFrame:frame];
	
	[[self view] addSubview:_sectionSelectorView];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [_sectionSelectorView release];
	_sectionSelectorView = nil;
}


- (void)dealloc {
    [super dealloc];
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
