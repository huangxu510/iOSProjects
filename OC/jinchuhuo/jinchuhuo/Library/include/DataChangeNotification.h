//
//  DataChangeNotification.h
//  iOSInterface
//
//  Created by apple on 16/7/5.
//  Copyright © 2016年 apple. All rights reserved.
//

#ifndef DataChangeNotification_h
#define DataChangeNotification_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#pragma mark -
#pragma mark 货单变更数据通知

//! @brief 添加货单
#ifndef kManifestInsertNotification
#define kManifestInsertNotification @"kManifestInsertNotification"
#endif

//! @brief 编辑货单
#ifndef kManifestUpdateNotification
#define kManifestUpdateNotification @"kManifestUpdateNotification"
#endif

//! @brief 退单
#ifndef kManifestReturnNotification
#define kManifestReturnNotification @"kManifestReturnNotification"
#endif

//! @brief 删单
#ifndef kManifestDeleteNotification
#define kManifestDeleteNotification @"kManifestDeleteNotification"
#endif

//! @brief 移库
#ifndef kManifestTransferNotification
#define kManifestTransferNotification @"kManifestTransferNotification"
#endif

//! @brief 货单应收应付
#ifndef kManifestARAPNotification
#define kManifestARAPNotification @"kManifestARAPNotification"
#endif

//! @brief 储值卡充值
#ifndef kManifestCardRechargeNotification
#define kManifestCardRechargeNotification @"kManifestCardRechargeNotification"
#endif

//! @brief 储值卡退卡
#ifndef kManifestCardReturnNotification
#define kManifestCardReturnNotification @"kManifestCardReturnNotification"
#endif

//! @brief 盘点单
#ifndef kManifestCountingNotification
#define kManifestCountingNotification @"kManifestCountingNotification"
#endif


#pragma mark -
#pragma mark 商品变更数据通知


//! @brief 添加商品
#ifndef kProductInsertNotification
#define kProductInsertNotification @"kProductInsertNotification"
#endif

//! @brief 编辑商品
#ifndef kProductUpdateNotification
#define kProductUpdateNotification @"kProductUpdateNotification"
#endif

//! @brief 删除商品
#ifndef kProductDeleteNotification
#define kProductDeleteNotification @"kProductDeleteNotification"
#endif

//! @brief 图片下载通知
#ifndef kProductImageDownloadNotification
#define kProductImageDownloadNotification @"kJCHiOSSyncImageFileDownloadCMDResponse"
#endif


#pragma mark -
#pragma mark 分类变更数据通知

//! @brief 添加分类
#ifndef kCategoryInsertNotification
#define kCategoryInsertNotification @"kCategoryInsertNotification"
#endif

//! @brief 编辑分类
#ifndef kCategoryUpdateNotification
#define kCategoryUpdateNotification @"kCategoryUpdateNotification"
#endif

//! @brief 删除分类
#ifndef kCategoryDeleteNotification
#define kCategoryDeleteNotification @"kCategoryDeleteNotification"
#endif




#pragma mark -
#pragma mark 单位变更数据通知

//! @brief 添加单位
#ifndef kUnitInsertNotification
#define kUnitInsertNotification @"kUnitInsertNotification"
#endif

//! @brief 编辑单位
#ifndef kUnitUpdateNotification
#define kUnitUpdateNotification @"kUnitUpdateNotification"
#endif

//! @brief 删除单位
#ifndef kUnitDeleteNotification
#define kUnitDeleteNotification @"kUnitDeleteNotification"
#endif





#pragma mark -
#pragma mark SKU变更数据通知

//! @brief 添加SKU
#ifndef kSKUInsertNotification
#define kSKUInsertNotification @"kSKUInsertNotification"
#endif

//! @brief 编辑SKU
#ifndef kSKUUpdateNotification
#define kSKUUpdateNotification @"kSKUUpdateNotification"
#endif

//! @brief 删除SKU
#ifndef kSKUDeleteNotification
#define kSKUDeleteNotification @"kSKUDeleteNotification"
#endif


#pragma mark-
#pragma mark 图片下载通知

//! @brief 单张图片下载通知
#ifndef kSingleImageDownloadNotification
#define kSingleImageDownloadNotification @"kSingleImageDownloadNotification"
#endif

//! @brief 所有图片全部下载完成通知
#ifndef kAllImageDownloadNotification
#define kAllImageDownloadNotification @"kAllImageDownloadNotification"
#endif


#pragma mark -
#pragma mark 仓库添加通知

//! @brief 添加仓库
#ifndef kWarehouseAddNotification
#define kWarehouseAddNotification @"kWarehouseAddNotification"
#endif

//! @brief 更新仓库
#ifndef kWarehouseUpdateNotification
#define kWarehouseUpdateNotification @"kWarehouseUpdateNotification"
#endif

//! @brief 删除仓库
#ifndef kWarehouseDeleteNotification
#define kWarehouseDeleteNotification @"kWarehouseDeleteNotification"
#endif

//! @brief 添加拼装单
#ifndef kAddAssemblingManifestNotification
#define kAddAssemblingManifestNotification @"kAddAssemblingManifestNotification"
#endif

//! @brief 添加拆装单
#ifndef kAddDismountingManifestNotification
#define kAddDismountingManifestNotification @"kAddDismountingManifestNotification"
#endif

//! @brief 添加外卖/餐饮货单
#ifndef kManifestRestaurantInsertNotification
#define kManifestRestaurantInsertNotification @"kManifestRestaurantInsertNotification"
#endif

//! @brief 删除外卖/餐饮货单
#ifndef kManifestRestaurantDeleteNotification
#define kManifestRestaurantDeleteNotification @"kManifestRestaurantDeleteNotification"
#endif


#pragma mark -
#pragma mark 发送通知
#ifndef JCHPostDataChangeNotification
#define JCHPostDataChangeNotification(notificationName) [[NSNotificationCenter defaultCenter] postNotificationName:(notificationName) object:[UIApplication sharedApplication] userInfo:@{}];
#endif


#endif /* DataChangeNotification_h */
