//
//  RTDMapViewController.h
//  RTD
//
//  Created by bryce.hammond on 12/6/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTDMapViewController;

@interface RTDMapViewController : UIViewController <UIScrollViewDelegate> {
	UIScrollView *_scrollView;
	
	UIImageView *_mapView;
	
}

@end
