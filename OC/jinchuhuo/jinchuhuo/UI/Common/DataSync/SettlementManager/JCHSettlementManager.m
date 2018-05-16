//
//  JCHSettlementManager.m
//  jinchuhuo
//
//  Created by apple on 2016/11/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSettlementManager.h"
#import "ServiceFactory.h"
#import "JCHSyncStatusManager.h"
#import "JCHSyncServerSettings.h"
#import "JCHManifestMemoryStorage.h"
#import "JCHCheckoutBottomMenuView.h"
#import "JCHPayCodeViewController.h"
#import "JCHCheckoutViewController.h"
#import "JCHGroupContactsViewController.h"
#import "JCHBarCodeScannerViewController.h"
#import "JCHSettlementGuideViewController.h"
#import "JCHCheckoutOnAccountViewController.h"
#import "CommonHeader.h"


enum {
    kWaitForPayResult = 30005,
};

@implementation JCHSettlementManager

+ (id)sharedInstance
{
    static dispatch_once_t dispatchOnce;
    static JCHSettlementManager *settlementManager = nil;
    dispatch_once(&dispatchOnce, ^{
        settlementManager = [[JCHSettlementManager alloc] init];
        
    });
    
    return settlementManager;
}

#pragma mark -
#pragma mark 扫描支付宝二维码
- (void)handleFinishScanBarAlipayBarCode:(NSString *)qrCode
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id<OnlineSettlement> settlementService = [[ServiceFactory sharedInstance] onlineSettlementService];
    JCHManifestMemoryStorage *memoryStorage = [JCHManifestMemoryStorage sharedInstance];
    
    CMBCShopScanCustomRequest *request = [[[CMBCShopScanCustomRequest alloc] init] autorelease];
    request.selectTradeType = @"API_ZFBSCAN";
    request.amount = memoryStorage.receivableAmount * 100;
    request.orderInfo = [NSString stringWithFormat:@"订单号: %@", memoryStorage.currentManifestID];
    request.orderId = [NSString stringWithFormat:@"%@-%@", statusManager.accountBookID, memoryStorage.currentManifestID];
    request.bindId = [self getBindID];
    request.remark = [[qrCode dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    request.token = statusManager.syncToken;
    request.serviceURL = [NSString stringWithFormat:@"%@/cmbc/scanPay", kCMBCPayServiceURL];
    
    [settlementService cmbcShopScanCustomScan:request callback:^(id response) {
        NSDictionary *userData = response;
        if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
            NSDictionary *responseData = userData[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                if (responseCode != kWaitForPayResult) {
                    // fail
                    [self handleShopScanCustomPayError:responseCode];
                    return;
                }
            }
            
            // success
            [MBProgressHUD hideAllHudsForWindow];
            [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                     detail:@"正在等待支付结果，请稍候..."
                                   duration:3000
                                       mode:MBProgressHUDModeIndeterminate
                                 completion:nil];
            
            NSLog(@"发送扫码支付请求成功");

        } else {
            // network error
            [MBProgressHUD showNetWorkFailedHud:@"网络连接失败，请重试"];
        }
    }];
}

#pragma mark -
#pragma mark 扫描微信二维码
- (void)handleFinishScanWeiXinBarCode:(NSString *)qrCode
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id<OnlineSettlement> settlementService = [[ServiceFactory sharedInstance] onlineSettlementService];
    JCHManifestMemoryStorage *memoryStorage = [JCHManifestMemoryStorage sharedInstance];
    
    CMBCShopScanCustomRequest *request = [[[CMBCShopScanCustomRequest alloc] init] autorelease];
    request.selectTradeType = @"API_WXSCAN";
    request.amount = memoryStorage.receivableAmount * 100;
    request.orderInfo = [NSString stringWithFormat:@"订单号: %@", memoryStorage.currentManifestID];
    request.orderId = [NSString stringWithFormat:@"%@-%@", statusManager.accountBookID, memoryStorage.currentManifestID];
    request.bindId = [self getBindID];
    request.remark = [[qrCode dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    request.token = statusManager.syncToken;
    request.serviceURL = [NSString stringWithFormat:@"%@/cmbc/scanPay", kCMBCPayServiceURL];
    
    [settlementService cmbcShopScanCustomScan:request callback:^(id response) {
        NSDictionary *userData = response;
        if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
            NSDictionary *responseData = userData[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                if (responseCode != kWaitForPayResult) {
                    // fail
                    [self handleShopScanCustomPayError:responseCode];
                    return;
                }
            }
            
            // success
            [MBProgressHUD hideAllHudsForWindow];
            [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                     detail:@"正在等待支付结果，请稍候..."
                                   duration:3000
                                       mode:MBProgressHUDModeIndeterminate
                                 completion:nil];
            
            NSLog(@"发送扫码支付请求成功");
        } else {
            // network error
            [MBProgressHUD showNetWorkFailedHud:@"网络连接失败，请重试"];
        }
    }];
}

