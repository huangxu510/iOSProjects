//
//  UIView+JCHView.h
//  jinchuhuo
//
//  Created by huangxu on 15/11/11.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (JCHView)

- (void)addSeparateLineWithFrameTop:(BOOL)top bottom:(BOOL)bottom;
- (void)addSeparateLineWithMasonryTop:(BOOL)top bottom:(BOOL)bottom;
- (void)addSeparateLineWithMasonryLeft:(BOOL)left right:(BOOL)right;
/**
 *  设置部分圆角
 *
 *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radii   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 *  @param rect    需要设置的圆角view的rect
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                withRadii:(CGSize)radii
                 viewRect:(CGRect)rect;

//添加边框
- (void)addBorderLine;

@end
