//
//  LoadingView.m
//  RTD
//
//  Created by bryce.hammond on 8/16/09.
//  Copyright 2009 Wall Street On Demand, Inc.. All rights reserved.
//

#import "LoadingView.h"


@implementation LoadingView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self setBackgroundColor:[UIColor colorWithWhite:0.750 alpha:0.80]];
		
		
		CGRect frame = [self frame];
		_loadingTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, round(frame.size.height / 2)-40, 320, 24)];
		
		[_loadingTextLabel setTextAlignment:UITextAlignmentCenter];
		[_loadingTextLabel setBackgroundColor:[UIColor clearColor]];
		[_loadingTextLabel setText:@"Loading"];
		[_loadingTextLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
		[_loadingTextLabel setTextColor:[UIColor whiteColor]];
		[self addSubview:_loadingTextLabel];
		
		_activityIndicator = [[UIActivityIndicatorView alloc] 
													   initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		CGPoint center = [_loadingTextLabel center];
		center.y -= 30;
		[_activityIndicator setCenter:center];
		[self addSubview:_activityIndicator];
		[_activityIndicator startAnimating];
		
    }
    return self;
}


- (void)drawRect:(CGRect)rect {

}

-(void)setMessage:(NSString *)message
{
	[_loadingTextLabel setText:message];
	[self setNeedsDisplay];
}

- (void)dealloc {
	[_loadingTextLabel release];
    [super dealloc];
}


@end
