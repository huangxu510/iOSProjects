//
//  JCHSavingCardUtility.h
//  jinchuhuo
//
//  Created by huangxu on 16/5/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef kSavingCardAmountUpperMax
#define kSavingCardAmountUpperMax 10000000
#endif

@interface JCHSavingCardUtility : NSObject

//! @brief  折扣string转换为float   98 -> 0.98   1 -> 0.1
+ (CGFloat)switchToDiscountFloatValue:(NSString *)discount;

//! @brief 折扣float转换为string   0.98 -> 98    0.1 -> 1
+ (NSString *)switchToDiscountStringValue:(CGFloat)discount;

//! @brief 储值卡金额 float 转换为 string
+ (NSString *)switchToAmountStringValue:(CGFloat)floatAmount;

//! @brief 储值卡金额 string 转 float
+ (CGFloat)switchToAmountFloatValue:(NSString *)stringAmount;
@end
