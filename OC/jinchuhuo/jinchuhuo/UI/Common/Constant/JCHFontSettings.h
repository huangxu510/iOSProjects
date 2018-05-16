//
//  JCHFontSettings.h
//  jinchuhuo
//
//  Created by huangxu on 15/8/31.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#ifndef jinchuhuo_JCHFontSettings_h
#define jinchuhuo_JCHFontSettings_h


#import <Availability.h>


#define FontSizeFromPixel_iPhone6P(pixelValue) ((pielVaue) / 3)
#define FontSizeFromPixel_iPhone6(pixelValue)  ((pielVaue) / 2)


#ifdef __OBJC__
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#endif

#define JCHNavButtonTitle_iPhone6P FontSizeFromPixel_iPhone6P(60)
#define JCHBigButtonTitle_iPhone6P FontSizeFromPixel_iPhone6P(50)
#define JCHSmallButtonTitle_iPhone6P FontSizeFromPixel_iPhone6P(46)
#define JCHMainBodyNormal_iPhone6P FontSizeFromPixel_iPhone6P(46)
#define JCHMainBodyProtrude_iPhone6P FontSizeFromPixel_iPhone6P(54)
#define JCHMainBodyCommentary_iPhone6P FontSizeFromPixel_iPhone6P(40)
#define JCHMainMinFontSize_iPhone6P FontSizeFromPixel_iPhone6P(36)

#define JCHNavButtonTitle_iPhone6 FontSizeFromPixel_iPhone6P(60)
#define JCHBigButtonTitle_iPhone6 FontSizeFromPixel_iPhone6P(50)
#define JCHSmallButtonTitle_iPhone6 FontSizeFromPixel_iPhone6P(46)
#define JCHMainBodyNormal_iPhone6 FontSizeFromPixel_iPhone6P(46)
#define JCHMainBodyProtrude_iPhone6 FontSizeFromPixel_iPhone6P(54)
#define JCHMainBodyCommentary_iPhone6 FontSizeFromPixel_iPhone6P(40)
#define JCHMainMinFontSize_iPhone6 FontSizeFromPixel_iPhone6P(36)

#endif

