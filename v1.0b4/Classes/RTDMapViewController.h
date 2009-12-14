//
//  RTDMapViewController.h
//  RTD
//
//  Created by bryce.hammond on 12/6/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTDMapViewController;

@protocol RTDMapViewControllerDelegate

- (void)RTDMapVieControllerDoneButtonWasClicked:(RTDMapViewController *)mapViewController;

@end


@interface RTDMapViewController : UIViewController <UIScrollViewDelegate> {
	IBOutlet UIScrollView *_scrollView;
	
	UIImageView *_mapView;
	
	id<RTDMapViewControllerDelegate> delegate;
}

@property (assign) id<RTDMapViewControllerDelegate> delegate;

- (IBAction)doneButtonClicked:(id)sender;

@end
