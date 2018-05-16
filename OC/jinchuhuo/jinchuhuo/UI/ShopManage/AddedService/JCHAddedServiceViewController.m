//
//  JCHValueAddedServiceViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/5/3.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAddedServiceViewController.h"
#import "JCHNetWorkingUtility.h"
#import "JCHAddedServicePackageView.h"
#import "JCHHTMLViewController.h"
#import "JCHAddedServiceInfoView.h"
#import "CommonHeader.h"
#import <StoreKit/StoreKit.h>

#ifndef kInAppPurchaseReceiptKey
#define kInAppPurchaseReceiptKey @"kInAppPurchaseReceiptKey"
#endif

@interface JCHAddedServiceViewController () <SKRequestDelegate,
SKProductsRequestDelegate,
SKPaymentTransactionObserver>
{
    UILabel *_endTimeLabel;
    UIButton *_mCodeExchangeButton;
    BOOL _uploadReceiptAfterPurchase;   //在购买成功后上传凭证的标记
}
@property (nonatomic, retain) NSArray *productList;
@property (nonatomic, retain) NSArray *productIDArray;

@end

@implementation JCHAddedServiceViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"银麦会员服务";
        self.productIDArray = @[@"Silver_service_pro_1m", @"Silver_service_pro_3m", @"Silver_service_pro_6m", @"Silver_service_pro_12m"];
        //self.productIDArray = @[@"Silver_service_pro_taste"];
        [self registerResponseNotificationHandler];
    }
    return self;
}

- (void)dealloc
{
    [self unregisterResponseNotificationHandler];
    self.productList = nil;
    self.productIDArray = nil;
    
    // 取消监听购买结果
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 监听购买结果
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [MBProgressHUD showHUDWithTitle:nil
                             detail:@"加载中..."
                           duration:100
                               mode:MBProgressHUDModeIndeterminate
                          superView:self.view
                         completion:nil];
    [self handleIAP];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self doQueryAddedServiceInfo];
}

