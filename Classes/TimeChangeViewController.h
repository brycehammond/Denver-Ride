//
//  TimeChangeViewController.h
//  RTD
//
//  Created by bryce.hammond on 9/13/09.
//  Copyright 2009 Wall Street On Demand, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TimeChangeViewController;

@protocol TimeChangeViewControllerDelegate

-(void)doneButtonClickedOnTimeChangeViewController:(TimeChangeViewController *)viewController;
-(void)cancelButtonClickedOnTimeChangeViewController:(TimeChangeViewController *)viewController;

@end


@interface TimeChangeViewController : UIViewController
{
	IBOutlet UIBarButtonItem *_cancelButton;
	IBOutlet UIBarButtonItem *_doneButton;
	IBOutlet UIDatePicker *_timePicker;
	IBOutlet UIView *_fadeView;
	
	id<TimeChangeViewControllerDelegate> delegate;
	
}

@property (assign) id<TimeChangeViewControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIToolbar *toolbar;

-(IBAction)doneButtonClicked;
-(IBAction)cancelButtonClicked;

-(void)setTimeInMinutes:(NSInteger)timeInMinutes;
-(NSInteger)timeInMinutes;

-(void)animateIn;
-(void)animateOut;

@end
