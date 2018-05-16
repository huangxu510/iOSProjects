//
//  JCHTakeoutOrderCancelViewController.h
//  jinchuhuo
//
//  Created by huangxu on 2016/12/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

@interface JCHTakeoutOrderCancelViewController : JCHBaseViewController

@property (copy, nonatomic) void(^orderCancelSuccess)(void);
- (instancetype)initWithOrderID:(NSString *)orderID resource:(NSString *)resource;

@end
