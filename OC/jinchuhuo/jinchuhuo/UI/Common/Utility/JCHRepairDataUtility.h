//
//  JCHRepairDataUtility.h
//  jinchuhuo
//
//  Created by huangxu on 16/10/17.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

//修复数据工具类
@interface JCHRepairDataUtility : NSObject

//!@brief 对权限的关系进行检查并修复
+ (void)checkAndRepairPermission;

@end
