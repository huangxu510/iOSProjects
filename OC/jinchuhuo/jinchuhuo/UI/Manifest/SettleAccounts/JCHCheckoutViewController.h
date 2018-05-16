//
//  JCHCheckoutByCashViewController.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/1.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

typedef NS_ENUM(NSInteger, JCHCheckoutPayWay) {
    kJCHCheckoutPayWayCash,
    kJCHCheckoutPayWaySavingCard,
};

@interface JCHCheckoutViewController : JCHBaseViewController

- (instancetype)initWithPayWay:(JCHCheckoutPayWay)payWay;

@end
