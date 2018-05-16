//
//  JCHSettleAccountsViewController.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/1.
//  Copyright © 2016年 apple. All rights reserved.
//  结算

#import "JCHBaseViewController.h"
#import "ServiceFactory.h"

@interface JCHSettleAccountsViewController : JCHBaseViewController

- (instancetype)initWithPayWayShow:(BOOL)show
                  enabledButtonTags:(NSArray *)ButtonTags;

@end
