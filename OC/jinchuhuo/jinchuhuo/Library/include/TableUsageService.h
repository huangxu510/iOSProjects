//
//  TableUsageService.h
//  iOSInterface
//
//  Created by apple on 2016/12/30.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableUsageRecord4Cocoa.h"

@protocol TableUsageService <NSObject>

//! @brief 尝试开台，开台后此餐桌进入锁定状态
- (int)tryLockTable:(TableUsageRecord4Cocoa *)record;

//! @brief 餐桌与货单ID绑定
- (int)bindOrderID:(long long)tableID orderID:(NSString *)orderID;

//! @brief 餐桌恢复可用
- (int)releaseTableByTableID:(long long)tableID;

//! @brief 餐桌恢复可用
- (int)releaseTableByOrderID:(NSString *)orderID;

//! @brief 换桌
- (int)changeTableFrom:(long long)fromTableID toTableID:(long long)toTableID;

//! @brief 查询当前的开台记录
- (NSArray *)queryCurrentTableUsage;

//! @brief 查询指定货单的开台记录，如果货单列表为空，则返回当前开台记录
- (NSArray *)queryTableUsage:(NSArray *)manifestIDList;

//! @brief 餐桌是否可用
- (bool)isTableAvailable:(long long)tableID;

@end