- (void)createUI
{
    CGFloat imageViewHeight = [JCHSizeUtility calculateWidthWithSourceWidth:100.0f * kSizeScaleFrom5S];
    UIImageView *topImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addedService_banner"]] autorelease];
    [self.backgroundScrollView addSubview:topImageView];
    [topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(imageViewHeight);
    }];
    
    UILabel *topTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                 title:@"套餐选择"
                                                  font:[UIFont jchSystemFontOfSize:12.0f]
                                             textColor:JCHColorMainBody aligin:NSTextAlignmentLeft];
    [self.backgroundScrollView addSubview:topTitleLabel];
    topTitleLabel.userInteractionEnabled = YES;
    topTitleLabel.enabled = YES;
    
    [topTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView).with.offset(kStandardLeftMargin);
        make.top.equalTo(topImageView.mas_bottom);
        make.width.mas_equalTo(kScreenWidth - 2 * kStandardLeftMargin);
        make.height.mas_equalTo(32.0f);
    }];
    
    _mCodeExchangeButton = [JCHUIFactory createButton:CGRectZero
                                               target:self
                                               action:@selector(handleMCodeExchange)
                                                title:@"M码兑换"
                                           titleColor:JCHColorRedButtonHeighlighted
                                      backgroundColor:[UIColor clearColor]];
    _mCodeExchangeButton.titleLabel.font = [UIFont jchSystemFontOfSize:12.0f];
    _mCodeExchangeButton.contentHorizontalAlignment = NSTextAlignmentRight;
    [topTitleLabel addSubview:_mCodeExchangeButton];
    
    
    CGSize mCodeFitSize = [_mCodeExchangeButton sizeThatFits:CGSizeZero];
    [_mCodeExchangeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.and.right.equalTo(topTitleLabel);
        make.width.mas_equalTo(mCodeFitSize.width + 20);
    }];
    
    
    _endTimeLabel = [JCHUIFactory createLabel:CGRectZero
                                        title:@"已购买至2016-06-06"
                                         font:[UIFont jchSystemFontOfSize:12.0f]
                                    textColor:JCHColorMainBody aligin:NSTextAlignmentRight];
    [topTitleLabel addSubview:_endTimeLabel];
    
    CGSize fitSize = [_endTimeLabel sizeThatFits:CGSizeZero];
    
    [_endTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.equalTo(topTitleLabel);
        make.right.equalTo(_mCodeExchangeButton.mas_left);
        make.width.mas_equalTo(fitSize.width + 20);
    }];
    
    JCHAddedServiceManager *addedServiceManager = [JCHAddedServiceManager shareInstance];
    if (addedServiceManager.level == kJCHAddedServiceSiverLevel) {
        _endTimeLabel.text = [NSString stringWithFormat:@"已购买至%@", [addedServiceManager.endTime substringToIndex:10]];
    } else {
        _endTimeLabel.hidden = YES;
    }
    
    
    UIView *middleContainerView = [[[UIView alloc] init] autorelease];
    [self.backgroundScrollView addSubview:middleContainerView];
    [middleContainerView addSeparateLineWithMasonryTop:YES bottom:NO];
    
    CGFloat middleContanierViewHeight = [JCHSizeUtility calculateWidthWithSourceWidth:124.0f * kSizeScaleFrom5S];
    [middleContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(topTitleLabel.mas_bottom);
        make.height.mas_equalTo(middleContanierViewHeight);
    }];
    
    CGFloat spacing = 8.0f  * kSizeScaleFrom5S;
    CGFloat packageViewWidth = (kScreenWidth - 3 * spacing) / 2;
    CGFloat packageViewHeight = (middleContanierViewHeight - 3 * spacing) / 2;
    
    NSArray *durationArray = @[@"1", @"3", @"6", @"12"];
    NSArray *priceArray = @[@(30), @(88), @(168), @(318)];
    NSArray *hotMarkHiddenFlagArray = @[@(YES), @(YES), @(YES), @(NO)];
    for (NSInteger i = 0; i < 4; i++) {
        CGFloat viewX = spacing + (packageViewWidth + spacing) * (i % 2);
        CGFloat viewY = spacing + (packageViewHeight + spacing) * (i / 2);
        CGRect frame = CGRectMake(viewX, viewY, packageViewWidth, packageViewHeight);
        JCHAddedServicePackageView *packageView = [[[JCHAddedServicePackageView alloc] initWithFrame:frame] autorelease];
        packageView.tag = i;
        packageView.userInteractionEnabled = YES;
        [middleContainerView addSubview:packageView];
        
        JCHAddedServicePackageViewData *data = [[[JCHAddedServicePackageViewData alloc] init] autorelease];
        data.duration = durationArray[i];
        data.price = [priceArray[i] doubleValue];
        data.hotMarkImageHidden = [hotMarkHiddenFlagArray[i] boolValue];
        [packageView setViewData:data];
        
        UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(purchaseAddedService:)] autorelease];
        [packageView addGestureRecognizer:tap];
    }
    UIView *separateView = [[[UIView alloc] init] autorelease];
    separateView.backgroundColor = JCHColorSeparateLine;
    [self.backgroundScrollView addSubview:separateView];
    
    [separateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.top.equalTo(middleContainerView.mas_bottom);
        make.height.mas_equalTo(10.0f);
        make.width.mas_equalTo(kScreenWidth);
    }];
    
    UILabel *middleTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                    title:@"银麦会员尊享"
                                                     font:[UIFont jchSystemFontOfSize:12.0f]
                                                textColor:JCHColorMainBody aligin:NSTextAlignmentLeft];
    [self.backgroundScrollView addSubview:middleTitleLabel];
    
    [middleTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView).with.offset(kStandardLeftMargin);
        make.top.equalTo(separateView.mas_bottom);
        make.width.mas_equalTo(kScreenWidth - 2 * kStandardLeftMargin);
        make.height.mas_equalTo(32.0f);
    }];
    
    CGFloat bottomContainerViewHeight = [JCHSizeUtility calculateWidthWithSourceWidth:170.0f * kSizeScaleFrom5S];
    
    UIView *bottomContainerView = [[[UIView alloc] init] autorelease];
    [self.backgroundScrollView  addSubview:bottomContainerView];
    
    [bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(middleTitleLabel.mas_bottom);
        make.height.mas_equalTo(bottomContainerViewHeight);
    }];
    
    [bottomContainerView addSeparateLineWithMasonryTop:YES bottom:NO];
    
    NSArray *titleArray = @[@"专属服务器", @"专业技术客服", @"更多店员", @"自动同步更快", @"更多店铺", @"多仓库"];
    NSArray *detailArray = @[@"连接快、数据更安全", @"需求直达，贴心服务", @"店铺经营负载提升", @"鸟枪换炮同步更及时", @"终于可再开一个店", @"每个店可多开一个仓库"];
    NSArray *markHiddenFlagArray = @[@(YES), @(YES), @(YES), @(YES), @(YES), @(YES)];
    
    CGFloat infoViewWidth = kScreenWidth / 2;
    CGFloat infoViewHeight =bottomContainerViewHeight / 3;
    for (NSInteger i = 0; i < 6; i++) {
        CGFloat infoViewX = infoViewWidth * (i % 2);
        CGFloat infoViewY = infoViewHeight * (i / 2);
        CGRect frame = CGRectMake(infoViewX, infoViewY, infoViewWidth, infoViewHeight);
        JCHAddedServiceInfoView *infoView = [[[JCHAddedServiceInfoView alloc] initWithFrame:frame] autorelease];
        [bottomContainerView addSubview:infoView];
        JCHAddedServiceInfoViewData *data = [[[JCHAddedServiceInfoViewData alloc] init] autorelease];
        NSString *icon = [NSString stringWithFormat:@"valueAddedService_pic%ld", i + 1];
        data.iconName = icon;
        data.title = titleArray[i];
        data.detail = detailArray[i];
        data.markLabelHidden = [markHiddenFlagArray[i] boolValue];
        
        [infoView setViewData:data];
    }
}

