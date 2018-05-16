//
//  JCHCheckoutOnAccountViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHCheckoutOnAccountViewController.h"
#import "JCHAccountBookViewController.h"
#import "JCHSettleAccountsViewController.h"
#import "JCHChargeAccountDetailViewController.h"
#import "JCHChargeAccountViewController.h"
#import "JCHBarCodeScannerViewController.h"
#import "JCHCheckoutViewController.h"
#import "JCHCheckoutBottomMenuView.h"
#import "JCHSettlementManager.h"
#import "CommonHeader.h"
#import "JCHManifestMemoryStorage.h"
#import "JCHManifestType.h"
#import "JCHSyncStatusManager.h"
#import "JCHBluetoothManager.h"
#import <MSWeakTimer.h>
#import <Masonry.h>

@interface JCHCheckoutOnAccountViewController () <JCHCheckoutBottomMenuViewDelegate>
{
    UIImageView *_headImageView;
    UILabel *_nameLabel;
    UILabel *_companyNameLabel;
    UIView *_centerContainerView;
    JCHLabel *_receivableAmountLabel;
    JCHCheckoutBottomMenuView *_bottomMenuView;
    UIView *_maskView;
    NSInteger queryPayStatusUsedTime;
}

@property (nonatomic, retain) MSWeakTimer *payStatusTimer;
@property (nonatomic, retain) NSString *onlinePayAccountUUID;

@end

@implementation JCHCheckoutOnAccountViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.onlinePayAccountUUID = @"";
    }
    return self;
}

