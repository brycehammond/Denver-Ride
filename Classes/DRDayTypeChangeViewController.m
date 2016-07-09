//
//  DayTypeChangeViewController.m
//  RTD
//
//  Created by bryce.hammond on 9/26/09.
//  Copyright 2009 Fluidvisiong Design. All rights reserved.
//

#import "DRDayTypeChangeViewController.h"
#import "NSDate+TimeInMinutes.h"
#import "Masonry.h"

@implementation DRDayTypeChangeViewController


@synthesize delegate;
@synthesize dayTypeToolbar = _dayTypeToolbar;

-(IBAction)doneButtonClicked
{
	[self.delegate doneButtonClickedOnDayTypeChangeViewController:self];
}

-(IBAction)cancelButtonClicked
{
	[self.delegate cancelButtonClickedOnDayTypeChangeViewController:self];
}

-(void)setDayType:(NSString *)dayTypeCode
{
	NSUInteger row = [_dayTypes indexOfObject:[NSDate fullDayTypesByCode][dayTypeCode]];
	[_picker selectRow:row inComponent:0 animated:NO];
}

-(NSString *)dayType
{
	return [NSDate codesByfullDayTypes][_dayTypes[[_picker selectedRowInComponent:0]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     _dayTypes = [NSDate fullDayTypes];
    self.dayTypeToolbar.tintColor = [UIColor colorWithHexString:kNavBarColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fadeViewTapped:)];
    [_fadeView addGestureRecognizer:tapGesture];
}
                                     
- (void)fadeViewTapped:(UITapGestureRecognizer *)gesture
{
    [self.delegate cancelButtonClickedOnDayTypeChangeViewController:self];
}

-(void)animateIn
{
    _fadeView.alpha = 0.0;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [self.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view.superview);
        }];
        [self.view.superview layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            _fadeView.alpha = 0.7;
        }];
    }];
}

-(void)animateOut
{
    [UIView animateWithDuration:0.2 animations:^{
        _fadeView.alpha = 0.0;
    } completion:^(BOOL finished) {
       [UIView animateWithDuration:0.3 animations:^{
           [self.view mas_remakeConstraints:^(MASConstraintMaker *make) {
               UIView *superview = self.view.superview;
               make.top.equalTo(superview.mas_bottom);
               make.left.equalTo(superview.mas_left);
               make.right.equalTo(superview.mas_right);
               make.height.equalTo(superview.mas_height);
           }];
           
           [self.view.superview layoutIfNeeded];
       } completion:^(BOOL finished) {
           [self.view removeFromSuperview];
       }];
    }];
}


#pragma mark -
#pragma mark UIPickerView methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [_dayTypes count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return _dayTypes[row];
}


@end

