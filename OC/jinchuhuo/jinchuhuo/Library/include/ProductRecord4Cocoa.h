//
//  ProductRecord4Cocoa.h
//  iOSInterface
//
//  Created by apple on 15/8/3.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>


@class ProductItemRecord4Cocoa;

@interface TakeoutProductRecord4Cocoa : NSObject
@property(retain, nonatomic, readwrite) NSString *meituanBindID;             // 美团菜品的绑定id
@property(retain, nonatomic, readwrite) NSString *eleBindID;                 // 饿了么菜品的绑定id
@property(retain, nonatomic, readwrite) NSString *baiduBindID;               // 百度外卖菜品的绑定id
@property(assign, nonatomic, readwrite) NSInteger meituanStatus;             // 美团菜品的状态，默认为0, 未上架
@property(assign, nonatomic, readwrite) NSInteger eleStatus;                 // 饿了么菜品的状态，默认为0, 未上架
@property(assign, nonatomic, readwrite) NSInteger baiduStatus;               // 百度外卖菜品的状态，默认为0, 未上架
@property(assign, nonatomic, readwrite) NSInteger boxNum;                    // 餐盒数量
@property(assign, nonatomic, readwrite) double boxPrice;                     // 餐盒价格
@end

@interface ProductRecord4Cocoa : NSObject

@property(retain, nonatomic, readwrite) NSString *goods_domain;                // 资产域 (必填)   预定义 (国家货币，用户自定义，标准商品，股票市场，...)
@property(retain, nonatomic, readwrite) NSString *goods_name;                  // 资产名称 (必填)   预定义 (货币名称...；自种水果...;商品名称；A股股票代码...)
@property(retain, nonatomic, readwrite) NSString *goods_type;                  // 资产类型 (必填)   预定义 (枚举：货币类型，金融类型，商品类型，服务类型)
@property(retain, nonatomic, readwrite) NSString *goods_memo;                  //
@property(retain, nonatomic, readwrite) NSString *goods_image_name;            // 商品图片名称
@property(retain, nonatomic, readwrite) NSString *goods_image_name2;           // 商品图片名称
@property(retain, nonatomic, readwrite) NSString *goods_image_name3;           // 商品图片名称
@property(retain, nonatomic, readwrite) NSString *goods_image_name4;           // 商品图片名称
@property(retain, nonatomic, readwrite) NSString *goods_image_name5;           // 商品图片名称
@property(retain, nonatomic, readwrite) NSString *goods_property;              //
@property(retain, nonatomic, readwrite) NSString *goods_unit;                  // 资产单位 (必填)
@property(retain, nonatomic, readwrite) NSString *goods_code;                  //
@property(retain, nonatomic, readwrite) NSString *goods_category_path;         //  资产分类路径
@property(assign, nonatomic, readwrite) double goods_sell_price;               // 销售定价，价格 (必填)
@property(retain, nonatomic, readwrite) NSString *goods_currency;              // 计价的币种(必填) 默认是本位币
@property(assign, nonatomic, readwrite) NSInteger goods_unit_digits;           // 商品单位小数点位数
@property(assign, nonatomic, readwrite) BOOL goods_hiden_flag;                 // 标识商品是否为隐藏状态
@property(assign, nonatomic, readwrite) BOOL sku_hiden_flag;                   // 标识商品规格是否为隐藏状态
@property(retain, nonatomic, readwrite) NSString *goods_uuid;                  // goods uuid
@property(retain, nonatomic, readwrite) NSString *goods_unit_uuid;             // unit uuid
@property(retain, nonatomic, readwrite) NSString *goods_category_uuid;         // category uuid
@property(retain, nonatomic, readwrite) NSString *goods_sku_uuid;              // goods sku uuid
@property(retain, nonatomic, readwrite) NSString *goods_bar_code;              // 商品条码
@property(retain, nonatomic, readwrite) NSString *goods_merchant_code;         // 商家编码
@property(assign, nonatomic, readwrite) double goods_last_purchase_price;      // 上次进货价格
@property(retain, nonatomic, readwrite) NSString *productNamePinYin;           // 商品名称拼音
@property(assign, nonatomic, readwrite) NSInteger sort_index;                  // 排序索引
@property(assign, nonatomic, readwrite) BOOL has_sold_out;                     // 是否已估清
@property(assign, nonatomic, readwrite) BOOL is_multi_unit_enable;             // 是否启用主辅助单位
@property(retain, nonatomic, readwrite) NSDictionary *last_purchase_price_map; // 主辅单位商品进价<单位UUID, 商品进价>
@property(retain, nonatomic, readwrite) NSArray<ProductItemRecord4Cocoa *> *productItemList;   // 单品列表