#pragma mark -
#pragma mark 查询支付状态
- (void)queryPayStatusStatus:(void(^)(void))paySuccessHandler
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    JCHManifestMemoryStorage *memoryStorage = [JCHManifestMemoryStorage sharedInstance];
    id<OnlineSettlement> settlementService = [[ServiceFactory sharedInstance] onlineSettlementService];
    
    CMBCPayQueryRequest *request = [[[CMBCPayQueryRequest alloc] init] autorelease];
    request.orderId = [NSString stringWithFormat:@"%@-%@", statusManager.accountBookID, memoryStorage.currentManifestID];
    request.bindId = [self getBindID];
    request.token = statusManager.syncToken;
    request.serviceURL = [NSString stringWithFormat:@"%@/cmbc/payRet", kCMBCPayServiceURL];
    
    [settlementService cmbcPayQuery:request callback:^(id response) {
        NSDictionary *userData = response;
        if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
            NSDictionary *responseData = userData[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                if (31004 != responseCode) {
                    [self showPayErrorHud:responseDescription];
                }
            } else {
                if (responseCode == 10000) {
                    // success
                    NSLog(@"查询货单支付状态成功: %@", responseDescription);
                    
                    if (nil != paySuccessHandler) {
                        paySuccessHandler();
                    }
                    
                    // 显示支付成功消息
                    [MBProgressHUD hideAllHudsForWindow];
                    [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                             detail:@"支付成功"
                                           duration:3
                                               mode:MBProgressHUDModeText
                                         completion:nil];
                } else {
                    NSLog(@"支付状态: %@", responseDescription);
                    
                    if (kWaitForPayResult != responseCode) {
                        [MBProgressHUD hideAllHudsForWindow];
                        [self handleQueryPayStatusError:responseCode];
                    } else {
                        NSLog(@"正在等待支付结果");
                    }
                }
            }
        } else {
            // network error
            [MBProgressHUD showNetWorkFailedHud:@"网络连接失败，请重试"];
        }
    }];
}

