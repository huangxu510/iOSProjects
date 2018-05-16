//
//  JCHFinanceCalculateUtility.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JCHCompareFloatNumberResult)
{
    kJCHCompareFloatNumberResultGreater,
    kJCHCompareFloatNumberResultLess,
    kJCHCompareFloatNumberResultSame,
};

@interface JCHFinanceCalculateUtility : NSObject

+ (BOOL)floatValueIsZero:(CGFloat)floatValue;

//! @brief 浮点数之间比较用
+ (JCHCompareFloatNumberResult)compareFloatNumber:(CGFloat)floatNum1 with:(CGFloat)floatNum2;

//! @brief 保留两位小数  (四舍五入)
+ (CGFloat)roundDownFloatNumber:(CGFloat)floatNumber;

//! @brief 保留scale位小数
+ (CGFloat)roundDownFloatNumber:(CGFloat)floatNumber scale:(short)scale;

+ (NSString *)convertFloatAmountToString:(CGFloat)amount;

@end
