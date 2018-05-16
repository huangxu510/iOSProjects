//
//  TakeOutOrderService.h
//  iOSInterface
//
//  Created by apple on 2016/12/23.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TakeOutRecord.h"

@protocol TakeOutService <NSObject>

//! @brief 外卖服务器 - 美团绑定接口
- (void)meituanBindShop:(TakeOutMeiTuanBindShopRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 饿了么绑定接口
- (void)elemeBindShop:(TakeOutElemeBindShopRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 首次绑定同步数据接口
- (void)bindShopSync:(TakeOutBindSyncRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 美团商品上架
- (void)putAwayProduct:(PutAwayProductRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 美团商品删除
- (void)deleteProduct:(DeleteProductRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 美团商品下架
- (void)soldOutProduct:(SoldOutProductRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 美团商品价格查询
- (void)queryProductPrice:(QueryProductPriceRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 分类新增
- (void)addCategory:(AddCategoryRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 分类更新
- (void)updateCategory:(UpdateCategoryRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 分类删除
- (void)deleteCategory:(DeleteCategoryRequest *)request callback:(void(^)(id response))callback;

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

//! @brief 外卖服务器 - 绑定状态查询
- (void)queryBindStatus:(QueryBindStatusRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 拉取已完成订单
- (void)fetchCompleteOrder:(FetchCompleteOrderRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 店铺开业停业
- (void)opencloseShop:(OpencloseShopRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 店铺设置营业时间
- (void)setServiceTime:(SetServiceTimeRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 注册
- (void)registerAccountBook:(RegisterAccountBookRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 自动接单状态查询
- (void)queryAutoReceiveOrder:(QueryAutoReceiveOrderRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 自动接单设置
- (void)setAutoReceiveOrder:(SetAutoReceiveOrderRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 店铺信息查询
- (void)queryShopInfo:(QueryShopInfoRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 查询订单-根据订单id数组
- (void)queryOrderByID:(QueryOrderByIDRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 同意退款
- (void)acceptRefund:(AcceptRefundRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 拒绝退款
- (void)refuseRefund:(RefuseRefundRequest *)request callback:(void(^)(id response))callback;

//! @brief 外卖服务器 - 拉取已退单订单
- (void)fetchBackOrder:(FetchBackOrderRequest *)request callback:(void(^)(id response))callback;


@end
