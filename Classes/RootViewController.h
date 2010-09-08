//
//  RootViewController.h
//  RTD
//
//  Created by bryce.hammond on 8/2/09.
//  Copyright Fluidvision Design 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChangeDirectionProtocol.h"
#import "RTDMapViewController.h"
#import "DenverRideBaseViewController.h"

@class ClosestSelectViewController, ManualSelectViewController;

@interface RootViewController : DenverRideBaseViewController <RTDMapViewControllerDelegate> {
	
	NSManagedObjectContext *_managedObjectContext;
	
	UIView *_containerView;
	
	ClosestSelectViewController *_closestViewController;
	ManualSelectViewController *_manualViewController;
	
	RTDMapViewController *_mapViewController;
	
	UIViewController<ChangeDirectionProtocol> *_activeViewController;
	
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) ClosestSelectViewController *closestViewController;
@property (nonatomic, retain) ManualSelectViewController *manualViewController;

-(IBAction)changeDirection:(id)sender;

@end