- (void)dealloc
{
    [self stopQueryPayStatusTimer];
    
    self.payStatusTimer = nil;
    self.onlinePayAccountUUID = nil;
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
    [self loadData];
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    if (manifestStorage.currentManifestType == kJCHOrderShipment) {
        self.title = @"赊销";
    } else if (manifestStorage.currentManifestType == kJCHOrderPurchases) {
        self.title = @"赊购";
    } else if (manifestStorage.currentManifestType == kJCHOrderReceipt) {
        self.title = @"收款";
    } else if (manifestStorage.currentManifestType == kJCHOrderPayment) {
        self.title = @"付款";
    }
    
    UIFont *textFont = [UIFont jchSystemFontOfSize:15.0f];
    CGFloat headImageViewTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:46.0f];
    CGFloat headImageViewWidth = ceil([JCHSizeUtility calculateWidthWithSourceWidth:65.0f]);
    CGFloat centerViewTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:208.0f];
    CGFloat centerViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:150.0f];
    CGFloat checkoutButtonTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:49.0f];
    CGFloat checkoutButtonHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:69.0f];
    CGFloat checkoutButtonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:255.0f];
    
    _headImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"homepage_avatar_default"]] autorelease];
    _headImageView.layer.cornerRadius = headImageViewWidth / 2;
    _headImageView.clipsToBounds = YES;
    [self.view addSubview:_headImageView];
    
    [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(headImageViewTopOffset);
        make.centerX.equalTo(self.view);
        make.height.and.width.mas_equalTo(headImageViewWidth);
    }];
    
    _nameLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@"张小姐"
                                      font:textFont
                                 textColor:JCHColorMainBody
                                    aligin:NSTextAlignmentCenter];
    [self.view addSubview:_nameLabel];
    
    CGSize fitSize = [@"张小姐" sizeWithAttributes:@{NSFontAttributeName : _nameLabel.font}];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_headImageView.mas_bottom).with.offset(4);
        make.height.mas_equalTo(fitSize.height + 3);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(kScreenWidth - 2 * kStandardLeftMargin);
    }];
    
    _companyNameLabel = [JCHUIFactory createLabel:CGRectZero
                                            title:@"深圳买卖人科技有限公司"
                                             font:textFont
                                        textColor:JCHColorAuxiliary
                                           aligin:NSTextAlignmentCenter];
    [self.view addSubview:_companyNameLabel];
    
    [_companyNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nameLabel.mas_bottom);
        make.height.and.width.and.centerX.equalTo(_nameLabel);
    }];
    
    _centerContainerView = [[[UIView alloc] init] autorelease];
    _centerContainerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_centerContainerView];
    
    [_centerContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(centerViewTopOffset);
        make.height.mas_equalTo(centerViewHeight);
    }];
    
    JCHLabel *receivableAmountTitleLabel = [JCHUIFactory createJCHLabel:CGRectZero
                                                              title:@"应付金额"
                                                               font:textFont
                                                          textColor:JCHColorMainBody
                                                             aligin:NSTextAlignmentLeft];
    receivableAmountTitleLabel.verticalAlignment = kVerticalAlignmentBottom;
    
    [_centerContainerView addSubview:receivableAmountTitleLabel];
    
    [receivableAmountTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_centerContainerView.mas_centerY).with.offset(-1.5 * kStandardLeftMargin);
        make.height.mas_equalTo(centerViewHeight / 3);
        make.left.equalTo(_centerContainerView).with.offset(kStandardLeftMargin);
        make.right.equalTo(_centerContainerView).with.offset(-kStandardLeftMargin);
    }];
    
    _receivableAmountLabel = [JCHUIFactory createJCHLabel:CGRectZero
                                                    title:@"¥ 0.00"
                                                     font:[UIFont jchSystemFontOfSize:42.0f]
                                                textColor:JCHColorMainBody
                                                   aligin:NSTextAlignmentLeft];
    _receivableAmountLabel.verticalAlignment = kVerticalAlignmentTop;
    [_centerContainerView addSubview:_receivableAmountLabel];
    
    [_receivableAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(receivableAmountTitleLabel.mas_bottom).with.offset(0.5 * kStandardLeftMargin);
        make.left.equalTo(receivableAmountTitleLabel).with.offset(kStandardLeftMargin);
        make.right.equalTo(receivableAmountTitleLabel);
        make.height.mas_equalTo(centerViewHeight / 2);
    }];
    
    UIButton *checkoutButton = [JCHUIFactory createButton:CGRectZero
                                                   target:self
                                                   action:@selector(handleCheckout)
                                                    title:@"确定"
                                               titleColor:[UIColor whiteColor]
                                          backgroundColor:UIColorFromRGB(0x69a4f1)];
    [self.view addSubview:checkoutButton];
    
    [checkoutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_centerContainerView.mas_bottom).with.offset(checkoutButtonTopOffset);
        make.height.mas_equalTo(checkoutButtonHeight);
        make.width.mas_equalTo(checkoutButtonWidth);
        make.centerX.equalTo(self.view);
    }];
    
    
    
    UILabel *infoLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@"确定后，请在“债务账户”下查看本单"
                                              font:[UIFont systemFontOfSize:13.0f]
                                         textColor:UIColorFromRGB(0x69a4f1)
                                            aligin:NSTextAlignmentCenter];
    [self.view addSubview:infoLabel];
    
    CGSize size = [infoLabel sizeThatFits:CGSizeZero];
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(checkoutButton.mas_bottom).with.offset(12.0f);
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(size.height);
        make.width.mas_equalTo(size.width);
    }];

    UIViewController *lastViewController = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
    if (![lastViewController isKindOfClass:[JCHSettleAccountsViewController class]]) {
        infoLabel.hidden = YES;
    }
    
    if (manifestStorage.currentManifestType == kJCHOrderShipment || manifestStorage.currentManifestType == kJCHOrderReceipt) {
        receivableAmountTitleLabel.text = @"应收金额";
        infoLabel.text = @"确定后，请在“债权账户”下查看本单";
    }
}

