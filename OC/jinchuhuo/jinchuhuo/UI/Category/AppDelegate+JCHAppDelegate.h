//
//  AppDelegate+JCHAppDelegate.h
//  jinchuhuo
//
//  Created by huangxu on 16/4/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (JCHAppDelegate)

@property (assign, nonatomic, readwrite) NSInteger autoSyncPushInterval;
@property (assign, nonatomic, readwrite) NSInteger autoSyncPullInterval;

- (void)startAutoSyncTimer;
- (void)stopAutoSyncTimer;

//! @brief 清除tabbar上每个页面的数据
- (void)clearDataOnTabbar;

//! @brief 选择店铺进入
- (void)switchToSelectedAccountBook:(NSString *)selectedAccountBookID
              currentViewController:(UIViewController *)currentViewController
                         completion:(void(^)(void))completion;

//跳转页面
- (void)switchToHomePage:(UIViewController *)currentViewController
              completion:(void(^)(void))completion;

@end
