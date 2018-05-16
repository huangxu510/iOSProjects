//
//  ManifestService.h
//  iOSInterface
//
//  Created by apple on 15/8/31.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#ifndef iOSInterface_ManifestService_h
#define iOSInterface_ManifestService_h

#import "ManifestRecord4Cocoa.h"

@protocol ManifestService <NSObject>

@required
// 货单添加/修改，如果是通用版，feedRecordList设置为nil
- (int)insertManifest:(ManifestInfoRecord4Cocoa *)manifestInfo
      transactionList:(NSArray *)transactionList
     manifestDiscount:(CGFloat)manifestDiscount
          eraseAmount:(CGFloat)eraseAmount
         counterParty:(NSString *)counterParty
   paymentAccountUUID:(NSString *)paymentAccountUUID
           operatorID:(NSInteger)operatorID
        feeRecordList:(NSArray *)feeRecordList;

- (int)updateManifest:(ManifestInfoRecord4Cocoa *)manifestInfo
      transactionList:(NSArray *)transactionList
     manifestDiscount:(CGFloat)manifestDiscount
          eraseAmount:(CGFloat)eraseAmount
         counterParty:(NSString *)counterParty
   paymentAccountUUID:(NSString *)paymentAccountUUID
           operatorID:(NSInteger)operatorID
        feeRecordList:(NSArray *)feeRecordList;

- (int)returnManifest:(NSInteger)manifestType
           manifestID:(NSString *)manifestID
     returnManifestID:(NSString *)returnManifestID;

//! @brief 货单整单退单, 根据第三方平台订单id进行退单
- (int)returnThirdPartManifest:(NSInteger)thirdPartType
              thirdPartOrderID:(NSString *)thirdPartOrderID;

//! @brief 添加移库单
- (int)transferManifest:(NSArray *)transactionList
           manifestTime:(time_t)mainfestTime
             operatorID:(NSInteger)operatorID
             manifestID:(NSString *)manifestID
                 remark:(NSString *)remark
        sourceWarehouse:(NSString *)sourceWarehouse
        targetWarehouse:(NSString *)targetWarehouse;

//! @brief 添加组装单
- (int)assemblingManifest:(NSString *)manifestID
             manifestTime:(time_t)mainfestTime
              warehouseID:(NSString *)warehouseID
               operatorID:(NSInteger)operatorID
              operateTime:(NSInteger)operateTime
                   remark:(NSString *)remark
        targetTransaction:(NSArray<ManifestTransactionRecord4Cocoa*> *)targetTransaction;
;

//! @brief 添加拆装单
- (int)dismountingManifest:(NSString *)manifestID
              manifestTime:(time_t)manifestTime
               warehouseID:(NSString *)warehouseID
                operatorID:(NSInteger)operatorID
               operateTime:(NSInteger)operateTime
                    remark:(NSString *)remark
         targetTransaction:(NSArray<ManifestTransactionRecord4Cocoa*> *)targetTransaction;

//! @brief 添加盘点单
- (int)countingManifest:(NSString *)manifestID
           manifestTime:(time_t)manifestTime
            warehouseID:(NSString *)warehouseID
         manifestRemark:(NSString *)manifestRemark
             operatorID:(int)operatorID
        transactionList:(NSArray<CountingTransactionRecord4Cocoa *> *)transactionList;

//! @brief 删除单
- (int)deleteManifest:(NSInteger)manifestType
           manifestID:(NSString *)manifestID;

- (NSString*)createManifestID:(int)manifestType;
- (NSString *)createReturnManifestID;

//! @brief 创建收款单ID
- (NSString *)createReceiptManifestID;

//! @brief 创建付款单ID
- (NSString *)createPaymentManifestID;

- (void)queryRecent3DaysManifest:(ManifestPurchasesShipmentAmountRecord4Cocoa **)amountRecord
                   manifestArray:(NSArray **)manifestArray;
