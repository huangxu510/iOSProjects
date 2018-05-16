//
//  ReportData4Cocoa.h
//  iOSInterface
//
//  Created by apple on 15/10/29.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//! @brief 进货/出货金额分析
@interface PurchaseShipmentAmountReportData4Cocoa : NSObject
@property(assign, nonatomic, readwrite) CGFloat totalAmount;
@property(assign, nonatomic, readwrite) NSInteger timestamp;
@end

//! @brief 进货/出货分类分析
@interface PurchaseShipmentCategoryReportData4Cocoa : NSObject
@property(assign, nonatomic, readwrite) CGFloat totalAmount;
@property(assign, nonatomic, readwrite) CGFloat totalCount;
@property(retain, nonatomic, readwrite) NSString *categoryName;
@end

//! @brief 进货/出货商品分析
@interface PurchaseShipmentProductReportData4Cocoa : NSObject
@property(assign, nonatomic, readwrite) CGFloat totalAmount;
@property(assign, nonatomic, readwrite) CGFloat totalCount;
@property(retain, nonatomic, readwrite) NSString *productName;
@property(retain, nonatomic, readwrite) NSString *productUnit;
@property(assign, nonatomic, readwrite) NSInteger unitDigitCount;
@property(retain, nonatomic, readwrite) NSString *productUUID;
@end

//! @brief 毛利金额分析
@interface ProfitAmountReportData4Cocoa : NSObject
@property(assign, nonatomic, readwrite) CGFloat totalAmount;
@property(assign, nonatomic, readwrite) CGFloat totalProfit;
@property(assign, nonatomic, readwrite) CGFloat profitRate;
@property(assign, nonatomic, readwrite) NSInteger timestamp;
@end

//! @brief 毛利分类分析
@interface ProfitCategoryReportData4Cocoa : NSObject
@property(assign, nonatomic, readwrite) CGFloat totalAmount;
@property(assign, nonatomic, readwrite) CGFloat totalProfit;
@property(assign, nonatomic, readwrite) CGFloat profitRate;
@property(retain, nonatomic, readwrite) NSString *categoryName;
@end

//! @brief 毛利商品分析
@interface ProfitProductReportData4Cocoa : NSObject
@property(assign, nonatomic, readwrite) CGFloat totalAmount;
@property(assign, nonatomic, readwrite) CGFloat totalProfit;
@property(assign, nonatomic, readwrite) CGFloat profitRate;
@property(retain, nonatomic, readwrite) NSString *productName;
@end

//! @brief 库存分类分析
@interface InventoryCategoryReportData4Cocoa : NSObject
@property(assign, nonatomic, readwrite) CGFloat totalAmount;
@property(assign, nonatomic, readwrite) CGFloat rate;
@property(retain, nonatomic, readwrite) NSString *categoryName;
@end

//! @brief 库存商品分析
@interface InventoryProductReportData4Cocoa : NSObject
@property(assign, nonatomic, readwrite) CGFloat totalAmount;
@property(assign, nonatomic, readwrite) CGFloat totalCount;
@property(assign, nonatomic, readwrite) CGFloat rate;
@property(retain, nonatomic, readwrite) NSString *productUnit;
@property(assign, nonatomic, readwrite) NSInteger unitDigitCount;
@property(retain, nonatomic, readwrite) NSString *productName;
@property(retain, nonatomic, readwrite) NSString *categoryName;
@property(retain, nonatomic, readwrite) NSString *productUUID;
@end


//! @brief 客户统计 -- 概览
@interface CustomReportSummaryRecord4Cocoa : NSObject
//! @brief 销售总额
@property(assign, nonatomic, readwrite) CGFloat totalSaleAmount;

//! @brief 退货总金额
@property(assign, nonatomic, readwrite) CGFloat totalReturnAmount;

//! @brief 净销售金额
@property(assign, nonatomic, readwrite) CGFloat netSaleAmount;

//! @brief 客户数量
@property(assign, nonatomic, readwrite) NSInteger totalCustomCount;

//! @brief 单均价
@property(assign, nonatomic, readwrite) CGFloat perManifestAmount;

//! @brief 毛利总额
@property(assign, nonatomic, readwrite) CGFloat totalProfitAmount;

//! @brief 毛利率
@property(assign, nonatomic, readwrite) CGFloat profitRatio;

//! @brief 净赊销金额
@property(assign, nonatomic, readwrite) CGFloat netCreditSaleAmount;

//! @brief 未收金额
@property(assign, nonatomic, readwrite) CGFloat totalARAmount;

//! @brief 客单价
@property(assign, nonatomic, readwrite) CGFloat perCustomAmount;

//! @brief 销售总单数
@property(assign, nonatomic, readwrite) NSInteger totalSaleManifestCount;

//! @brief 退货单数
@property(assign, nonatomic, readwrite) NSInteger totalReturnManifestCount;

//! @brief 净销售单数
@property(assign, nonatomic, readwrite) NSInteger netSaleManifestCount;

//! @brief 净赊销订单数
@property(assign, nonatomic, readwrite) NSInteger netCreditSaleManifestCount;

//! @brief 未收订单数
@property(assign, nonatomic, readwrite) NSInteger arManifestCount;

//! @brief 本期货单退货金额
@property(assign, nonatomic, readwrite) CGFloat manifestReturnAmount;

//! @brief 本期货单退货数量
@property(assign, nonatomic, readwrite) NSInteger manifestReturnCount;

@end

//! @brief 客户统计 -- 记录
@interface CustomReportRecord4Cocoa : NSObject
//! @brief 客户名称
@property(retain, nonatomic, readwrite) NSString *customName;

