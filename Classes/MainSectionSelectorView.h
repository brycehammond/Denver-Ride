//
//  MainSectionSelectorView.h
//  RTD
//
//  Created by bryce.hammond on 9/6/10.
//  Copyright 2010 Fluidvision Design. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MainSectionSelectorViewDelegate

- (void)nortboundWasSelected;
- (void)southboundWasSelected;
- (void)mapWasSelected;
- (void)bcycleWasSelected;

@end


@interface MainSectionSelectorView : UIView 
{
	UIButton *_northButton;
	UIButton *_southButton;
	UIButton *_mapButton;
	UIButton *_bcycleButton;
	
	UIButton *_activeButton; //weak
	
	NSObject<MainSectionSelectorViewDelegate> *delegate;
}

@property (assign) NSObject<MainSectionSelectorViewDelegate> *delegate;

- (id)initWithDefaultFrame;

- (void)setToNorthbound;
- (void)setToSouthbound;
- (void)setToMap;
- (void)setToBcycle;

@end