// 外卖版
@property(retain, nonatomic, readwrite) TakeoutProductRecord4Cocoa *takoutRecord;
@property(retain, nonatomic, readwrite) NSString *cuisineProperty;             // 菜品的属性

// 查询时返回
@property(assign, nonatomic, readwrite) double topSaleAmount;                  // 销量排名对应的销售金额
@end


@interface ProductItemRecord4Cocoa : NSObject
@property(retain, nonatomic, readwrite) NSString *goodsUUID;                     // 商品UUID
@property(retain, nonatomic, readwrite) NSString *goodsUnitUUID;                 // 商品单位UUID
@property(retain, nonatomic, readwrite) NSString *goodsSkuUUID;                  // 商品规格UUID,不为空时优先使用这个
@property(retain, nonatomic, readwrite) NSArray<NSString *> *skuUUIDVector;      // 商品规格UUID,GoodsSkuUUID为空时,使用此vector查询数据库或生成新的记录
@property(retain, nonatomic, readwrite) NSString *imageName1;                    // 单品图片
@property(retain, nonatomic, readwrite) NSString *imageName2;                    // 单品图片
@property(retain, nonatomic, readwrite) NSString *imageName3;                    // 单品图片
@property(retain, nonatomic, readwrite) NSString *imageName4;                    // 单品图片
@property(retain, nonatomic, readwrite) NSString *imageName5;                    // 单品图片
@property(assign, nonatomic, readwrite) double itemPrice;                        // 单品价格
@property(retain, nonatomic, readwrite) NSString *itemBarCode;                   // 单品条码
@property(assign, nonatomic, readwrite) double ratio;                            // 1辅单位等于ratio主单位,换算比率
@property(retain, nonatomic, readwrite) NSString *unitName;                      // 辅单位名字
@property(assign, nonatomic, readwrite) int unitDigits;                          // 辅单位精度
@property(assign, nonatomic, readwrite) BOOL hasSoldOut;                         // 标记是否已估清
// 外卖版
@property(retain, nonatomic, readwrite) TakeoutProductRecord4Cocoa *takoutRecord;
@end


@interface ProductPriceRecord4Cocoa : NSObject
@property(retain, nonatomic, readwrite) NSString *goodsUUID;                     // 商品UUID
@property(retain, nonatomic, readwrite) NSString *goodsSkuUUID;                  // 商品规格UUID
@property(retain, nonatomic, readwrite) NSArray<NSString *> *skuUUIDVector;      // 商品规格UUID
@property(assign, nonatomic, readwrite) int customType;                          // 客户类型
@property(assign, nonatomic, readwrite) double itemPrice;                        // 单品价格
@end

@interface ProductUnitRecord4Cocoa : NSObject
@property(retain, nonatomic, readwrite) NSString *goodsUUID;                     // 商品UUID
@property(retain, nonatomic, readwrite) NSString *unitUUID;                      // 辅单位UUID
@property(assign, nonatomic, readwrite) double ratio;                            // 1辅单位等于ratio主单位,换算比率
// 以下只在查询的时候填写
@property(retain, nonatomic, readwrite) NSString *unitName;                      // 辅单位名字
@property(assign, nonatomic, readwrite) int unitDigits;                          // 辅单位精度
@end



