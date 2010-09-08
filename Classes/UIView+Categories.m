//
//  UIView+Categories.m
//
//  Copyright 2010 Fluidvision Design. All rights reserved.
//

#import "UIView+Categories.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (FrameConvenience)

- (void)setFrameOrigin:(CGPoint)origin
{
	CGRect viewFrame = [self frame];
	viewFrame.origin = origin;
	[self setFrame:viewFrame];
}

- (void)setFrameXOrigin:(CGFloat)xOrigin {
    CGRect viewFrame = [self frame];
    viewFrame.origin.x = xOrigin;
    [self setFrame:viewFrame];
}

- (void)setFrameYOrigin:(CGFloat)yOrigin {
    CGRect viewFrame = [self frame];
    viewFrame.origin.y = yOrigin;
    [self setFrame:viewFrame];
}

- (void)setFrameSize:(CGSize)size
{
	CGRect viewFrame = [self frame];
	viewFrame.size = size;
	[self setFrame:viewFrame];
}

- (void)setFrameHeight:(CGFloat)height {
    CGRect viewFrame = [self frame];
    viewFrame.size.height = height;
    [self setFrame:viewFrame];
}

- (void)setFrameWidth:(CGFloat)width {
    CGRect viewFrame = [self frame];
    viewFrame.size.width = width;
    [self setFrame:viewFrame];
}

- (void)setFrameRightBorderXValue:(CGFloat)xValue {
    CGRect viewFrame = [self frame];
    viewFrame.origin.x = xValue - viewFrame.size.width;
    [self setFrame:viewFrame];
}

- (CGFloat)rightBorderXValue {
    CGFloat xOrigin = [self frame].origin.x;
    CGFloat width = [self frame].size.width;
    return (xOrigin + width);
}

- (CGFloat)bottomBorderYValue {
    CGFloat yOrigin = [self frame].origin.y;
    CGFloat height = [self frame].size.height;
    return (yOrigin + height);
}

- (CGRect)frameForBorderWithSize:(CGFloat)size {
    CGFloat x = [self frame].origin.x - size;
    CGFloat y = [self frame].origin.y - size;
    CGFloat width = [self frame].size.width + (size * 2);
    CGFloat height =  [self frame].size.height + (size * 2);
    return CGRectMake(x, y, width, height);
}

- (void)centerVerticallyInSuperviewWithXOrigin:(CGFloat)xOrigin
{
    if(nil == [self superview])
    {
        return;
    }
    
    CGRect superviewBounds = [[self superview] bounds];
    CGRect selfFrame = [self frame];
    selfFrame.origin.x = xOrigin;
    selfFrame.origin.y = floor((superviewBounds.size.height - selfFrame.size.height)/2);
    [self setFrame:selfFrame];
}
- (void)centerHorizontallyInSuperviewWithYOrigin:(CGFloat)yOrigin
{
    if(nil == [self superview])
    {
        return;
    }
    
    CGRect superviewBounds = [[self superview] bounds];
    CGRect selfFrame = [self frame];
    selfFrame.origin.x = floor((superviewBounds.size.width - selfFrame.size.width)/2);
    selfFrame.origin.y = yOrigin;
    [self setFrame:selfFrame];
}

- (void)centerInSuperview
{
    if(nil == [self superview])
    {
        return;
    }
    
    CGRect superviewBounds = [[self superview] bounds];
    CGRect selfFrame = [self frame];
    selfFrame.origin.x = floor((superviewBounds.size.width - selfFrame.size.width)/2);
    selfFrame.origin.y = floor((superviewBounds.size.height - selfFrame.size.height)/2);
    [self setFrame:selfFrame];
}

- (void)centerInSuperviewWithOffset:(CGPoint)offset
{
    if(nil == [self superview])
    {
        return;
    }
    CGRect superviewBounds = [[self superview] bounds];
    CGRect selfFrame = [self frame];
    selfFrame.origin.x = floor((superviewBounds.size.width - selfFrame.size.width)/2) + offset.x;
    selfFrame.origin.y = floor((superviewBounds.size.height - selfFrame.size.height)/2) + offset.y;
    [self setFrame:selfFrame];
}

@end

