//
//  DatabaseUpgradeService.h
//  iOSInterface
//
//  Created by apple on 15/10/20.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DatabaseUpgradeService <NSObject>

//! @brief 升级数据库
- (NSInteger)upgradeDatabase;

//! @brief 升级内置数据
- (NSInteger)upgradeBuiltinData:(NSInteger)fromVersion;

//! @brief 同步后修复数据库数据
- (NSInteger)fixupDataAfterSync;

//! @brief 判断当前数据库是否需要在线升级
- (BOOL)isNeedOnlineUpgrade;

//! @brief 判断数据库是否需要升级
- (BOOL)isNeedUpgrade;

//! @brief 是否需要加锁的方式来进行升级
- (BOOL)isNeedLockToUpgrade;

//! @brief 获取当前数据库版本号
- (NSInteger)getCurrentDatabaseVersion;

//! @brief 准备上传数据
- (NSInteger)preparePushColumnData:(NSString *)databaseFilePath;

@end