- (void)purchaseAddedService:(UITapGestureRecognizer *)tap
{
    NSInteger index = tap.view.tag;
    
    for (SKProduct *product in self.productList) {
        if ([product.productIdentifier isEqualToString:self.productIDArray[index]]) {
            SKPayment * payment = [SKPayment paymentWithProduct:product];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
            [MBProgressHUD showHUDWithTitle:@"请稍候..." detail:nil duration:1000 mode:MBProgressHUDModeIndeterminate completion:nil];
            NSLog(@"productID = %@", product.productIdentifier);
        }
    }
}


- (void)handleIAP
{
    if ([SKPaymentQueue canMakePayments]) {
        // 执行下面提到的第5步：
        [self requestProductList];
    } else {
        NSLog(@"失败，用户禁止应用内付费购买.");
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:@"您已经禁止应用内付费购买"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)requestProductList
{
    //判断网络情况
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager startMonitoring];
    
    WeakSelf;
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"networkChagne");
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
            NSLog(@"没有网络");
            [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
            [MBProgressHUD showNetWorkFailedHud:nil];
        } else {
            NSLog(@"有网络");
            NSSet * set = [NSSet setWithArray:weakSelf.productIDArray];
            SKProductsRequest * request = [[[SKProductsRequest alloc] initWithProductIdentifiers:set] autorelease];
            request.delegate = weakSelf;
            [request start];
            
            [manager stopMonitoring];
            [manager setReachabilityStatusChangeBlock:nil];
        }
    }];
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    //[MBProgressHUD hideAllHudsForWindow];
    NSArray *productList = response.products;
    if (productList.count == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:@"从Apple服务器上获取可购买服务列表失败"
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
    
    self.productList = productList;
    [self createUI];
    
    //发送未验证的凭证和transactionID到服务器
    [self uploadReceiptNotUpload];
}


//! @brief 发送未验证的凭证和transactionID到服务器
- (void)uploadReceiptNotUpload
{
    //上传这个receipt
    JCHAddedServiceManager *addedServiceManager = [JCHAddedServiceManager shareInstance];
    
    if (addedServiceManager.notVerifiedTransactionIDList != nil && addedServiceManager.notVerifiedTransactionIDList.count != 0) {
        
        NSString *notVerifiedTransactionID = [addedServiceManager.notVerifiedTransactionIDList lastObject];
        [MBProgressHUD showHUDWithTitle:@"刷新服务中..." detail:@"" duration:100 mode:MBProgressHUDModeText completion:nil];
        [self uploadPaymentReceiptToServer:notVerifiedTransactionID];
    } else {
        
        [self doQueryAddedServiceInfo];
    }
    
    return;
}


