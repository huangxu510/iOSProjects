//
//  TransactionRecord.h
//  iOSInterface
//
//  Created by apple on 15/7/29.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface TransactionRecord4Cocoa : NSObject

@property (retain, nonatomic, readwrite) NSString *transId;                       // 交易流水号，相同流水号的多条记录视为同一笔交易， 一笔交易必须平账 (必填)
@property (assign, nonatomic, readwrite) NSInteger transSide;                     // 流水方向 =-1，出；=+1，入 (必填)
@property (retain, nonatomic, readwrite) NSString *transMemo;                      //
@property (retain, nonatomic, readwrite) NSString *transProperty;                  //
@property (assign, nonatomic, readwrite) NSInteger transTime;                     // 入账时间：UTC不带时区的时间，本地化后再显示
@property (assign, nonatomic, readwrite) NSInteger transBaltype;                  // 平帐类型 (必填) =1 ：一出一入类型，出入要平衡
@property (assign, nonatomic, readwrite) NSInteger accountSchema;                 // 科目字段结构版本号 (必填)
@property (retain, nonatomic, readwrite) NSString *accountDomain;                  //
@property (retain, nonatomic, readwrite) NSString *accountName;                    // 科目名称 (必填)
@property (retain, nonatomic, readwrite) NSString *accountType;                    // 科目类型，用于科目间核算规则
@property (retain, nonatomic, readwrite) NSString *accountMemo;                    //
@property (retain, nonatomic, readwrite) NSString *accountProperty;                //
@property (retain, nonatomic, readwrite) NSString *accountCode;                    //
@property (assign, nonatomic, readwrite) NSInteger goodsSchema;                   // 资产字段结构版本号 (必填)
@property (retain, nonatomic, readwrite) NSString *goodsDomain;                    // 资产域 (必填)   预定义 (国家货币，用户自定义，标准商品，股票市场，...)
@property (retain, nonatomic, readwrite) NSString *goodsName;                      // 资产名称 (必填)   预定义 (货币名称...；自种水果...;商品名称；A股股票代码...)
@property (retain, nonatomic, readwrite) NSString *goodsType;                      // 资产类型 (必填)   预定义 (枚举：货币类型，金融类型，商品类型，服务类型)
@property (retain, nonatomic, readwrite) NSString *goodsMemo;                      //
@property (retain, nonatomic, readwrite) NSString *goodsProperty;                  //
@property (assign, nonatomic, readwrite) CGFloat goodsAmount;                      // 资产数量 (必填)
@property (assign, nonatomic, readwrite) CGFloat goodsDiscount;                    // 资产数量 (必填)
@property (retain, nonatomic, readwrite) NSString *goodsUnit;                      // 资产折扣 (必填)
@property (assign, nonatomic, readwrite) CGFloat goodsPrice;                       // 价格 (必填)
@property (retain, nonatomic, readwrite) NSString *goodsCurrency;                  // 计价的币种(必填) 默认是本位币, 备注：同一个交易号trans_id下的多条流水使用相同的币种
@property (retain, nonatomic, readwrite) NSString *goodsCode;                      //
@property (assign, nonatomic, readwrite) NSInteger orderSchema;                   // 订单字段结构版本号
@property (assign, nonatomic, readwrite) NSInteger orderType;                     // 订单类型
@property (retain, nonatomic, readwrite) NSString *orderId;                        // 订单号
@property (assign, nonatomic, readwrite) NSInteger orderStatus;                   // 订单状态: 0--正常，1--已退单，2--作废
@property (retain, nonatomic, readwrite) NSString *orderRelativeId;                // 订单退单号@property (retain, nonatomic, readwrite)

@property (retain, nonatomic, readwrite) NSString *warehouseUUID;                   // warehouse uuid
@property (retain, nonatomic, readwrite) NSString *transactionUUID;                 // transaction uuid
@property (retain, nonatomic, readwrite) NSString *unitUUID;                        // unit uuid
@property (retain, nonatomic, readwrite) NSString *goodsNameUUID;                   // goods name uuid
@property (retain, nonatomic, readwrite) NSString *goodsCategoryUUID;               // goods category uuid
@property (retain, nonatomic, readwrite) NSString *goodsSKUUUID;                    // goods sku uuid

@end


@interface TransactionInsertRecord4Cococa : NSObject
@property(retain, nonatomic, readwrite) NSString *productName;
@property(retain, nonatomic, readwrite) NSString *productCategory;
@property(retain, nonatomic, readwrite) NSString *productImageName;
@property(assign, nonatomic, readwrite) CGFloat productCount;
@property(assign, nonatomic, readwrite) CGFloat productDiscount;
@property(assign, nonatomic, readwrite) CGFloat productPrice;
@property(retain, nonatomic, readwrite) NSString *productUnit;
@property(retain, nonatomic, readwrite) NSString *warehouseUUID;                   // warehouse uuid
@property(retain, nonatomic, readwrite) NSString *transactionUUID;                 // transaction uuid
@property(retain, nonatomic, readwrite) NSString *unitUUID;                        // unit uuid
@property(retain, nonatomic, readwrite) NSString *goodsNameUUID;                   // goods name uuid
@property(retain, nonatomic, readwrite) NSString *goodsCategoryUUID;               // goods category uuid
@property(retain, nonatomic, readwrite) NSString *goodsSKUUUID;                    // goods sku uuid

@end
