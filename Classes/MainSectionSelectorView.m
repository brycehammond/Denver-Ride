//
//  MainSectionSelectorView.m
//  RTD
//
//  Created by bryce.hammond on 9/6/10.
//  Copyright 2010 Fluidvision Design. All rights reserved.
//

#import "MainSectionSelectorView.h"

#define kNorthboundIndex	0
#define kSouthboundIndex	1
#define kMapIndex			2
#define kBcycleIndex		3

@interface MainSectionSelectorView (Private)

- (void)buttonPressed:(UIButton *)button;

@end


@implementation MainSectionSelectorView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		
		//set background with header
		[self setBackgroundColor:[UIColor colorFromHex:@"4E9CE1" withAlpha:1]];
		UIView *headerRule = [[UIView alloc] initWithFrame:
							  CGRectMake(0, 0, frame.size.width, 1)];
		[headerRule setBackgroundColor:[UIColor colorFromHex:@"185FC7" withAlpha:1]];
		[self addSubview:headerRule];

		UIImage *buttonImage = [UIImage imageNamed:@"nav-northbound.png"];
		_northButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_northButton setImage:buttonImage
										  forState:UIControlStateNormal];
		[_northButton setImage:[UIImage imageNamed:@"nav-northbound_down.png"]
										  forState:UIControlStateDisabled];
		[_northButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[_northButton setFrame:CGRectMake(3, 4, buttonImage.size.width, buttonImage.size.height)];
		[self addSubview:_northButton];
		
		buttonImage = [UIImage imageNamed:@"nav-southbound.png"];
		_southButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_southButton setImage:buttonImage
					  forState:UIControlStateNormal];
		[_southButton setImage:[UIImage imageNamed:@"nav-southbound_down.png"]
					  forState:UIControlStateDisabled];
		[_southButton setFrame:CGRectMake(CGRectGetMaxX(_northButton.frame), 4,
										  buttonImage.size.width, buttonImage.size.height)];
		[_southButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_southButton];
		
		
		buttonImage = [UIImage imageNamed:@"nav-route-map.png"];
		_mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_mapButton setImage:buttonImage
					  forState:UIControlStateNormal];
		[_mapButton setImage:[UIImage imageNamed:@"nav-route-map_down.png"]
					  forState:UIControlStateDisabled];
		[_mapButton setFrame:CGRectMake(CGRectGetMaxX(_southButton.frame), 4,
										  buttonImage.size.width, buttonImage.size.height)];
		[_mapButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_mapButton];
		
		buttonImage = [UIImage imageNamed:@"nav-bcycle.png"];
		_bcycleButton= [UIButton buttonWithType:UIButtonTypeCustom];
		[_bcycleButton setImage:buttonImage
					  forState:UIControlStateNormal];
		[_bcycleButton setImage:[UIImage imageNamed:@"nav-bcycle_down.png"]
					  forState:UIControlStateDisabled];
		[_bcycleButton setFrame:CGRectMake(CGRectGetMaxX(_mapButton.frame), 4,
										  buttonImage.size.width, buttonImage.size.height)];
		[_bcycleButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_bcycleButton];
		
		
		
		
    }
    return self;
}


- (id)initWithDefaultFrame
{
	if((self = [self initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,
											 kSelectorHeight)]))
	{
		
	}
	
	return self;
}

- (void)buttonPressed:(UIButton *)button
{
	[_activeButton setEnabled:YES];
	_activeButton = button;
	[button setEnabled:NO];
	if(button == _northButton)
	{
		[delegate nortboundWasSelected];
	}
	else if(button == _southButton)
	{
		[delegate southboundWasSelected];
	}
	else if(button == _mapButton)
	{
		[delegate mapWasSelected];
	}
	else if(button == _bcycleButton)
	{
		[delegate bcycleWasSelected];
	}
}

- (void)setToNorthbound
{
	[self buttonPressed:_northButton];
}

- (void)setToSouthbound
{
	[self buttonPressed:_southButton];
}

- (void)setToMap
{
	[self buttonPressed:_mapButton];
}

- (void)setToBcycle
{
	[self buttonPressed:_bcycleButton];
}



@end
