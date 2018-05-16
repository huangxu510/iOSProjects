//
//  WarehouseRecord4Cocoa.h
//  iOSInterface
//
//  Created by apple on 16/8/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WarehouseRecord4Cocoa : NSObject

@property (retain, nonatomic, readwrite) NSString *warehouseID;           // 仓库ID
@property (retain, nonatomic, readwrite) NSString *warehouseName;         // 仓库名称
@property (retain, nonatomic, readwrite) NSString *warehouseAddr;         // 仓库地址
@property (retain, nonatomic, readwrite) NSString *contactUUID;           // 仓库负责人UUID
@property (retain, nonatomic, readwrite) NSString *warehouseRemarks;      // 仓库备注
@property (assign, nonatomic, readwrite) int warehouseStatus;             // 仓库状态

@end
