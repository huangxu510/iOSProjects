//
//  ManifestRecord4Cocoa.h
//  iOSInterface
//
//  Created by apple on 15/8/31.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//! @brief 货单中交易记录
@interface ManifestTransactionRecord4Cocoa : NSObject
@property (retain, nonatomic, readwrite) NSString *productCategory;
@property (retain, nonatomic, readwrite) NSString *productName;
@property (retain, nonatomic, readwrite) NSString *productImageName;
@property (assign, nonatomic, readwrite) CGFloat productCount;
@property (assign, nonatomic, readwrite) CGFloat productDiscount;
@property (assign, nonatomic, readwrite) CGFloat productPrice;
@property (retain, nonatomic, readwrite) NSString *productUnit;
@property (assign, nonatomic, readwrite) NSInteger unitDigits;                      // 单位小数点个数
@property (retain, nonatomic, readwrite) NSString *warehouseUUID;                   // warehouse uuid
@property (retain, nonatomic, readwrite) NSString *transactionUUID;                 // transaction uuid
@property (retain, nonatomic, readwrite) NSString *unitUUID;                        // unit uuid
@property (retain, nonatomic, readwrite) NSString *goodsNameUUID;                   // goods name uuid
@property (retain, nonatomic, readwrite) NSString *goodsCategoryUUID;               // goods category uuid
@property (retain, nonatomic, readwrite) NSString *goodsSKUUUID;                    // 查询货单时，存储当前记录对应的SKU UUID, 插入货单时忽略
@property (retain, nonatomic, readwrite) NSArray  *goodsSKUUUIDArray;               // 插入货单时，存储当前货单对应的SKU, 查询货单时忽略
@property (retain, nonatomic, readwrite) NSString *productNamePinYin;                // 商品名称拼音
@property (assign, nonatomic, readwrite) time_t transTime;
@property (assign, nonatomic, readwrite) NSInteger operatorID;
@property (retain, nonatomic, readwrite) NSString *dishProperty;                    // 菜品属性
@end

//! @brief 货单记录
@interface ManifestRecord4Cocoa : NSObject
@property (retain, nonatomic, readwrite) NSString *manifestID;
@property (assign, nonatomic, readwrite) NSInteger manifestType;
@property (retain, nonatomic, readwrite) NSString *manifestDate;
@property (retain, nonatomic, readwrite) NSString *manifestRemark;
@property (assign, nonatomic, readwrite) time_t manifestTimestamp;
@property (assign, nonatomic, readwrite) BOOL isManifestReturned;
@property (assign, nonatomic, readwrite) CGFloat manifestAmount;
@property (assign, nonatomic, readwrite) CGFloat manifestDiscount;
@property (assign, nonatomic, readwrite) NSInteger productCount;
@property (assign, nonatomic, readwrite) NSInteger operatorID;
@property (assign, nonatomic, readwrite) time_t operateTimestamp;
@property (assign, nonatomic, readwrite) CGFloat eraseAmount;
@property (assign, nonatomic, readwrite) CGFloat lessAmount;
@property (retain, nonatomic, readwrite) NSArray *manifestTransactionArray;
@property (retain, nonatomic, readwrite) NSString *buyerName;
@property (retain, nonatomic, readwrite) NSString *sellerName;
@property (retain, nonatomic, readwrite) NSString *buyerUUID;
@property (retain, nonatomic, readwrite) NSString *sellerUUID;
@property (retain, nonatomic, readwrite) NSString *paymentMethod;
@property (assign, nonatomic, readwrite) BOOL hasPayed;
@property (retain, nonatomic, readwrite) NSString *arapOrderID;
@property (retain, nonatomic, readwrite) NSString *arapRemark;
@property (assign, nonatomic, readwrite) time_t arapTime;
@property (assign, nonatomic, readwrite) CGFloat profitRatio;
@property (assign, nonatomic, readwrite) CGFloat profitAmount;
@property (assign, nonatomic, readwrite) CGFloat finalAmount;
@property (retain, nonatomic, readwrite) NSString *sourceWarehouseID;
@property (retain, nonatomic, readwrite) NSString *targetWarehouseID;
@property (retain, nonatomic, readwrite) NSArray *manifestReturnTransArray;
@property (retain, nonatomic, readwrite) NSArray *countingTransactionArray;
@property (retain, nonatomic, readwrite) NSArray *feeList;
@property (retain, nonatomic, readwrite) NSString *thirdPartOrderID;
@property (assign, nonatomic, readwrite) NSInteger thirdPartType;
@property (retain, nonatomic, readwrite) NSString *expressCompany;
@property (retain, nonatomic, readwrite) NSString *expressNumber;
@property (retain, nonatomic, readwrite) NSString *consigneeName;
@property (retain, nonatomic, readwrite) NSString *consigneePhone;
@property (retain, nonatomic, readwrite) NSString *consigneeAddress;
@end


