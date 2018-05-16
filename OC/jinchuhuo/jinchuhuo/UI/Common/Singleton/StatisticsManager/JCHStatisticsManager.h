//
//  JCHStatisticsManager.h
//  jinchuhuo
//
//  Created by apple on 2016/11/7.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCHStatisticsManager : NSObject

+ (id)sharedInstance;

//! @brief 用户登录统计信息
- (void)loginStatistics;

//! @brief 新建店铺统计信息
- (void)createShopStatistics;

//! @brief 手动同步统计信息
- (void)manualDataSyncStatistics;

//! @brief 自动同步统计信息
- (void)autoDataSyncStatistics;

//! @brief 上传统计信息，可自定义统计模块名称
- (void)uploadStatistics:(NSString *)appModule;

@end
