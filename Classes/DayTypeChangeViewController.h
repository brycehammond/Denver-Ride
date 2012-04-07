//
//  DayTypeChangeViewController.h
//  RTD
//
//  Created by bryce.hammond on 9/26/09.
//  Copyright 2009 Fluidvisiong Design. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DayTypeChangeViewController;

@protocol DayTypeChangeViewControllerDelegate

-(void)doneButtonClickedOnDayTypeChangeViewController:(DayTypeChangeViewController *)viewController;
-(void)cancelButtonClickedOnDayTypeChangeViewController:(DayTypeChangeViewController *)viewController;

@end

@interface DayTypeChangeViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
	IBOutlet UIBarButtonItem *_cancelButton;
	IBOutlet UIBarButtonItem *_doneButton;
	IBOutlet UIPickerView *_picker;
	IBOutlet UIView *_fadeView;
	
	id<DayTypeChangeViewControllerDelegate> delegate;
	
	NSArray *_dayTypes;
}

@property (assign) id<DayTypeChangeViewControllerDelegate> delegate;

@property (retain, nonatomic) IBOutlet UIToolbar *dayTypeToolbar;

-(IBAction)doneButtonClicked;
-(IBAction)cancelButtonClicked;

-(void)setDayType:(NSString *)dayTypeCode;
-(NSString *)dayType;

-(void)animateIn;
-(void)animateOut;

@end
