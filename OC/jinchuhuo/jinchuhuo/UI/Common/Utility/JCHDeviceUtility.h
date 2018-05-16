//
//  JCHDeviceUtility.h
//  jinchuhuo
//
//  Created by huangxu on 15/9/14.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCHDeviceUtility : NSObject

//!@brief 获取设备型号
+ (NSString *)getDeviceString;

//!@brief 获取网络类型
+ (NSString *)getNetWorkStates;

@end
