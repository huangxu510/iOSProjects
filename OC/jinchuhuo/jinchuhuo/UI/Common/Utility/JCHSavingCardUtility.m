//
//  JCHSavingCardUtility.m
//  jinchuhuo
//
//  Created by huangxu on 16/5/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSavingCardUtility.h"

@implementation JCHSavingCardUtility

//! @brief  折扣string转换为float   98 -> 0.98   1 -> 0.1
+ (CGFloat)switchToDiscountFloatValue:(NSString *)discount
{
    if ([discount isEqualToString:@""]) {
        return 1.0;
    } else {
        if (discount.length == 1) {
            return [discount doubleValue] / 10;
        } else if (discount.length == 2) {
            return [discount doubleValue] / 100;
        } else {
            NSLog(@"==========  discount length error! =========");
            return 1.0;
        }
    }
}

//! @brief 折扣float转换为string   0.98 -> 98    0.1 -> 1
+ (NSString *)switchToDiscountStringValue:(CGFloat)discount
{
    if (discount == 1) {
        return @"";
    } else if ((NSInteger)(discount * 100) % 10 == 0){
        return [NSString stringWithFormat:@"%ld", (long)(discount * 10)];
    } else {
        return [NSString stringWithFormat:@"%ld", (long)(discount * 100)];
    }
}

+ (NSString *)switchToAmountStringValue:(CGFloat)floatAmount
{
    if (floatAmount == -1 || floatAmount == kSavingCardAmountUpperMax) {
        return @"";
    }  else {
        return [NSString stringWithFormat:@"%.0f", floatAmount];
    }
}

+ (CGFloat)switchToAmountFloatValue:(NSString *)stringAmount
{
    if ([stringAmount isEqualToString:@""] || stringAmount == nil) {
        return -1;
    } else {
        return [stringAmount doubleValue];
    }
}

@end
