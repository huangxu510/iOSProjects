//
//  JCHSizeOfViewUtility.h
//  jinchuhuo
//
//  Created by huangxu on 15/8/26.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JCHSizeUtility.h"

#define kStandardWidthOffset            [JCHSizeUtility calculateWidthWithSourceWidth:10.0f]
#define kStandardHeightOffsetWithTabBar [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:10.0f]
#define kStandardHeightOffsetNoTabBar   [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:10.0f]


enum ScreenSize
{
    kMockValue
};

@interface JCHSizeUtility : NSObject


+ (CGFloat)calculateHeightWithNavigationBar:(BOOL)hasNavigationBar
                                     TabBar:(BOOL)hasTabBar
                               sourceHeight:(CGFloat)sourceHeight;
+ (CGFloat)calculateHeightWithNavigationBar:(BOOL)hasNavigationBar
                                     TabBar:(BOOL)hasTabBar
                               sourceHeight:(CGFloat)sourceHeight
                        noStretchingIn6Plus:(BOOL)noStretchingIn6Plus;
+ (CGFloat)calculateWidthWithSourceWidth:(CGFloat)sourceWidth;
+ (CGFloat)calculateFontSizeWithSourceSize:(CGFloat)sourceSize;

+ (CGFloat)calculateHeightFor4SAndOther:(CGFloat)sourceHeight;

+ (BOOL)viewIsCoveredByKeyboard:(CGRect)viewFrame KeyboardHeight:(CGFloat)keyboardHeight;

@end
