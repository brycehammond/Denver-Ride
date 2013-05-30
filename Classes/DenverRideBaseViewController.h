//
//  DenverRideBaseViewController.h
//  RTD
//
//  Created by bryce.hammond on 9/6/10.
//  Copyright 2010 Fluidvision Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRRTDMapViewController.h"
#import "BCycleViewController.h"

@interface DenverRideBaseViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *mapButton;
@property (nonatomic, weak) IBOutlet UIButton *bcycleButton;
@property (nonatomic, weak) IBOutlet UILabel *currentDirectionLabel;
@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) DRRTDMapViewController *mapViewController;
@property (nonatomic, strong) BCycleViewController *bcycleViewController;
@property (weak, nonatomic) IBOutlet UIImageView *currentDirectionHand;

- (IBAction)northboundSelected:(UIButton *)sender;
- (IBAction)southboundSelected:(UIButton *)sender;
- (IBAction)westboundSelected:(UIButton *)sender;
- (IBAction)eastboundSelected:(UIButton *)sender;
- (IBAction)mapSelected:(UIButton *)sender;
- (IBAction)bcycleSelected:(UIButton *)sender;

- (void)directionSelected:(NSString *)direction;

@end
