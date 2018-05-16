//
//  JCHInAppPurchaseViewController.m
//  jinchuhuo
//
//  Created by apple on 16/4/28.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "JCHServiceResponseSettings.h"
#import "JCHServiceResponseNotification.h"
#import "JCHInAppPurchaseViewController.h"

#ifndef kInAppPurchaseReceiptKey
#define kInAppPurchaseReceiptKey @"kInAppPurchaseReceiptKey"
#endif

@interface JCHInAppPurchaseViewController ()<SKRequestDelegate,
                                            SKProductsRequestDelegate,
                                            SKPaymentTransactionObserver>
{
    UITableView *contentTableView;
}
@end

@implementation JCHInAppPurchaseViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self registerResponseNotificationHandler];
    }
    
    return self;
}

- (void)dealloc
{
    [self unregisterResponseNotificationHandler];
    
    // 取消监听购买结果
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    
    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 监听购买结果
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    [self createUI];
    [self handleIAP];
    
    return;
}

- (void)createUI
{
    return;
}

- (void)handleIAP
{
    if ([SKPaymentQueue canMakePayments]) {
        // 执行下面提到的第5步：
        [self requestProductList];
    } else {
        NSLog(@"失败，用户禁止应用内付费购买.");
    }
}

- (void)requestProductList
{
    NSSet * set = [NSSet setWithArray:@[@"com.maimairen.jinchuhuopro.service.1month"]];
    SKProductsRequest * request = [[[SKProductsRequest alloc] initWithProductIdentifiers:set] autorelease];
    request.delegate = self;
    [request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *productList = response.products;
    if (productList.count == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:@"从Apple服务器上获取可购买服务列表失败，请重试"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    for (SKProduct *product in productList) {
        NSLog(@"title: %@\ndescription: %@\nprice: %@\n",
              product.localizedTitle,
              product.localizedDescription,
              [product.price descriptionWithLocale:product.priceLocale]);
    }
    
    SKPayment * payment = [SKPayment paymentWithProduct:productList[0]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            {
                // 1) 用户购买成功
                NSLog(@"transactionIdentifier = %@", transaction.transactionIdentifier);
                [self completeTransaction:transaction];
            }
                break;
                
            case SKPaymentTransactionStateFailed:
            {
                // 2) 用户购买失败
                [self failedTransaction:transaction];
            }
                break;
                
            case SKPaymentTransactionStateRestored://已经购买过该商品
            {
                // 3) 用户已购买过此商品，恢复用户已购买状态
                [self restoreTransaction:transaction];
            }
                break;
                
            case SKPaymentTransactionStatePurchasing:
            {
                // 4) AppStore正在处理此购买请求
                NSLog(@"AppStore正在处理此购买请求");
            }
                break;
                
            default:
            {
                // 5) 其它未处理的购买状态
                NSLog(@"WARNING: 未处理的应用内购买状态: %d", (int)transaction.transactionState);
            }
                break;
        }
    }
    
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSString *productIdentifier = transaction.payment.productIdentifier;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *receiptList = [userDefaults objectForKey:kInAppPurchaseReceiptKey];
    if (nil == receiptList) {
        receiptList = @[transaction.transactionReceipt];
    } else {
        receiptList = [receiptList arrayByAddingObject:transaction.transactionReceipt];
    }
    
    [userDefaults setObject:receiptList forKey:kInAppPurchaseReceiptKey];
    [userDefaults synchronize];
    
    [self uploadPaymentReceiptToServer];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if(transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"购买失败");
    } else {
        NSLog(@"用户取消交易");
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    // 对于已购商品，处理恢复购买的逻辑
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)registerResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(handleUploadPaymentReceiptToServer:)
                               name:kJCHUploadIAPReceiptNotification
                             object:[UIApplication sharedApplication]];
}

- (void)unregisterResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self
                                  name:kJCHUploadIAPReceiptNotification
                                object:[UIApplication sharedApplication]];
}

//! @brief 发送购买凭证到服务器
- (void)uploadPaymentReceiptToServer
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *receiptList = [userDefaults objectForKey:kInAppPurchaseReceiptKey];
    if (nil == receiptList) {
        return;
    }
    
    if (0 == receiptList.count) {
        return;
    }
    
    NSString *receipt = [receiptList firstObject];
    
    //! @todo 上传这个receipt
    
    return;
}

- (void)handleUploadPaymentReceiptToServer:(NSNotification *)notification
{
    NSDictionary *userData = notification.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        NSString *responseDescription = responseData[@"desc"];
        NSString *responseStatus = responseData[@"status"];
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
        
        if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
            //! @todo
            NSLog(@"upload receipt fail.");
            return;
        } else {
            // 删除当前已上传的receipt
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSArray *receiptList = [userDefaults objectForKey:kInAppPurchaseReceiptKey];
            if (nil == receiptList) {
                return;
            }
            
            if (receiptList.count <= 1) {
                receiptList = @[];
            } else {
                receiptList = [receiptList subarrayWithRange:NSMakeRange(1, receiptList.count - 1)];
            }
            
            [userDefaults setObject:receiptList forKey:kInAppPurchaseReceiptKey];
            [userDefaults synchronize];
        }
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
    }
    
    // 上传剩下的receipt
    [self uploadPaymentReceiptToServer];
    
    return;
}

- (void)checkPaymentReceipt:(NSData *)receiptData
{
    NSError *formatError = nil;;
    NSDictionary *requestContents = @{@"receipt-data": [receiptData base64EncodedStringWithOptions:0]};
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents
                                                          options:0
                                                            error:&formatError];
    if (nil == requestData) {
        NSLog(@"format request fail: %@", formatError);
        return;
    }
    
    NSURL *storeURL = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
    [storeRequest setHTTPMethod:@"POST"];
    [storeRequest setHTTPBody:requestData];

    NSOperationQueue *operationQueue = [[[NSOperationQueue alloc] init] autorelease];
    [NSURLConnection sendAsynchronousRequest:storeRequest
                                       queue:operationQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                   NSLog(@"connect to apple fail: %@", connectionError);
                               } else {
                                   NSError *parserError = nil;;
                                   NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                                                options:0
                                                                                                  error:&parserError];
                                   if (nil == jsonResponse) {
                                       NSLog(@"parse response fail: %@", parserError);
                                   } else {
                                       NSLog(@"验证结果: %@", jsonResponse);
                                   }
                               }
                           }];

}

@end
