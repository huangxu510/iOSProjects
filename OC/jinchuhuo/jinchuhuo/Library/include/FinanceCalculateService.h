//
//  FinanceCalculateService.h
//  iOSInterface
//
//  Created by apple on 15/8/26.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InventoryRecord4Cocoa.h"
#import "BookMemberRecord4Cocoa.h"
#import "ProductRecord4Cocoa.h"
#import "ReportData4Cocoa.h"

@protocol FinanceCalculateService <NSObject>

//! @brief 计算今日进货金额
- (CGFloat)calculateTodayPurchasesAmount:(NSInteger *)trend;

//! @brief 计算今日出货金额
- (CGFloat)calculateTodayShipmentAmount:(NSInteger *)trend;

//! @brief 计算本月出货
- (CGFloat)calculateThisMonthShipmentAmount;

//! @brief 计算本月进货
- (CGFloat)calculateThisMonthPurchaseAmount;

//! @brief 计算总库总金额
- (CGFloat)calculateTotalInventoryAmount:(NSString *)warehouseUUID;

//! @brief 计算本月毛利
- (CGFloat)calculateThisMonthGrossProfit;

//! @brief 计算今日毛利
- (CGFloat)calculateTodayGrossProfit;

//! @brief 查询今日开单数接口
- (NSInteger)calculateTodayShipmentManifest;

//! @brief 经营指数
- (void)calculateManageIndex:(CGFloat *)manageIndex
          chainRelativeRatio:(CGFloat *)chainRelativeRatio;

//! @brief 计算今日销量top3
- (void)calculateTodaySaleTop3:(NSArray<ProductRecord4Cocoa *> **)topSaleList;

//! @brief 计算今日销冠
- (void)calculateTodayBestSeller:(BookMemberRecord4Cocoa **)record saleAmount:(CGFloat *)saleAmount;

//! @brief 查询所有的库存信息
- (NSArray *)calculateAllInventory:(NSString *)warehouseUUID;

//! @brief 查询指定的商品的库存信息
- (InventoryDetailRecord4Cocoa *)calculateInventoryFor:(NSString *)productUUID
                                              unitUUID:(NSString *)unitUUID
                                         warehouseUUID:(NSString *)warehouseUUID;

//! @brief 查询指定商品的期初库存
- (int)queryProductBeginningInventoryInfo:(NSString *)productUUID
                           inventoryArray:(NSArray **)inventoryArray;

//! @brief 进货分析
- (void)calculatePurchaseReportData:(NSInteger)iBeginTime
                            endTime:(NSInteger)iEndTime
                       amountReport:(NSArray **)amountReportVector
                      productReport:(NSArray **)productReportVector
                     categoryReport:(NSArray **)categoryReportVector
                        totalAmount:(CGFloat *)totalAmount;

//! @brief 出货分析
- (void)calculateShipmentReportData:(NSInteger)iBeginTime
                            endTime:(NSInteger)iEndTime
                       amountReport:(NSArray **)amountReportVector
                      productReport:(NSArray **)productReportVector
                     categoryReport:(NSArray **)categoryReportVector
                        totalAmount:(CGFloat *)totalAmount;

//! @brief 毛利分析
- (void)calculateProfitReportData:(NSInteger)iBeginTime
                          endTime:(NSInteger)iEndTime
                     amountReport:(NSArray **)amountReportVector
                    productReport:(NSArray **)productReportVector
                   categoryReport:(NSArray **)categoryReportVector
                      profitValue:(CGFloat *)profitValue
                       profitRate:(CGFloat *)profitRate;

//! @brief 库存分析
- (void)calculateInventoryReportData:(NSString *)warehouseUUID
                       productReport:(NSArray **)productReportVector
                      categoryReport:(NSArray **)categoryReportVector
                totalInventoryAmount:(CGFloat *)totalInventoryAmount;


//! @brief 计算账户资金余额
- (NSArray *)calculateAccountBalance;

// 客户统计
- (void)calculateCustomSumaryReport:(time_t)beginDatetime
                        endDatetime:(time_t)endTime
                      summaryReport:(CustomReportSummaryRecord4Cocoa **)summaryReport
                       customRecord:(NSArray **)customRecordVector;

// 客户明细(非退货)
- (void)calculateCustomDetailReport:(time_t)beginDatetime
                        endDatetime:(time_t)endDatetime
                           customID:(NSString *)customID
                       detailReport:(CustomDetailReportRecord4Cocoa **)detailReport
                     manifestVector:(NSArray **)manifestVector
                     categoryVector:(NSArray **)categoryVector
                      productVector:(NSArray **)productVector;

// 客户明细(退货)
- (void)calculateCustomReturnDetailReport:(time_t)beginDatetime
                              endDatetime:(time_t)endDatetime
                                 customID:(NSString *)customID
                             detailReport:(CustomDetailReportRecord4Cocoa **)detailReport
                           manifestVector:(NSArray **)manifestVector
                           categoryVector:(NSArray **)categoryVector
                            productVector:(NSArray **)productVector;



@end
