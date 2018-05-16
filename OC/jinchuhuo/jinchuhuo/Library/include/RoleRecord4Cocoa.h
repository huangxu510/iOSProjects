//
//  RoleRecord4Cocoa.h
//  iOSInterface
//
//  Created by apple on 15/12/29.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RoleRecord4Cocoa : NSObject

@property (retain, nonatomic, readwrite) NSString *roleUUID;          // 角色UUID
@property (retain, nonatomic, readwrite) NSString *roleName;          // 角色名称
@property (assign, nonatomic, readwrite) BOOL canAddPurchaseManifest;     // 是否可进货
@property (assign, nonatomic, readwrite) BOOL canAddShipmentManifest;     // 是否可出货
@property (assign, nonatomic, readwrite) BOOL canReturnManifest;          // 是否可退单
@property (assign, nonatomic, readwrite) BOOL canDeleteManifest;          // 是否可删单
@property (assign, nonatomic, readwrite) BOOL displayCostPrice;           // 是否显示成本价
@property (assign, nonatomic, readwrite) BOOL displayThisMonthPurchase;   // 是否显示本月进货
@property (assign, nonatomic, readwrite) BOOL displayInventory;           // 是否显示我的库存
@property (assign, nonatomic, readwrite) BOOL displayThisMonthShipment;   // 是否显示本月出货
@property (assign, nonatomic, readwrite) BOOL canTransferManifest;        // 是否可调库
@property (assign, nonatomic, readwrite) BOOL canAssemblingManifest;      // 是否可组装货单
@property (assign, nonatomic, readwrite) BOOL canDismountManifest;        // 是否可拆单
@property (assign, nonatomic, readwrite) BOOL displayPurchaseAnalysis;    // 是否显示进货分析
@property (assign, nonatomic, readwrite) BOOL displayShipmentAnalysis;    // 是否显示出货分析
@property (assign, nonatomic, readwrite) BOOL displayProfitAnalysis;      // 是否显示毛利分析
@property (assign, nonatomic, readwrite) BOOL displayInventoryAnalysis;   // 是否显示库存分析
@property (assign, nonatomic, readwrite) BOOL canModifyCategory;          // 是否可操作分类
@property (assign, nonatomic, readwrite) BOOL canModifyGoods;             // 是否可操作商品
@property (assign, nonatomic, readwrite) BOOL canModifyUnit;              // 是否可操作单位
@property (assign, nonatomic, readwrite) BOOL canUsePrinter;              // 是否可操作打印机
@property (assign, nonatomic, readwrite) BOOL canCountManifest;           // 是否可盘点
@property (assign, nonatomic, readwrite) BOOL displayCustomerAnalysis;    // 是否显示客户分析
@property (assign, nonatomic, readwrite) BOOL displayCashAccount;         // 是否显示现金账户
@property (assign, nonatomic, readwrite) BOOL displayEWalletAccount;      // 是否显示电子钱包
@property (assign, nonatomic, readwrite) BOOL displayDebitAccount;        // 是否显示债权账户
@property (assign, nonatomic, readwrite) BOOL displayCreditAccount;       // 是否显示负债账户
@property (assign, nonatomic, readwrite) BOOL displayCustomer;            // 是否显示通讯录中的会员/客户
@property (assign, nonatomic, readwrite) BOOL displaySupplier;            // 是否显示通讯录中的供应商
@property (assign, nonatomic, readwrite) BOOL displayBookMember;          // 是否显示店铺成员
@property (assign, nonatomic, readwrite) BOOL canModifySKU;               // 是否可操作规格
@property (assign, nonatomic, readwrite) BOOL canModifySettlementSrv;     // 是否可开通结算服务
@property (assign, nonatomic, readwrite) BOOL canModifyStoredCard;        // 是否可设置储值卡规则
@property (assign, nonatomic, readwrite) BOOL canModifyWarehouse;         // 是否可修改仓库
@property (assign, nonatomic, readwrite) BOOL canModifyCashRegister;      // 是否可管理收银机
@property (assign, nonatomic, readwrite) BOOL canModifyRole;              // 是否可调整角色权限

@end