//! @brief 客户ID
@property(retain, nonatomic, readwrite) NSString *customUUID;

//! @brief 销售总金额
@property(assign, nonatomic, readwrite) CGFloat totalSaleAmount;

//! @brief 销售金额占比
@property(assign, nonatomic, readwrite) CGFloat saleAmountRatio;

//! @brief 总毛利金额
@property(assign, nonatomic, readwrite) CGFloat totalProfitAmount;

//! @brief 毛利率
@property(assign, nonatomic, readwrite) CGFloat profitRatio;

//! @brief 单均价
@property(assign, nonatomic, readwrite) CGFloat perManifestAmount;

//! @brief 订单数量
@property(assign, nonatomic, readwrite) NSInteger totalManifestCount;

//! @brief 退货金额
@property(assign, nonatomic, readwrite) CGFloat totalReturnAmount;

//! @brief 退货订单数量
@property(assign, nonatomic, readwrite) NSInteger totalReturnManifestCount;

//! @brief 赊销金额
@property(assign, nonatomic, readwrite) CGFloat totalCreditSaleAmount;

//! @brief 赊销笔数
@property(assign, nonatomic, readwrite) NSInteger totalCreditSaleCount;

//! @brief 未收金额
@property(assign, nonatomic, readwrite) CGFloat totalARAmount;

//! @brief 未收笔数
@property(assign, nonatomic, readwrite) NSInteger totalARCount;

//! @brief 本期货单退货金额
@property(assign, nonatomic, readwrite) CGFloat manifestReturnAmount;

//净销金额
@property(assign, nonatomic, readwrite) CGFloat netSaleAmount;

//净销单数
@property(assign, nonatomic, readwrite) NSInteger netSaleManifestCount;

//净销金额占比
@property(assign, nonatomic, readwrite) CGFloat netSaleAmountRatio;

//! @brief 退货金额占比
@property(assign, nonatomic, readwrite) CGFloat returnAmountRatio;

@end

//! @brief 客户详情 -- 概览
@interface CustomDetailReportRecord4Cocoa : NSObject
//! @brief 货单总数
@property(assign, nonatomic, readwrite) NSInteger totalManifestCount;

//! @brief 应收货单数量
@property(assign, nonatomic, readwrite) NSInteger totalARAPManifestCount;

//! @brief 货单总金额
@property(assign, nonatomic, readwrite) CGFloat totalManifestAmount;

//! @brief 应收总金额
@property(assign, nonatomic, readwrite) CGFloat totalARAPManifestAmount;
@end


//! @brief 客户详情(非退货) -- 分类明细
@interface CustomCategoryReportRecord4Cocoa : NSObject
//! @brief 商品名称
@property(retain, nonatomic, readwrite) NSString *categoryName;

//! @brief 销售金额
@property(assign, nonatomic, readwrite) CGFloat totalSaleAmount;

//! @brief 销售利润
@property(assign, nonatomic, readwrite) CGFloat totalProfitAmount;

//! @brief 利润率
@property(assign, nonatomic, readwrite) CGFloat profitRatio;

//! @brief 包含的商品数量
@property(assign, nonatomic, readwrite) NSInteger productCount;
@end

//! @brief 客户详情(非退货) -- 商品明细
@interface CustomProductReportRecord4Cocoa : NSObject
//! @brief 商品名称
@property(retain, nonatomic, readwrite) NSString *productName;

//! @brief 商品分类
@property(retain, nonatomic, readwrite) NSString *categoryName;

//! @brief 销售金额
@property(assign, nonatomic, readwrite) CGFloat totalSaleAmount;

//! @brief 销售数量
@property(assign, nonatomic, readwrite) CGFloat totalSaleCount;

//! @brief 销售利润
@property(assign, nonatomic, readwrite) CGFloat totalProfitAmount;

//! @brief 利润率
@property(assign, nonatomic, readwrite) CGFloat profitRatio;

//! @brief 商品单位
@property(retain, nonatomic, readwrite) NSString *productUnit;

//! @brief 小数点位数
@property(assign, nonatomic, readwrite) NSInteger unitDigitsCount;
@end


//! @brief 客户详情(退货) -- 分类明细
@interface CustomCategoryReturnReportRecord4Cocoa : NSObject
//! @brief 商品名称
@property(retain, nonatomic, readwrite) NSString *categoryName;

//! @brief 退货金额
@property(assign, nonatomic, readwrite) CGFloat totalSaleAmount;

//! @brief 退货金额占比
@property(assign, nonatomic, readwrite) CGFloat amountRatio;

//! @brief 包含的商品数量
@property(assign, nonatomic, readwrite) NSInteger productCount;
@end

//! @brief 客户详情(退货) -- 商品明细
@interface CustomProductReturnReportRecord4Cocoa : NSObject
//! @brief 商品名称
@property(retain, nonatomic, readwrite) NSString *productName;

//! @brief 商品分类
@property(retain, nonatomic, readwrite) NSString *categoryName;

//! @brief 退货金额
@property(assign, nonatomic, readwrite) CGFloat totalSaleAmount;

//! @brief 退货数量
@property(assign, nonatomic, readwrite) CGFloat totalSaleCount;

//! @brief 退货金额占比
@property(assign, nonatomic, readwrite) CGFloat amountRatio;

//! @brief 商品单位
@property(retain, nonatomic, readwrite) NSString *productUnit;

//! @brief 小数点位数
@property(assign, nonatomic, readwrite) NSInteger unitDigitsCount;
@end