// 订单信息
@interface ManifestInfoRecord4Cocoa : NSObject
@property (retain, nonatomic, readwrite) NSString *manifestID;
@property (assign, nonatomic, readwrite) NSInteger manifestType;
@property (retain, nonatomic, readwrite) NSString *manifestRemark;
@property (assign, nonatomic, readwrite) time_t manifestTimestamp;
@property (retain, nonatomic, readwrite) NSString *thirdPartOrderID;
@property (assign, nonatomic, readwrite) NSInteger thirdPartType;
@property (retain, nonatomic, readwrite) NSString *expressCompany;
@property (retain, nonatomic, readwrite) NSString *expressNumber;
@property (retain, nonatomic, readwrite) NSString *consigneeName;
@property (retain, nonatomic, readwrite) NSString *consigneePhone;
@property (retain, nonatomic, readwrite) NSString *consigneeAddress;
@end

//! @brief 进出货金额记录
@interface ManifestPurchasesShipmentAmountRecord4Cocoa : NSObject
@property (assign, nonatomic, readwrite) CGFloat purchasesAmount;
@property (assign, nonatomic, readwrite) CGFloat shipmentAmount;
@end


@interface ManifestARAPRecord4Cocoa : NSObject
//! @brief 货单号
@property (retain, nonatomic, readwrite) NSString *manifestID;

//! @brief 应收应付单号
@property (retain, nonatomic, readwrite) NSString *arapOrderID;

//! @brief 应收应付备注
@property (retain, nonatomic, readwrite) NSString *arapRemark;

//! @brief 货单类型
@property (assign, nonatomic, readwrite) NSInteger manifestType;

//! @brief 当前货单应收应付金额
@property (assign, nonatomic, readwrite) CGFloat manifestARAPAmount;

//! @brief 当前货单实现应收应付金额
@property (assign, nonatomic, readwrite) CGFloat manifestRealPayAmount;
@end


@interface CounterPartyARAPRecord4Cocoa : NSObject
@property (retain, nonatomic, readwrite) NSString *counterPartyUUID;
@property (assign, nonatomic, readwrite) NSInteger manifestCount;
@property (assign, nonatomic, readwrite) double amount;
@end


@interface CounterPartyARAPReportRecord4Cocoa : NSObject
//! @brief 应收应付总金额
@property (assign, nonatomic, readwrite) double totalAPAmount;

//! @brief 应收应收总金额
@property (assign, nonatomic, readwrite) double totalARAmount;

//! @brief 本月新增加的应收金额
@property (assign, nonatomic, readwrite) double thisMonthARAmountNew;

//! @brief 本月已收到的应收金额
@property (assign, nonatomic, readwrite) double thisMonthARAmountPayed;

//! @brief 本月新增加的应付金额
@property (assign, nonatomic, readwrite) double thisMonthAPAmountNew;

//! @brief 本月已偿还的应付金额
@property (assign, nonatomic, readwrite) double thisMonthAPAmountPayed;
@end


