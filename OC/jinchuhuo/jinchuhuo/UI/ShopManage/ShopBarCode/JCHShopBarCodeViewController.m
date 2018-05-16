//
//  JCHShopBarCodeViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/24.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHShopBarCodeViewController.h"
#import "CommonHeader.h"
#import "JCHSyncStatusManager.h"
#import "ServiceFactory.h"
#import <Masonry.h>
#import <LBXScanWrapper.h>

@interface JCHShopBarCodeViewController ()
{
    JCHShopBarCodeType _currentType;
    UIImageView *_barCodeImageView;
    UIImageView *_shopImageView;
    UILabel *_shopNameLabel;
    UILabel *_countDownLabel;
    CGFloat _barCodeImageViewWidth;
    NSTimer *_timer;
}
@end
@implementation JCHShopBarCodeViewController

- (instancetype)initWithShopBarCodeType:(JCHShopBarCodeType)type
{
    self = [super init];
    if (self) {
        _currentType = type;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self handleRefreshBarCode];
    [self.navigationController setNavigationBarHidden:YES animated:self.navigationBarHiddenAnimation];
}


- (void)createUI
{
    self.view.backgroundColor = UIColorFromRGB(0xd14e4f);
    
    UIColor *textColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [JCHUIFactory createLabel:CGRectMake(0, 20, kScreenWidth, kNavigatorBarHeight)
                                              title:@"店铺二维码"
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

    UILabel *guideLabel = [JCHUIFactory createLabel:CGRectMake(0, 20, kScreenWidth, kNavigatorBarHeight)
                                              title:@"向店员出示店铺二维码"
                                               font:[UIFont systemFontOfSize:15.0f]
                                          textColor:textColor
                                             aligin:NSTextAlignmentCenter];
    [self.view addSubview:guideLabel];
    
    CGFloat guideLabelTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:20];
    CGFloat guideLabelHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:45];
    [guideLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).with.offset(guideLabelTopOffset);
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
        make.top.equalTo(guideLabel.mas_bottom);
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
                                                  action:@selector(handleRefreshBarCode)
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
    
    CGSize fitSize = [@"验证码已过期" sizeWithAttributes:@{NSFontAttributeName : [UIFont jchSystemFontOfSize:12.0f]}];
    
    _countDownLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@"120s"
                                            font:[UIFont jchSystemFontOfSize:12.0f]
                                       textColor:JCHColorAuxiliary
                                          aligin:NSTextAlignmentRight];
    [shopInfoContainerView addSubview:_countDownLabel];
    
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
    
    CGFloat noticeImageViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:231.0f];
    CGFloat noticeImageViewHeight = [JCHSizeUtility calculateWidthWithSourceWidth:29.0f];
    CGFloat noticeImageViewTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:17.0f];
    UIImageView *noticeImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setting_qrcode_tips"]] autorelease];
    [self.view addSubview:noticeImageView];
    
    [noticeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(barCodeContainerView.mas_bottom).with.offset(noticeImageViewTopOffset);
        make.height.mas_equalTo(noticeImageViewHeight);
        make.width.mas_equalTo(noticeImageViewWidth);
        make.centerX.equalTo(self.view);
    }];
    
    if (_currentType == kJCHShopBarCodeFindShopAssistant) {
        titleLabel.text = @"找店员";
        guideLabel.text = @"向店员出示店铺二维码";
        _shopNameLabel.text = @"";
    }
}

- (void)handleRefreshBarCode
{
     NSString *barCode = [self generateQRCode];
    _barCodeImageView.image = [LBXScanWrapper createQRWithString:barCode
                                                            size:CGSizeMake(_barCodeImageViewWidth, _barCodeImageViewWidth)];
    [_timer invalidate];
    _countDownLabel.text = @"120s";
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self
                                                    selector:@selector(countDown)
                                                   userInfo:nil
                                                    repeats:YES];
}

- (NSString *)generateQRCode
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id<BookInfoService> bookInfoService = [[ServiceFactory sharedInstance] bookInfoService];
    id<PermissionService> permissionService = [[ServiceFactory sharedInstance] permissionService];
    id<UtilityService> utilityService = [[ServiceFactory sharedInstance] utilityService];
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    BookInfoRecord4Cocoa *bookInfo = [bookInfoService queryBookInfo:statusManager.userID];
    
    _shopNameLabel.text = bookInfo.bookName;
    
    NSString *qrCode = [dataSyncService generateQRCodeString:statusManager.userID
                                               accountBookID:statusManager.accountBookID
                                             accountBookName:bookInfo.bookName
                                                     roleUID:[permissionService getDefaultRoleUUID]
                                                   validTime:[[NSDate date] timeIntervalSince1970] + 60 * 2
                                                   checkUUID:[utilityService generateUUID]
                                                    userName:statusManager.userName];
    
    
    return qrCode;
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
    [self.navigationController popViewControllerAnimated:YES];
}

@end
