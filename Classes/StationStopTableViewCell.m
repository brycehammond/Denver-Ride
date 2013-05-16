//
//  StationStopTableViewCell.m
//  RTD
//
//  Created by bryce.hammond on 8/15/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import "StationStopTableViewCell.h"
#import "Line.h"
#import "RTDAppDelegate.h"

@implementation StationStopTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
		
	}
	
	return self;
}

-(void)setStop:(Stop *)stop
{	
	self.textLabel.text = [stop formattedTime];
	[self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
}

-(void)setEndOfLineStation:(Station *)station withStartStop:(Stop *)stop
{
	[self setStop:stop];
	
	self.detailTextLabel.text = [NSString stringWithFormat:@"%@ Line (%@)",[[stop line] name],
								 [station name]];
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




@end
