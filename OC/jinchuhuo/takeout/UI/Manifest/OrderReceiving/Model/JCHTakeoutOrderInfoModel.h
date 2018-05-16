//
//  JCHTakeoutOrderInfoModel.h
//  jinchuhuo
//
//  Created by huangxu on 2017/1/13.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NSObject+YYModel.h>
#import "CommonHeader.h"

// 退款时间模型
@interface JCHTakeoutOrderRefundTimeModel : NSObject

@property (nonatomic, assign) NSInteger refundTime;             // 用户申请退款时间
@property (nonatomic, assign) NSInteger agreeTime;              // 商家同意退款时间
@property (nonatomic, assign) NSInteger rejectRefundTime;       // 拒绝退款时间
@property (nonatomic, assign) NSInteger complaintTime;          // 申诉时间
@property (nonatomic, assign) NSInteger cancelTime;             // 取消退款时间
@property (nonatomic, assign) NSInteger cancelComplaintTime;    // 取消申诉时间
@property (nonatomic, assign) NSInteger agreeComplaintTime;     // 同意申诉时间
@property (nonatomic, assign) NSInteger rejectComplaintTime;    // 拒绝申诉时间

@end

// 退款原因模型
@interface JCHTakeoutOrderRefundReasonModel : NSObject

@property (nonatomic, retain) NSString *refundReason;                                   // 退款原因
@property (nonatomic, retain) NSString *refundDealReason;                               // 退款处理原因
@property (nonatomic, retain) NSString *complaintReason;                                // 退款申诉原因
@property (nonatomic, retain) NSString *complaintDealReason;                            // 退款申诉处理原因

@end

// 退单时间模型
@interface JCHTakeoutOrderBackTimeModel : NSObject

@property (nonatomic, assign) NSInteger backTime;               // 用户申请退单时间
@property (nonatomic, assign) NSInteger agreeTime;              // 商家同意退款时间
@property (nonatomic, assign) NSInteger rejectBackTime;         // 拒绝退款时间
@property (nonatomic, assign) NSInteger complaintTime;          // 申诉时间
@property (nonatomic, assign) NSInteger cancelTime;             // 取消退款时间
@property (nonatomic, assign) NSInteger cancelComplaintTime;    // 取消申诉时间
@property (nonatomic, assign) NSInteger agreeComplaintTime;     // 同意申诉时间
@property (nonatomic, assign) NSInteger rejectComplaintTime;    // 拒绝申诉时间

@end

// 退单原因模型
@interface JCHTakeoutOrderBackReasonModel : NSObject

@property (nonatomic, retain) NSString *backReason;                                     // 退单原因
@property (nonatomic, retain) NSString *backDealReason;                                 // 退单处理原因
@property (nonatomic, retain) NSString *backComplaintReason;                            // 退单申诉原因
@property (nonatomic, retain) NSString *backComplaintDealReason;                        // 退单申诉处理原因

@end

// 订单菜品详情模型
@interface JCHTakeoutOrderInfoDishModel : NSObject

@property (nonatomic, retain) NSString *foodName;
@property (nonatomic, retain) NSString *foodId;
@property (nonatomic, assign) NSInteger quantity;
@property (nonatomic, assign) CGFloat price;
@property (nonatomic, retain) NSString *skuName;
@property (nonatomic, retain) NSString *foodProperty;
@property (nonatomic, assign) NSInteger boxNum;
@property (nonatomic, assign) CGFloat boxPrice;

@end

// 订单模型
@interface JCHTakeoutOrderInfoModel : NSObject

@property (nonatomic, assign) JCHTakeoutResource resource;                              // 外卖平台
@property (nonatomic, assign) NSTimeInterval orderTime;                                 // 订单时间
@property (nonatomic, retain) NSString *orderId;                                        // 订单id
@property (nonatomic, retain) NSString *orderIdView;                                    // 展示的订单id
@property (nonatomic, retain) NSString *recipientName;                                  // 客户姓名
@property (nonatomic, retain) NSString *recipientAddress;                               // 客户地址
@property (nonatomic, retain) NSString *recipientPhone;                                 // 客户电话
@property (nonatomic, assign) JCHTakeoutPayType payType;                                // 支付方式
@property (nonatomic, assign) CGFloat orderTotalAmount;                                 // 订单总金额
@property (nonatomic, assign) JCHTakeoutOrderStatus orderStatus;                        // 订单状态
@property (nonatomic, assign) NSInteger deliveryWay;                                    // 配送方式

// 退款相关
@property (nonatomic, assign) JCHTakeoutRefundStatus refundStatus;                      // 退款状态
@property (nonatomic, retain) JCHTakeoutOrderRefundTimeModel *refundTimeInfo;           // 退款相关时间
@property (nonatomic, retain) JCHTakeoutOrderRefundReasonModel *refundReasonInfo;       // 退款相关原因

// 退单相关
@property (nonatomic, assign) JCHTakeoutRefundStatus backStatus;                        // 退单状态
@property (nonatomic, retain) JCHTakeoutOrderBackTimeModel *backTimeInfo;               // 退单相关时间
@property (nonatomic, retain) JCHTakeoutOrderBackReasonModel *backReasonInfo;           // 退单相关原因

@property (nonatomic, assign) CGFloat shippingFee;                                      // 配送费
@property (nonatomic, retain) NSString *caution;                                        // 备注
@property (nonatomic, retain) NSArray<JCHTakeoutOrderInfoDishModel *> *detail;          // 菜品详情

@property (nonatomic, assign) BOOL dishInfoExpanded;                                    // 菜品信息 是否展开
@property (nonatomic, assign) BOOL refundInfoExpanded;                                  // 退款信息是否展开

@end