#pragma mark - LoadData
- (void)loadData
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];

    //如果是赊销赊购的还款单 
    if (manifestStorage.currentManifestType == kJCHOrderPayment ||
        manifestStorage.currentManifestType == kJCHOrderReceipt)
    {
        manifestStorage.currentManifestEraseAmount = 0.0f;
        manifestStorage.currentManifestDiscount = 1.0f;
        CGFloat totalAmount = 0.0f;
        for (ManifestARAPRecord4Cocoa *manifestARAPRecord in manifestStorage.manifestARAPList) {
            totalAmount += manifestARAPRecord.manifestARAPAmount;
        }
        manifestStorage.receivableAmount = totalAmount;
        manifestStorage.isRejected = NO;
    }
    

    _receivableAmountLabel.text = [NSString stringWithFormat:@"¥ %.2f", manifestStorage.receivableAmount];
    
    _headImageView.image = [UIImage imageWithColor:nil
                                              size:_headImageView.frame.size
                                              text:manifestStorage.currentContactsRecord.name
                                              font:[UIFont jchSystemFontOfSize:27.0f]];
    
    _nameLabel.text = manifestStorage.currentContactsRecord.name;
    _companyNameLabel.text = manifestStorage.currentContactsRecord.company;
    
    if ([_companyNameLabel.text isEqualToString:@""] || _companyNameLabel.text == nil) {
        
        CGFloat centerViewTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:208.0f];
        CGSize companyAddressLabelSize = [@"张小姐" sizeWithAttributes:@{NSFontAttributeName : _nameLabel.font}];
        
        [_centerContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(centerViewTopOffset - companyAddressLabelSize.height - 3);
        }];
    }
}