#pragma mark -
#pragma mark - 付款方式
- (void)handleSelectPayWay:(UIButton *)button viewController:(UIViewController *)theViewController
{
    __block UIViewController *weakController = theViewController;
    JCHManifestMemoryStorage *manifestMemoryStorage = [JCHManifestMemoryStorage sharedInstance];
    
    switch (button.tag) {
        case kJCHPayWayCachTag:  //现金
        {
            JCHCheckoutViewController *checkoutBuCashVC = [[[JCHCheckoutViewController alloc] initWithPayWay:kJCHCheckoutPayWayCash] autorelease];
            [weakController.navigationController pushViewController:checkoutBuCashVC animated:YES];
        }
            break;
            
        case kJCHPayWayUnionPayTag:  //银联
        {
            JCHSettlementGuideViewController *guideController = [[[JCHSettlementGuideViewController alloc] init] autorelease];
            [weakController.navigationController pushViewController:guideController animated:YES];
            return;
            
        }
            break;
            
        case kJCHPayWayWeChatTag:  //微信
        {
            id <AccountService> accountService = [[ServiceFactory sharedInstance] accountService];
            BOOL isCMBCAccountExist = [accountService isWeiXinViaCMBCAccount];
            
            if (!isCMBCAccountExist) {
                
                JCHSettlementGuideViewController *guideController = [[[JCHSettlementGuideViewController alloc] init] autorelease];
                [weakController.navigationController pushViewController:guideController animated:YES];
            } else {
                // 保存当前货单状态
                id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
                [self saveOrder:[manifestService getWeiXinPayViaCMBCAccountUUID]];
                
                JCHManifestMemoryStorage *memoryStorage = [JCHManifestMemoryStorage sharedInstance];
                JCHPayCodeViewController *payCodeVC = [[[JCHPayCodeViewController alloc] init] autorelease];
                WeakSelf;
                payCodeVC.barCodeBlock = ^(NSString *barCode){
                    [weakSelf handleFinishScanWeiXinBarCode:barCode];
                };
                
                payCodeVC.changePayMethod = ^() {
                    SEL restartQueryPayStatus = NSSelectorFromString(@"restartQueryPayStatus");
                    if ([weakController respondsToSelector:restartQueryPayStatus]) {
                        [weakController performSelector:restartQueryPayStatus];
                    }
                };
                
                payCodeVC.payAmount = memoryStorage.receivableAmount * 100;
                payCodeVC.orderInfo = [NSString stringWithFormat:@"订单号: %@", memoryStorage.currentManifestID];
                payCodeVC.orderID = memoryStorage.currentManifestID;
                payCodeVC.bindID = [self getBindID];
                payCodeVC.enumPayCodeType = kJCHPayCodeWeiXin;
                [weakController presentViewController:payCodeVC animated:YES completion:nil];
                
                // 启动支付状态查询
                [weakController performSelector:NSSelectorFromString(@"startQueryPayStatusTimer")];
            }
        }
            break;
            
        case kJCHPayWayAlipayTag:   //支付宝
        {
            id <AccountService> accountService = [[ServiceFactory sharedInstance] accountService];
            BOOL isCMBCAccountExist = [accountService isAliViaCMBCAccount];
            
            if (!isCMBCAccountExist) {
                JCHSettlementGuideViewController *guideController = [[[JCHSettlementGuideViewController alloc] init] autorelease];
                [weakController.navigationController pushViewController:guideController animated:YES];
            } else {
                // 保存当前货单状态
                id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
                [self saveOrder:[manifestService getAliPayViaCMBCAccountUUID]];
                
                JCHManifestMemoryStorage *memoryStorage = [JCHManifestMemoryStorage sharedInstance];
                JCHPayCodeViewController *payCodeVC = [[[JCHPayCodeViewController alloc] init] autorelease];
                WeakSelf;
                payCodeVC.barCodeBlock = ^(NSString *barCode){
                    [weakSelf handleFinishScanBarAlipayBarCode:barCode];
                };
                
                payCodeVC.changePayMethod = ^() {
                    SEL restartQueryPayStatus = NSSelectorFromString(@"restartQueryPayStatus");
                    if ([weakController respondsToSelector:restartQueryPayStatus]) {
                        [weakController performSelector:restartQueryPayStatus];
                    }
                };
                
                payCodeVC.payAmount = memoryStorage.receivableAmount * 100;
                payCodeVC.orderInfo = [NSString stringWithFormat:@"订单号: %@", memoryStorage.currentManifestID];
                payCodeVC.orderID = memoryStorage.currentManifestID;
                payCodeVC.bindID = [self getBindID];
                payCodeVC.enumPayCodeType = kJCHPayCodeAlipay;
                [weakController presentViewController:payCodeVC animated:YES completion:nil];
                
                
                // 启动支付状态查询
                [weakController performSelector:NSSelectorFromString(@"startQueryPayStatusTimer")];
            }
        }
            break;
            
        case kJCHPayWayTickTag:      //赊销赊购
        {
            if (manifestMemoryStorage.currentContactsRecord.contactUUID) {
                JCHCheckoutOnAccountViewController *onAccountVC = [[[JCHCheckoutOnAccountViewController alloc] init] autorelease];
                [weakController.navigationController pushViewController:onAccountVC animated:YES];
            } else {
                
                kJCHGroupContactsType groupContactsType;
                if (manifestMemoryStorage.currentManifestType == kJCHOrderPurchases) {
                    groupContactsType = kJCHGroupContactsSupplier;
                } else if (manifestMemoryStorage.currentManifestType == kJCHOrderShipment) {
                    groupContactsType = kJCHGroupContactsClient;
                }
                JCHGroupContactsViewController *contactsVC = [[[JCHGroupContactsViewController alloc] initWithType:groupContactsType selectMember:YES] autorelease];
                [contactsVC setSendValueBlock:^(ContactsRecord4Cocoa *contactRecord) {
                    manifestMemoryStorage.currentContactsRecord = contactRecord;
                }];
                UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:contactsVC] autorelease];
                //[self.navigationController pushViewController:contactsVC animated:YES];
                [weakController presentViewController:nav animated:YES completion:nil];
                
                return;
            }
            
        }
            break;
            
        case kJCHPayWaySavingsCardTag: //储值卡
        {
            JCHCheckoutViewController *checkoutVC = [[[JCHCheckoutViewController alloc] initWithPayWay:kJCHCheckoutPayWaySavingCard] autorelease];
            [weakController.navigationController pushViewController:checkoutVC animated:YES];
        }
            break;
        default:
            break;
    }

}