//! @brief 账户余额调整记录
@interface AccountBalanceChangeRecord4Cocoa : NSObject
//! @brief 调整金额
@property (assign, nonatomic, readwrite) double amount;
    
//! @brief 货单类型
@property (assign, nonatomic, readwrite) NSInteger manifestType;
    
//! @brief 货单时间戳
@property (assign, nonatomic, readwrite) NSInteger manifestTimestamp;
@end


//! @brief 储值卡充值记录
@interface CardRechargeRecord4Cocoa : NSObject

//! @brief 充值/退款金额
@property (assign, nonatomic, readwrite) double amount;
    
//! @brief 货单类型(充值单/退卡单)
@property (assign, nonatomic, readwrite) NSInteger manifestType;
    
//! @brief 客户UUID
@property (retain, nonatomic, readwrite) NSString *customUUID;
    
//! @brief 货单时间戳
@property (assign, nonatomic, readwrite) time_t manifestTimestamp;

//! @brief 支付方式
@property (retain, nonatomic, readwrite) NSString *paymentMethod;

//! @brief 操作员ID
@property (retain, nonatomic, readwrite) NSString *operatorName;

@end

//! @brief 用户储值卡余额信息
@interface UserCardBalanceRecord4Cocoa : NSObject

//! @brief 用户名称
@property (retain, nonatomic, readwrite) NSString *userName;

//! @brief 用户UUID
@property (retain, nonatomic, readwrite) NSString *userUUID;

//! @brief 账户流入余额
@property (assign, nonatomic, readwrite) double incomeBalance;

//! @brief 账户流出金额
@property (assign, nonatomic, readwrite) double outcomeBalance;

@end


//! @brief 结算状态
enum ManifestSettleStatus {
    NotPaid = 0,        // 未支付
    HasPaid = 1,        // 已支付
    NotReceived = 2,    // 未收款
    HasReceived = 3     // 已收款
};


//! @brief 货单的筛选和搜索条件
@interface ManifestCondition4Cocoa : NSObject

//! @brief 搜索条件
@property (retain, nonatomic, readwrite ) NSString *searchText;

//! @brief 开始日期, 不限制则为0
@property (assign, nonatomic, readwrite) long long beginDateTime;

//! @brief 结束日期, 不限制则为0
@property (assign, nonatomic, readwrite) long long endDateTime;

//! @brief 开始时间, 不限制则为0. 范围[0, 86399]
@property (assign, nonatomic, readwrite) long long beginTimeOfDay;

//! @brief 结束时间, 不限制则为0. 范围[0, 86399]
@property (assign, nonatomic, readwrite) long long endTimeOfDay;

//! @brief 起始金额, 不限制则为0
@property (assign, nonatomic, readwrite) double minAmount;

//! @brief 截止金额, 不限制则为0
@property (assign, nonatomic, readwrite) double maxAmount;

//! @brief 货单类型, 不限制则为empty
@property (retain, nonatomic, readwrite) NSArray<NSNumber *> *manifestTypeVector;

//! @brief 支付方式, 不限制则为empty
@property (retain, nonatomic, readwrite) NSArray<NSString *> *paymentAccountUUIDVector;

//! @brief 结算状态, 不限制则为empty
@property (retain, nonatomic, readwrite) NSArray<NSNumber *> *settleStatusVector;

@end


@interface AccountTransactionRecord4Cocoa : NSObject
//! @brief 流水的单号
@property (retain, nonatomic, readwrite ) NSString *manifestID;

//! @brief 流水发生时间
@property (assign, nonatomic, readwrite) long long transTime;

//! @brief 产生此账户流水的货单类型
@property (assign, nonatomic, readwrite ) NSInteger manifestType;

//! @brief 账户流水的简要描述
@property (retain, nonatomic, readwrite ) NSString *recordDescription;

//! @brief 流水金额
@property (assign, nonatomic, readwrite) double amount;

