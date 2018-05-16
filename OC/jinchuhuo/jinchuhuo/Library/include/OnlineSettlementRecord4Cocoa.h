//
//  OnlineSettlementRecord4Cocoa.h
//  iOSInterface
//
//  Created by apple on 16/3/10.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#pragma mark -
#pragma mark 绑定微信支付账户
@interface BindWeiXinPayAccountRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@property (retain, nonatomic, readwrite) NSString *bindID;
@property (retain, nonatomic, readwrite) NSString *merchantID;
@end




#pragma mark -
#pragma mark 查询微信支付绑定状态
@interface QueryWeiXinPayAccountBindStatusRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@property (retain, nonatomic, readwrite) NSString *bookID;
@end




#pragma mark -
#pragma mark 微信支付
@interface WeiXinPayRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *manifestID;
@property (retain, nonatomic, readwrite) NSString *bindID;
@property (retain, nonatomic, readwrite) NSString *authCode;
@property (retain, nonatomic, readwrite) NSString *goodsName;
@property (assign, nonatomic, readwrite) NSInteger payAmount;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end



#pragma mark -
#pragma mark 查询微信支付结果
@interface QueryWeiXinPayResultRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *bindID;
@property (retain, nonatomic, readwrite) NSString *manifestID;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end


#pragma mark -
#pragma mark 微信退款
@interface WeiXinRefundRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *manifestID;
@property (retain, nonatomic, readwrite) NSString *bindID;
@property (retain, nonatomic, readwrite) NSString *payTransId;
@property (retain, nonatomic, readwrite) NSString *refundTransId;
@property (assign, nonatomic, readwrite) NSInteger refundFee;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

#pragma mark -
#pragma mark 微信退款状态查询
@interface QueryWeiXinRefundResultRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *bindID;
@property (retain, nonatomic, readwrite) NSString *refundTransId;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

#pragma mark -
#pragma mark IAP购买校验查询
@interface IAPByResultVerifyRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *bookID;
@property (retain, nonatomic, readwrite) NSString *iapTransactionID;
@property (retain, nonatomic, readwrite) NSString *iapReceipt;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end



#pragma mark -
#pragma mark 民生正扫支付
@interface CMBCCustomScanShopRequest : NSObject

//! @brief 支付类型：API_WXQRCODE API_ZFBQRCODE
@property (retain, nonatomic, readwrite) NSString *selectTradeType;

//! @brief 支付金额：单位为分，不能有小数位
@property (assign, nonatomic, readwrite) NSInteger amount;

//! @brief 订单简述
@property (retain, nonatomic, readwrite) NSString *orderInfo;

//! @brief 订单 ID
@property (retain, nonatomic, readwrite) NSString *orderId;

//! @brief 绑定ID
@property (retain, nonatomic, readwrite) NSString *bindId;

//! @brief token
@property (retain, nonatomic, readwrite) NSString *token;

//! @brief service url
@property (retain, nonatomic, readwrite) NSString *serviceURL;

@end

#pragma mark -
#pragma mark 民生反扫支付
@interface CMBCShopScanCustomRequest : NSObject

//! @brief 支付类型：API_WXQRCODE API_ZFBQRCODE
@property (retain, nonatomic, readwrite) NSString *selectTradeType;

//! @brief 支付金额：单位为分，不能有小数位
@property (assign, nonatomic, readwrite) NSInteger amount;

//! @brief 订单简述
@property (retain, nonatomic, readwrite) NSString *orderInfo;

//! @brief 订单 ID
@property (retain, nonatomic, readwrite) NSString *orderId;

//! @brief 绑定ID
@property (retain, nonatomic, readwrite) NSString *bindId;

//! @brief 付款二维码
@property (retain, nonatomic, readwrite) NSString *remark;

//! @brief token
@property (retain, nonatomic, readwrite) NSString *token;

//! @brief service url
@property (retain, nonatomic, readwrite) NSString *serviceURL;

@end

#pragma mark -
#pragma mark 民生退款
@interface CMBCRefundRequest : NSObject

//! @brief 退款金额：单位为分，不能有小数位
@property (assign, nonatomic, readwrite) NSInteger orderAmount;

//! @brief 退款描述
@property (retain, nonatomic, readwrite) NSString *orderNote;

//! @brief 订单号
@property (retain, nonatomic, readwrite) NSString *orderId;

//! @brief 绑定ID
@property (retain, nonatomic, readwrite) NSString *bindId;

//! @brief token
@property (retain, nonatomic, readwrite) NSString *token;

//! @brief service url
@property (retain, nonatomic, readwrite) NSString *serviceURL;

@end

#pragma mark -
#pragma mark 民生支付查询
@interface CMBCPayQueryRequest : NSObject

//! @brief 订单号
@property (retain, nonatomic, readwrite) NSString *orderId;

//! @brief 绑定ID
@property (retain, nonatomic, readwrite) NSString *bindId;

//! @brief token
@property (retain, nonatomic, readwrite) NSString *token;

//! @brief service url
@property (retain, nonatomic, readwrite) NSString *serviceURL;

@end

#pragma mark -
#pragma mark 民生退款查询
@interface CMBCRefundQueryRequest : NSObject

//! @brief 订单号
@property (retain, nonatomic, readwrite) NSString *orderId;

//! @brief 绑定ID
@property (retain, nonatomic, readwrite) NSString *bindId;

//! @brief token
@property (retain, nonatomic, readwrite) NSString *token;

//! @brief service url
@property (retain, nonatomic, readwrite) NSString *serviceURL;

@end

#pragma mark -
#pragma mark 民生绑定查询
@interface CMBCBindQueryRequest : NSObject

//! @brief 绑定ID
@property (retain, nonatomic, readwrite) NSString *bindId;

//! @brief token
@property (retain, nonatomic, readwrite) NSString *token;

//! @brief user id
@property (retain, nonatomic, readwrite) NSString *userID;

//! @brief book id
@property (retain, nonatomic, readwrite) NSString *bookID;

//! @brief service url
@property (retain, nonatomic, readwrite) NSString *serviceURL;

@end

