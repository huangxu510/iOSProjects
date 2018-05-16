//
//  JCHFinanceCalculateUtility.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHFinanceCalculateUtility.h"

@implementation JCHFinanceCalculateUtility

//! @brief 判断当前的小数是否为0, 与 0.000000001 比较
+ (BOOL)floatValueIsZero:(CGFloat)floatValue
{
    const double fTargetValue = 0.000000001;
    if (fabs(floatValue) <= fTargetValue) {
        return YES;
    } else {
        return NO;
    }
}

+ (JCHCompareFloatNumberResult)compareFloatNumber:(CGFloat)floatNum1 with:(CGFloat)floatNum2
{
    if ([self floatValueIsZero:(floatNum1 - floatNum2)]) {
        return kJCHCompareFloatNumberResultSame;
    } else if (floatNum1 > floatNum2) {
        return kJCHCompareFloatNumberResultGreater;
    } else {
        return kJCHCompareFloatNumberResultLess;
    }
}

/**
 *  保留两位小数  (四舍五入)
 *
 *  注: 浮点数 0.45499999999999999 通过该计算后为 0.46
 *      0.45500000001 直接 [NSString stringWithFormat:@"%.2f"]  为  @"0.45"，所以需要四舍五入为0.46
 *
 */
+ (CGFloat)roundDownFloatNumber:(CGFloat)floatNumber
{
    return [self roundDownFloatNumber:floatNumber scale:2];
}

+ (CGFloat)roundDownFloatNumber:(CGFloat)floatNumber scale:(short)scale
{
    NSDecimalNumberHandler *numberHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                                   scale:scale
                                                                                        raiseOnExactness:NO
                                                                                         raiseOnOverflow:NO
                                                                                        raiseOnUnderflow:NO
                                                                                     raiseOnDivideByZero:NO];
    
//    NSDecimalNumber *receivableAmountNumber = [[[NSDecimalNumber alloc] initWithString:[NSString stringWithFormat:@"%f", floatNumber]] autorelease];
    NSDecimalNumber *receivableAmountNumber = [[[NSDecimalNumber alloc] initWithDouble:floatNumber] autorelease];
    
    NSDecimalNumber *realReceivableAmountNumber = [receivableAmountNumber decimalNumberByRoundingAccordingToBehavior:numberHandler];
    return [realReceivableAmountNumber doubleValue];
    //return round(floatNumber * 100) / 100;
}

+ (NSString *)convertFloatAmountToString:(CGFloat)amount
{
    if (amount < 0) {
        return [NSString stringWithFormat:@"- ¥ %.2f", fabs(amount)];
    } else {
        return [NSString stringWithFormat:@"¥ %.2f", amount];
    }
}

@end