- (void)querySettlementMethodStatus:(void(^)(NSInteger enableMerchant, NSInteger enableAlipay, NSInteger enableWeiXin, NSString *bindID)) successHandler
                     failureHandler:(void(^)(void))failureHandler
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id<OnlineSettlement> settlementService = [[ServiceFactory sharedInstance] onlineSettlementService];
    
    CMBCBindQueryRequest *request = [[[CMBCBindQueryRequest alloc] init] autorelease];
    request.bindId = @"";
    request.token = [statusManager syncToken];
    request.userID = [statusManager userID];
    request.bookID = [statusManager accountBookID];
    request.serviceURL = kCMBCQueryBindServiceURL;
    [settlementService cmbcBindQuery:request callback:^(id response) {
        NSDictionary *userData = response;
        if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
            NSDictionary *responseData = userData[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                // fail
                if (31004 != responseCode) {
                    [self showPayErrorHud:responseDescription];
                }
            } else {
                // success
                NSDictionary *record = responseData[@"data"];
                NSInteger alipayID = [record[@"ali"] integerValue];
                NSInteger enableMerchant = [record[@"merchant"] integerValue];
                NSInteger wxID = [record[@"weixin"] integerValue];
                NSString *bindID = record[@"bindId"];
                
                if (0 == enableMerchant && 0 == alipayID) {
                    id<AccountService> accountService = [[ServiceFactory sharedInstance] accountService];
                    if (NO == [accountService isAliViaCMBCAccount]) {
                        [accountService addAliViaCMBCAccount:@"支付宝民生账户"];
                    }
                }
                
                if (0 == enableMerchant && 0 == wxID) {
                    id<AccountService> accountService = [[ServiceFactory sharedInstance] accountService];
                    if (NO == [accountService isWeiXinViaCMBCAccount]) {
                        [accountService addWeiXinViaCMBCAccount:@"微信民生账户"];
                    }
                }
                
                if (nil != bindID && (NO == [bindID isEmptyString])) {
                    [self setBindID:bindID];
                }
                
                [self setOpenAccountStatus:enableMerchant];
                
                if (nil != successHandler) {
                    successHandler(enableMerchant, alipayID, wxID, bindID);
                }
            }
        } else {
            // network error
            [MBProgressHUD showNetWorkFailedHud:@"网络连接失败，请重试"];
            
            if (nil != failureHandler) {
                failureHandler();
            }
        }
    }];
}

- (void)handleCustomScanShopPayError:(NSInteger)errorCode
{
    NSString *errorMessage = @"";
    switch (errorCode) {
        case 20001:
            errorMessage = @"参数错误";
            break;
        case 20002:
            errorMessage = @"具体参数错误，请检查详细信息";
            break;
        case 30001:
            errorMessage = @"系统级错误，需要检查日志";
            break;
        case 30002:
            errorMessage = @"订单未支付，不能退款";
            break;
        case 30003:
            errorMessage = @"支付系统返回失败，请检查详细信息";
            break;
        case 30004:
            errorMessage = @"该订单正在进行退款操作，不能重复退款";
            break;
        case 30005:
            errorMessage = @"该订单退款失败，请重新退款";
            break;
        default:
            errorMessage = @"未知错误";
            break;
    }
    
    [MBProgressHUD showHUDWithTitle:@"温馨提示"
                             detail:[NSString stringWithFormat:@"支付失败:\"%@\", 请重试", errorMessage]
                           duration:2.5
                               mode:MBProgressHUDModeText
                         completion:nil];
    
    return;
}

