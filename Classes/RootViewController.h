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
#import "BCycleViewController.h"
#import "DenverRideBaseViewController.h"

@class ClosestSelectViewController, ManualSelectViewController;

@interface RootViewController : DenverRideBaseViewController {
	
	NSManagedObjectContext *_managedObjectContext;
	
	UIView *_containerView;
	
	UIBarButtonItem *_typeSwitchButton;
	
	ClosestSelectViewController *_closestViewController;
	ManualSelectViewController *_manualViewController;
	
	RTDMapViewController *_mapViewController;
	BCycleViewController *_bcycleViewController;
	
	UIViewController<ChangeDirectionProtocol> *_activeViewController;
	
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) ClosestSelectViewController *closestViewController;
@property (nonatomic, strong) ManualSelectViewController *manualViewController;


@end
