//
//  Header.h
//  jinchuhuo
//
//  Created by huangxu on 2016/12/27.
//  Copyright © 2016年 apple. All rights reserved.
//

#ifndef Header_h
#define Header_h

// 订单状态
typedef NS_ENUM(NSInteger, JCHTakeoutOrderStatus) {
    kJCHTakeoutOrderStatusNew = 3,                          // 新订单
    kJCHTakeoutOrderStatusToBeDelivery = 4,                 // 待配送
    kJCHTakeoutOrderStatusDidStartDelivery = 6,             // 开始配送
    kJCHTakeoutOrderStatusToBeCustomerConfirm = 7,          // 等待客户确认
    kJCHTakeoutOrderStatusCompleted = 8,                    // 已完成
    kJCHTakeoutOrderStatusCanceled = 9,                     // 已取消
    kJCHTakeoutOrderStatusRefundUntreated = 20,             // 用户申请退款（未处理退款）
    kJCHTakeoutOrderStatusRefundCompleted = 21,             // 退款处理完成
    kJCHTakeoutOrderStatusUrged,                            // 催单
};

// 栏目类型 （查询用，一个栏目可能包含多个订单状态）
typedef NS_ENUM(NSInteger, JCHTakeoutOrderSubfieldType) {
    kJCHTakeoutOrderSubfieldTypeNew = 0,                        // 新订单
    kJCHTakeoutOrderSubfieldTypeToBeDelivery = 1,               // 待配送
    kJCHTakeoutOrderSubfieldTypeDelivering = 2,                 // 配送中
    kJCHTakeoutOrderSubfieldTypeRefunding = 3,                  // 退款中
    kJCHTakeoutOrderSubfieldTypeRefunded = 4,                   // 退款处理完成
    kJCHTakeoutOrderSubfieldTypeBacked = 6,                     // 退单完成
    kJCHTakeoutOrderSubfieldTypeCompleted = 8,                  // 已完成
    kJCHTakeoutOrderSubfieldTypeCanceled = 9,                   // 已取消
};

// 外卖平台来源
typedef NS_ENUM(NSInteger, JCHTakeoutResource) {
    kJCHTakeoutResourceMeituan = 1,             // 美团
    kJCHTakeoutResourceEleme,                   // 饿了么
    kJCHTakeoutResourceBaidu,                   // 百度外卖
};


// 外卖付款方式
typedef NS_ENUM(NSInteger, JCHTakeoutPayType){
    kJCHTakeoutPayTypeDelivery = 1,           // 货到付款
    kJCHTakeoutPayTypeHasPayedOnline,         // 在线支付
};


// 退款 / 退单 状态
typedef NS_ENUM(NSInteger, JCHTakeoutRefundStatus) {
    kJCHTakeoutRefundStatusDisrelated = 0,                  // 非退款状态
    kJCHTakeoutRefundStatusStart,                           // 发起退款
    kJCHTakeoutRefundStatusConfirm,                         // 确认退款
    kJCHTakeoutRefundStatusReject,                          // 驳回退款
    kJCHTakeoutRefundStatusAppealStart,                     // 发起退款申诉
    kJCHTakeoutRefundStatusCustomerCancelRefund,            // 用户取消退款申请
    kJCHTakeoutRefundStatusCustomerCancelAppeal,            // 用户取消退款申诉
};

// 美团配送状态
//typedef NS_ENUM(NSInteger, JCHTakeoutMeituanShippingStatus) {
//    kJCHTakeoutMeituanShippingStatusStart = 0,               // 配送单发往配送
//    kJCHTakeoutMeituanShippingStatusCompleted = 40,          // 骑手已送达
//    kJCHTakeoutMeituanShippingStatusCancel = 100,            // 配送单已取消
//};


//// 外卖配送方式
//typedef NS_ENUM(NSInteger, JCHTakeoutDeliveryWay) {
//    kJCHTakeoutDeliverySelf,
//    kJCHTakeoutDeliveryQuHuo,
//    kJCHTakeoutDeliveryDaDa,
//    kJCHTakeoutDeliveryEDaiSong,
//    kJCHTakeoutDelivery,
//};

#endif /* Header_h */
