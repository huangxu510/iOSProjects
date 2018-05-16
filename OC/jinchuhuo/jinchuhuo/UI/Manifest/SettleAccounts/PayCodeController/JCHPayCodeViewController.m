//
//  JCHPayCodeViewController.m
//  jinchuhuo
//
//  Created by huangxu on 2016/11/18.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHPayCodeViewController.h"
#import "JCHBarCodeScannerViewController.h"
#import "CommonHeader.h"
#import "JCHSettlementManager.h"
#import <LBXScanWrapper.h>
#import <MSWeakTimer.h>

@interface JCHPayCodeViewController ()
{
    UIImageView *_barCodeImageView;
    UIImageView *_shopImageView;
    UILabel *_shopNameLabel;
    UILabel *_countDownLabel;
    CGFloat _barCodeImageViewWidth;
    MSWeakTimer *_timer;
}
@end

@implementation JCHPayCodeViewController

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
    [self requestPayQRCode];
}

- (void)dealloc
{
    self.barCodeBlock = nil;
    self.changePayMethod = nil;
    self.orderID = nil;
    self.orderInfo = nil;
    self.bindID = nil;
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)createUI
{
    self.view.backgroundColor = UIColorFromRGB(0xd14e4f);
    
    NSString *payMethod = @"";
    if (self.enumPayCodeType == kJCHPayCodeWeiXin) {
        payMethod = @"微信";
    } else if (self.enumPayCodeType == kJCHPayCodeAlipay) {
        payMethod = @"支付宝";
    }
    
    UIColor *textColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [JCHUIFactory createLabel:CGRectMake(0, 20, kScreenWidth, kNavigatorBarHeight)
                                              title:[NSString stringWithFormat:@"%@收款", payMethod]
                                               font:[UIFont systemFontOfSize:17.0f]
                                          textColor:textColor
                                             aligin:NSTextAlignmentCenter];
    [self.view addSubview:titleLabel];
    
    UIButton *backButton = [JCHUIFactory createButton:CGRectMake(0, 20, 50, kNavigatorBarHeight)
                                               target:self
                                               action:@selector(handleDissmiss)
                                                title:nil
                                           titleColor:nil
                                      backgroundColor:nil];
    [backButton setImage:[UIImage imageNamed:@"bt_back"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    
    CGFloat amountLabelTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:60];
    CGFloat amountLabelHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:50];
    UILabel *amountLabel = [JCHUIFactory createLabel:CGRectZero
                                               title:@""
                                                font:JCHFont(24.0)
                                           textColor:[UIColor whiteColor]
                                              aligin:NSTextAlignmentCenter];
    [self.view addSubview:amountLabel];
    
    [amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(titleLabel).offset(amountLabelTopOffset);
        make.height.mas_equalTo(amountLabelHeight);
    }];
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    NSString *amountInfo = [NSString stringWithFormat:@"付款 ¥%.2f", manifestStorage.receivableAmount];
    amountLabel.text = amountInfo;
    
    UILabel *guideLabel = [JCHUIFactory createLabel:CGRectMake(0, 20, kScreenWidth, kNavigatorBarHeight)
                                              title:[NSString stringWithFormat:@"请用%@扫描二维码", payMethod]
                                               font:[UIFont systemFontOfSize:15.0f]
                                          textColor:textColor
                                             aligin:NSTextAlignmentCenter];
    [self.view addSubview:guideLabel];
    
    CGFloat guideLabelHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:30];
    [guideLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(amountLabel.mas_bottom);
        make.height.mas_equalTo(guideLabelHeight);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
    
    CGFloat barCodeContainerVievWidth = [JCHSizeUtility calculateWidthWithSourceWidth:274.0f];
    CGFloat barCodeContainerViewHeight = [JCHSizeUtility calculateWidthWithSourceWidth:335.0f];
    
    UIView *barCodeContainerView = [[[UIView alloc] init] autorelease];
    barCodeContainerView.backgroundColor = JCHColorGlobalBackground;
    barCodeContainerView.layer.cornerRadius = 5;
    barCodeContainerView.clipsToBounds = YES;
    [self.view addSubview:barCodeContainerView];
    
    [barCodeContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(barCodeContainerVievWidth);
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(barCodeContainerViewHeight);
        make.top.equalTo(guideLabel.mas_bottom).offset(10);
    }];
    
    _barCodeImageViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:220.0f];
    CGFloat barCodeImageViewTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:35.0f];
    
    _barCodeImageView = [[[UIImageView alloc] init] autorelease];
    [barCodeContainerView addSubview:_barCodeImageView];
    
    [_barCodeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(_barCodeImageViewWidth);
        make.centerX.equalTo(barCodeContainerView);
        make.height.mas_equalTo(_barCodeImageViewWidth);
        make.top.equalTo(barCodeContainerView).with.offset(barCodeImageViewTopOffset);
    }];
    
    CGFloat shopInfoContainerViewHeight = [JCHSizeUtility calculateWidthWithSourceWidth:50.0f];
    UIView *shopInfoContainerView = [[[UIView alloc] init] autorelease];
    shopInfoContainerView.backgroundColor = textColor;
    [barCodeContainerView addSubview:shopInfoContainerView];
    
    [shopInfoContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(barCodeContainerView);
        make.right.equalTo(barCodeContainerView);
        make.bottom.equalTo(barCodeContainerView);
        make.height.mas_equalTo(shopInfoContainerViewHeight);
    }];
    
    CGFloat shopImageViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:39.0f];
    CGFloat shopImageViewWidthOffset = [JCHSizeUtility calculateWidthWithSourceWidth:12.0f];
    _shopImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_store_1"]] autorelease];
    
    [shopInfoContainerView addSubview:_shopImageView];
    
    [_shopImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(shopInfoContainerView).with.offset(shopImageViewWidthOffset);
        make.width.mas_equalTo(shopImageViewWidth);
        make.height.mas_equalTo(shopImageViewWidth);
        make.centerY.equalTo(shopInfoContainerView);
    }];
    
    CGFloat refreshButtonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:44.0f];
    
    UIButton *refreshButton = [JCHUIFactory createButton:CGRectZero
                                                  target:self
                                                  action:@selector(requestPayQRCode)
                                                   title:nil
                                              titleColor:nil
                                         backgroundColor:nil];
    [refreshButton setImage:[UIImage imageNamed:@"setting_findclerk_refresh"] forState:UIControlStateNormal];
    [shopInfoContainerView addSubview:refreshButton];
    
    [refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(shopInfoContainerView);
        make.width.mas_equalTo(refreshButtonWidth);
        make.top.equalTo(shopInfoContainerView);
        make.bottom.equalTo(shopInfoContainerView);
    }];
    refreshButton.hidden = YES;
    
    CGSize fitSize = [@"验证码已过期" sizeWithAttributes:@{NSFontAttributeName : [UIFont jchSystemFontOfSize:12.0f]}];
    
    _countDownLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@"120s"
                                           font:[UIFont jchSystemFontOfSize:12.0f]
                                      textColor:JCHColorAuxiliary
                                         aligin:NSTextAlignmentRight];
    [shopInfoContainerView addSubview:_countDownLabel];
    _countDownLabel.hidden = YES;
    
    [_countDownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(refreshButton.mas_left);
        make.width.mas_equalTo(fitSize.width + 5);
        make.top.equalTo(shopInfoContainerView);
        make.bottom.equalTo(shopInfoContainerView);
    }];
    
    
    _shopNameLabel = [JCHUIFactory createLabel:CGRectZero
                                         title:@""
                                          font:[UIFont jchSystemFontOfSize:15.0f]
                                     textColor:JCHColorMainBody
                                        aligin:NSTextAlignmentLeft];
    [shopInfoContainerView addSubview:_shopNameLabel];
    
    [_shopNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_shopImageView.mas_right).with.offset(shopImageViewWidthOffset);
        make.right.equalTo(_countDownLabel.mas_left);
        make.top.equalTo(shopInfoContainerView);
        make.bottom.equalTo(shopInfoContainerView);
    }];
    
    
    UIButton *switchCodeButton = [JCHUIFactory createButton:CGRectZero
                                                     target:self
                                                     action:@selector(switchScanCode)
                                                      title:@"切换扫码收款"
                                                 titleColor:[UIColor whiteColor]
                                            backgroundColor:[UIColor clearColor]];
    switchCodeButton.layer.borderColor = [UIColor whiteColor].CGColor;
    switchCodeButton.layer.borderWidth = 1;
    switchCodeButton.layer.cornerRadius = 5;
    [self.view addSubview:switchCodeButton];
    
    [switchCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-50);
        make.height.mas_equalTo(kStandardButtonHeight);
        make.width.mas_equalTo(kStandardButtonHeight * 4);
        make.centerX.equalTo(self.view);
    }];
    
    id<BookInfoService> bookInfoService = [[ServiceFactory sharedInstance] bookInfoService];
    BookInfoRecord4Cocoa *bookInfo = [bookInfoService queryBookInfo:[[JCHSyncStatusManager shareInstance] userID]];
    _shopNameLabel.text = bookInfo.bookName;
}

