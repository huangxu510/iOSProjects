//
//  JCHColorSettings.h
//  jinchuhuo
//
//  Created by huangxu on 15/8/31.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#ifndef jinchuhuo_JCHColorSettings_h
#define jinchuhuo_JCHColorSettings_h

#import <Availability.h>


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define RGBColor(r,g,b,alp) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(alp)]

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#endif

#if 0
// Colors
#define JCHColorHeaderBackground UIColorFromRGB(0xdd4041)
#define JCHColorGlobalBackground UIColorFromRGB(0xf3f3f3)

#define JCHColorRedButton UIColorFromRGB(0xff7e65)
#define JCHColorBlueButton UIColorFromRGB(0x6cbfff)

#define JCHColorMainBody UIColorFromRGB(0x4a4a4a)
#define JCHColorAuxiliary UIColorFromRGB(0xa4a4a4)
#define JCHColorSeparateLine UIColorFromRGB(0xdedede)
#define JCHColorPriceText UIColorFromRGB(0xe85e5e)
#define JCHColorSpecialReminder UIColorFromRGB(0x008aff)
#define JCHColorSelectedBackground UIColorFromRGB(0xeeeeee)

#endif

#endif
