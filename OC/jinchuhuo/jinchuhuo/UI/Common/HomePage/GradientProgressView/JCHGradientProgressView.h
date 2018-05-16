//
//  JCHGradientProgressView.h
//  jinchuhuo
//
//  Created by apple on 15/8/13.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHGradientProgressView : UIView

- (id)initWithFrame:(CGRect)frame
     gradientColors:(NSArray*)gradientColors
        cycleRadius:(CGFloat)cycleRadius
         startAngle:(CGFloat)startAngle
           endAngle:(CGFloat)endAngle
          lineWidth:(CGFloat)lineWidth
    animateDuration:(CGFloat)animateDuration;
- (void)startAnimation:(CGFloat)duration;
- (void)endAnimation;

@end
