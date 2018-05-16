//
//  JCHUISettings.h
//  jinchuhuo
//
//  Created by apple on 15/8/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#ifndef jinchuhuo_JCHUISettings_h
#define jinchuhuo_JCHUISettings_h


#import <Availability.h>
#import "JCHCurrentDevice.h"
#import "UIFont+JCHFont.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#ifdef __OBJC__
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#endif

#define kStatusBarHeight 20.0f
#define kNavigatorBarHeight  44.0f
#define kTabBarHeight 49.0f

#define HighlightedAlphaValue  0.25f

//
#define kSeparateLineWidth (iPhone6Plus ? 0.6666667 : 0.5)
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kHeight self.frame.size.height
#define kWidth self.frame.size.width

#define kStandardLeftMargin 14
#define kStandardRightMargin 14
#define kStandardTopMargin 20
#define kStandardItemHeight 44
#define kStandardSeparateViewHeight 20
#define kStandardButtonHeight 50
#define kStandardDatePickerViewHeight 216
#define kMaxSaveStringLength 32

#ifndef kSizeScaleFrom5S
#define kSizeScaleFrom5S (750.0 / 640)
#endif

// Colors
#define JCHColorHeaderBackground UIColorFromRGB(0xdd4041)
#define JCHColorGlobalBackground UIColorFromRGB(0xf3f3f3)

#define JCHColorMainBody UIColorFromRGB(0x4a4a4a)
#define JCHColorAuxiliary UIColorFromRGB(0xa4a4a4)
#define JCHColorSeparateLine UIColorFromRGB(0xdedede)
#define JCHColorBorder UIColorFromRGB(0xd5d5d5)
#define JCHColorPriceText UIColorFromRGB(0xdd4041)
#define JCHColorSpecialReminder UIColorFromRGB(0x008aff)
#define JCHColorSelectedBackground UIColorFromRGB(0xeeeeee)
#define JCHColorBlueButton UIColorFromRGB(0x69a4f1)
#define JCHColorDisableButton UIColorFromRGB(0xd5d5d5)
#define JCHColorRedButtonHeighlighted UIColorFromRGB(0xcc3b3c)

#define FontRoundedNumber       @"ArialRoundedMTBold"
#define FontLightNumber @"Helvetica"
#define FontHeitiMedium @"STHeitiSC-Medium"
#define FontHeitiLight @"STHeitiSC-Light"

#define DrawFrame(ViewObject, CGColor)   ViewObject.layer.borderColor = CGColor; \
ViewObject.layer.borderWidth = 1.0f


//Font
#define JCHFontStandard [UIFont jchSystemFontOfSize:16.0f]
#define JCHFont(fontSize) [UIFont jchSystemFontOfSize:fontSize]


#ifndef kDefaultCameraButtonImageName
#define kDefaultCameraButtonImageName @"default_img_setting_goods"
#endif

#endif
