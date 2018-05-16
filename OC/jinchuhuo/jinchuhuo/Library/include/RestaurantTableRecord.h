//
//  RestaurantTableRecord.h
//  iOSInterface
//
//  Created by apple on 2017/1/6.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ManifestRecord4Cocoa;

//! @brief 餐饮版 -- 开台接口
@interface RestaurantLockTableRequest : NSObject

@property (retain, nonatomic, readwrite) NSString *accountBookID;           // 账本ID
@property (retain, nonatomic, readwrite) NSString *tableID;                 // 餐桌id
@property (assign, nonatomic, readwrite) NSInteger numberOfPerson;          // 就餐人数
@property (retain, nonatomic, readwrite) NSString *orderID;                 // 货单号（选填）
@property (assign, nonatomic, readwrite) NSInteger operatorID;              // 操作员userID(选填)
@property (retain, nonatomic, readwrite) NSString *serviceURL;              // service url

@end

//! @brief 餐饮版 -- 撤台接口
@interface RestaurantReleaseTable : NSObject

@property (retain, nonatomic, readwrite) NSString *accountBookID;           // 账本ID
@property (retain, nonatomic, readwrite) NSString *tableID;                 // 餐桌id
@property (assign, nonatomic, readwrite) NSInteger operatorID;              // 操作员userID(选填)
@property (retain, nonatomic, readwrite) NSString *serviceURL;              // service url

@end

//! @brief 餐饮版 -- 下单接口
@interface RestaurantPreInsertManifest : NSObject

@property (retain, nonatomic, readwrite) NSString *accountBookID;           // 账本ID
@property (retain, nonatomic, readwrite) NSString *tableID;                 // 餐桌id
@property (retain, nonatomic, readwrite) NSString *tableName;               // 餐桌名
@property (assign, nonatomic, readwrite) NSInteger operatorID;              // 操作员userID(选填)
@property (retain, nonatomic, readwrite) ManifestRecord4Cocoa * manifest;   // 货单
@property (retain, nonatomic, readwrite) NSArray *oldTransactionList;       // 改单前的流水
@property (retain, nonatomic, readwrite) NSString *serviceURL;              // service url

@end

//! @brief 餐饮版 -- 换台接口
@interface RestaurantChangeTable : NSObject

@property (retain, nonatomic, readwrite) NSString *accountBookID;           // 账本ID
@property (retain, nonatomic, readwrite) NSString *oldTableID;              // 旧餐桌id
@property (retain, nonatomic, readwrite) NSString *tableID;                 // 新餐桌id
@property (retain, nonatomic, readwrite) NSString *manifestID;              // 货单ID
@property (assign, nonatomic, readwrite) NSInteger operatorID;              // 操作员userID(选填)
@property (retain, nonatomic, readwrite) NSString *serviceURL;              // service url

@end

