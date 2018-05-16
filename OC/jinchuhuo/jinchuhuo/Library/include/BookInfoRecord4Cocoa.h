//
//  BookInfoRecord4Cocoa.h
//  iOSInterface
//
//  Created by apple on 15/12/28.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoleRecord4Cocoa.h"

@interface BookInfoRecord4Cocoa : NSObject

@property (retain, nonatomic, readwrite) NSString *bookName;          // 账本名称
@property (retain, nonatomic, readwrite) NSString *bookAddress;       // 店铺地址
@property (retain, nonatomic, readwrite) NSString *bookType;          // 店铺类型
@property (retain, nonatomic, readwrite) NSString *bookID;            // 账本ID
@property (retain, nonatomic, readwrite) RoleRecord4Cocoa *roleRecord;// role
@property (assign, nonatomic, readwrite) BOOL enableNegativeInventory;// 是否允许负库存出货
@property (retain, nonatomic, readwrite) NSString *shopImageName;     // 店铺图片
@property (assign, nonatomic, readwrite) BOOL alertHighInventory;     // 是否启用高库存预警
@property (assign, nonatomic, readwrite) BOOL alertLowInventory;      // 是否启用低库存预警
@property (assign, nonatomic, readwrite) double highInventoryValue;   // 高库存预警值
@property (assign, nonatomic, readwrite) double lowInventoryValue;    // 低库存预警值
@property (assign, nonatomic, readwrite) NSInteger bookStatus;        // 账本状态
@property (retain, nonatomic, readwrite) NSString *telephone;         // 店铺联系电话
@property (retain, nonatomic, readwrite) NSString *announcement;      // 店铺公告
@property (retain, nonatomic, readwrite) NSString *bizHours;          // 店铺营业时间

@end