//! @brief 交易方UUID
@property (retain, nonatomic, readwrite ) NSString *counterPartyUUID;

//! @brief 操作人ID
@property (assign, nonatomic, readwrite ) NSInteger operatorID;

//! @brief 备注信息
@property (retain, nonatomic, readwrite) NSString *remark;

@end


@interface PartReturnProductRecord4Cocoa : NSObject

//! @brief 商品UUID
@property (retain, nonatomic, readwrite ) NSString *productUUID;

//! @brief 商品SKU UUID
@property (retain, nonatomic, readwrite ) NSString *productSKUUUID;

//! @brief 退货数量
@property (assign, nonatomic, readwrite) double productCount;


@end


//! @brief 盘点单流水记录
@interface CountingTransactionRecord4Cocoa : NSObject
//! @brief 商品uuid
@property (retain, nonatomic, readwrite) NSString *productUUID;

//! @brief 商品名称
@property (retain, nonatomic, readwrite) NSString *productName;

//! @brief 插入货单时，存储商品的SKU UUID组合
@property (retain, nonatomic, readwrite) NSArray<NSString *> *productSKUUUIDVector;

//! @brief 盘前数量
@property (assign, nonatomic, readwrite) double productCountBefore;

//! @brief 盘前平均成本价
@property (assign, nonatomic, readwrite) double averagePriceBefore;

//! @brief 盘后数量
@property (assign, nonatomic, readwrite) double productCountAfter;

//! @brief 盘后平均成本价
@property (assign, nonatomic, readwrite) double averagePriceAfter;

//! @brief 商品所属分类uuid
@property (retain, nonatomic, readwrite) NSString *productCategoryUUID;

//! @brief 商品类别
@property (retain, nonatomic, readwrite) NSString *productCategory;

//! @brief 单位 uuid
@property (retain, nonatomic, readwrite) NSString *unitUUID;

//! @brief 商品单位
@property (retain, nonatomic, readwrite) NSString *productUnit;

//! @brief 商品图片
@property (retain, nonatomic, readwrite) NSString *productImageName;

//! @brief 仓库 uuid
@property (retain, nonatomic, readwrite) NSString *warehouseID;

//! @brief 查询货单时，存储商品的SKU UUID
@property (retain, nonatomic, readwrite) NSString *productSKUUUID;

//! @brief 单位小数位数
@property (assign, nonatomic, readwrite) int unitDigits;
@end



//! @brief 盘点货单记录
@interface CountManifestRecord4Cocoa : NSObject

//! @brief 货单ID
@property (retain, nonatomic, readwrite) NSString *manifestID;

//! @brief 盘点商品个数
@property (assign, nonatomic, readwrite) int countingProduct;

//! @brief 货单时间戳
@property (assign, nonatomic, readwrite) time_t manifestTimestamp;

//! @brief 盘盈盘亏，正数为盘盈，负数为盘亏
@property (assign, nonatomic, readwrite) double countingPrice;

//! @brief 仓库名字
@property (retain, nonatomic, readwrite) NSString *warehouseName;

//! @brief 仓库UUID
@property (assign, nonatomic, readwrite) long long warehouseID;

//! @brief 盘点详情
@property (retain, nonatomic, readwrite) NSArray<CountingTransactionRecord4Cocoa *> *countingTransactionArray;

//! @brief 当前货单的备注信息
@property (retain, nonatomic, readwrite) NSString *manifestRemark;

//! @brief 操作员ID
@property (assign, nonatomic, readwrite) int operatorID;

@end


//! @brief 货单中交易中的费用
@interface FeeRecord4Cocoa : NSObject
@property (retain, nonatomic, readwrite) NSString *feeAccountUUID;    // 费用科目的UUID
@property (assign, nonatomic, readwrite) double fee;                  // 费用
@property (retain, nonatomic, readwrite) NSString *feeAccountName;    // 费用名称(查询时返回)
@end


