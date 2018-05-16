//
//  JCHChargeAccountViewController.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

typedef NS_ENUM(NSInteger, JCHChargeAccountType)
{
    kJCHChargeAccountReceipt = 1,
    kJCHChargeAccountPayment,
};

@interface JCHChargeAccountViewController : JCHBaseViewController

- (instancetype)initWithChargeAccountType:(JCHChargeAccountType)chargeAccountType;

@end
