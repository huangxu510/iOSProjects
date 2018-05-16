//
//  OnlineSettlement.h
//  iOSInterface
//
//  Created by apple on 16/3/10.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnlineSettlementRecord4Cocoa.h"

@protocol OnlineSettlement <NSObject>

//! @brief 绑定微信账号
- (int)bindWeiXinPayAccount:(BindWeiXinPayAccountRequest *)request
                   response:(NSString *)responseNotification;

//! @brief 查询微信账户是否已绑定
- (int)queryWeiXinPayAccountOpenStatus:(QueryWeiXinPayAccountBindStatusRequest *)request
                              response:(NSString *)responseNotification;

//! @brief 微信支付
- (int)weixinPay:(WeiXinPayRequest *)request
        response:(NSString *)responseNotification;

//! @brief 查询订单支付状态
- (int)queryWeiXinPayResult:(QueryWeiXinPayResultRequest *)request
                   response:(NSString *)responseNotification;

//! @brief 微信退款
- (int)weixinRefund:(WeiXinRefundRequest *)request
           response:(NSString *)responseNotification;

//! @brief 微信退款查询
- (int)queryWeiXinPayRefundResult:(QueryWeiXinRefundResultRequest *)request
                         response:(NSString *)responseNotification;

//! @brief IAP购买检验查询
- (int)verifyIAPBuyResultRequest:(IAPByResultVerifyRequest *)request
                        response:(NSString *)responseNotification;

//! @brief 民生正扫支付
- (int)cmbcCustomScanShopScan:(CMBCCustomScanShopRequest *)request callback:(void(^)(id response))callback;

//! @brief 民生反扫支付
- (int)cmbcShopScanCustomScan:(CMBCShopScanCustomRequest *)request callback:(void(^)(id response))callback;

//! @brief 民生退款
- (int)cmbcRefund:(CMBCRefundRequest *)request callback:(void(^)(id response))callback;

//! @brief 民生支付查询
- (int)cmbcPayQuery:(CMBCPayQueryRequest *)request callback:(void(^)(id response))callback;

//! @brief 民生退款查询
- (int)cmbcRefundQuery:(CMBCRefundQueryRequest *)request callback:(void(^)(id response))callback;

//! @brief 民生绑定查询
- (int)cmbcBindQuery:(CMBCBindQueryRequest *)request callback:(void(^)(id response))callback;

@end
