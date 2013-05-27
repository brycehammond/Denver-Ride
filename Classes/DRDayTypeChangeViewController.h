//
//  DayTypeChangeViewController.h
//  RTD
//
//  Created by bryce.hammond on 9/26/09.
//  Copyright 2009 Fluidvisiong Design. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRDayTypeChangeViewController;

@protocol DayTypeChangeViewControllerDelegate

-(void)doneButtonClickedOnDayTypeChangeViewController:(DRDayTypeChangeViewController *)viewController;
-(void)cancelButtonClickedOnDayTypeChangeViewController:(DRDayTypeChangeViewController *)viewController;

@end

@interface DRDayTypeChangeViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
	IBOutlet UIBarButtonItem *_cancelButton;
	IBOutlet UIBarButtonItem *_doneButton;
	IBOutlet UIPickerView *_picker;
	IBOutlet UIView *_fadeView;
	
	id<DayTypeChangeViewControllerDelegate> __weak delegate;
	
	NSArray *_dayTypes;
}

@property (weak) id<DayTypeChangeViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIToolbar *dayTypeToolbar;

-(IBAction)doneButtonClicked;
-(IBAction)cancelButtonClicked;

-(void)setDayType:(NSString *)dayTypeCode;
-(NSString *)dayType;

-(void)animateIn;
-(void)animateOut;

@end
