//
//  BKCalculatorUtility.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/16.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKCalculatorUtility.h"

@implementation BKCalculatorUtility

+ (CGFloat)calculateMonthInterest:(CGFloat)capital months:(NSInteger)months rate:(CGFloat)rate way:(RepaymentWay)repaymentWay
{
    CGFloat monthInterest = 0.0;
    if (repaymentWay == kRepaymentWay1) {
        monthInterest = capital * rate * powf(1 + rate, months) / (powf(1 + rate, months) - 1) - capital;
    } else if (repaymentWay == kRepaymentWay2) {

        monthInterest = (months + 1) * capital * rate / 2 / months;
    }
    return monthInterest;
}

@end
