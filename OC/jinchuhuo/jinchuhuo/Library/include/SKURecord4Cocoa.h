//
//  SKURecord4Cocoa.h
//  iOSInterface
//
//  Created by apple on 15/11/18.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

//! @brief SKU类型
@interface SKUTypeRecord4Cocoa : NSObject
@property(retain, nonatomic, readwrite) NSString *skuTypeUUID;
@property(retain, nonatomic, readwrite) NSString *skuTypeName;
@property(assign, nonatomic, readwrite) NSInteger skuSortIndex;
@end

//! @brief SKU值
@interface SKUValueRecord4Cocoa : NSObject
@property(retain, nonatomic, readwrite) NSString *skuTypeUUID;
@property(retain, nonatomic, readwrite) NSString *skuValueUUID;
@property(retain, nonatomic, readwrite) NSString *skuType;
@property(retain, nonatomic, readwrite) NSString *skuValue;
@end

//! @brief 商品SKU列表
@interface GoodsSKURecord4Cocoa : NSObject
@property(retain, nonatomic, readwrite) NSString *goodsSKUUUID;
@property(retain, nonatomic, readwrite) NSMutableArray *skuArray;
@end


//! @brief 期初库存信息
@interface BeginningInventoryInfoRecord4Cocoa : NSObject

//! @brief 规格组合(此字段只在添加/修改商品期初库存时传入，查询时不付出)
@property (retain, nonatomic, readwrite) NSArray *skuUUIDVector;

//! @brief 期初金额
@property (assign, nonatomic, readwrite) double beginningPrice;

//! @brief 期初库存
@property (assign, nonatomic, readwrite) double beginningCount;

//! @brief 商品单位
@property (retain, nonatomic, readwrite) NSString *unitName;

//! @brief 单位UUID
@property (retain, nonatomic, readwrite) NSString *unitUUID;

//! @brief 仓库UUID
@property (retain, nonatomic, readwrite) NSString *warehouseUUID;

//! @brief 此字段只在查询商品期初库存时传出，添加/修改期初库存时不需要传入(默认为nil即可)
@property (retain, nonatomic, readwrite) GoodsSKURecord4Cocoa *goodsSkuRecord;

@end
