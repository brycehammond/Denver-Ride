//
//  StationChangeViewController.h
//  RTD
//
//  Created by bryce.hammond on 9/26/09.
//  Copyright 2009 Fluidvisiong Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRStationListViewController.h"
#import "Station+Convenience.h"

@protocol StationChangeViewControllerDelegate

-(void)stationWasSelected:(Station *)station;
-(void)viewWasCancelled;

@end

@interface DRStationChangeViewController : DRStationListViewController 

@property (weak) id<StationChangeViewControllerDelegate> delegate;

@end
