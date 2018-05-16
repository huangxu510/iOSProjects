//
//  JCHTakeoutShopStatusSetViewController.h
//  jinchuhuo
//
//  Created by huangxu on 2016/12/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

@interface JCHTakeoutShopStatusSetViewController : JCHBaseViewController

@property (copy, nonatomic) void(^shopStatusChangeBlock)(BOOL status);

@end
