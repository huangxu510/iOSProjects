//
//  DiningTableService.h
//  iOSInterface
//
//  Created by apple on 2016/12/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DiningTableRecord4Cocoa.h"

@protocol DiningTableService <NSObject>

//! @brief 添加餐桌区域
- (int)addOrUpdateTableRegion:(TableRegionRecord4Cocoa *)record;

//! @brief 删除餐桌区域
- (int)deleteTableRegion:(long long )tableRegionID;

//! @brief 查询餐桌区域
- (NSArray *)queryTableRegion;

//! @brief 添加餐桌类型
- (int)addOrUpdateTableType:(TableTypeRecord4Cocoa*)record;

//! @brief 删除餐桌类型
- (int)deleteTableType:(long long)tableTypeID;

//! @brief 查询餐桌类型
- (NSArray *)queryTableType;

- (int)addDiningTable:(DiningTableRecord4Cocoa *)record;

- (int)updateDiningTable:(DiningTableRecord4Cocoa *)record;

- (int)deleteDiningTable:(long long)diningTableID;

- (NSArray *)queryDiningTable;

- (DiningTableRecord4Cocoa *)qeryDiningTable:(long long)llDiningTableID;

@end
