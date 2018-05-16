//
//  JCHSettlementManager.h
//  jinchuhuo
//
//  Created by apple on 2016/11/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


//! @brief 查询时间间隔
#ifndef kQueryCMBCPayStatusTime
#define kQueryCMBCPayStatusTime 3
#endif

//! @brief 查询超时时间
#ifndef kQueryCMBCPayStatusTimeOut
#define kQueryCMBCPayStatusTimeOut 300
#endif

@interface JCHSettlementManager : NSObject

+ (id)sharedInstance;

#pragma mark -
#pragma mark 保存bindID
- (NSString *)getBindID;

#pragma mark -
#pragma mark 获取bindID
- (void)setBindID:(NSString *)bindID;

#pragma mark -
#pragma mark 获取开户状态
- (BOOL)getOpenAccountStatus;

#pragma mark -
#pragma mark 保存开户状态
- (void)setOpenAccountStatus:(BOOL)status;

#pragma mark -
#pragma mark 扫描支付宝二维码
- (void)handleFinishScanBarAlipayBarCode:(NSString *)qrCode;

#pragma mark -
#pragma mark 扫描微信二维码
- (void)handleFinishScanWeiXinBarCode:(NSString *)qrCode;

#pragma mark -
#pragma mark 查询支付状态
- (void)queryPayStatusStatus:(void(^)(void))paySuccessHandler;

#pragma mark -
#pragma mark - 付款方式
- (void)handleSelectPayWay:(UIButton *)button viewController:(UIViewController *)viewController;

#pragma mark -
#pragma mark 查询支付通知开通状态
- (void)querySettlementMethodStatus:(void(^)(NSInteger enableMerchant, NSInteger enableAlipay, NSInteger enableWeiXin, NSString *bindID)) successHandler
                     failureHandler:(void(^)(void))failureHandler;

- (void)handleCustomScanShopPayError:(NSInteger)errorCode;
- (void)handleShopScanCustomPayError:(NSInteger)errorCode;
- (void)handleRefundError:(NSInteger)errorCode;

@end