- (void)handleCheckout
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    if (manifestStorage.currentManifestType == kJCHOrderPayment || manifestStorage.currentManifestType == kJCHOrderReceipt) {
        
        [self showBottomMenuView];
    } else {
        
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
        NSString *counterPartyUUID = manifestStorage.currentContactsRecord.contactUUID;
        NSString *paymentAccountUUID = @"";
        if (kJCHOrderShipment == manifestStorage.currentManifestType) {
            paymentAccountUUID = [manifestService getCreditSaleAccountUUID];
        } else if (kJCHOrderPurchases == manifestStorage.currentManifestType) {
            paymentAccountUUID = [manifestService getCreditBuyingAccountUUID];
        } else {
            return;
        }
        NSInteger operatorID = [[[JCHSyncStatusManager shareInstance] userID] integerValue];
        int status = 1;

        
        
        //新增货单 / 复制货单
        if (manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeNew || manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeCopy) {
            
            ManifestInfoRecord4Cocoa *manifestInfoRecord = [[[ManifestInfoRecord4Cocoa alloc] init] autorelease];
            manifestInfoRecord.manifestID = manifestStorage.currentManifestID;
            manifestInfoRecord.manifestType = manifestStorage.currentManifestType;
            manifestInfoRecord.manifestRemark = manifestStorage.currentManifestRemark;
            manifestInfoRecord.manifestTimestamp = manifestTime;
            manifestInfoRecord.thirdPartOrderID = @"";
            manifestInfoRecord.thirdPartType = 0;
            manifestInfoRecord.expressCompany = @"";
            manifestInfoRecord.expressNumber = @"";
            manifestInfoRecord.consigneeName = @"";
            manifestInfoRecord.consigneePhone = @"";
            manifestInfoRecord.consigneeAddress = @"";
            
            
            status = [manifestService insertManifest:manifestInfoRecord
                                     transactionList:transactionList
                                    manifestDiscount:manifestStorage.currentManifestDiscount
                                         eraseAmount:manifestStorage.currentManifestEraseAmount * manifestStorage.isRejected
                                        counterParty:counterPartyUUID
                                  paymentAccountUUID:paymentAccountUUID
                                          operatorID:operatorID
                                       feeRecordList:nil];
        } else if (manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeEdit) {
            //编辑货单
            ManifestInfoRecord4Cocoa *manifestInfoRecord = [[[ManifestInfoRecord4Cocoa alloc] init] autorelease];
            manifestInfoRecord.manifestID = manifestStorage.currentManifestID;
            manifestInfoRecord.manifestType = manifestStorage.currentManifestType;
            manifestInfoRecord.manifestRemark = manifestStorage.currentManifestRemark;
            manifestInfoRecord.manifestTimestamp = manifestTime;
            manifestInfoRecord.thirdPartOrderID = @"";
            manifestInfoRecord.thirdPartType = 0;
            manifestInfoRecord.expressCompany = @"";
            manifestInfoRecord.expressNumber = @"";
            manifestInfoRecord.consigneeName = @"";
            manifestInfoRecord.consigneePhone = @"";
            manifestInfoRecord.consigneeAddress = @"";
            
            status = [manifestService updateManifest:manifestInfoRecord
                                     transactionList:transactionList
                                    manifestDiscount:manifestStorage.currentManifestDiscount
                                         eraseAmount:manifestStorage.currentManifestEraseAmount * manifestStorage.isRejected counterParty:counterPartyUUID
                                  paymentAccountUUID:paymentAccountUUID
                                          operatorID:operatorID
                                       feeRecordList:nil];
        } else {
            //pass
        }
        
        manifestStorage.hasPayed = NO;
#if !TARGET_OS_SIMULATOR
        //蓝牙打印
        {
            JCHBluetoothManager *bluetoothManager = [JCHBluetoothManager shareInstance];
            
            if ((bluetoothManager.canPrintInShipment && manifestStorage.currentManifestType == kJCHOrderShipment) ||
                (bluetoothManager.canPrintInPurchase && manifestStorage.currentManifestType == kJCHOrderPurchases)) {
                
#if !TARGET_OS_SIMULATOR
                JCHPrintInfoModel *printInfo = [[[JCHPrintInfoModel alloc] init] autorelease];
                printInfo.manifestType = manifestStorage.currentManifestType;
                printInfo.manifestID = manifestStorage.currentManifestID;
                printInfo.manifestDate = manifestStorage.currentManifestDate;
                printInfo.manifestDiscount = manifestStorage.currentManifestDiscount;
                printInfo.eraseAmount = manifestStorage.currentManifestEraseAmount * manifestStorage.isRejected;
                printInfo.manifestRemark = manifestStorage.currentManifestRemark;
                printInfo.contactName = manifestStorage.currentContactsRecord.name;
                printInfo.hasPayed = manifestStorage.hasPayed;
                printInfo.transactionList = currentProductInManifestList;
                [[JCHBluetoothManager shareInstance] printManifest:printInfo showHud:NO];
#endif
            }
        }
#endif
        NSString *detailTextSuccess = nil;
        NSString *detailTextFailed = nil;
        if (manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeEdit) {
            detailTextSuccess = @"订单修改成功";
            detailTextFailed = @"订单修改失败";
            
        }  else if (manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeCopy) {
            detailTextSuccess = @"订单复制成功";
            detailTextFailed = @"订单复制失败";
            
        } else if (manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeNew) {
            if (manifestStorage.currentManifestType == kJCHOrderPurchases) {
                detailTextSuccess = @"赊购成功";
                detailTextFailed = @"赊购失败";
            } else if (manifestStorage.currentManifestType == kJCHOrderShipment) {
                detailTextSuccess = @"赊销成功";
                detailTextFailed = @"赊销失败";
            }
        } else {
            //pass
        }
        
        
        if (status == 0) {
            if (detailTextSuccess) {
                [MBProgressHUD showHUDWithTitle:detailTextSuccess
                                         detail:nil
                                       duration:kJCHDefaultShowHudTime
                                           mode:MBProgressHUDModeText
                                     completion:nil];
            }
        } else {
            if (detailTextFailed) {
                [MBProgressHUD showHUDWithTitle:detailTextFailed
                                         detail:nil
                                       duration:kJCHDefaultShowHudTime
                                           mode:MBProgressHUDModeText
                                     completion:nil];
            }
        }

        AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
        [self.navigationController popToViewController:appDelegate.switchToTargetController animated:YES];
    }
}

