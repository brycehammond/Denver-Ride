//
//  RootViewController.h
//  RTD
//
//  Created by bryce.hammond on 8/2/09.
//  Copyright Fluidvision Design 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClosestSelectViewController, ManualSelectViewController;

@interface RootViewController : UIViewController {
	
	NSManagedObjectContext *_managedObjectContext;
	
	IBOutlet UIView *_containerView;
	
	ClosestSelectViewController *_closestViewController;
	ManualSelectViewController *_manualViewController;
	
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
