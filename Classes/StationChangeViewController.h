//
//  StationChangeViewController.h
//  RTD
//
//  Created by bryce.hammond on 9/26/09.
//  Copyright 2009 Fluidvisiong Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StationListViewController.h"

@protocol StationChangeViewControllerDelegate

-(void)stationWasSelected:(NSString *)station;
-(void)viewWasCancelled;

@end

@interface StationChangeViewController : StationListViewController {
	id<StationChangeViewControllerDelegate> __weak delegate;
}

@property (weak) id<StationChangeViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIToolbar *stationChangeToolbar;

-(IBAction)cancelButtonClicked;

@end
