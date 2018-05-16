//
//  SKUService.h
//  iOSInterface
//
//  Created by apple on 15/11/18.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKURecord4Cocoa.h"

@protocol SKUService <NSObject>

- (int)addGoodsSKU:(NSString *)goodsSKUUUID skuUUID:(NSString *)skuValueUUID;
- (int)deleteGoodsSKU:(NSString *)goodsSKUUUID skuUUID:(NSString *)skuValueUUID;

- (int)addTransactionSKU:(NSString *)goodsSKUUUID skuUUID:(NSString *)skuValueUUID;
- (int)deleteTransactionSKU:(NSString *)goodsSKUUUID skuUUID:(NSString *)skuValueUUID;

- (int)addSKUValue:(SKUValueRecord4Cocoa *)skuValueRecord;
- (int)updateSKUValue:(SKUValueRecord4Cocoa *)skuValueRecord;
- (int)deleteSKUValue:(NSString *)skuValueUUID;
- (int)querySKUWithType:(NSString *)skuTypeUUID skuRecordVector:(NSArray **)skuRecordVector;
- (BOOL)isSKUValueCanBeDeleted:(NSString *)skuValueUUID;
- (BOOL)isSKUValueUsedInManifest:(NSString *)skuValueUUID;
- (BOOL)isSKUValueUsedInManifest:(NSString *)skuValueUUID goodsUUID:(NSString *)goodsUUID;

- (int)addSKUType:(SKUTypeRecord4Cocoa *)skuTypeRecord;
- (int)updateSKUType:(SKUTypeRecord4Cocoa *)skuTypeRecord;
- (int)deleteSKUType:(NSString *)skuTypeUUID;
- (BOOL)isSKUTypeCanBeDeleted:(NSString *)skuTypeUUID;
- (int)queryAllSKUType:(NSArray **)skuTypeArray;

- (int)queryGoodsSKU:(NSString *)goodsSKUUUID skuArray:(GoodsSKURecord4Cocoa **)goodsSKU;
- (int)queryAllGoodsSKU:(NSArray **)goodsSKUArray;
@end
