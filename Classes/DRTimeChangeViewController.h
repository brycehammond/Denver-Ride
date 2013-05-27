//
//  TimeChangeViewController.h
//  RTD
//
//  Created by bryce.hammond on 9/13/09.
//  Copyright 2009 Wall Street On Demand, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRTimeChangeViewController;

@protocol TimeChangeViewControllerDelegate

-(void)doneButtonClickedOnTimeChangeViewController:(DRTimeChangeViewController *)viewController;
-(void)cancelButtonClickedOnTimeChangeViewController:(DRTimeChangeViewController *)viewController;

@end


@interface DRTimeChangeViewController : UIViewController
{
	IBOutlet UIBarButtonItem *_cancelButton;
	IBOutlet UIBarButtonItem *_doneButton;
	IBOutlet UIDatePicker *_timePicker;
	IBOutlet UIView *_fadeView;
	
	id<TimeChangeViewControllerDelegate> __weak delegate;
	
}

@property (weak) id<TimeChangeViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIToolbar *timeChangeToolbar;

-(IBAction)doneButtonClicked;
-(IBAction)cancelButtonClicked;

-(void)setTimeInMinutes:(NSInteger)timeInMinutes;
-(NSInteger)timeInMinutes;

-(void)animateIn;
-(void)animateOut;

@end
