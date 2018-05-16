//
//  JCHSizeOfViewUtility.m
//  jinchuhuo
//
//  Created by huangxu on 15/8/26.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHSizeUtility.h"
#import "JCHUISettings.h"



@implementation JCHSizeUtility

+ (CGFloat)calculateHeightWithNavigationBar:(BOOL)hasNavigationBar TabBar:(BOOL)hasTabBar sourceHeight:(CGFloat)sourceHeight
{
    if (hasNavigationBar && hasTabBar) {
       
        return sourceHeight / (667 - 64 - 49) * (kScreenHeight - 64 - 49);
    }
    else if (hasNavigationBar && !hasTabBar)
    {
        return sourceHeight / (667 - 64) * (kScreenHeight - 64);
    }
    else if (!hasNavigationBar && hasTabBar)
    {
        return sourceHeight / (667 - 49) * (kScreenHeight - 49);
    }
    return  sourceHeight / 667 * kScreenHeight;
}

+ (CGFloat)calculateHeightWithNavigationBar:(BOOL)hasNavigationBar
                                     TabBar:(BOOL)hasTabBar
                               sourceHeight:(CGFloat)sourceHeight
                        noStretchingIn6Plus:(BOOL)noStretchingIn6Plus
{
    if (noStretchingIn6Plus) {
        if (iPhone6Plus) {
            return sourceHeight;
        } else {
            return [self calculateHeightWithNavigationBar:hasNavigationBar TabBar:hasTabBar sourceHeight:sourceHeight];
        }
    } else {
        return [self calculateHeightWithNavigationBar:hasNavigationBar TabBar:hasTabBar sourceHeight:sourceHeight];
    }
}

+ (CGFloat)calculateWidthWithSourceWidth:(CGFloat)sourceWidth
{
    return sourceWidth / 375 * kScreenWidth;
}

+ (CGFloat)calculateFontSizeWithSourceSize:(CGFloat)sourceSize
{
    if (iPhone6 || iPhone6Plus) {
        return sourceSize;
    }
    else
    {
        return sourceSize / 375 * kScreenWidth;
    }
}

+ (CGFloat)calculateHeightFor4SAndOther:(CGFloat)sourceHeight
{
    if (iPhone4) {
        return sourceHeight / (667 - 64) * (kScreenHeight - 64);;
    }
    else {
        return sourceHeight;
    }
}

+ (BOOL)viewIsCoveredByKeyboard:(CGRect)viewFrame KeyboardHeight:(CGFloat)keyboardHeight
{
    if (kScreenHeight - 64 - CGRectGetMaxY(viewFrame) < keyboardHeight)
    {
        return YES;
    }
    return NO;
}

@end
