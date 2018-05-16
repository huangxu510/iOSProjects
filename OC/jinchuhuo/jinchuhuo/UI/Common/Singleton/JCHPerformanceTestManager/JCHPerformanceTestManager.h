//
//  JCHPerformanceTestManager.h
//  jinchuhuo
//
//  Created by huangxu on 16/7/7.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JCHPerformanceTestManager : NSObject

//! @brief 进出货时商品列表的加载时间
@property (nonatomic, assign) CGFloat productListLoadTime;

//! @brief 货单列表加载时间
@property (nonatomic, assign) CGFloat manifestListLoadTime;

//! @brief 库存列表加载时间
@property (nonatomic, assign) CGFloat inventoryListLoadTime;

//! @brief 货单详情加载时间
@property (nonatomic, assign) CGFloat manifestDetailLoadTime;

//! @brief 库存详情加载时间
@property (nonatomic, assign) CGFloat inventoryDetailLoadTime;

//! @brief 出货分析加载时间
@property (nonatomic, assign) CGFloat shipmentAnalyseLoadTime;

//! @brief 进货分析加载时间
@property (nonatomic, assign) CGFloat purchaseAnalyseLoadTime;

//! @brief 毛利分析加载时间
@property (nonatomic, assign) CGFloat profitAnalyseLoadTime;

//! @brief 库存分析加载时间
@property (nonatomic, assign) CGFloat inventoryAnalyseLoadTime;

//! @brief 账户首页加载时间
@property (nonatomic, assign) CGFloat accountBookLoadTime;

//! @brief 现金账户加载时间
@property (nonatomic, assign) CGFloat cashAccountLoadTime;

//! @brief 总应收账款加载时间
@property (nonatomic, assign) CGFloat receiptAccountLoadTime;

//! @brief 个人应收账款加载时间
@property (nonatomic, assign) CGFloat receiptAccountForSomebodyLoadTime;

//! @brief 总应付账款加载时间
@property (nonatomic, assign) CGFloat paymentAccountLoadTime;

//! @brief 个人应付账款加载时间
@property (nonatomic, assign) CGFloat paymentAccountForSomebodyLoadTime;

//! @brief 储值卡账户流水加载时间
@property (nonatomic, assign) CGFloat savingCardAccountLoadTime;

+ (instancetype)shareInstance;

@end
