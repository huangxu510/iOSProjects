//
//  TakeOutOrderService.h
//  iOSInterface
//
//  Created by apple on 2016/12/23.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TakeOutRecord.h"

@protocol TakeOutOrderService <NSObject>

//! @brief 外卖服务器 - 查询
- (void)queryOrder:(TakeOutQueryOrderRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 确认
- (void)confirmOrder:(TakeOutConfirmOrderRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 取消
- (void)cancelOrder:(TakeOutCancelOrderRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 统计未处理订单
- (void)untreatedOrderStatistics:(UntreatedOrderStatisticsRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 配送
- (void)delivery:(DeliveryRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 配送完成
- (void)deliveryComplete:(DeliveryCompleteRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 取消配送
- (void)deliveryCancel:(DeliveryCancelRequest *)request callback:(void(^)(id response))callback;

@end
