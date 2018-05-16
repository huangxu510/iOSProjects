//
//  JCHPerformanceTestManager.m
//  jinchuhuo
//
//  Created by huangxu on 16/7/7.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHPerformanceTestManager.h"

@implementation JCHPerformanceTestManager

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static JCHPerformanceTestManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[JCHPerformanceTestManager alloc] init];
    });
    return manager;
}

@end
