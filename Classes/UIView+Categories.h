//
//  UIView+Categories.h
//  Copyright 2010 Fluidvision Design. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (FrameConvenience)

- (void)setFrameSize:(CGSize)size;
- (void)setFrameHeight:(CGFloat)height;
- (void)setFrameWidth:(CGFloat)width;

- (void)setFrameOrigin:(CGPoint)origin;
- (void)setFrameXOrigin:(CGFloat)xOrigin;
- (void)setFrameYOrigin:(CGFloat)yOrigin;


- (void)setFrameRightBorderXValue:(CGFloat)xValue;
- (CGFloat)rightBorderXValue;
- (CGFloat)bottomBorderYValue;

- (CGRect)frameForBorderWithSize:(CGFloat)size;

- (void)centerVerticallyInSuperviewWithXOrigin:(CGFloat)xOrigin;
- (void)centerHorizontallyInSuperviewWithYOrigin:(CGFloat)yOrigin;
- (void)centerInSuperview;
- (void)centerInSuperviewWithOffset:(CGPoint)offset;

@end
