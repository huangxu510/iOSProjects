//
//  JCHTransactionUtility.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/9.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "ProductRecord4Cocoa.h"
#import "SKURecord4Cocoa.h"

@interface JCHTransactionUtility : NSObject


/*
        @{skuValuesCombineArray : skuValueUUIDsArray}   
 
        skuValuesCombineArray -> @[skuValueCombine1, skuValueCombine2, skuValueCombine3, ...]
        skuValueUUIDsArray -> @[skuValueUUIDs, skuValueUUIDs, skuValueUUIDs, ...]
 */
+ (NSDictionary *)getTransactionsWithData:(NSArray *)data;


//! @brief 添加货单时自定义键盘的折扣  float 转 string
+ (NSString *)getOrderDiscountFromFloat:(CGFloat)discount;


//! @brief 添加货单时自定义键盘的折扣  string 转 float
+ (CGFloat)getOrderDiscountFromString:(NSString *)discountStr;


//! @brief 判断两个skuUUIDs的组合是否相等
+ (BOOL)skuUUIDs:(NSArray<NSString *> *)skuUUIDs isEqualToArray:(NSArray<NSString *> *)otherskuUUIDs;


+ (NSArray *)fliterSKUInventoryRecordList:(NSArray *)skuInventoryRecordList forProduct:(ProductRecord4Cocoa *)productRecord;


//! @brief 根据价格数组得到价格区间
+ (NSString *)getPriceStringFrowPriceArray:(NSArray *)priceArray;

+ (NSArray *)getSKUCombineListWithGoodsSKURecord:(GoodsSKURecord4Cocoa *)goodsSKURecord;


@end
