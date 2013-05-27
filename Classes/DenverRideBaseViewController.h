//
//  DenverRideBaseViewController.h
//  RTD
//
//  Created by bryce.hammond on 9/6/10.
//  Copyright 2010 Fluidvision Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainSectionSelectorView.h"

@interface DenverRideBaseViewController : UIViewController

- (IBAction)nortboundSelected:(UIButton *)sender;
- (IBAction)southboundSelected:(UIButton *)sender;
- (IBAction)westboundSelected:(UIButton *)sender;
- (IBAction)eastboundSelected:(UIButton *)sender;
- (IBAction)mapSelected:(UIButton *)sender;
- (IBAction)bcycleSelected:(UIButton *)sender;

@end
