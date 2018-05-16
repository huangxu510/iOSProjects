//
//  LargeDatabaseSyncService.h
//  iOSInterface
//
//  Created by apple on 16/8/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LargeDatabaseSyncService <NSObject>

//! @brief 同步服务器 - pull
- (void)pullCommand:(PullCommandRequest *)request responseNotification:(NSString *)responseNotification;


//! @brief 同步服务器 - push
- (void)pushCommand:(PushCommandRequest *)request responseNotification:(NSString *)responseNotification;


//! @brief 同步服务器 - connect
- (void)connectCommand:(ConnectCommandRequest *)request responseNotification:(NSString *)responseNotification;


#pragma mark -
#pragma mark 在线升级相关

//! @brief 获取账本控制权 - bookControl
- (void)controlBookCommand:(ControlCommandRequest *)request responseNotification:(NSString *)responseNotification;

//! @brief 释放账本控制权 - bookRelease
- (void)releaseBookCommand:(ControlCommandRequest *)request responseNotification:(NSString *)responseNotification;

//! @brief 同步服务器 - pullColumn
- (void)onlineUpgradePullColumnCommand:(PullCommandRequest *)request responseNotification:(NSString *)responseNotification;

//! @brief 同步服务器 - pushColumn
- (void)onlineUpgradePushColumnCommand:(PushCommandRequest *)request responseNotification:(NSString *)responseNotification;

@end