- (void)handleShopScanCustomPayError:(NSInteger)errorCode
{
    if (31002 == errorCode) {
        return;
    }
    
    NSString *errorMessage = @"";
    switch (errorCode) {
        case 20001:
            errorMessage = @"参数错误";
            break;
        case 20002:
            errorMessage = @"参数不完整，请检查详细信息";
            break;
        case 30001:
            errorMessage = @"系统级错误，需要检查日志";
            break;
        case 31001:
            errorMessage = @"未开通支付";
            break;
        case 31002:
            errorMessage = @"正在支付中，请稍等查询支付结果";
            break;
        case 31003:
            errorMessage = @"该订单已经支付成功，不能重复支付";
            break;
        case 31004:
            errorMessage = @"支付系统返回失败，请检查详细信息";
            break;
        case 31006:
            errorMessage = @"扫码支付失败，请重新支付";
            break;
        default:
            errorMessage = @"未知错误";
            break;
    }
    
    [MBProgressHUD showHUDWithTitle:@"温馨提示"
                             detail:[NSString stringWithFormat:@"支付失败:\"%@\", 请重试", errorMessage]
                           duration:2.5
                               mode:MBProgressHUDModeText
                         completion:nil];
    
    return;
}


- (void)handleRefundError:(NSInteger)errorCode
{
    NSString *errorMessage = @"";
    switch (errorCode) {
        case 20001:
            errorMessage = @"参数错误";
            break;
        case 20002:
            errorMessage = @"具体参数错误，请检查详细信息";
            break;
        case 30001:
            errorMessage = @"系统级错误，需要检查日志";
            break;
        case 30002:
            errorMessage = @"订单未支付，不能退款";
            break;
        case 30003:
            errorMessage = @"支付系统返回失败，请检查详细信息";
            break;
        case 30004:
            errorMessage = @"该订单正在进行退款操作，不能重复退款";
            break;
        case 30005:
            errorMessage = @"该订单退款失败，请重新退款";
            break;
        default:
            errorMessage = @"未知错误";
            break;
    }
    
    [MBProgressHUD showHUDWithTitle:@"温馨提示"
                             detail:[NSString stringWithFormat:@"支付操作失败:\"%@\", 请重试", errorMessage]
                           duration:2.5
                               mode:MBProgressHUDModeText
                         completion:nil];
    
    return;
}

- (void)handleQueryPayStatusError:(NSInteger)errorCode
{
    NSString *errorMessage = @"";
    switch (errorCode) {
        case 20001:
            errorMessage = @"参数错误";
            break;
        case 20002:
            errorMessage = @"参数不完整，请检查详细信息";
            break;
        case 30001:
            errorMessage = @"系统级错误，需要检查日志";
            break;
        case 31003:
            errorMessage = @"该订单已经支付成功，不能重复支付";
            break;
        case 31004:
            errorMessage = @"支付系统返回失败，请检查详细信息";
            break;
        case 31007:
            errorMessage = @"订单未支付，请先支付";
            break;
        case 31008:
            errorMessage = @"订单支付失败，请重新支付";
            break;
        default:
            errorMessage = @"未知错误";
            break;
    }
    
    [MBProgressHUD showHUDWithTitle:@"温馨提示"
                             detail:[NSString stringWithFormat:@"支付操作失败:\"%@\", 请重试", errorMessage]
                           duration:2.5
                               mode:MBProgressHUDModeText
                         completion:nil];
    
    return;
}


- (void)showPayErrorHud:(NSString *)errorMessage
{
    [MBProgressHUD showHUDWithTitle:@"查询失败"
                             detail:errorMessage
                           duration:2
                               mode:MBProgressHUDModeText
                         completion:nil];
}