#pragma mark - SKRequestDelegate
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [MBProgressHUD hideAllHudsForWindow];
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                         message:error.localizedDescription
                                                        delegate:nil
                                               cancelButtonTitle:@"我知道了"
                                               otherButtonTitles:nil] autorelease];
    [alertView show];
    NSLog(@"request error = %@", error.localizedDescription);
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    [MBProgressHUD hideAllHudsForWindow];
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
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
                //[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
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

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [MBProgressHUD showHUDWithTitle:@"刷新服务中..." detail:@"" duration:100 mode:MBProgressHUDModeText completion:nil];
    _uploadReceiptAfterPurchase = YES;
    
    JCHAddedServiceManager *addedServiceManager = [JCHAddedServiceManager shareInstance];
    NSArray *notVerifiedTransactionIDList = addedServiceManager.notVerifiedTransactionIDList;
    
    if (![notVerifiedTransactionIDList containsObject:transaction.transactionIdentifier]) {
        notVerifiedTransactionIDList = [notVerifiedTransactionIDList arrayByAddingObject:transaction.transactionIdentifier];
    }
    addedServiceManager.notVerifiedTransactionIDList = notVerifiedTransactionIDList;
    
    [self uploadPaymentReceiptToServer:transaction.transactionIdentifier];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if(transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"error = %@\n%@", transaction.error.localizedDescription, transaction.error);
        NSLog(@"购买失败");
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"购买失败"
                                                             message:transaction.error.localizedDescription
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
    } else {
        NSLog(@"用户取消交易");
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
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
    
    [notificationCenter addObserver:self
                           selector:@selector(queryAddedServiceInfo:)
                               name:kJCHQueryAddedServiceInfoNotification
                             object:[UIApplication sharedApplication]];
}

- (void)unregisterResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self
                                  name:kJCHUploadIAPReceiptNotification
                                object:[UIApplication sharedApplication]];
    [notificationCenter removeObserver:self
                                  name:kJCHQueryAddedServiceInfoNotification
                                object:[UIApplication sharedApplication]];
}

//! @brief 发送购买凭证到服务器
- (void)uploadPaymentReceiptToServer:(NSString *)transactionID
{
    //上传这个receipt
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:receiptUrl];
    
    NSString *receiptBase64Str = [receipt base64EncodedStringWithOptions:0];
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    IAPByResultVerifyRequest *request = [[[IAPByResultVerifyRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.deviceUUID = statusManager.deviceUUID;
    request.bookID = statusManager.accountBookID;
    request.iapTransactionID = transactionID;
    request.iapReceipt = receiptBase64Str;
    request.serviceURL = [NSString stringWithFormat:@"%@/trade/applepay/notifying", kStoreServerIP];
    
    id <OnlineSettlement> onlineSettlementService = [[ServiceFactory sharedInstance] onlineSettlementService];
    [onlineSettlementService verifyIAPBuyResultRequest:request response:kJCHUploadIAPReceiptNotification];
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
            //在购买成功后验证凭证才提示hud信息
            if (_uploadReceiptAfterPurchase) {
                if (responseCode == 20003) {
                    [MBProgressHUD showHUDWithTitle:@"验证失败" detail:@"请重新登录" duration:2 mode:MBProgressHUDModeText completion:nil];
                } else {
                    [MBProgressHUD showHUDWithTitle:@"验证失败" detail:@"请联系客服" duration:2 mode:MBProgressHUDModeText completion:nil];
                }
            }
            
            return;
        } else {
            
            NSDictionary *serviceResponse = responseData[@"data"];
            
            NSInteger status = [serviceResponse[@"status"] integerValue];
            JCHAddedServiceManager *addedServiceManager = [JCHAddedServiceManager shareInstance];
            //购买成功
            if (status == 0) {
                
                NSArray *notVerifiedTransactionIDList = addedServiceManager.notVerifiedTransactionIDList;
                if (notVerifiedTransactionIDList.count > 0) {
                    notVerifiedTransactionIDList = [notVerifiedTransactionIDList subarrayWithRange:NSMakeRange(0, notVerifiedTransactionIDList.count - 1)];
                    addedServiceManager.notVerifiedTransactionIDList = notVerifiedTransactionIDList;
                }
                
                //购买成功之后，查询购买信息
                if (_uploadReceiptAfterPurchase) {
                    [self doQueryAddedServiceInfo];
                } else {
                    //每次进入页面后上传为验证的凭证，没验证完继续验证
                    if (notVerifiedTransactionIDList.count > 0) {
                        [self uploadPaymentReceiptToServer:[notVerifiedTransactionIDList lastObject]];
                    } else {
                        [self doQueryAddedServiceInfo];
                    }
                }
                
            } else if (status == -1) {
                //连接苹果服务器失败,重新验证
                [self uploadPaymentReceiptToServer:[addedServiceManager.notVerifiedTransactionIDList lastObject]];
            } else {
                NSLog(@"验证凭证失败 status = %ld", status);
                
                if (_uploadReceiptAfterPurchase) {
                    [MBProgressHUD showHUDWithTitle:@"验证凭证失败" detail:@"" duration:kJCHDefaultShowHudTime mode:MBProgressHUDModeText completion:nil];
                }
            }
        }
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
        
        NSError *networkError = userData[@"data"];
        if (_uploadReceiptAfterPurchase) {
            [JCHNetWorkingUtility showNetworkErrorAlert:networkError];
        }
    }
    
    _uploadReceiptAfterPurchase = NO;
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
                                       
                                       //responesStatusCode  https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html
                                   }
                               }
                           }];
    
}