- (void)showBottomMenuView
{
    CGFloat bottomViewHeight = 190;
    _bottomMenuView = [[[JCHCheckoutBottomMenuView alloc] initWithFrame:CGRectMake(-kScreenWidth, kScreenHeight + 44, 2 * kScreenWidth, bottomViewHeight)] autorelease];
    _bottomMenuView.delegate = self;
    [_bottomMenuView setButton:kJCHPayWayTickTag Enabled:NO];
 
#if 0
    //如果是收款单 并且客户储值卡余额大于0，点亮储值卡按钮   暂时不点亮!!!
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    CGFloat balance = [manifestService queryCardBalance:manifestStorage.currentContactsRecord.contactUUID];
    if (balance > 0 && manifestStorage.currentManifestType == kJCHOrderReceipt) {
        [_bottomMenuView setButton:kJCHPayWaySavingsCardTag Enabled:YES];
    }
#endif
    
    UIView *window = [UIApplication sharedApplication].windows[0];
    _maskView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    _maskView.backgroundColor = [UIColor blackColor];
    _maskView.alpha = 0;
    [window addSubview:_maskView];
    [window addSubview:_bottomMenuView];
    
    [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(window);
        make.right.equalTo(window);
        make.bottom.equalTo(window);
        make.top.equalTo(window);
    }];
    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBottomMenuView)] autorelease];
    [_maskView addGestureRecognizer:tap];

    CGRect frame = _bottomMenuView.frame;
    frame.origin.y -= bottomViewHeight + 44;
    [UIView animateWithDuration:0.25 animations:^{
        _bottomMenuView.frame = frame;
        _maskView.alpha = 0.5;
        
    }];
}

- (void)hideBottomMenuView
{
    CGFloat bottomViewHeight = 190;
    CGRect frame = _bottomMenuView.frame;
    frame.origin.y += bottomViewHeight + 44;
    [UIView animateWithDuration:0.3 animations:^{
        _bottomMenuView.frame = frame;
        _maskView.alpha = 0;
    } completion:^(BOOL finished) {
        [_maskView removeFromSuperview];
        [_bottomMenuView removeFromSuperview];
    }];
}

#pragma mark - JCHCheckoutBottomMenuViewDelegate

- (void)handleSelectPayWay:(UIButton *)button
{
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    switch (button.tag) {
        case kJCHPayWayCachTag:  //现金
        {
            [self hideBottomMenuView];
            JCHCheckoutViewController *checkoutBuCashVC = [[[JCHCheckoutViewController alloc] initWithPayWay:kJCHCheckoutPayWayCash] autorelease];
            [self.navigationController pushViewController:checkoutBuCashVC animated:YES];
        }
            break;
            
        case kJCHPayWayWeChatTag:  //微信
        {
            self.onlinePayAccountUUID = [manifestService getWeiXinPayViaCMBCAccountUUID];
            JCHSettlementManager *settlementManager = [JCHSettlementManager sharedInstance];
            [settlementManager handleSelectPayWay:button viewController:self];              
        }
            break;
            
        case kJCHPayWayAlipayTag:   //支付宝
        {
            self.onlinePayAccountUUID = [manifestService getAliPayViaCMBCAccountUUID];
            JCHSettlementManager *settlementManager = [JCHSettlementManager sharedInstance];
            [settlementManager handleSelectPayWay:button viewController:self];            
        }
            break;
            
        case kJCHPayWayUnionPayTag:  //银联
        {
            JCHSettlementManager *settlementManager = [JCHSettlementManager sharedInstance];
            [settlementManager handleSelectPayWay:button viewController:self];
        }
            break;
            
        case kJCHPayWayTickTag:      //赊销赊购
        {
            
        }
            break;
            
        case kJCHPayWaySavingsCardTag: //储值卡
        {
            [self hideBottomMenuView];
            JCHCheckoutViewController *checkoutVC = [[[JCHCheckoutViewController alloc] initWithPayWay:kJCHCheckoutPayWaySavingCard] autorelease];
            [self.navigationController pushViewController:checkoutVC animated:YES];
        }
            break;
        default:
            break;
    }
}


#pragma mark -
#pragma mark 扫描支付宝二维码
- (void)handleFinishScanBarAlipayBarCode:(NSString *)qrCode
{
    JCHSettlementManager *settlementManager = [JCHSettlementManager sharedInstance];
    [settlementManager handleFinishScanBarAlipayBarCode:qrCode];
}

#pragma mark -
#pragma mark 扫描微信二维码
- (void)handleFinishScanWeiXinBarCode:(NSString *)qrCode
{
    JCHSettlementManager *settlementManager = [JCHSettlementManager sharedInstance];
    [settlementManager handleFinishScanWeiXinBarCode:qrCode];
}


