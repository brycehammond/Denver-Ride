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
	id<StationChangeViewControllerDelegate> delegate;
}

@property (assign) id<StationChangeViewControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIToolbar *toolbar;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;

-(IBAction)cancelButtonClicked;

@end
