//
//  UIView+JCHView.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/11.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "UIView+JCHView.h"
#import "JCHUISettings.h"
#import "JCHColorSettings.h"
#import <Masonry.h>

@implementation UIView (JCHView)

- (void)addSeparateLineWithFrameTop:(BOOL)top bottom:(BOOL)bottom
{
    if (top) {
        UIView *seprateLine = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), kSeparateLineWidth)] autorelease];
        seprateLine.backgroundColor = JCHColorSeparateLine;
        [self addSubview:seprateLine];
    }
    if (bottom) {
        UIView *seprateLine = [[[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - kSeparateLineWidth, kScreenWidth, kSeparateLineWidth)] autorelease];
        seprateLine.backgroundColor = JCHColorSeparateLine;
        [self addSubview:seprateLine];
    }
}

- (void)addSeparateLineWithMasonryTop:(BOOL)top bottom:(BOOL)bottom
{
    if (top) {
        UIView *seprateLine = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), kSeparateLineWidth)] autorelease];
        seprateLine.backgroundColor = JCHColorSeparateLine;
        [self addSubview:seprateLine];
        
        [seprateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.top.equalTo(self);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }
    if (bottom) {
        UIView *seprateLine = [[[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - kSeparateLineWidth, kScreenWidth, kSeparateLineWidth)] autorelease];
        seprateLine.backgroundColor = JCHColorSeparateLine;
        [self addSubview:seprateLine];
        
        [seprateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }
}

- (void)addSeparateLineWithMasonryLeft:(BOOL)left right:(BOOL)right
{
    if (left) {
        UIView *seprateLine = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        seprateLine.backgroundColor = JCHColorSeparateLine;
        [self addSubview:seprateLine];
        
        [seprateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.width.mas_equalTo(kSeparateLineWidth);
            make.top.bottom.equalTo(self);
        }];
    }
    if (right) {
        UIView *seprateLine = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        seprateLine.backgroundColor = JCHColorSeparateLine;
        [self addSubview:seprateLine];
        
        [seprateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self);
            make.width.mas_equalTo(kSeparateLineWidth);
            make.top.bottom.equalTo(self);
        }];
    }
}

/**
 *  设置部分圆角
 *
 *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radii   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 *  @param rect    需要设置的圆角view的rect
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                withRadii:(CGSize)radii
                 viewRect:(CGRect)rect
{
    
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:radii];
    CAShapeLayer* shape = [[[CAShapeLayer alloc] init] autorelease];
    [shape setPath:rounded.CGPath];
    
    self.layer.mask = shape;
}

- (void)addBorderLine
{
    self.layer.borderColor = JCHColorSeparateLine.CGColor;
    self.layer.borderWidth = kSeparateLineWidth;
}

@end