- (void)queryRecent7DaysManifest:(ManifestPurchasesShipmentAmountRecord4Cocoa **)amountRecord
                   manifestArray:(NSArray **)manifestArray;
- (void)queryAllManifest:(ManifestPurchasesShipmentAmountRecord4Cocoa **)amountRecord
           manifestArray:(NSArray **)manifestArray;
- (void)queryAllManifestList:(NSInteger)offset
                    pageSize:(NSInteger)pageSize
                   condition:(ManifestCondition4Cocoa *)condition
         manifestRecordArray:(NSArray<ManifestRecord4Cocoa *> **)manifestRecordArray;

- (ManifestRecord4Cocoa *)queryManifestDetail:(NSString *)manifestID;

- (void)checkAndBalanceAllManifest;


//! @brief 进货单的默认供货商UUID
- (NSString *)getDefaultSupplierUUID;

//! @brief 出货单的默认客户UUID
- (NSString *)getDefaultCustomUUID;

//! @brief 人民币现金账户UUID
- (NSString *)getDefaultCashRMBAccountUUID;

//! @brief 进货单时赊购账户UUID
- (NSString *)getCreditBuyingAccountUUID;

//! @brief 出货单时赊销账户UUID
- (NSString *)getCreditSaleAccountUUID;

//! @brief 出货单时微信支付账户UUID
- (NSString *)getWeiXinPayAccountUUID;

//! @brief 添加初始库存时的支付账户UUID
- (NSString *)getBeginningInventoryPaymentAccountUUID;

//! @brief 出货单时储值卡账户UUID
- (NSString *)getCardAccountUUID;

//! @brief 出货单时 微信支付-民生通道 账户UUID
- (NSString *)getWeiXinPayViaCMBCAccountUUID;

//! @brief 出货单时 支付宝支付-民生通道 账户UUID
- (NSString *)getAliPayViaCMBCAccountUUID;

//! @brief 餐饮版下单时用的支付账户UUID
- (NSString *)getPreInsertManifestAccountUUID;

//! @brief 配送费账户UUID
- (NSString *)getShippingFeeAccountUUID;

//! @brief 餐盒费账户UUID
- (NSString *)getBoxFeeAccountUUID;

//! @brief 美团外卖账户
- (NSString *)getMeiTuanTakeoutAccountUUID;

//! @brief 饿了么外卖账户
- (NSString *)getEleTakeoutAccountUUID;

//! @brief 百度外卖账户
- (NSString *)getBaiduTakeoutAccountUUID;

//! @brief 货单应收应付
- (int)manifestARAP:(NSString *)counterPartyUUID
        accountUUID:(NSString *)paymentAccountUUID
         operatorID:(NSInteger)operatorID
   manifestARAPList:(NSArray *)manifestARAPList;

//! @brief 计算每个交易方对应的应收应付金额
- (int)calculateCounterPartyARAP:(CounterPartyARAPReportRecord4Cocoa **)reportRecord
                         receipt:(NSArray **)receiptVector
                          payment:(NSArray **)paymentVector;

//! @brief 计算每个交易方对应的应收金额
- (int)calculateCounterPartyAR:(CounterPartyARAPReportRecord4Cocoa **)reportRecord
                         receipt:(NSArray **)receiptVector;

//! @brief 计算每个交易方对应的应付金额
- (int)calculateCounterPartyAP:(CounterPartyARAPReportRecord4Cocoa **)reportRecord
                         payment:(NSArray **)paymentVector;

//! @brief 查询指定用户应收账款对应的货单列表
- (int)queryManifestOfAccountReceivable:(NSString *)counterPartyUUID
                    manifestRecordArray:(NSArray **)manifestRecordArray;

//! @brief 查询以指定账户支付的货单
- (int)queryManifestPayByAccount:(NSString *)accountUUID
                        inAmount:(double *)inAmountValue
                       outAmount:(double *)outAmountValue
             manifestRecordArray:(NSArray **)manifestRecordArray;

