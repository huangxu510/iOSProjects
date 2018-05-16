//
//  ServiceFactory.h
//  iOSInterface
//
//  Created by apple on 15/7/29.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TransactionService.h"
#import "UnitService.h"
#import "SKUService.h"
#import "UtilityService.h"
#import "ProductService.h"
#import "AccountService.h"
#import "MetaInfoService.h"
#import "CategoryService.h"
#import "ManifestService.h"
#import "DataSyncService.h"
#import "BookInfoService.h"
#import "PermissionService.h"
#import "BookMemberService.h"
#import "FinanceCalculateService.h"
#import "DatabaseUpgradeService.h"
#import "ContactsService.h"
#import "OnlineSettlement.h"
#import "CardDiscountService.h"
#import "FinanceService.h"
#import "LargeDatabaseSyncService.h"
#import "WarehouseService.h"
#import "DiningTableService.h"
#import "BalanceStatusService.h"
#import "TakeOutService.h"
#import "TableUsageService.h"
#import "RestaurantTableService.h"

@interface ServiceFactory : NSObject

+ (int)initializeServiceFactory:(NSString *)databasePath
                         userID:(NSString *)userID
                        appType:(NSInteger)appBookType;
+ (id)sharedInstance;
+ (NSString *)getCurrentDatabasePath;
+ (NSInteger)getCurrentBookType;
+ (void *)getServiceHandler;
+ (NSInteger)getDefaultBookType;
+ (NSInteger)getRestaurantBookType;
+ (NSInteger)getTakeoutBookType;

//! @brief 获取数据库类型
- (int)getDBType;

//! @todo 配合测试开放的接口
- (void)clearDatabase;

- (id<TransactionService>)transactionService;
- (id<UnitService>)unitService;
- (id<ProductService>)productService;
- (id<AccountService>)accountService;
- (id<MetaInfoService>)metaInfoService;
- (id<CategoryService>)categoryService;
- (id<FinanceCalculateService>)financeCalculateService;
- (id<ManifestService>)manifestService;
- (id<DatabaseUpgradeService>)databaseUpgradeService;
- (id<UtilityService>)utilityService;
- (id<SKUService>)skuService;
- (id<DataSyncService>)dataSyncService;
- (id<BookInfoService>)bookInfoService;
- (id<BookMemberService>)bookMemberService;
- (id<PermissionService>)permissionService;
- (id<ContactsService>)contactsService;
- (id<OnlineSettlement>)onlineSettlementService;
- (id<CardDiscountService>)cardDiscountService;
- (id<FinanceService>)financeService;
- (id<LargeDatabaseSyncService>)largeDatabaseSyncService;
- (id<WarehouseService>)warehouseService;
- (id<BalanceStatusService>)balanceStatusService;
- (id<DiningTableService>)diningTableService;
- (id<TakeOutService>)takeoutService;
- (id<TableUsageService>)tableUsageService;
- (id<RestaurantTableService>)restaurantTableService;

// =========================== 同步逻辑相关操作 =========================== //
+ (NSString *)getSyncUserDatabasePath;


// =========================== 多店逻辑相关操作 =========================== //
+ (NSArray *)getAllAccountBookList:(NSString *)userID;

+ (void)updateBookInfoInAllAccountBook:(NSString *)userID
                                 block:(BookInfoRecord4Cocoa *(^)(NSString *bookID, BookInfoRecord4Cocoa *bookInfo))callback;

//! @brief 更新所有账本中的book member信息
+ (void)updateBookMemberInAllAccountBook:(NSString *)userID bookMember:(BookMemberRecord4Cocoa *)bookMemeber;

//! @brief 删除指定账本
+ (void)deleteAccountBook:(NSString *)userAccountID accountBookID:(NSString *)accountBookID;


//! @brief 判断当前用户是否为指定账本的店长
+ (BOOL)isShopManager:(NSString *)userID accountBookID:(NSString *)accountBookID;

// ===================================== 同步目录操作相关 =================================== //
//! @brief 获取App Document目录
+ (NSString *)getAppDocumentPath;

//! @brief 获取默认的数据库路径
+ (NSString *)getDefaultDatabasePath;

//! @brief 同步上传文件路径
+ (NSString *)getSyncUploadFilePath;

//! @brief 同步下载文件路径
+ (NSString *)getSyncDownloadFilePath;

//! @brief 获取用户账户数据库路径
+ (NSString *)getUserAccountDatabasePath:(NSString *)userAccountID;

//! @brief 获取用户的指定账本路径
+ (NSString *)getAccountBookDatabasePath:(NSString *)userAccountID accountBookID:(NSString *)accountBookID;

//! @brief 创建同步文件结构
+ (void)createDataSyncDirectoryStructure;

//! @brief 创建账号目录
+ (void)createDirectoryForUserAccount:(NSString *)userAccountID;

//! @brief 创建账本目录
+ (void)createDirectoryForUserAccount:(NSString *)userAccountID accountBookID:(NSString *)accountBookID;

//! @brief 基于当前最新的数据库来创建一个sync connect上传的数据库
+ (NSString *)createSyncConnectNewUploadDatabase:(NSString *)seedDatabase;


// ========================================================================================//



// ===================================== 单元测试操作相关 =================================== //
+ (NSInteger)runUnitTest:(NSString *)sourceDatabasePath
          targetDatabase:(NSString *)targetDatabasePath
           manifestCount:(NSInteger)manifestCount
   transactionInManifest:(NSInteger)transactionInManifest;

+ (NSInteger)createLargeDatabase:(NSString *)sourceDatabasePath
                  targetDatabase:(NSString *)targetDatabasePath
                   manifestCount:(NSInteger)manifestCount
           transactionInManifest:(NSInteger)transactionInManifest
                    intervalDays:(NSInteger)intervalDays;

@end
