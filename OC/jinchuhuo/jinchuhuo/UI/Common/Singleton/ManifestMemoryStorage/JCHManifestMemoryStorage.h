//
//  JCHManifestMemoryStorage.h
//  jinchuhuo
//
//  Created by apple on 15/9/8.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JCHAddProductMainViewController.h"
#import "JCHManifestType.h"
#import "ServiceFactory.h"
#import "JCHManifestInventoryCheckMemory.h"

typedef NS_ENUM(NSInteger, JCHManifestMemoryType)
{
    kJCHManifestMemoryTypeNew,   //新建货单
    kJCHManifestMemoryTypeEdit,  //编辑货单
    kJCHManifestMemoryTypeCopy,  //货单复制
};

@interface JCHManifestMemoryStorage : NSObject

//当前类型(新建/编辑/复制)
@property (assign, nonatomic, readwrite) JCHManifestMemoryType manifestMemoryType;
@property (retain, nonatomic, readwrite) NSString *currentManifestID;
@property (retain, nonatomic, readwrite) NSString *currentManifestDate;
@property (retain, nonatomic, readwrite) NSString *currentManifestRemark;

//! @brief 货单类型
@property (assign, nonatomic, readwrite) enum JCHOrderType currentManifestType;

//! @brief 仓库id
@property (retain, nonatomic, readwrite) NSString *warehouseID;


#pragma mark - // ================================进出货单相关Property================================ //
//! @brief 是否抹零
@property (assign, nonatomic, readwrite) BOOL isRejected;

//! @brief 抹零数
@property (assign, nonatomic, readwrite) CGFloat currentManifestEraseAmount;

//! @brief 折扣
@property (assign, nonatomic, readwrite) CGFloat currentManifestDiscount;

//! @brief 应收金额
@property (assign, nonatomic, readwrite) CGFloat receivableAmount;

//! @brief 联系人信息
@property (retain, nonatomic, readwrite) ContactsRecord4Cocoa *currentContactsRecord;

//! @brief 是否已经付款
@property (assign, nonatomic, readwrite) BOOL hasPayed;

//! @brief 应收应付列表
@property (retain, nonatomic, readwrite) NSArray *manifestARAPList;

//! @brief 储值卡充值金额
@property (assign, nonatomic, readwrite) CGFloat savingCardRechargeAmount;

//! @brief 餐饮版盘点/入库/估清类型
@property (assign, nonatomic, readwrite) enum JCHRestaurantManifestType enumRestaurantManifestType;


#pragma mark - // ================================盘点单相关Property================================ //

@property (nonatomic, retain) JCHManifestInventoryCheckMemory *inventoryCheckMemory;

//! @brief 餐饮版相关属性
@property (assign, nonatomic, readwrite) long long tableID;

//! @brief 餐饮版相关属性
@property (retain, nonatomic, readwrite) NSString *tableName;

//! @brief 当前就餐人数
@property (assign, nonatomic, readwrite) NSInteger restaurantPeopleCount;

//! @brief 餐饮版改单前的货单流水
@property (retain, nonatomic, readwrite) NSArray *restaurantPreInsertManifestArray;


+ (id)sharedInstance;
- (void)insertManifestRecordAtHead:(ManifestTransactionDetail *)record;
- (void)addManifestRecord:(ManifestTransactionDetail *)record;
- (void)addManifestRecordArray:(NSArray *)recordArray;
- (void)removeManifestRecord:(ManifestTransactionDetail *)record;
- (void)removeAllManifestRecords;
- (NSArray *)getAllManifestRecord;
- (void)clearData;






@end
