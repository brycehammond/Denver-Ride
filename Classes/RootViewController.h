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

@class ClosestSelectViewController, ManualSelectViewController;

@interface RootViewController : UIViewController <RTDMapViewControllerDelegate> {
	
	NSManagedObjectContext *_managedObjectContext;
	
	IBOutlet UIView *_containerView;
	IBOutlet UISegmentedControl *_northOrSouthControl;
	
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
