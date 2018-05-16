//
//  JCHAdjustBalanceViewController.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/23.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

@interface JCHAdjustBalanceViewController : JCHBaseViewController

@property (nonatomic, copy) void(^needReloadDataBlock)(BOOL needReloadData);
- (instancetype)initWithAccountUUID:(NSString *)accountUUID
               currentBalanceAmount:(CGFloat)currentBalanceAmount;

@end
