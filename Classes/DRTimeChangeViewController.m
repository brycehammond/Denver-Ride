//
//  TimeChangeViewController.m
//  RTD
//
//  Created by bryce.hammond on 9/13/09.
//  Copyright 2009 Wall Street On Demand, Inc.. All rights reserved.
//

#import "DRTimeChangeViewController.h"

@implementation DRTimeChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.timeChangeToolbar.tintColor = [UIColor colorWithHexString:kNavBarColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fadeViewTapped:)];
    [_fadeView addGestureRecognizer:tapGesture];
}

- (void)fadeViewTapped:(UITapGestureRecognizer *)gesture
{
    [self.delegate cancelButtonClickedOnTimeChangeViewController:self];
}


-(IBAction)doneButtonClicked
{
	[self.delegate doneButtonClickedOnTimeChangeViewController:self];
}

-(IBAction)cancelButtonClicked
{
	[self.delegate cancelButtonClickedOnTimeChangeViewController:self];
}

-(void)setTimeInMinutes:(NSInteger)timeInMinutes
{
	NSCalendar *gregorian = [NSCalendar currentCalendar];
	
	NSDate *currentDate = [NSDate date];
	//subtract the hours and minutes of the day to get the start of the day
	NSDateComponents *components = [gregorian components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:currentDate];
	[components setHour:-[components hour]];
	[components setMinute:-[components minute]];
	currentDate = [gregorian dateByAddingComponents:components toDate:currentDate options:0];
	NSInteger hours = timeInMinutes / 60;
	NSInteger minutes = timeInMinutes % 60;
	[components setHour:hours];
	[components setMinute:minutes];
	currentDate = [gregorian dateByAddingComponents:components toDate:currentDate options:0];
	
	[_timePicker setDate:currentDate];
	
}

-(NSInteger)timeInMinutes
{
	NSCalendar *gregorian = [NSCalendar currentCalendar];
	NSDateComponents *components = [gregorian components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[_timePicker date]];
	NSInteger hours = [components hour];
	NSInteger minutes = [components minute];
	
	return (hours * 60) + minutes;
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



@end

