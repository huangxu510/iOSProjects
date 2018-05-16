//
//  JCHPerimissionUtility.m
//  jinchuhuo
//
//  Created by huangxu on 16/1/13.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSyncStatusManager.h"
#import "JCHPerimissionUtility.h"

@implementation JCHPerimissionUtility

+ (BOOL)canAddPurchaseManifest     // 是否可进货
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return YES;
    }
    
    return statusManager.roleRecord.canAddPurchaseManifest;
}


+ (BOOL)canAddShipmentManifest     // 是否可出货
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return YES;
    }
    
    return statusManager.roleRecord.canReturnManifest;
}


+ (BOOL)canReturnManifest          // 是否可退单
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return YES;
    }
    
    return statusManager.roleRecord.canReturnManifest;
}


+ (BOOL)canDeleteManifest          // 是否可删单
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return YES;
    }
    
    return statusManager.roleRecord.canDeleteManifest;
}


+ (BOOL)canEditManifest            //是否可以编辑货单
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return YES;
    }
    
    //TODO: 货单编辑权限问题
    return statusManager.isShopManager;
}

+ (BOOL)canCopyManifest
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return YES;
    }
    
    //TODO: 货单复制权限问题
    return statusManager.isShopManager;
}


+ (BOOL)displayCostPrice           // 是否显示成本价
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return YES;
    }
    
    return statusManager.roleRecord.displayCostPrice;
}


+ (BOOL)displayThisMonthPurchase   // 是否显示本月进货
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return YES;
    }
    
    return statusManager.roleRecord.displayThisMonthPurchase;
}


+ (BOOL)displayInventory           // 是否显示我的库存
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return YES;
    }
    
    return statusManager.roleRecord.displayInventory;
}


+ (BOOL)displayThisMonthShipment   // 是否显示本月出货
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return YES;
    }
    
    return statusManager.roleRecord.displayThisMonthShipment;
}


+ (BOOL)canTransferManifest        // 是否可调库
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return YES;
    }
    
    return statusManager.roleRecord.canTransferManifest;
}


+ (BOOL)canAssemblingManifest      // 是否可组装货单
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return YES;
    }
    
    return statusManager.roleRecord.canAssemblingManifest;
}


+ (BOOL)canDismountManifest        // 是否可拆单
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return YES;
    }
    
    return statusManager.roleRecord.canDismountManifest;
}


+ (BOOL)displayPurchaseAnalysis    // 是否显示进货分析
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return YES;
    }
    
    return statusManager.roleRecord.displayPurchaseAnalysis;
}


+ (BOOL)displayShipmentAnalysis    // 是否显示出货分析
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return YES;
    }
    
    return statusManager.roleRecord.displayShipmentAnalysis;
}


+ (BOOL)displayProfitAnalysis      // 是否显示毛利分析
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return YES;
    }
    
    return statusManager.roleRecord.displayProfitAnalysis;
}


+ (BOOL)displayInventoryAnalysis   // 是否显示库存分析
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return YES;
    }
    
    return statusManager.roleRecord.displayInventoryAnalysis;
}


+ (BOOL)canModifyCategory          // 是否可操作分类
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return YES;
    }
    
    return statusManager.roleRecord.canModifyCategory;
}


+ (BOOL)canModifyGoods             // 是否可操作商品
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return YES;
    }
    
    return statusManager.roleRecord.canModifyGoods;
}


+ (BOOL)canModifyUnit              // 是否可操作单位
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return YES;
    }
    
    return statusManager.roleRecord.canModifyUnit;
}

+ (BOOL)canUsePrinter              // 是否可操作打印机
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return YES;
    }
    
    return statusManager.roleRecord.canUsePrinter;
}

@end