#pragma mark - 查询购买信息
- (void)doQueryAddedServiceInfo
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    QueryPurchaseInfoRequest *request = [[[QueryPurchaseInfoRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.token = statusManager.syncToken;
    request.serviceURL = [NSString stringWithFormat:@"%@/terminal/member", kJCHUserManagerServerIP];
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService queryPurchaseInfo:request responseNotification:kJCHQueryAddedServiceInfoNotification];
}

- (void)queryAddedServiceInfo:(NSNotification *)notify
{
    NSDictionary *userData = notify.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        NSString *responseDescription = responseData[@"desc"];
        NSString *responseStatus = responseData[@"status"];
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
        
        if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
            //! @todo
            NSLog(@"queryAddedServiceInfo Fail.");
            [MBProgressHUD hideAllHudsForWindow];
            return;
        } else {
            //! @todo
            NSDictionary *serviceResponse = responseData[@"data"];
            NSInteger level = [[NSString stringWithFormat:@"%@", serviceResponse[@"level"]] integerValue];
            NSString *endTime = [NSString stringWithFormat:@"%@", serviceResponse[@"endTime"]];
            //NSTimeInterval endTimeInterval = [[NSString stringWithFormat:@"%@", serviceResponse[@"endTimestamp"]] integerValue];
            
            JCHAddedServiceManager *addedServiceManager = [JCHAddedServiceManager shareInstance];
            addedServiceManager.level = level;
            addedServiceManager.endTime = endTime;
            
            if (level == 2) {
                _endTimeLabel.hidden = NO;
                _endTimeLabel.text = [NSString stringWithFormat:@"已购买至%@", [endTime substringToIndex:10]];
            }
            
            [MBProgressHUD hideAllHudsForWindow];
        }
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
        [MBProgressHUD showNetWorkFailedHud:nil];
    }
}

- (void)handleMCodeExchange
{
    //@"http://192.168.1.12:8080/mmr-credit/login/simpleLogin.html"     http://192.168.1.9:8088/mmr-credit/
    
    JCHHTMLViewController *exchangeController = [[[JCHHTMLViewController alloc] initWithURL:kJCHMCodeExchangeEntranceIP postRequest:YES] autorelease];
    exchangeController.navigationBarColor = JCHColorHeaderBackground;
    exchangeController.hidesBottomBarWhenPushed = YES;
    exchangeController.showNavigationBarRightButton = NO;
    
    [self.navigationController pushViewController:exchangeController animated:YES];
}


@end
