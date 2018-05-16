//
//  TakeOutRecord.h
//  iOSInterface
//
//  Created by apple on 2016/12/12.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TakeOutMeiTuanBindShopRequest : NSObject

@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *bindName;
@property (retain, nonatomic, readwrite) NSString *serviceURL;

@end

@interface TakeOutElemeBindShopRequest : NSObject

@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *shopID;
@property (retain, nonatomic, readwrite) NSString *serviceURL;

@end


@interface TakeOutBindSyncRequest : NSObject

@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *resource;
@property (retain, nonatomic, readwrite) NSString *serviceURL;

@end


@interface PutAwayProductRequest : NSObject

@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSArray *dishList;
@property (retain, nonatomic, readwrite) NSString *resource;
@property (retain, nonatomic, readwrite) NSString *serviceURL;

@end


@interface DeleteProductRequest : NSObject

@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSDictionary *dishList;
@property (retain, nonatomic, readwrite) NSString *serviceURL;

@end


@interface SoldOutProductRequest : NSObject

@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *resource;
@property (retain, nonatomic, readwrite) NSArray *dishIDList;
@property (retain, nonatomic, readwrite) NSString *serviceURL;

@end


@interface QueryProductPriceRequest : NSObject

@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *resource;
@property (retain, nonatomic, readwrite) NSArray *dishIDList;
@property (retain, nonatomic, readwrite) NSString *serviceURL;

@end

@interface AddCategoryRequest : NSObject

@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (assign, nonatomic, readwrite) NSInteger index;
@property (retain, nonatomic, readwrite) NSString *name;
@property (retain, nonatomic, readwrite) NSString *serviceURL;

@end

@interface UpdateCategoryRequest : NSObject

@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *oldName;
@property (retain, nonatomic, readwrite) NSString *currentNewName;
@property (assign, nonatomic, readwrite) NSInteger index;
@property (retain, nonatomic, readwrite) NSString *serviceURL;

@end

//! @brief 外卖服务器 - 删除菜品分类
@interface DeleteCategoryRequest : NSObject

@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSArray *nameList;
@property (retain, nonatomic, readwrite) NSString *serviceURL;

@end

//! @brief 外卖服务器 - 查询订单
@interface TakeOutQueryOrderRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (assign, nonatomic, readwrite) NSInteger offset;
@property (assign, nonatomic, readwrite) NSInteger limit;
@property (assign, nonatomic, readwrite) NSInteger status;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

//! @brief 外卖服务器 - 确认接单
@interface TakeOutConfirmOrderRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *resource;
@property (retain, nonatomic, readwrite) NSString *orderId;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

@interface TakeOutCancelOrderRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *resource;
@property (retain, nonatomic, readwrite) NSString *orderId;
@property (retain, nonatomic, readwrite) NSString *reason;
@property (retain, nonatomic, readwrite) NSString *reasonCode;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

//! @brief 外卖服务器 - 统计未处理订单
@interface UntreatedOrderStatisticsRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

//! @brief 外卖服务器 - 配送
@interface DeliveryRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *resource;
@property (retain, nonatomic, readwrite) NSString *orderId;
@property (retain, nonatomic, readwrite) NSString *type;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

//! @brief 外卖服务器 - 配送完成
@interface DeliveryCompleteRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *resource;
@property (retain, nonatomic, readwrite) NSString *orderId;
@property (retain, nonatomic, readwrite) NSString *type;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

//! @brief 外卖服务器 - 取消配送
@interface DeliveryCancelRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *resource;
@property (retain, nonatomic, readwrite) NSString *orderId;
@property (retain, nonatomic, readwrite) NSString *type;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

//! @brief 外卖服务器 - 绑定状态查询
@interface QueryBindStatusRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

//! @brief 外卖服务器 - 拉取已完成订单
@interface FetchCompleteOrderRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

//! @brief 外卖服务器 - 店铺开业停业
@interface OpencloseShopRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *operate;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

//! @brief 外卖服务器 - 店铺设置营业时间
@interface SetServiceTimeRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *serviceTime;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

//! @brief 外卖服务器 - 注册
@interface RegisterAccountBookRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *name;
@property (retain, nonatomic, readwrite) NSString *address;
@property (retain, nonatomic, readwrite) NSString *latitude;
@property (retain, nonatomic, readwrite) NSString *longitude;
@property (retain, nonatomic, readwrite) NSString *phone;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

//! @brief 外卖服务器 - 自动接单状态查询
@interface QueryAutoReceiveOrderRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

//! @brief 外卖服务器 - 自动接单设置
@interface SetAutoReceiveOrderRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (assign, nonatomic, readwrite) NSInteger status;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

//! @brief 外卖服务器 - 店铺信息查询
@interface QueryShopInfoRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

//! @brief 外卖服务器 - 基于单号查询订单信息
@interface QueryOrderByIDRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *resource;
@property (retain, nonatomic, readwrite) NSArray *orderIDList;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

@interface RefuseRefundRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *resource;
@property (retain, nonatomic, readwrite) NSString *orderId;
@property (retain, nonatomic, readwrite) NSString *reason;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

@interface AcceptRefundRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *resource;
@property (retain, nonatomic, readwrite) NSString *orderId;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

@interface FetchBackOrderRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