//! @brief 查询以指定账户支付的货单
- (int)queryManifestPayByAccount:(NSInteger)offset
                        pageSize:(NSInteger)pageSize
                     accountUUID:(NSString *)accountUUID
                        inAmount:(double *)inAmountValue
                       outAmount:(double *)outAmountValue
             manifestRecordArray:(NSArray **)manifestRecordArray;

//! @brief 查询指定用户应付账款对应的货单列表
- (int)queryManifestOfAccountPayable:(NSString *)counterPartyUUID
                 manifestRecordArray:(NSArray **)manifestRecordArray;

//! @brief 查询赊销赊购类型的货单是否已进行过应收应付操作
- (BOOL)isManifestAlreadyARAP:(NSString *)manifestID
                 manifestType:(NSInteger)manifestType;

//! @brief 查询指定的货单是否通过在线支付的方式进行支付
- (BOOL)isManifestPayByOnline:(NSString *)manifestID
                 manifestType:(NSInteger)manifestType;

//! @brief 储值卡充值
- (int)rechargeCard:(NSString *)manifestID
       manifestTime:(time_t)manifestTime
         customUUID:(NSString *)customUUID
 paymentAccountUUID:(NSString *)paymentAccountUUID
             amount:(double)amount
         operatorID:(int)operatorID
   operateTimestamp:(time_t)operateTimestamp;

//! @brief 储值卡退卡
- (int)refundCard:(NSString *)manifestID
     manifestTime:(time_t)manifestTime
       customUUID:(NSString *)customUUID
paymentAccountUUID:(NSString *)paymentAccountUUID
           amount:(double)amount
       operatorID:(int)operatorID
 operateTimestamp:(time_t)operateTimestamp;

//! @brief 查询所有有储值卡流水
- (int)queryAllCardManifest:(NSArray **)rechargeRecordArray;

//! @brief 查询所有用户的储值卡余额
- (int)queryAllUserCardBalance:(NSArray **)cardBalanceArray;

//! @brief 查询指定用户的储值卡流水
- (int)queryCardManifestByUser:(NSString *)userID
           rechargeRecordArray:(NSArray **)rechargeRecordArray;

//! @brief 查询指定用户的储值卡余额
- (double)queryCardBalance:(NSString *)userID;

//! @brief 添加其它收入/支出单
- (int)insertIncomeExpenses:(NSInteger)manifestType
                     amount:(CGFloat)amount
               manifestTime:(time_t)manifestTime
            fromAccountUUID:(NSString *)fromAccountUUID
              toAccountUUID:(NSString *)toAccountUUID
                 operatorID:(NSInteger)operatorID
                     remark:(NSString *)remark;

//! @brief 添加其它收支
- (int)updateIncomeExpenses:(NSInteger)manifestType
                 manifestID:(NSString *)manifestID
                     amount:(CGFloat)amount
               manifestTime:(time_t)manifestTime
            fromAccountUUID:(NSString *)fromAccountUUID
              toAccountUUID:(NSString *)toAccountUUID
                 operatorID:(NSInteger)operatorID
                     remark:(NSString *)remark;

//! @brief 货单部分退单
- (int)partReturnManifest:(NSInteger)manifestType
               manfiestID:(NSString *)manifestID
         returnManifestID:(NSString *)returnManifestID
         counterPartyUUID:(NSString *)counterPartyUUID
               operatorID:(NSInteger)operatorID
              warehouseID:(NSString *)warehouseID
           manifestAmount:(double)manfiestAmount
           discountAmount:(double)discountAmount
              productList:(NSArray<PartReturnProductRecord4Cocoa *> *)productList;

//! @brief 查询盘点单详情
- (CountManifestRecord4Cocoa *)queryCountManifest:(NSString *)manifestID;


