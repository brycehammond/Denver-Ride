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

@interface DRRootViewController : DenverRideBaseViewController 

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
