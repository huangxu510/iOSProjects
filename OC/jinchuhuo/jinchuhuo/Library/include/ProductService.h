//
//  ProductService.h
//  iOSInterface
//
//  Created by apple on 15/8/4.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductRecord4Cocoa.h"
#import "SKURecord4Cocoa.h"

@protocol ProductService <NSObject>

- (int)insertProduct:(ProductRecord4Cocoa *)record
       beginingCount:(double)beginningCount
      beginningPrice:(double)beginningPrice;

- (int)updateProduct:(ProductRecord4Cocoa *)record
       beginingCount:(double)beginningCount
      beginningPrice:(double)beginningPrice;

- (int)addProduct:(ProductRecord4Cocoa *)record
     recordVector:(NSArray<BeginningInventoryInfoRecord4Cocoa *> *)recordVector;


- (int)updateProduct:(ProductRecord4Cocoa *)record
        recordVector:(NSArray<BeginningInventoryInfoRecord4Cocoa *> *)recordVector;

- (int)updateProduct:(ProductRecord4Cocoa *)record;

- (int)updateProductSortIndex:(NSString *)productUUID
                    sortIndex:(NSInteger)sortIndex;


- (int)deleteProduct:(NSString *)productUUID;
- (int)isProductCanBeDeleted:(NSString *)productUUID
                canBeDeleted:(BOOL *)canBeDeleted;
- (NSArray *)queryAllProduct;
- (ProductRecord4Cocoa *)queryProductByUUID:(NSString *)productUUID;

- (int)addOrUpdateProductItem:(ProductItemRecord4Cocoa*)record;
- (int)deleteGoodsItem:(NSString *)goodsUUID unitUUID:(NSString *)unitUUID skuUUID:(NSString *)skuUUID;
- (NSArray<ProductItemRecord4Cocoa *> *)queryGoodsItem:(NSString *)goodsUUID unitUUID:(NSString *)unitUUID skuUUID:(NSString *)skuUUID;
- (NSArray<ProductItemRecord4Cocoa *> *)querySkuGoodsItem:(NSString *)goodsUUID;
- (NSArray<ProductItemRecord4Cocoa *> *)queryUnitGoodsItem:(NSString *)goodsUUID;
- (int)addOrUpdateProductItemPrice:(ProductPriceRecord4Cocoa*)record;
- (int)deleteGoodsItemPrice:(NSString *)goodsUUID unitUUID:(NSString *)unitUUID skuUUID:(NSString *)skuUUID customType:(NSInteger)customType;
- (NSArray<ProductPriceRecord4Cocoa*> *)queryGoodsItemPrice:(NSString *)goodsUUID;
- (int)addGoodsUnit:(ProductUnitRecord4Cocoa *)record;
- (int)updateGoodsUnit:(ProductUnitRecord4Cocoa *)record;
- (int)deleteGoodsUnit:(NSString *)goodsUUID;
- (int)deleteGoodsUnit:(NSString *)goodsUUID unitUUID:(NSString *)unitUUID;
- (NSArray<ProductUnitRecord4Cocoa*> *)queryGoodsUnit;
- (NSArray<ProductUnitRecord4Cocoa*> *)queryGoodsUnit:(NSString *)goodsUUID;
- (ProductUnitRecord4Cocoa *)queryGoodsUnit:(NSString *)goodsUUID unitUUID:(NSString *)unitUUID;

//! @brief 添加菜品
- (int)addCuisine:(ProductRecord4Cocoa *)record;

//! @brief 更新商品
- (int)updateCuisine:(ProductRecord4Cocoa *)record;

//! @brief 删除菜品
- (int)deleteCuisine:(NSString *)productUUID;

//! @brief 查询菜品
- (NSArray *)queryAllCuisine:(BOOL)bFiltDeletedProduct;

//! @brief 查询菜品
- (ProductRecord4Cocoa *)queryCuisine:(NSString *)productUUID;

//! @brief 设置单品的估清标志
- (int)setProductItemSoldOutFlag:(NSArray<ProductItemRecord4Cocoa *> *)itemList soldOut:(BOOL)hasSoldOut;

@end