//! @brief 暂存货单
- (int)stashManifest:(NSArray *)transactionList
        manifestType:(NSInteger)manifestType
        manifestTime:(time_t)mainfestTime
          manifestID:(NSString *)manifestID
    manifestDiscount:(CGFloat)manifestDiscount
      manifestRemark:(NSString *)manifestRemark
         eraseAmount:(CGFloat)eraseAmount
        counterParty:(NSString *)counterParty;

//! @brief 查询所有挂单,支持分批查询
- (void)queryStashManifestList:(NSInteger)offset
                      pageSize:(NSInteger)pageSize
                     condition:(ManifestCondition4Cocoa *)condition
           manifestRecordArray:(NSArray<ManifestRecord4Cocoa *> **)manifestRecordArray;

//! @brief 删除挂单
- (int)deleteStashManifest:(NSString *)manifestID;

//! @brief 保存支付失败的货单
- (int)savePayErrorManifest:(NSArray *)transactionList
               manifestType:(NSInteger)manifestType
               manifestTime:(time_t)mainfestTime
                 manifestID:(NSString *)manifestID
           manifestDiscount:(CGFloat)manifestDiscount
             manifestRemark:(NSString *)manifestRemark
                eraseAmount:(CGFloat)eraseAmount
               counterParty:(NSString *)counterParty;

//! @brief 查询当前挂单数量
- (int)calculateStashManifestCount:(BOOL)bOnlyThisNode;

//! @brief 盘点 原料损耗
- (int)countingProductWaste:(NSString *)manifestID
               manifestTime:(time_t)manifestTime
                warehouseID:(NSString *)warehouseID
             manifestRemark:(NSString *)manifestRemark
                 operatorID:(int)operatorID
            transactionList:(NSArray<CountingTransactionRecord4Cocoa *> *)transactionList;

//! @brief 盘点 菜品入库
- (int)countingCuisineStore:(NSString *)manifestID
               manifestTime:(time_t)manifestTime
                warehouseID:(NSString *)warehouseID
             manifestRemark:(NSString *)manifestRemark
                 operatorID:(int)operatorID
            transactionList:(NSArray<CountingTransactionRecord4Cocoa *> *)transactionList;

//! @brief 盘点 菜品损耗
- (int)countingCuisineWaste:(NSString *)manifestID
               manifestTime:(time_t)manifestTime
                warehouseID:(NSString *)warehouseID
             manifestRemark:(NSString *)manifestRemark
                 operatorID:(int)operatorID
            transactionList:(NSArray<CountingTransactionRecord4Cocoa *> *)transactionList;


#pragma mark -
#pragma mark 餐饮/外卖接口
//! @brief 插入餐饮/外卖货单
- (int)preInsertOrUpdateManifest:(NSArray *)transactionList
                    manifestType:(NSInteger)manifestType
                    manifestTime:(time_t)mainfestTime
                      manifestID:(NSString *)manifestID
                manifestDiscount:(CGFloat)manifestDiscount
                  manifestRemark:(NSString *)manifestRemark
                     eraseAmount:(CGFloat)eraseAmount
                    counterParty:(NSString *)counterParty
              paymentAccountUUID:(NSString *)paymentAccountUUID
                      operatorID:(NSInteger)operatorID
                         tableID:(long long)tableID;

//! @brief 删除未结算的货单,如挂单，餐饮版的下单
- (int)deletePreInsertManifest:(NSString *)manifestID;

//! @brief 查询指定ID的未结算货单
- (ManifestRecord4Cocoa *)queryPreInsertManifest:(NSString *)manifestID;

//! @brief 查询所有未结算的货单,支持分批查询
- (void)queryPreInsertManifestList:(NSInteger)offset
                          pageSize:(NSInteger)pageSize
                         condition:(ManifestCondition4Cocoa *)condition
               manifestRecordArray:(NSArray<ManifestRecord4Cocoa *> **)manifestRecordArray;



@end

#endif
