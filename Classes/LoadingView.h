//
//  LoadingView.h
//  RTD
//
//  Created by bryce.hammond on 8/16/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoadingView : UIView {
	UILabel *_loadingTextLabel;
	UIActivityIndicatorView *_activityIndicator;
}

-(void)setMessage:(NSString *)message;

@end