- (void)switchScanCode
{
    if ([self.presentingViewController isKindOfClass:[JCHBarCodeScannerViewController class]]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        JCHBarCodeScannerViewController *barCodeScannerVC = [[[JCHBarCodeScannerViewController alloc] init] autorelease];
        if (self.enumPayCodeType == kJCHPayCodeAlipay) {
            barCodeScannerVC.title = @"支付宝收款";
            barCodeScannerVC.detailInfo = @"扫描客户支付宝里的二维码";
        } else if (self.enumPayCodeType == kJCHPayCodeWeiXin) {
            barCodeScannerVC.title = @"微信收款";
            barCodeScannerVC.detailInfo = @"扫描客户微信钱包里的二维码";
        }

        // barCodeScannerVC.showSwitchCodeButton = YES;
        // 空数组代表所有类型
        barCodeScannerVC.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        barCodeScannerVC.barCodeBlock = self.barCodeBlock;
        barCodeScannerVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:barCodeScannerVC animated:YES completion:nil];
    }
    
    // 切换扫码方式
    if (nil != self.changePayMethod) {
        self.changePayMethod();
    }
}

- (void)countDown
{
    NSString *secondsStr = [_countDownLabel.text substringToIndex:_countDownLabel.text.length - 1];
    NSInteger seconds = [secondsStr integerValue];
    seconds--;
    _countDownLabel.text = [NSString stringWithFormat:@"%lds", seconds];
    if (seconds == 0) {
        _countDownLabel.text = @"验证码已过期";
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)handleDissmiss
{
    if ([self.presentingViewController isKindOfClass:[JCHBarCodeScannerViewController class]]) {
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark 请求支付二维码
- (void)requestPayQRCode
{
    NSString *selectTradeType = @"";
    if (self.enumPayCodeType == kJCHPayCodeAlipay) {
        selectTradeType = @"API_ZFBQRCODE";
    } else if (self.enumPayCodeType == kJCHPayCodeWeiXin) {
        selectTradeType = @"API_WXQRCODE";
    } else {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@""
                                                             message:@""
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id<OnlineSettlement> settlementService = [[ServiceFactory sharedInstance] onlineSettlementService];
    
    CMBCCustomScanShopRequest *request = [[[CMBCCustomScanShopRequest alloc] init] autorelease];
    request.selectTradeType = selectTradeType;
    request.amount = self.payAmount;
    request.orderInfo = self.orderInfo;
    request.orderId = [NSString stringWithFormat:@"%@-%@", statusManager.accountBookID, self.orderID];
    request.bindId = self.bindID;
    request.token = statusManager.syncToken;
    request.serviceURL = [NSString stringWithFormat:@"%@/cmbc/qrPay", kCMBCPayServiceURL];
    
    [MBProgressHUD hideAllHudsForWindow];
    [MBProgressHUD showHUDWithTitle:@"温馨提示"
                             detail:@"正在获取支付二维码，请稍候..."
                           duration:3000
                               mode:MBProgressHUDModeIndeterminate
                         completion:nil];
    
    [settlementService cmbcCustomScanShopScan:request callback:^(id response) {
        [MBProgressHUD hideAllHudsForWindow];
        
        NSDictionary *userData = response;
        if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
            NSDictionary *responseData = userData[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                // fail
                [[JCHSettlementManager sharedInstance] handleCustomScanShopPayError:responseCode];
            } else {
                // success
                NSString *qrCodeURL = responseData[@"data"][@"qrCode"];
                if (self.enumPayCodeType == kJCHPayCodeAlipay) {
                    qrCodeURL = [qrCodeURL substringToIndex:qrCodeURL.length - 1];
                } else if (self.enumPayCodeType == kJCHPayCodeWeiXin) {
                    // pass
                }
                
                if (nil == qrCodeURL) {
                    [self showPayFailureAlert:@"获取二维码失败"];
                } else {
                    _barCodeImageView.image = [LBXScanWrapper createQRWithString:qrCodeURL
                                                                            size:CGSizeMake(_barCodeImageViewWidth, _barCodeImageViewWidth)];
                    [_timer invalidate];
                    _countDownLabel.text = @"120s";
                    _timer = [MSWeakTimer scheduledTimerWithTimeInterval:1
                                                                  target:self
                                                                selector:@selector(countDown)
                                                                userInfo:nil
                                                                 repeats:YES
                                                           dispatchQueue:dispatch_get_main_queue()];
                }
            }
        } else {
            // network error
            [self showPayFailureAlert:@"网络连接失败，请重试"];
        }
    }];
}

#pragma mark -
#pragma mark 显示支付失败提示
- (void)showPayFailureAlert:(NSString *)message
{
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"支付失败"
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"我知道了"
                                               otherButtonTitles:nil] autorelease];
    [alertView show];
}


@end