#pragma mark -
#pragma mark 保存bindID
- (NSString *)getBindID
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"bind_id_%@", statusManager.accountBookID];
    NSString *value = [userDefaults objectForKey:key];
    if (nil == value) {
        return @"";
    } else {
        return value;
    }
}

#pragma mark -
#pragma mark 获取bindID
- (void)setBindID:(NSString *)bindID
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"bind_id_%@", statusManager.accountBookID];
    [userDefaults setObject:bindID forKey:key];
    [userDefaults synchronize];
}

#pragma mark -
#pragma mark 获取开户状态
- (BOOL)getOpenAccountStatus
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"open_account_status_%@", statusManager.accountBookID];
    NSNumber *value = [userDefaults objectForKey:key];
    if (nil == value) {
        return NO;
    } else {
        if (NO == [value boolValue]) {
            return YES;
        } else {
            return NO;
        }
    }
}

#pragma mark -
#pragma mark 保存开户状态
- (void)setOpenAccountStatus:(BOOL)status
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"open_account_status_%@", statusManager.accountBookID];
    [userDefaults setObject:@(status) forKey:key];
    [userDefaults synchronize];
}

#pragma mark -
#pragma mark 保存货单
- (void)saveOrder:(NSString *)payAccountUUID
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    NSArray *currentProductInManifestList = [manifestStorage getAllManifestRecord];
    NSMutableArray *transactionList = [[[NSMutableArray alloc] init] autorelease];
    
    for (ManifestTransactionDetail *productDetail in currentProductInManifestList) {
        
        NSString *transactionUUID = [[[ServiceFactory sharedInstance] utilityService] generateUUID];
        ManifestTransactionRecord4Cocoa *record = [[[ManifestTransactionRecord4Cocoa alloc] init] autorelease];
        record.productCategory = productDetail.productCategory;
        //record.productCount = [productDetail.productCount doubleValue];
        record.productCount = productDetail.productCountFloat;
        record.productDiscount = [productDetail.productDiscount doubleValue];
        record.productName = productDetail.productName;
        record.productPrice = [productDetail.productPrice doubleValue];
        record.productUnit = productDetail.productUnit;
        
        record.goodsNameUUID = productDetail.goodsNameUUID;
        record.goodsCategoryUUID = productDetail.goodsCategoryUUID;
        record.unitUUID = productDetail.unitUUID;
        record.warehouseUUID = productDetail.warehouseUUID;
        record.transactionUUID = transactionUUID;
        record.goodsSKUUUIDArray = productDetail.skuValueUUIDs;
        record.dishProperty = productDetail.dishProperty;
        
        [transactionList addObject:record];
    }
    
    NSString *orderDate = manifestStorage.currentManifestDate;
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *selectedDate = [dateFormater dateFromString:orderDate];
    time_t manifestTime = [selectedDate timeIntervalSince1970];
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    //! @todo 接入通讯录后，这里设置为真实的结算账户及交易方
    NSString *counterPartyUUID = @"";
    
    if (kJCHOrderShipment == manifestStorage.currentManifestType) {
        counterPartyUUID = [manifestService getDefaultCustomUUID];
    } else if (kJCHOrderPurchases == manifestStorage.currentManifestType) {
        counterPartyUUID = [manifestService getDefaultSupplierUUID];
    }
    
    if (manifestStorage.currentContactsRecord.contactUUID) {
        counterPartyUUID = manifestStorage.currentContactsRecord.contactUUID;
    }
    
    int status = [manifestService savePayErrorManifest:transactionList
                                          manifestType:manifestStorage.currentManifestType
                                          manifestTime:manifestTime
                                            manifestID:manifestStorage.currentManifestID
                                      manifestDiscount:manifestStorage.currentManifestDiscount
                                        manifestRemark:manifestStorage.currentManifestRemark
                                           eraseAmount:manifestStorage.currentManifestEraseAmount
                                          counterParty:counterPartyUUID];
    if (0 != status) {
        NSLog(@"savePayErrorManifest fail, errno: %d", status);
    }
}

@end
