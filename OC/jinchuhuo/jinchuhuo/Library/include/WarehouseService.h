//
//  WarehouseService.h
//  iOSInterface
//
//  Created by apple on 16/8/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WarehouseRecord4Cocoa.h"

@protocol WarehouseService <NSObject>

- (int)insertWarehouse:(WarehouseRecord4Cocoa *)record;
- (int)updateWarehouse:(WarehouseRecord4Cocoa *)record;
- (int)deleteWarehouse:(NSString *)warehouseUUID;
- (NSArray *)queryAllWarehouse;
- (WarehouseRecord4Cocoa *)queryWarehouseByUUID:(NSString *)warehouseUUID;
- (BOOL)isWarehouseCanBeDeleted:(NSString *)warehouseUUID;
- (NSString *)generateWarehouseID;

@end
