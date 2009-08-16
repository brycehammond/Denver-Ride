//
//  StationStopTableViewCell.m
//  RTD
//
//  Created by bryce.hammond on 8/15/09.
//  Copyright 2009 Wall Street On Demand, Inc.. All rights reserved.
//

#import "StationStopTableViewCell.h"
#import "Line.h"
#import "RTDAppDelegate.h"

@implementation StationStopTableViewCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}

-(void)setStop:(Stop *)stop
{	
	NSString *amOrPm = @"A";
	int hours = [[stop timeInMinutes] intValue] / 60;
	if(hours > 12)
	{
		hours -= 12;
		amOrPm = @"P";
	}	
	int minutes = [[stop timeInMinutes] intValue] % 60;
	NSString *formatedMinutes =(minutes < 10) ? [NSString stringWithFormat:@"0%i",minutes] : [NSString stringWithFormat:@"%i",minutes];
	
	self.textLabel.text = [NSString stringWithFormat:@"%i:%@%@",hours,formatedMinutes,amOrPm];
	[self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
}

-(void)setEndOfLineStop:(Stop *)stop
{
	
	self.detailTextLabel.text = [NSString stringWithFormat:@"%@ Line (%@)",[[stop line] name],
								 [[stop station] name]];
	RTDAppDelegate *appDelegate = (RTDAppDelegate *)[[UIApplication sharedApplication] delegate];
	self.detailTextLabel.textColor = [[appDelegate linesToColors] objectForKey:[[stop line] name]];
	
	
}

-(StationStopTableViewCell *)initWithReuseIdentifier:(NSString *)cellIdentifier;
{
	StationStopTableViewCell *cell = [self initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
	
	return cell;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
