//
//  RootViewController.h
//  RTD
//
//  Created by bryce.hammond on 8/2/09.
//  Copyright Fluidvision Design 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChangeDirectionProtocol.h"
#import "DRRTDMapViewController.h"
#import "BCycleViewController.h"
#import "DenverRideBaseViewController.h"

@class DRClosestSelectViewController, DRManualSelectViewController;

@interface DRRootViewController : DenverRideBaseViewController {
	
	UIView *_containerView;
	
	UIBarButtonItem *_typeSwitchButton;
	
	DRRTDMapViewController *_mapViewController;
	BCycleViewController *_bcycleViewController;
	
	UIViewController<DRChangeDirectionProtocol> *_activeViewController;
	
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) DRClosestSelectViewController *closestViewController;
@property (nonatomic, strong) DRManualSelectViewController *manualViewController;

@end
