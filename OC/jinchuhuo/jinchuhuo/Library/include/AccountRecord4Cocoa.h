//
//  AccountRecord4Cocoa.h
//  iOSInterface
//
//  Created by apple on 15/8/3.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AccountRecord4Cocoa : NSObject

@property (retain, nonatomic, readwrite) NSString *accountDomain;            // 科目域
@property (retain, nonatomic, readwrite) NSString *accountName;              // 科目名称 (必填)
@property (retain, nonatomic, readwrite) NSString *accountType;              // 科目类型，用于科目间核算规则
@property (retain, nonatomic, readwrite) NSString *accountMemo;              //
@property (retain, nonatomic, readwrite) NSString *accountProperty;          //
@property (retain, nonatomic, readwrite) NSString *accountCode;              // 科目代码（用户定义）
@property (retain, nonatomic, readwrite) NSString *accountCategoryPath;      // 科目分类路径
@property (assign, nonatomic, readwrite) NSInteger bindGoodsSchema;          // 资产字段结构版本号 (必填)
@property (retain, nonatomic, readwrite) NSString *bindGoodsDomain;          // 资产域 (必填)   预定义 (国家货币，用户自定义，标准商品，股票市场，...)
@property (retain, nonatomic, readwrite) NSString *bindGoodsName;            // 资产名称 (必填)   预定义 (货币名称...；自种水果...;商品名称；A股股票代码...)
@property (retain, nonatomic, readwrite) NSString *bindGoodsType;            // 资产类型 (必填)   预定义 (枚举：货币类型，金融类型，商品类型，服务类型)
@property (retain, nonatomic, readwrite) NSString *bindGoodsUnit;            // 资产单位 (必填)
@property (retain, nonatomic, readwrite) NSString *bindGoodsCode;            //
@property (assign, nonatomic, readwrite) CGFloat   balanceGoodsAmount;       // 资产合计数量 (可选)该科目对应资产的合计数量
@property (assign, nonatomic, readwrite) CGFloat   balanceGoodsPrice;        // 价格均价 = 资产总值／资产合计数量
@property (assign, nonatomic, readwrite) NSInteger balanceTime;              // 该科目合计计算时间
@property (retain, nonatomic, readwrite) NSString *balanceGoodsCurrency;     // 计价的币种 默认是本位币
@property (retain, nonatomic, readwrite) NSString *accountUUID;              // account uuid
@property (assign, nonatomic, readwrite) NSInteger accountMark;              // 核算标记
@property (assign, nonatomic, readwrite) NSInteger accountCurrency;           // 账户货币类型: 1 -- 人民币, 2 -- 美元
@property (retain, nonatomic, readwrite) NSString *accountParentUUID;         // 父级账户UUID

@end
