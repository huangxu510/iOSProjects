//
//  InventoryRecord4Cocoa.h
//  iOSInterface
//
//  Created by apple on 15/9/1.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SKUInventoryRecord4Cocoa : NSObject
@property(assign, nonatomic, readwrite) CGFloat currentTotalPurchasesCount;
@property(assign, nonatomic, readwrite) CGFloat currentTotalShipmentCount;
@property(assign, nonatomic, readwrite) CGFloat currentInventoryCount;
@property(assign, nonatomic, readwrite) CGFloat shipmentPrice;
@property(assign, nonatomic, readwrite) CGFloat averageCostPrice;
@property(retain, nonatomic, readwrite) NSString *productSKUUUID;
@end

@interface InventoryDetailRecord4Cocoa : NSObject
@property(retain, nonatomic, readwrite) NSString *productName;
@property(retain, nonatomic, readwrite) NSString *productNamePinYin;
@property(retain, nonatomic, readwrite) NSString *productCategory;
@property(retain, nonatomic, readwrite) NSString *productUnit;
@property(retain, nonatomic, readwrite) NSString *productImageName;
@property(retain, nonatomic, readwrite) NSString *productRemark;
@property(assign, nonatomic, readwrite) NSInteger productLatestPurchaseTime;
@property(assign, nonatomic, readwrite) NSInteger productLatestShipmentTime;
@property(assign, nonatomic, readwrite) CGFloat currentInventoryCount;
@property(assign, nonatomic, readwrite) CGFloat shipmentPrice;
@property(assign, nonatomic, readwrite) CGFloat purchasesPrice;
@property(assign, nonatomic, readwrite) CGFloat averageCostPrice;
@property(assign, nonatomic, readwrite) CGFloat currentTotalPurchasesCount;
@property(assign, nonatomic, readwrite) CGFloat currentTotalShipmentCount;
@property(assign, nonatomic, readwrite) CGFloat currentTotalPurchaseCost;
@property(retain, nonatomic, readwrite) NSString *productCategoryUUID;
@property(retain, nonatomic, readwrite) NSString *productNameUUID;
@property(retain, nonatomic, readwrite) NSString *productUnitUUID;
@property(retain, nonatomic, readwrite) NSArray *productSKUInventoryArray;
@property(retain, nonatomic, readwrite) NSString *productBarCode;              // 商品条码
@property(retain, nonatomic, readwrite) NSString *productMerchantCode;         // 商家编码
@property(retain, nonatomic, readwrite) NSString *productSKUUUID;              

//! @brief 便于上层业务处理数据及UI展示
@property(assign, nonatomic, readwrite) NSInteger unitDigits;

@end
