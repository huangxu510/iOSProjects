//
//  BKCalculatorUtility.h
//  BookKeeping123
//
//  Created by huangxu on 2018/5/16.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RepaymentWay) {
    kRepaymentWay1, // 等额本息
    kRepaymentWay2, // 等额本金
};

@interface BKCalculatorUtility : NSObject

+ (CGFloat)calculateMonthInterest:(CGFloat)capital months:(NSInteger)months rate:(CGFloat)rate way:(RepaymentWay)repaymentWay;

@end
