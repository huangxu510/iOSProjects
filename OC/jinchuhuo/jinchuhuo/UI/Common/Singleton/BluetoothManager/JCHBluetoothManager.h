//
//  JCHBluetoothHelper.h
//  jinchuhuo
//
//  Created by huangxu on 15/11/23.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "JCHPrintInfoModel.h"


typedef NS_ENUM(NSInteger, JCHPrintRepeatCount) {
    kJCHPrintRepeatCountOne,
    kJCHPrintRepeatCountTwo,
    kJCHPrintRepeatCountThree,
};

typedef NS_ENUM(NSInteger, JCHPrintMeanwhileItem) {
    kJCHPrintMeanwhileItemNone,
    kJCHPrintMeanwhileItemLabel,
};

typedef NS_ENUM(NSInteger, JCHDefaultPrintType) {
    kJCHDefaultPrintTypeReceipt,
    kJCHDefaultPrintTypeLabel,
};


@interface JCHBluetoothManager : NSObject

@property (nonatomic, assign) BOOL canPrintInShipment;                                  // 出货可打印
@property (nonatomic, assign) BOOL canPrintInPurchase;                                  // 进货可打印
@property (nonatomic, assign) BOOL canPrintInManifestDetail;                            // 货单详情可打印

@property (nonatomic, assign) JCHPrintRepeatCount printRepeatCount;                     // 重复打印份数
@property (nonatomic, assign) JCHPrintMeanwhileItem printMeanwhileItem;                 // 同时打印
@property (nonatomic, assign) JCHDefaultPrintType defaultPrintType;                     // 默认打印票据类型

@property (retain, nonatomic) JCHTakeoutPrintInfoModel *takeoutPrintInfo;               // 外卖版打印信息


+ (instancetype)shareInstance;

// 自动连接上次连接的设备
- (void)autoConnectLastPeripheral;



#pragma mark  -  打印方法
//! @brief 普通版打印
- (void)printManifest:(JCHPrintInfoModel *)model showHud:(BOOL)hud;

//! @brief 外卖版打印
- (void)printTakeoutProductList:(NSArray *)productList showHud:(BOOL)hud;

//! @brief 外卖版根据服务器返回的订单信息打印订单
- (void)printTakeoutOrderInfo:(NSDictionary *)orderInfo;

//! @brief 餐厅版打印
- (void)printRestaurantProductList:(NSArray *)productList showHud:(BOOL)hud;

@end