- (void)restartQueryPayStatus
{
    // 停掉之前的查询定时器
    [self stopQueryPayStatusTimer];
    
    // 重新启动定时器
    [self startQueryPayStatusTimer];
}

- (void)queryPayStatusStatus
{
    queryPayStatusUsedTime += kQueryCMBCPayStatusTime;
    if (queryPayStatusUsedTime >= kQueryCMBCPayStatusTimeOut) {
        [self stopQueryPayStatusTimer];
        [self dismissViewControllerAnimated:YES completion:nil];
        [MBProgressHUD hideAllHudsForWindow];
        [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                 detail:@"查询支付状态超时"
                               duration:3.0
                                   mode:MBProgressHUDModeText
                             completion:nil];
        return;
    }
    
    JCHSettlementManager *settlementManager = [JCHSettlementManager sharedInstance];
    [settlementManager queryPayStatusStatus:^{
        // 停止支付状态查询
        [self stopQueryPayStatusTimer];
        
        // 保存货单
        [self saveOrderList:self.onlinePayAccountUUID];
    }];
}

#pragma mark -
#pragma mark 启动支付结果查询定时器
- (void)startQueryPayStatusTimer
{
    queryPayStatusUsedTime = 0;
    [self stopQueryPayStatusTimer];
    
    self.payStatusTimer = [MSWeakTimer scheduledTimerWithTimeInterval:kQueryCMBCPayStatusTime
                                                               target:self
                                                             selector:@selector(queryPayStatusStatus)
                                                             userInfo:nil
                                                              repeats:YES
                                                        dispatchQueue:dispatch_get_main_queue()];
    
}

#pragma mark -
#pragma mark 停止支付状态查询定时器
- (void)stopQueryPayStatusTimer
{
    [self.payStatusTimer invalidate];
    self.payStatusTimer = nil;
}

- (void)saveOrderList:(NSString *)paymentAccountUUID
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];

    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    
    //应收应付货单
    [manifestService manifestARAP:manifestStorage.currentContactsRecord.contactUUID
                      accountUUID:paymentAccountUUID
                       operatorID:[[[JCHSyncStatusManager shareInstance] userID] integerValue]
                 manifestARAPList:manifestStorage.manifestARAPList];

    
    //NSArray *allManifestList = nil;
    //ManifestPurchasesShipmentAmountRecord4Cocoa *allAmountRecord = nil;
    //[manifestService queryAllManifest:&allAmountRecord manifestArray:&allManifestList];
    
    if (manifestStorage.currentManifestType == kJCHOrderReceipt || manifestStorage.currentManifestType == kJCHChargeAccountPayment) {
        //! @brief 查询指定用户应收账款对应的货单列表 //! @brief 查询指定用户应付账款对应的货单列表
        
        NSArray *viewControllers = self.navigationController.viewControllers;
        
        JCHChargeAccountDetailViewController *chargeAccountDetailVC = nil;
        JCHChargeAccountViewController *chargeAccountVC = nil;
        for (UIViewController *viewController in viewControllers) {
            
            if ([viewController isKindOfClass:[JCHChargeAccountDetailViewController class]]) {
                chargeAccountDetailVC = (JCHChargeAccountDetailViewController *)viewController;
                
                //! @note 结账后标记该页面需要刷新
                chargeAccountDetailVC.isNeedReloadAllData = YES;
            }
            
            if ([viewController isKindOfClass:[JCHChargeAccountViewController class]]) {
                chargeAccountVC = (JCHChargeAccountViewController *)viewController;
                chargeAccountVC.isNeedReloadAllData = YES;
            }
            
            if ([viewController isKindOfClass:[JCHAccountBookViewController class]]) {
                JCHAccountBookViewController *accountBookViewController = (JCHAccountBookViewController *)viewController;
                accountBookViewController.isNeedReloadAllData = YES;
            }
        }
        
        if (chargeAccountDetailVC.allManifest.count > 1) {
            [self.navigationController popToViewController:chargeAccountDetailVC animated:YES];
        } else {
            [self.navigationController popToViewController:chargeAccountVC animated:YES];
        }
    }
}



@end
