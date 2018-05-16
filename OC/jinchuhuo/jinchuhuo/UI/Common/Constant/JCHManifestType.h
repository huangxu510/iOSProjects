//
//  JCHManifestType.h
//  jinchuhuo
//
//  Created by apple on 15/8/13.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#ifndef jinchuhuo_JCHManifestType_h
#define jinchuhuo_JCHManifestType_h

//! @brief 借贷类型
enum JCHLoanType
{
    kJCHLoanDebit = 1,          // 借
    kJCHLoadCredit = 2,         // 贷
    
    kJCHLoadUnknown,            // 未知
};

//! @brief 货单类型
enum JCHCreateManifestType
{
    kJCHCreatePurchasesManifest = 0,            /*! 创建进货单 */
    kJCHCreateShipmentManifest = 1,             /*! 创建出货单 */
};

enum JCHOrderType {
    kJCHOrderPurchases = 0,             // 进货单
    kJCHOrderShipment = 1,              // 出货单
    kJCHOrderPurchasesReject = 2,       // 进货退单
    kJCHOrderShipmentReject = 3,        // 出货退单
    kJCHOrderReceipt = 4,               // 收款单
    kJCHOrderPayment = 5,               // 付款单
    kJCHManifestMigrate = 6,            // 移库单
    kJCHManifestDismounting = 7,        // 拆装单
    kJCHManifestInventory = 8,          // 盘点单
    kJCHManifestAssembling = 9,         // 组装单
    kJCHManifestInventoryProfit = 10,   // 盘盈单
    kJCHManifestInventoryLoss = 11,     // 盘亏单
    kJCHManifestAbandon = 12,           // 废弃单
    kJCHManifestDelete = 13,            // 删除单
    kJCHOrderBeginningBalance = 14,     // 期初余额单
    kJCHOrderTransferAccount = 15,      // 转账单
    kJCHOrderModifyBalance = 16,        // 余额调整单
    kJCHManifestBeginningInventory = 17,// 期初库存单
    kJCHManifestCardRecharge = 18,      // 储值卡充值单
    kJCHManifestCardRefund = 19,        // 储值卡退卡单
    kJCHManifestExtraIncome = 21,       // 其它收入
    kJCHManifestExtraExpenses = 22,     // 其它支出
    
    kJCHManifestMaterialWastage = 101,  // 餐饮版--原料损耗
    kJCHRestaurntManifestOpenTable = 102,   // 餐饮版--开台
    
    kJCHOrderAllType,                   // 所有订单类型
};

enum JCHOrderStatus {
    kJCHOrderNormal = 0,                // 正常
    kJCHOrderReject = 1,                // 退单
    kJCHOrderCancel = 2,                // 作废
};

//! @brief 资产类型
enum JCHAssetsType {
    kJCHAssetsMoney = 0,                // 货币
    kJCHAssetsGoods = 1,                // 商品
    kJCHAssetsDiscount = 2,             // 财务费用/折扣金额
    kJCHAssetsExtraIncome = 3,          // 营业外收入
};

//! @brief 餐饮版新增货单类型
enum JCHRestaurantManifestType {
    kJCHRestaurantOpenTable = 0,            // 开台
    kJCHRestaurantMaterialInventory = 1,    // 原料盘点
    kJCHRestaurantMaterialWastage = 2,      // 原料损耗
    kJCHRestaurantDishesStorage = 3,        // 菜品入库
    kJCHRestaurantDishesWastage = 4,        // 菜品损耗
    kJCHRestaurantDishesMarkSold = 5,       // 菜品估清
    kJCHRestaurantDishesUnmarkSold = 6,     // 取消估清
};

//! @brief 第三方平台类型
enum JCHThirdPartType {
    kJCHThirdPartMMR = 1,               // 买卖人商城(预留)
    kJCHThirdPartMeituan = 2,           // 美团外卖平台
    kJCHThirdPartEle = 3,               // 饿了么平台
    kJCHThirdPartBaidu = 4,             // 百度外卖平台
    kJCHThirdPartEFengShe = 5,          // E蜂社平台
};

#endif
