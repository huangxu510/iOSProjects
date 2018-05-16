//
//  JCHPerimissionUtility.h
//  jinchuhuo
//
//  Created by huangxu on 16/1/13.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCHPerimissionUtility : NSObject

+ (BOOL)canAddPurchaseManifest;     // 是否可进货
+ (BOOL)canAddShipmentManifest;     // 是否可出货
+ (BOOL)canReturnManifest;          // 是否可退单
+ (BOOL)canDeleteManifest;          // 是否可删单
+ (BOOL)canEditManifest;            // 是否可以编辑货单
+ (BOOL)canCopyManifest;            // 是否可以复制货单
+ (BOOL)displayCostPrice;           // 是否显示成本价
+ (BOOL)displayThisMonthPurchase;   // 是否显示本月进货
+ (BOOL)displayInventory;           // 是否显示我的库存
+ (BOOL)displayThisMonthShipment;   // 是否显示本月出货
+ (BOOL)canTransferManifest;        // 是否可调库
+ (BOOL)canAssemblingManifest;      // 是否可组装货单
+ (BOOL)canDismountManifest;        // 是否可拆单
+ (BOOL)displayPurchaseAnalysis;    // 是否显示进货分析
+ (BOOL)displayShipmentAnalysis;    // 是否显示出货分析
+ (BOOL)displayProfitAnalysis;      // 是否显示毛利分析
+ (BOOL)displayInventoryAnalysis;   // 是否显示库存分析
+ (BOOL)canModifyCategory;          // 是否可操作分类
+ (BOOL)canModifyGoods;             // 是否可操作商品
+ (BOOL)canModifyUnit;              // 是否可操作单位
+ (BOOL)canUsePrinter;              // 是否可操作打印机

@end
