//
//  LoadingView.m
//  RTD
//
//  Created by bryce.hammond on 8/16/09.
//  Copyright 2009 Fluidvision Design. All rights reserved.
//

#import "LoadingView.h"


@implementation LoadingView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self setBackgroundColor:[UIColor colorFromHex:kBackgroundColor withAlpha:0.8]];
		
		
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
		
		_progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		_progressView.frame = CGRectMake(41.0, 213.0, 237.0, 9.0);
		_progressView.progress = 0;
		_progressView.progressViewStyle = UIProgressViewStyleDefault;
        [_progressView setHidden:YES];
		[self addSubview:_progressView];

    }
    return self;
}


-(void)setMessage:(NSString *)message
{
	[_loadingTextLabel setText:message];
}

- (void)setDownloadProgress:(double)progress
{
    if(progress > 0)
    {
        [_progressView setHidden:NO];
    }
	[_progressView setProgress:progress];
}

- (void)dealloc {
	[_loadingTextLabel release];
	[_activityIndicator release];
	[_progressView release];
    [super dealloc];
}


@end
