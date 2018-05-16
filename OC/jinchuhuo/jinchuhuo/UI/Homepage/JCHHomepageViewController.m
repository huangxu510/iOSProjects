//
//  JCHHomepageViewController.m
//  jinchuhuo
//
//  Created by apple on 15/8/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHHomepageViewController.h"
#import "JCHTakeoutOrderReceivingViewController.h"
#import "JCHAddOtherIncomeAndExpenseViewController.h"
#import "JCHMenuView.h"
#import "JCHHomepageViewController+updateWarehouseStatus.h"
#import "JCHServiceWindowViewController.h"
#import "JCHGuideFirstViewController.h"
#import "JCHShopAssistantHomepageViewController.h"
#import "JCHGuideFirstViewController.h"
#import "JCHEnforceLoginViewController.h"
#import "JCHTempManifestViewController.h"
#import "JCHHTMLViewController.h"
#import "JCHLoginViewController.h"
#import "JCHHomePageView.h"
#import "JCHBarCodeScannerViewController.h"
#import "JCHShopsContainerView.h"
#import "JCHMyViewController.h"
#import "JCHManageStatisticsView.h"
#import "JCHAddProductMainViewController.h"
#import "JCHCreateManifestViewController.h"
#import "JCHRestaurantOpenTableViewController.h"
#import "JCHIntroductionView.h"
#import "JCHGradientProgressView.h"
#import "JCHManifestMemoryStorage.h"
#import "JCHManifestType.h"
#import "JCHUIDebugger.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "ServiceFactory.h"
#import "JCHCurrentDevice.h"
#import "JCHManifestUtility.h"
#import "JCHSyncServerSettings.h"
#import "JCHSyncStatusManager.h"
#import "JCHServiceResponseSettings.h"
#import "JCHServiceResponseNotification.h"
#import "JCHControllerNavigationSettings.h"
#import "JCHManifestKeyboardView.h"
#import "JCHStatisticsManager.h"
#import "BButton.h"
#import "JCHColorSettings.h"
#import "UIImage+JCHImage.h"
#import "Masonry.h"
#import "MBProgressHUD+JCHHud.h"
#import "AppDelegate.h"
#import "PermissionService.h"
#import "JCHSyncStatusManager.h"
#import "BookInfoService.h"
#import "JCHStatisticsManager.h"
#import "JCHAudioUtility.h"
#import "JCHTitleArrowButton.h"
#import "JCHNetWorkingUtility.h"
#import "JCHDisplayNameUtility.h"
#import "ImageFileSynchronizer.h"
#import "JCHOnlineUpgradeView.h"
#import "JCHUserInfoViewController.h"
#import "AppDelegate+JCHAppDelegate.h"
#import "CommonHeader.h"
#import "JCHShopUtility.h"
#import <LBXScanView.h>
#import <KLCPopup.h>
#import "NSArray+JCHArray.h"

/**
 *  HelveticaNeueInterface-Regular  iOS8
    SFUIText-Regular                iOS9
 */

enum ProgressViewSettings
{
    kTotalManageScoreValue = 600,
    kMinManageScoreValue = 350,
    kMinStartAngle = -225,
    kMaxEndAngle = 45,
    kInitializeAngle = 60,
};

//! @brief 刷新经营指数的时间间隔
#ifndef kRefreshManageIndexTime
#define kRefreshManageIndexTime (60 * 60 * 24 * 7)
#endif



@interface JCHHomepageViewController () <JCHShopsContainerViewDelegate,
                                        JCHOnlineUpgradeViewDelegate,
                                        JCHMenuViewDelegate>
{
    JCHIntroductionView *introductionView;
    
    UIImageView *rootViewContent;
    JCHShopsContainerView *shopsContainerView;
    JCHManageStatisticsView *manageStatisticsView;
    UIImageView *progressBackground;
    JCHGradientProgressView *manageGradientProgressView;
    JCHOnlineUpgradeView *onlineUpgradeView;
    
    UILabel *manageScoreValueLabel;
    UIImageView *manageScoreBg;
    
    UILabel *updateInfoLabel;

    UIButton *purchasesButton;
    UIButton *shipmentButton;
    UIButton *temporaryManifestButton;
    
    NSInteger currentTotalAnimateLoopCount;
    NSInteger totalAnimateLoopCount;
    CGFloat totalAnimateTime;
    
    CGFloat progressViewHeight;
    CGFloat progressViewWidth;
    
    CGFloat manageIndexValue;
    CGFloat chainRelativeRatio;
    NSTimeInterval updateTimeInterval;
    
    JCHTitleArrowButton *titleButton;
    UIBarButtonItem *my;
    
    BOOL updateTopStatisticsFlag;
    BOOL isLockUpgradeMode;
    NSInteger onlineUpgradePushVersion;
    
    KLCPopup *currentPopupView;
    BOOL isInManualSyncProgress;
    BOOL isInAutoSyncPushMode;
    BOOL isInAutoSyncPullMode;
}

@property (retain, nonatomic, readwrite) NSString *syncUploadFilePath;
@property (retain, nonatomic, readwrite) NSString *syncDownloadFilePath;
@property (retain, nonatomic, readwrite) NSString *syncColumnFilePath;
@property (retain, nonatomic, readwrite) MBProgressHUD *syncHUDProgressView;
@property (retain, nonatomic, readwrite) NSString *currentCreateShopID;
@property (retain, nonatomic, readwrite) JoinAccountBookResponse *currentJoinAccountBookInfo;

//暂存经营指数
@property (retain, nonatomic, readwrite) NSNumber *manageIndexCache;

@end

@implementation JCHHomepageViewController

- (id)init
{
    self = [super init];
    if (self) {

        totalAnimateLoopCount = 30;
        totalAnimateTime = 0.5f;
        manageIndexValue = kMinManageScoreValue;
        chainRelativeRatio = 100.0f;
        updateTopStatisticsFlag = YES;
        isInManualSyncProgress = NO;
        isInAutoSyncPushMode = NO;
        isInAutoSyncPullMode = NO;
        
        progressViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:227];
        progressViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:270];
        
        [self registerResponseNotificationHandler];
    }
    
    return self;
}

- (void)dealloc
{
    [self unregisterResponseNotificationHandler];
    [self.syncUploadFilePath release];
    [self.syncDownloadFilePath release];
    [self.syncColumnFilePath release];
    [self.syncHUDProgressView release];
    [self.currentCreateShopID release];
    [self.currentJoinAccountBookInfo release];
    [self.manageIndexCache release];
    
    [super dealloc];
    return;
}

- (void)loadView
{
    CGRect viewFrame = [[UIScreen mainScreen] applicationFrame];
    viewFrame.origin = CGPointMake(0.0f, 0.0f);
    self.view = [[[JCHHomePageView alloc] initWithFrame:viewFrame] autorelease];
    
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
    
    return;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar setBarTintColor:JCHColorHeaderBackground];
    self.hidesBottomBarWhenPushed = NO;
    titleButton.selected = NO;
    
    //设置最根部的nav的导航栏隐藏
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    UINavigationController *rootNav = (UINavigationController *)window.rootViewController;
    [rootNav setNavigationBarHidden:YES animated:NO];
    
    //当从店员首页退出登陆，再登陆进店长首页的时候tabbar有可能会消失，这里取消隐藏
    self.tabBarController.tabBar.hidden = NO;
    
#if MMR_TAKEOUT_VERSION
    [self fetchTakeoutInfo];
#endif
}

- (void)handleApplicationWillEnterForeground
{
    [super handleApplicationWillEnterForeground];
    
#if MMR_TAKEOUT_VERSION
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (statusManager.isLogin) {
        [self fetchTakeoutInfo];
    }
#endif
}

// 拉去外卖相关信息
- (void)fetchTakeoutInfo
{
    // 外卖版查询新订单个数和已经完成的订单
    JCHTakeoutManager *takeoutManager = [JCHTakeoutManager sharedInstance];
    [takeoutManager queryTakeoutNewOrder:YES];
    [takeoutManager fetchCompletedOrders];
    [takeoutManager fetchRefundedOrders];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 检查是否需要在线升级，如果需要，则进行在线升级
    BOOL isNeedOnlineUpgrade = [self doOnlineUpgrade];
    if (NO == isNeedOnlineUpgrade) {
        // 不需要在线升级，刷新数据
        updateTopStatisticsFlag = YES;
        [self loadData];
    } else {
        // 需要在线升级,由doOnlineUpgrade继续进行在线升级
    }

    //刷新挂单数据
    [self handleRefreshTemporaryManifestButton];
    
#if 0
    //查询刷新仓库状态
    [self handleUpdateWarehouseStatus];
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    updateTopStatisticsFlag = FALSE;
    if (nil != manageGradientProgressView) {
        manageGradientProgressView.hidden = YES;
        [manageGradientProgressView removeFromSuperview];
        manageGradientProgressView = nil;
        manageIndexValue = kMinManageScoreValue;
        [self createManageIndexView:0.0];
    }
    
    AppDelegate *theDelegate = [AppDelegate sharedAppDelegate];
    theDelegate.switchToTargetController = self;
}

- (void)handleFinanceBusiness
{
    //@"http://192.168.1.12:8080/mmr-credit/login/simpleLogin.html"     http://192.168.1.9:8088/mmr-credit/
    
    JCHHTMLViewController *finace = [[[JCHHTMLViewController alloc] initWithURL:kJCHQianChengDaiEntranceIP postRequest:YES] autorelease];
    finace.navigationBarColor = UIColorFromRGB(0xfe7600);
    finace.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:finace animated:YES];
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;

    titleButton = [JCHTitleArrowButton buttonWithType:UIButtonTypeCustom];
    titleButton.autoReverseArrow = YES;
    titleButton.autoAdjustButtonWidth = YES;
    titleButton.maxWidth = 140;
    [titleButton setImage:[UIImage imageNamed:@"homepage_storename_open"] forState:UIControlStateNormal];
    titleButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleButton.frame = CGRectMake(0, 0, 40, 40);
    [titleButton setTitle:@"我的小店" forState:UIControlStateNormal];
    [titleButton addTarget:self action:@selector(handlePushPullShopsView:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleButton;

    UIButton *addButton = [JCHUIFactory createButton:CGRectMake(0, 0, 30, 44)
                                              target:self
                                              action:@selector(showTopMenuView)
                                               title:nil
                                          titleColor:nil
                                     backgroundColor:nil];
    [addButton setImage:[UIImage imageNamed:@"icon_account_add"] forState:UIControlStateNormal];
    UIBarButtonItem *addItem = [[[UIBarButtonItem alloc] initWithCustomView:addButton] autorelease];
    

    UIBarButtonItem *fixedSpace = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:self
                                                                                action:nil] autorelease];
    fixedSpace.width = -5;
    
#if !MMR_TAKEOUT_VERSION
    UIButton *scanButton = [JCHUIFactory createButton:CGRectMake(0, 0, 30, 44)
                                               target:self
                                               action:@selector(handleScanQRCode)
                                                title:nil
                                           titleColor:nil
                                      backgroundColor:nil];
    [scanButton setImage:[UIImage imageNamed:@"nav_ic_homepage_scan"] forState:UIControlStateNormal];
    UIBarButtonItem *scanItem = [[[UIBarButtonItem alloc] initWithCustomView:scanButton] autorelease];
#endif
    
#if MMR_TAKEOUT_VERSION
    self.navigationItem.rightBarButtonItems = @[fixedSpace, addItem];
#else
    self.navigationItem.rightBarButtonItems = @[fixedSpace, addItem, scanItem];
#endif
    
    

    UIButton *myButton = [JCHUIFactory createButton:CGRectMake(0, 0, 30, 30)
                                             target:self
                                             action:@selector(handlePushToMyViewController)
                                              title:nil
                                         titleColor:nil
                                    backgroundColor:nil];
    myButton.layer.borderColor = [UIColor whiteColor].CGColor;
    myButton.layer.borderWidth = 1;
    myButton.clipsToBounds = YES;
    myButton.layer.cornerRadius = 15;
    [myButton setImage:[UIImage imageNamed:@"homepage_avatar_default"] forState:UIControlStateNormal];

    my = [[[UIBarButtonItem alloc] initWithCustomView:myButton] autorelease];
    

    self.navigationItem.leftBarButtonItems = @[fixedSpace, my];
    

    UIPanGestureRecognizer *pan = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)] autorelease];
    [self.view addGestureRecognizer:pan];
    
    CGFloat shopsContainerViewHeight = [JCHSizeUtility calculateWidthWithSourceWidth:kJCHShopsComponentViewHeight];
    CGRect shopsContainerViewFrame = CGRectMake(0, -2 * shopsContainerViewHeight, kScreenWidth, 2 * shopsContainerViewHeight);
    shopsContainerView = [[[JCHShopsContainerView alloc] initWithFrame:shopsContainerViewFrame] autorelease];
    shopsContainerView.delegate = self;
    shopsContainerView.clipsToBounds = YES;
    [self.view addSubview:shopsContainerView];
    JCHHomePageView *homePageView = (JCHHomePageView *)self.view;
    homePageView.subView = shopsContainerView;
    
    // 创建UI容器
    const CGFloat rootViewTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:15.0f];
    const CGFloat rootViewLeftRightOffset = [JCHSizeUtility calculateWidthWithSourceWidth:14.0f];
    const CGFloat rootViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:434.0f];


    rootViewContent = [[[UIImageView alloc] init] autorelease];
    rootViewContent.userInteractionEnabled = YES;
    rootViewContent.layer.cornerRadius = 5.0f;
    rootViewContent.image = [UIImage imageNamed:@"info_piao"];
    [self.view addSubview:rootViewContent];
    
    [rootViewContent mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).with.offset(rootViewTopOffset);
        make.left.equalTo(self.view.mas_left).with.offset(rootViewLeftRightOffset);
        make.height.mas_equalTo(rootViewHeight);
    }];
    
    // 经营统计
    const CGFloat manageStatisticsViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:118.5f];
    manageStatisticsView = [[[JCHManageStatisticsView alloc] initWithFrame:CGRectZero] autorelease];
    [rootViewContent addSubview:manageStatisticsView];
    [manageStatisticsView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(rootViewContent.mas_centerX);
        make.top.equalTo(rootViewContent.mas_top);
        make.left.equalTo(rootViewContent.mas_left);
        make.height.mas_equalTo(manageStatisticsViewHeight);
    }];
    
    JCHManageStatisticsViewData *cellData = [[[JCHManageStatisticsViewData alloc] init] autorelease];
    cellData.todayPurchaseAmount = @"0.00";
    cellData.monthProfitAmount = @"0.00";
    cellData.todayShipmentAmount = @"0.00";
    [manageStatisticsView setViewData:cellData];
    
    
    const CGFloat progressViewTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:35];
    
    //圆环背景
    NSString *progressBgImageName = @"pan_bg";

    progressBackground = [[[UIImageView alloc] init] autorelease];
    progressBackground.image  = [UIImage imageNamed:progressBgImageName];
    progressBackground.contentMode = UIViewContentModeScaleAspectFit;
    [rootViewContent addSubview:progressBackground];
    [progressBackground mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(rootViewContent.mas_centerX);
        make.width.mas_equalTo(progressViewWidth);
        make.top.equalTo(manageStatisticsView.mas_bottom).with.offset(progressViewTopOffset);
        make.height.mas_equalTo(progressViewHeight);
    }];
    
    
    //环形渐变进度条
    [self createManageIndexView:0.0];
    
    
    //经营分数圆盘背景
    manageScoreBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pan_o"]];
    [rootViewContent addSubview:manageScoreBg];
    manageScoreBg.contentMode = UIViewContentModeScaleAspectFit;
    manageScoreBg.userInteractionEnabled = YES;
    [manageScoreBg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(progressBackground.mas_centerX);
        make.width.mas_equalTo(7.5 * kStandardHeightOffsetWithTabBar);
        make.centerY.equalTo(progressBackground.mas_top).with.offset(13.5 * kStandardHeightOffsetWithTabBar);
        make.height.mas_equalTo(7.5 * kStandardHeightOffsetWithTabBar);
    }];
    
    
    // 经营分数
    manageScoreValueLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    [rootViewContent addSubview:manageScoreValueLabel];
    manageScoreValueLabel.text = @"350";
    manageScoreValueLabel.textAlignment = NSTextAlignmentCenter;
    manageScoreValueLabel.textColor = UIColorFromRGB(0Xff7372);
    manageScoreValueLabel.font = [UIFont fontWithName:FontRoundedNumber size:[JCHSizeUtility calculateFontSizeWithSourceSize:26.0f]];
    manageScoreValueLabel.userInteractionEnabled = YES;
    [manageScoreValueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(manageScoreBg);
    }];
    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchToAnalyseVC)] autorelease];
    [manageScoreValueLabel addGestureRecognizer:tap];
    
    const CGFloat updateInfoLabelTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:7.5f];
    const CGFloat updateInfoLabelHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:17];
    
    //环比增长
    updateInfoLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@"更新日期:"
                                              font:JCHFont(12)
                                         textColor:UIColorFromRGB(0xb0b0b0)
                                            aligin:NSTextAlignmentCenter];
    [rootViewContent addSubview:updateInfoLabel];
    
    
    [updateInfoLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(progressViewWidth);
        make.top.equalTo(progressBackground.mas_bottom).with.offset(updateInfoLabelTopOffset);
        make.height.mas_equalTo(updateInfoLabelHeight);
    }];
    
    
    // 进货按钮
    
    UIFont *btnTitltFont = [UIFont jchSystemFontOfSize:17];
    const CGFloat buttonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:167];
    purchasesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    purchasesButton.titleLabel.font = btnTitltFont;
    [purchasesButton setTitle:@"进货" forState:UIControlStateNormal];
    [purchasesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [purchasesButton addTarget:self
                        action:@selector(handlePurchase:)
              forControlEvents:UIControlEventTouchUpInside];
    purchasesButton.layer.cornerRadius = 2.0f;
    [purchasesButton setImage:[UIImage imageNamed:@"icon_jinHuo"] forState:0];
    [purchasesButton setBackgroundImage: [UIImage imageNamed:@"bt_jinHuo"] forState:0];
    [purchasesButton setBackgroundImage: [UIImage imageNamed:@"bt_jinHuo_click"] forState:UIControlStateHighlighted];
    purchasesButton.adjustsImageWhenHighlighted = NO;
    purchasesButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);

    [self.view addSubview:purchasesButton];
    [purchasesButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rootViewContent.mas_left);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-2.65 * kStandardHeightOffsetWithTabBar);
        make.width.mas_equalTo(buttonWidth);
        make.top.equalTo(rootViewContent.mas_bottom).with.offset(2.9 * kStandardHeightOffsetWithTabBar);
    }];

    
    // 出货按钮
    shipmentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shipmentButton.titleLabel.font = btnTitltFont;
    [shipmentButton setTitle:@"出货" forState:UIControlStateNormal];
    [shipmentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shipmentButton setBackgroundImage:[UIImage imageNamed:@"bt_chuHuo"] forState:0];
    [shipmentButton setBackgroundImage:[UIImage imageNamed:@"bt_chuHuo_click"] forState:UIControlStateHighlighted];
    [shipmentButton setImage:[UIImage imageNamed:@"icon_chuHuo"] forState:0];

    [shipmentButton addTarget:self
                       action:@selector(handleShipment:)
             forControlEvents:UIControlEventTouchUpInside];
    shipmentButton.layer.cornerRadius = 2.0f;
    shipmentButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    shipmentButton.adjustsImageWhenHighlighted = NO;
    [self.view addSubview:shipmentButton];
    [shipmentButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(rootViewContent.mas_right);
        make.top.equalTo(purchasesButton.mas_top);
        make.width.mas_equalTo(buttonWidth);
        make.bottom.equalTo(purchasesButton.mas_bottom);
    }];
    

    CGFloat temporaryButtonWidth = 30;
    CGFloat temporaryButtonHeight = 40;
    //挂单按钮
    temporaryManifestButton = [JCHUIFactory createButton:CGRectZero
                                                  target:self
                                                  action:@selector(handleShowTemporaryManifestList)
                                                   title:@""
                                              titleColor:[UIColor whiteColor]
                                         backgroundColor:[UIColor clearColor]];
    temporaryManifestButton.adjustsImageWhenHighlighted = NO;
    //[temporaryManifestButton setImage:[UIImage imageNamed:@"bg_homepage_restingorder"] forState:UIControlStateNormal];
    [temporaryManifestButton setBackgroundImage:[UIImage imageNamed:@"bg_homepage_restingorder"] forState:UIControlStateNormal];
    temporaryManifestButton.titleEdgeInsets = UIEdgeInsetsMake(-5, 0, 0, 0);
    temporaryManifestButton.hidden = YES;
    [self.view addSubview:temporaryManifestButton];
    [temporaryManifestButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(shipmentButton.mas_top).with.offset(-kStandardLeftMargin / 2);
        make.right.equalTo(shipmentButton);
        make.width.mas_equalTo(temporaryButtonWidth);
        make.height.mas_equalTo(temporaryButtonHeight);
    }];

#if MMR_RESTAURANT_VERSION
    [purchasesButton setTitle:@"采购" forState:UIControlStateNormal];
    [shipmentButton setTitle:@"开台" forState:UIControlStateNormal];
#endif
    
    
#if MMR_TAKEOUT_VERSION
    [purchasesButton setTitle:@"接单" forState:UIControlStateNormal];
    [shipmentButton setTitle:@"开单" forState:UIControlStateNormal];
#endif
    
    
#if MMR_TAKEOUT_VERSION
    titleButton.arrowHidden = YES;
    [titleButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [self.view removeGestureRecognizer:pan];
#endif
}

- (void)showTopMenuView
{
    CGFloat menuWidth = 120;
    CGFloat rowHeight = 44;
    JCHMenuView *topMenuView = [[[JCHMenuView alloc] initWithTitleArray:@[@"店铺服务", @"数据同步", @"记一笔"]   // @"商品拼装", @"商品拆卸",
                                                             imageArray:@[@"nav_ic_homepage_service", @"nav_ic_homepage_synchronization", @"nav_ic_homepage_addNote"]
                                                                 origin:CGPointMake(kScreenWidth - menuWidth - kStandardLeftMargin * 1.5, 64)
                                                                  width:menuWidth
                                                              rowHeight:rowHeight
                                                              maxHeight:CGFLOAT_MAX
                                                                 Direct:kRightTriangle] autorelease];
    topMenuView.delegate = self;
    topMenuView.tag = 2000;
    topMenuView.titleLabelTextAlignment = NSTextAlignmentLeft;
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    [window addSubview:topMenuView];
}

#pragma mark - JCHMenuViewDelegate   扫码、服务窗、同步

- (void)menuItemDidSelected:(JCHMenuView *)menuView indexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:     //店铺服务
        {
            JCHServiceWindowViewController *viewController = [[[JCHServiceWindowViewController alloc] init] autorelease];
            viewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
            
        case 1:     //数据同步
        {
            [self doManualDataSync];
        }
            break;
            
        case 2:     //记一笔
        {
            JCHAddOtherIncomeAndExpenseViewController *viewController = [[[JCHAddOtherIncomeAndExpenseViewController alloc] init] autorelease];
            viewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)switchToAnalyseVC
{
#if MMR_TAKEOUT_VERSION || MMR_RESTAURANT_VERSION
    
#else
    self.tabBarController.selectedIndex = 3;
#endif
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan
{
    CGPoint offset = [pan translationInView:pan.view];

    CGFloat shopsContainerViewHeight = shopsContainerView.frame.size.height;
    CGFloat originY = self.view.frame.origin.y;
    
    if (pan.state == UIGestureRecognizerStateChanged) {
        
        CGRect frame = self.view.frame;
        //titleButton.enabled = NO;
        [titleButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
        frame.origin.y += offset.y;
        [pan setTranslation:CGPointZero inView:pan.view];
        if (frame.origin.y >= 64 + shopsContainerViewHeight || frame.origin.y <= 64) {
            return;
        }
        self.view.frame = frame;
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        
            CGRect frame = self.view.frame;
            if (originY - 64 >= shopsContainerViewHeight / 2) {
                frame.origin.y = shopsContainerViewHeight + 64;
                [UIView animateWithDuration:0.25 animations:^{
                    self.view.frame = frame;
                } completion:^(BOOL finished) {
                    titleButton.selected = YES;
                    [titleButton addTarget:self action:@selector(handlePushPullShopsView:) forControlEvents:UIControlEventTouchUpInside];
                }];
            }
            else {
                frame.origin.y = 64;
                [UIView animateWithDuration:0.25 animations:^{
                    self.view.frame = frame;
                } completion:^(BOOL finished) {
                    titleButton.selected = NO;
                    [titleButton addTarget:self action:@selector(handlePushPullShopsView:) forControlEvents:UIControlEventTouchUpInside];
                }];
            }
    }
}



- (void)createManageIndexView:(CGFloat)initialAngle
{
    //updateTopStatisticsFlag = FALSE;
    NSMutableArray *gradientColors = [NSMutableArray array];
    [gradientColors addObject:(id)[UIColor colorWithHue:165 / 360.0
                                             saturation:0.59
                                             brightness:0.90
                                                  alpha:1.0].CGColor];
    
    [gradientColors addObject:(id)[UIColor colorWithHue:50 / 360.0
                                             saturation:0.67
                                             brightness:0.91
                                                  alpha:1.0].CGColor];
    
    [gradientColors addObject:(id)[UIColor colorWithHue:350 / 360.0
                                             saturation:0.62
                                             brightness:0.87
                                                  alpha:1.0].CGColor];

    CGFloat cycleLineWidth = 14.0f;
    CGFloat cycleRadius = 115.0 - 7;
    if (iPhone6Plus){
        cycleLineWidth = 22.0f;
        cycleRadius = 194.0 - 11;
    } else if (iPhone6PlusEnlarger) {
        cycleLineWidth = 19.0f;
        cycleRadius = 150;
    } else if (iPhone6) {
        cycleLineWidth = 19.0f;
        cycleRadius = 135.0f - 8.5;
    } else if (iPhone5) {
        cycleLineWidth = 16.0f;
        cycleRadius = 135.0f - 8;
    }
    
    
    CGRect progressFrame = CGRectMake(0, 0, progressViewWidth, progressViewHeight);
    manageIndexValue = MAX(350, manageIndexValue);
    CGFloat endAngle = 1.0 * (kMaxEndAngle - kMinStartAngle - kInitializeAngle) / kTotalManageScoreValue * (manageIndexValue - kMinManageScoreValue) + kMinStartAngle + initialAngle;
    
    manageGradientProgressView = [[[JCHGradientProgressView alloc] initWithFrame:progressFrame
                                                                  gradientColors:gradientColors
                                                                     cycleRadius:cycleRadius
                                                                      startAngle:-225.0f
                                                                        endAngle:endAngle
                                                                       lineWidth:cycleLineWidth
                                                                 animateDuration:totalAnimateTime] autorelease];
    [progressBackground addSubview:manageGradientProgressView];
    
    [manageGradientProgressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(progressBackground);
    }];
    
    return;
}

- (void)animateScoreAndProgressView
{
    const CGFloat animateInterval = totalAnimateTime / totalAnimateLoopCount;
    [NSTimer scheduledTimerWithTimeInterval:animateInterval
                                     target:self
                                   selector:@selector(handleAnimateTimer:)
                                   userInfo:nil
                                    repeats:YES];
    
    [manageGradientProgressView startAnimation:totalAnimateTime];
}

- (void)handleAnimateTimer:(NSTimer *)timer
{
    currentTotalAnimateLoopCount++;
    const CGFloat manageScoreBaseValue = 350.0f;
    CGFloat currentScoreValue = (manageIndexValue - manageScoreBaseValue) * 1.0 / totalAnimateLoopCount * currentTotalAnimateLoopCount + manageScoreBaseValue;
    manageScoreValueLabel.text = [NSString stringWithFormat:@"%ld", (long)(currentScoreValue + 0.5)];
    
    if (currentTotalAnimateLoopCount == totalAnimateLoopCount) {
        [timer invalidate];
        currentTotalAnimateLoopCount = 0;
    }
}

//下拉/还原店铺列表
- (void)handlePushPullShopsView:(UIButton *)button
{
    button.selected = !button.selected;
    CGFloat shopsContainerViewHeight = shopsContainerView.frame.size.height;
    CGRect frame = self.view.frame;
    
    if (button.selected && frame.origin.y == 64) {
        frame.origin.y = shopsContainerViewHeight + 64;
    } else if (!button.selected && frame.origin.y == 64 + shopsContainerViewHeight){
        frame.origin.y = 64;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = frame;
    }];
}

//刷新挂单数据
- (void)handleRefreshTemporaryManifestButton
{
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    NSInteger manifestCount = [manifestService calculateStashManifestCount:NO];
    if (manifestCount > 0) {
        NSString *title = [NSString stringWithFormat:@"%ld", manifestCount];
        if (manifestCount > 9) {
            title = @"9+";
        }
        
        temporaryManifestButton.hidden = NO;
        NSString *currentTitle = temporaryManifestButton.currentTitle;
        [temporaryManifestButton setTitle:title forState:UIControlStateNormal];
        if (![currentTitle isEqualToString:title]) {
            
            temporaryManifestButton.transform = CGAffineTransformMakeTranslation(0, -40);
            [UIView animateWithDuration:0.6
                                  delay:0
                 usingSpringWithDamping:0.4
                  initialSpringVelocity:1
                                options:0
                             animations:^{
                                 
                                 temporaryManifestButton.transform = CGAffineTransformIdentity;
                             } completion:nil];
        }
    } else {
        [temporaryManifestButton setTitle:@"" forState:UIControlStateNormal];
        temporaryManifestButton.hidden = YES;
    }
}

#pragma mark -
#pragma mark 经营分析事件响应
- (void)handleAnylize:(id)sender
{
    
    return;
}

#pragma mark 进货响应事件
- (void)handlePurchase:(id)sender
{
#if MMR_TAKEOUT_VERSION
    JCHTakeoutOrderReceivingViewController *orderReceivingVC = [[[JCHTakeoutOrderReceivingViewController alloc] init] autorelease];
    orderReceivingVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:orderReceivingVC animated:YES];
#else
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    [manifestStorage clearData];
    
    manifestStorage.currentManifestID = [manifestService createManifestID:kJCHOrderPurchases];
    manifestStorage.currentManifestDate = [JCHManifestUtility getOrderDate];
    manifestStorage.currentManifestDiscount = 1.0f;
    manifestStorage.currentManifestType = kJCHOrderPurchases;
    
    JCHAddProductMainViewController *addProductViewController = [[[JCHAddProductMainViewController alloc] init] autorelease];
    addProductViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addProductViewController animated:YES];
#endif
}

#pragma mark -
#pragma mark 出货响应事件
- (void)handleShipment:(id)sender
{
#if MMR_RESTAURANT_VERSION
    // 餐饮版
    JCHRestaurantOpenTableViewController *openTableController = [[[JCHRestaurantOpenTableViewController alloc] initWithOperationType:kJCHRestaurantOpenTableOperationTypeOpenTable tableRecord:nil] autorelease];
    openTableController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:openTableController animated:YES];
#else
    // 通用版
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    [manifestStorage clearData];
    
    manifestStorage.currentManifestID = [manifestService createManifestID:kJCHOrderShipment];
    manifestStorage.currentManifestDate = [JCHManifestUtility getOrderDate];
    manifestStorage.currentManifestDiscount = 1.0f;
    manifestStorage.currentManifestType = kJCHOrderShipment;
    
    JCHAddProductMainViewController *addProductViewController = [[[JCHAddProductMainViewController alloc] init] autorelease];
    addProductViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addProductViewController animated:YES];
#endif
    
    return;
}

#pragma mark -
#pragma mark 挂单响应事件
- (void)handleShowTemporaryManifestList
{
    JCHTempManifestViewController *tempManifestViewController = [[[JCHTempManifestViewController alloc] init] autorelease];
    
    tempManifestViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:tempManifestViewController animated:YES];
}

#pragma mark - JCHShopsContainerViewDelegate

- (void)handleSwitchShop:(NSInteger)buttonTag data:(NSArray *)data
{
    if (buttonTag == data.count) {
        
        JCHSyncStatusManager *manager = [JCHSyncStatusManager shareInstance];
        if (manager.isLogin) {

            JCHGuideFirstViewController *guide = [[[JCHGuideFirstViewController alloc] init] autorelease];
            guide.showBackButton = YES;
            guide.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:guide animated:YES];
        }
    } else {
        
        BookInfoRecord4Cocoa *record = data[buttonTag];
        
        [MBProgressHUD showHUDWithTitle:@"切店中..."
                                 detail:@""
                               duration:1000
                                   mode:MBProgressHUDModeIndeterminate
                             completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self switchAccountBook:record.bookID updateRole:YES completion:nil];
            [MBProgressHUD hideAllHudsForWindow];
        });

        
        //虽然在店铺切换后的loadData里面会判断哪个是当前账本，但是大账本数据判断会很慢，所以这里先置当前点击的店铺为选择状态，
        [shopsContainerView selectShop:buttonTag];
        [JCHAudioUtility playAudio:@"switch_store_sound.wav" shake:NO];
        [self handlePushPullShopsView:titleButton];
        
        [titleButton setTitle:[JCHDisplayNameUtility getdisplayShopName:record] forState:UIControlStateNormal];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = (NSInteger)scrollView.contentOffset.x / (NSInteger)scrollView.frame.size.width;
    [shopsContainerView updatePageControl:index];
}

#pragma mark - ClearData
- (void)clearData
{
    NSLog(@"CLearHomepageData");
    //主要清除今日进货,本月毛利，今日出货
    JCHManageStatisticsViewData *cellData = [[[JCHManageStatisticsViewData alloc] init] autorelease];
    cellData.todayPurchaseAmount = @"0.00";
    cellData.monthProfitAmount = @"0.00";
    cellData.todayShipmentAmount = @"0.00";
    
    [manageStatisticsView setViewData:cellData];
}

#pragma mark - Update Data
- (void)loadData
{
    NSLog(@"LoadHomePageData");
    //修改用户图像
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    UIButton *myButton = my.customView;
    UIImage *image = [UIImage jchAvatarImageNamed:statusManager.headImageName];
    [myButton setImage:image forState:UIControlStateNormal];
    
    if (!statusManager.isLogin) {
        titleButton.hidden = YES;
    } else {
        titleButton.hidden = NO;
        
        id <BookInfoService> bookInfoService = [[ServiceFactory sharedInstance] bookInfoService];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            BookInfoRecord4Cocoa *bookInfoRecord = [bookInfoService queryBookInfo:statusManager.userID];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [titleButton setTitle:[JCHDisplayNameUtility getdisplayShopName:bookInfoRecord] forState:UIControlStateNormal];
            });
            
        });
    }
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        double todayPurchaseAmount = 0.0f;
        double todayShipmentIncome = 0.0f;
        double thisMonthGrossProfit = 0.0f;
        NSInteger todayShipmentManifest = 0;
        double thisMonthShipmentAmount = 0.0f;
        
        NSInteger todayPurchaseTrend = 0;
        NSInteger todayShipmentTrend = 0;
        
        id<FinanceCalculateService> calculateService = [[ServiceFactory sharedInstance] financeCalculateService];
        
        if (YES == updateTopStatisticsFlag)
        {
            todayPurchaseAmount = [calculateService calculateTodayPurchasesAmount:&todayPurchaseTrend];
            todayShipmentIncome = [calculateService calculateTodayShipmentAmount:&todayShipmentTrend];
            thisMonthGrossProfit = [calculateService calculateThisMonthGrossProfit];
            todayShipmentManifest = [calculateService calculateTodayShipmentManifest];
            thisMonthShipmentAmount = [calculateService calculateThisMonthShipmentAmount];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                JCHManageStatisticsViewData *cellData = [[[JCHManageStatisticsViewData alloc] init] autorelease];
                cellData.todayPurchaseAmount = [NSString stringWithFormat:@"%.2f", todayPurchaseAmount];
                
                if (statusManager.isShopManager || statusManager.isLogin == NO) {
                    cellData.monthProfitAmount = [NSString stringWithFormat:@"%.2f", thisMonthGrossProfit];
                } else {
                    cellData.monthProfitAmount = @"--.--";
                }
                
                cellData.todayShipmentAmount = [NSString stringWithFormat:@"%.2f", todayShipmentIncome];
                cellData.todayShipmentManifest = [NSString stringWithFormat:@"%ld", todayShipmentManifest];
                cellData.thisMonthShipmentAmount = [NSString stringWithFormat:@"%.2f", thisMonthShipmentAmount];
                
                [manageStatisticsView setViewData:cellData];
                updateTopStatisticsFlag = NO;
            });
        }
    });
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        TICK;
        NSArray *accountBookList = [ServiceFactory getAllAccountBookList:statusManager.userID];
        TOCK(@"getAllAccountBookList");
        
        // 去除默认类型的店铺
        accountBookList = [JCHShopUtility removeDefaultBookInfoRecord:accountBookList];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CGRect frame = shopsContainerView.frame;
            CGFloat shopsContainerViewHeight = 0;
            if (YES == statusManager.isLogin && statusManager.isShopManager) {
                // 如果是已登录状态
                if (accountBookList.count > 0 && accountBookList.count < 4) {
                    shopsContainerViewHeight = [JCHSizeUtility calculateWidthWithSourceWidth:kJCHShopsComponentViewHeight];
                } else if (accountBookList.count >= 4){
                    shopsContainerViewHeight = 2 * [JCHSizeUtility calculateWidthWithSourceWidth:kJCHShopsComponentViewHeight];
                    
                    if (accountBookList.count >= 8) {
                        shopsContainerViewHeight += kJCHPageControlHeight;
                    }
                } else{
                    NSLog(@"accountBookList Error!!!");
                }
            } else {
                // 未登录状态
                shopsContainerViewHeight = 0;
            }
            
            frame.size.height = shopsContainerViewHeight;
            frame.origin.y = -shopsContainerViewHeight;
            shopsContainerView.frame = frame;
            
            [shopsContainerView setViewData:accountBookList];
        });
    });
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
        // 间隔指定时间重新计算经营指数
        if ((nil != statusManager.accountBookID) &&
            (NO == [statusManager.accountBookID isEqualToString:@""])) {
            NSString *manageIndexKey = [NSString stringWithFormat:@"%@_ManageIndex", statusManager.accountBookID];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            
            NSInteger lastUpdateManageIndexTimestamp = 0;
            NSDictionary *manageIndexData = [userDefaults objectForKey:manageIndexKey];
            if (nil != manageIndexData) {
                lastUpdateManageIndexTimestamp = [[manageIndexData objectForKey:@"timestamp"] integerValue];
            }
            
            if (nil == manageIndexData || lastUpdateManageIndexTimestamp != [self getMondayStartTime]) {

                [self doQueryManageIndex];
            } else {
                manageIndexValue = [[manageIndexData objectForKey:@"manageIndex"] doubleValue];
                updateTimeInterval = [[manageIndexData objectForKey:@"timestamp"] integerValue];
            }
        }
        
        [self updateManageIndexUI];
    });
    
    return;
}

- (void)updateManageIndexUI
{
    //增长背景
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //UIColorFromRGB(0xb0b0b0)  UIColorFromRGB(0xff7372)
        
        NSString *updateDate = [NSString stringFromSeconds:updateTimeInterval dateStringType:kJCHDateStringType4];
        NSString *text = [NSString stringWithFormat:@"更新日期：%@", updateDate];
        NSMutableAttributedString *updateInfo = [[[NSMutableAttributedString alloc] initWithString:text] autorelease];
        [updateInfo setAttributes:@{NSFontAttributeName : JCHFont(12), NSForegroundColorAttributeName : UIColorFromRGB(0xb0b0b0)} range:NSMakeRange(0, 5)];
        [updateInfo setAttributes:@{NSFontAttributeName : JCHFont(12), NSForegroundColorAttributeName : UIColorFromRGB(0xff7372)} range:NSMakeRange(5, text.length - 5)];
        updateInfoLabel.attributedText = updateInfo;
        
        if (nil != manageGradientProgressView) {
            manageGradientProgressView.hidden = YES;
            [manageGradientProgressView removeFromSuperview];
            manageGradientProgressView = nil;
            [self createManageIndexView:kInitializeAngle];
        }
        
        [self animateScoreAndProgressView];
    });

}


// ========================================================================================//
#if 1
- (void)registerResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    
    [notificationCenter addObserver:self
                           selector:@selector(handleJoinAccountBook:)
                               name:kJCHSyncJoinCommandNotification
                             object:[UIApplication sharedApplication]];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleFetchJoinedAccountBook:)
                               name:kJCHSyncJoinThenConnectCommandNotification
                             object:[UIApplication sharedApplication]];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleFetchAllAccountBookInfoList:)
                               name:kJCHSyncFetchAllAccountBookListCommandNotification
                             object:[UIApplication sharedApplication]];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleOnlineUpgradeDoSyncPushCommand:)
                               name:kJCHOnlineUpgradeDoSyncPushCommandNotification
                             object:[UIApplication sharedApplication]];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleOnlineUpgradeDoSyncPullCommand:)
                               name:kJCHOnlineUpgradeDoSyncPullCommandNotification
                             object:[UIApplication sharedApplication]];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleQueryManageIndex:)
                               name:kJCHQueryManageIndexNotification
                             object:[UIApplication sharedApplication]];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleQueryManageIndexDetail:)
                               name:kJCHQueryManageIndexDetailNotification
                             object:[UIApplication sharedApplication]];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleOnlineUpgradeDoSyncPushColumnCommand:)
                               name:kJCHOnlineUpgradeDoSyncPushColumnCommandNotification
                             object:[UIApplication sharedApplication]];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleOnlineUpgradeDoSyncPullColumnCommand:)
                               name:kJCHOnlineUpgradeDoSyncPullColumnCommandNotification
                             object:[UIApplication sharedApplication]];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleOnlineUpgradeDoSyncControlCommand:)
                               name:kJCHOnlineUpgradeDoSyncControlCommandNotification
                             object:[UIApplication sharedApplication]];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleOnlineUpgradeDoSyncReleaseCommand:)
                               name:kJCHOnlineUpgradeDoSyncReleaseCommandNotification
                             object:[UIApplication sharedApplication]];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleOnlineUpgradeDoSyncFinalPushCommand:)
                               name:kJCHOnlineUpgradeDoSyncFinalPushCommandNotification
                             object:[UIApplication sharedApplication]];
    

    
    return;
}

- (void)unregisterResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    
    [notificationCenter removeObserver:self
                                  name:kJCHSyncJoinCommandNotification
                                object:[UIApplication sharedApplication]];
    
    [notificationCenter removeObserver:self
                                  name:kJCHSyncJoinThenConnectCommandNotification
                                object:[UIApplication sharedApplication]];
    
    [notificationCenter removeObserver:self
                                  name:kJCHSyncFetchAllAccountBookListCommandNotification
                                object:[UIApplication sharedApplication]];
    
    [notificationCenter removeObserver:self
                                  name:kJCHOnlineUpgradeDoSyncPushCommandNotification
                                object:[UIApplication sharedApplication]];
    
    [notificationCenter removeObserver:self
                                  name:kJCHOnlineUpgradeDoSyncPullCommandNotification
                                object:[UIApplication sharedApplication]];
    
    [notificationCenter removeObserver:self
                                  name:kJCHQueryManageIndexNotification
                                object:[UIApplication sharedApplication]];
    
    [notificationCenter removeObserver:self
                                  name:kJCHQueryManageIndexDetailNotification
                                object:[UIApplication sharedApplication]];
    
    [notificationCenter removeObserver:self
                                  name:kJCHOnlineUpgradeDoSyncPullColumnCommandNotification
                                object:[UIApplication sharedApplication]];
    
    [notificationCenter removeObserver:self
                                  name:kJCHOnlineUpgradeDoSyncPushColumnCommandNotification
                                object:[UIApplication sharedApplication]];
    
    [notificationCenter removeObserver:self
                                  name:kJCHOnlineUpgradeDoSyncControlCommandNotification
                                object:[UIApplication sharedApplication]];
    
    [notificationCenter removeObserver:self
                                  name:kJCHOnlineUpgradeDoSyncReleaseCommandNotification
                                object:[UIApplication sharedApplication]];
    
    [notificationCenter removeObserver:self
                                  name:kJCHOnlineUpgradeDoSyncFinalPushCommandNotification
                                object:[UIApplication sharedApplication]];
    return;
}
#endif


#if 1
//! @brief 手动同步模式
- (void)doManualDataSync
{
    // 如果正在手动同步中，则忽略本次触发的同步操作，直接返回
    if (YES == isInManualSyncProgress) {
        return;
    }
    
    // 如果正在进行自动同步，直接返回
    if (YES == isInAutoSyncPushMode ||
        YES == isInAutoSyncPullMode) {
        //! @todo 这里是否需要给用户提示正在进行自动同步
        [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                 detail:@"当前正在自动同步中"
                               duration:kJCHDefaultShowHudTime
                                   mode:MBProgressHUDModeText
                             completion:nil];
        return;
    }
    
    // 标记当前正在进行手动同步操作，必须后续进行重复同步
    isInManualSyncProgress = YES;
    
    [self showSyncProgressHUD:nil
                      message:@"正在同步数据"
                     duration:1000
                         mode:MBProgressHUDModeIndeterminate];

    [self performSelector:@selector(doSyncPushCommand:)
               withObject:@(NO)
               afterDelay:0.01];
    
    return;
}

//! @brief 自动同步模式PUSH
- (void)doAutoDataSyncPush
{
    // 如果未登录，直接返回
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return;
    }
    
     //如果当前在注册流程中，不能进行自动同步
    if (NO == statusManager.enableAutoSync) {
        return;
    }
    
    // 如果正在手动同步中，则忽略本次触发的同步操作，直接返回
    if (YES == isInManualSyncProgress) {
        return;
    }
    
    // 如果正在进行自动同步PUSH/PULL操作，直接返回
    if (YES == isInAutoSyncPullMode ||
        YES == isInAutoSyncPushMode) {
        return;
    }
    
    // 标记当前正在进行同步PUSH操作，必须后续进行重复同步
    isInAutoSyncPushMode = YES;
    
    [self doSyncPushCommand:nil];
    
    return;
}

//! @brief 自动同步模式PULL
- (void)doAutoDataSyncPull
{
    // 如果未登录，直接返回
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (NO == statusManager.isLogin) {
        return;
    }
    
    //如果当前在注册流程中，不能进行自动同步
    if (NO == statusManager.enableAutoSync) {
        return;
    }
    
    // 如果正在手动同步中，则忽略本次触发的同步操作，直接返回
    if (YES == isInManualSyncProgress) {
        return;
    }
    
    // 如果正在进行PUSH/PULL操作，直接返回
    if (YES == isInAutoSyncPullMode ||
        YES == isInAutoSyncPushMode) {
        return;
    }
    
    // 标记当前正在进行同步PULL操作，必须后续进行重复同步
    isInAutoSyncPullMode = YES;
    
    [self doSyncPullCommand:0];
    
    return;
}

#pragma mark - PUSH
- (void)doSyncPushCommand:(id)placeholder
{
    JCHDataSyncManager *dataSyncManager = [JCHDataSyncManager shareInstance];
    WeakSelf;
    [dataSyncManager doSyncPushCommand:^(NSInteger pushFlag, NSInteger pullFlag, NSDictionary *responseData) {
        
        [weakSelf handlePushSuccess:pushFlag
                           pullFlag:pullFlag
                       responseData:responseData];
    } failure:^(NSInteger responseCode, NSError *error) {
        
        [weakSelf handlePushFailure:responseCode error:error];
    }];
    
    return;
}

//! @brief push成功的处理逻辑
- (void)handlePushSuccess:(NSInteger)pushFlag
                 pullFlag:(NSInteger)pullFlag
             responseData:(NSDictionary *)responseData
{
    if (pushFlag == 0) {
        // 当前无需要push数据，标记push完成
        isInAutoSyncPushMode = NO;
        
        // 如果是手动同步过程，需要进行PULL操作
        if (YES == isInManualSyncProgress) {
            [self doSyncPullCommand:0];
        }
    } else {
        //push数据成功
        
        // 4) 发起pull操作(非自动同步模式下，PUSH完成后发起PULL操作)
        if (NO == isInAutoSyncPushMode) {
            isInManualSyncProgress = YES;
            [self doSyncPullCommand:pullFlag];
            
            // 发送手动同步统计信息
            [[JCHStatisticsManager sharedInstance] manualDataSyncStatistics];
        }
        
        // 如果是自动同步PULL成功，PULL间隔/2
        if (YES == isInAutoSyncPushMode) {
            AppDelegate *theApp = [AppDelegate sharedAppDelegate];
            theApp.autoSyncPushInterval /= 2;
            
            // 发送自动同步统计信息
            [[JCHStatisticsManager sharedInstance] autoDataSyncStatistics];
        }
        
        // 5) 当前自动同步PUSH操作完成
        isInAutoSyncPushMode = NO;
    }
}

//! @brief push失败的处理逻辑
- (void)handlePushFailure:(NSInteger)responseCode error:(NSError *)error
{
    //网络错误
    if (responseCode == kNetWorkErrorCode) {
        //非自动同步提示错误信息
        if (isInAutoSyncPushMode == NO) {
            [JCHNetWorkingUtility showNetworkErrorAlert:error];
        }
    } else {
        [self checkSyncStatus:responseCode];
    }
    
    [self hideSyncProgressHUD];
    
    // 如果是自动同步PUSH失败，PUSH间隔*2
    if (YES == isInAutoSyncPushMode) {
        AppDelegate *theApp = [AppDelegate sharedAppDelegate];
        theApp.autoSyncPushInterval *= 2;
    }
    
    // 当前同步操作push失败，标记同步操作已完成(中断)
    isInManualSyncProgress = NO;
    isInAutoSyncPushMode = NO;
}

#pragma mark - PULL
- (void)doSyncPullCommand:(NSInteger)pullFlag
{
    JCHDataSyncManager *dataSyncManager = [JCHDataSyncManager shareInstance];
    WeakSelf;
    [dataSyncManager doSyncPullCommand:pullFlag success:^(NSDictionary *responseData) {
        [weakSelf handlePullSuccess:responseData];
    } failure:^(NSInteger responseCode, NSError *error) {
        [weakSelf handlePullFailure:responseCode error:error];
    }];
    
    return;
}

//! @brief pull成功的处理逻辑
- (void)handlePullSuccess:(NSDictionary *)responseData
{
    JCHDataSyncManager *dataSyncManager = [JCHDataSyncManager shareInstance];
    // 如果是自动同步PULL成功，PULL间隔/2
    if (YES == isInAutoSyncPullMode) {
        AppDelegate *theApp = [AppDelegate sharedAppDelegate];
        theApp.autoSyncPullInterval /= 2;
    }
    
    // 对于pull数据为空的情况，没有对应的同步下载文件
    // 只在数据库文件存在的情况下执行数据更新逻辑
    if (YES == [[NSFileManager defaultManager] fileExistsAtPath:dataSyncManager.syncDownloadFilePath]) {
        
        id<DataSyncService> dataSync = [[ServiceFactory sharedInstance] dataSyncService];
        NSInteger updatePullStatus = [dataSync updateFromPullDatabase:dataSyncManager.syncDownloadFilePath];
        
        //status 1成功 2部分成功 3成功，没数据
        if (updatePullStatus < 1) {
            NSLog(@"sync pull fail. updatePullStatus = %ld", updatePullStatus);
            
            // 当前同步操作pull成功，标记同步操作已完成
            
            if (isInManualSyncProgress) {
                [MBProgressHUD showResultCustomViewHUDWithTitle:nil detail:@"数据同步失败" duration:1 result:NO completion:nil];
            }
            
            isInManualSyncProgress = NO;
            isInAutoSyncPullMode = NO;
            
            return;
        }
        
        // 如果返回4,则需要再进行一次pull操作
        if (updatePullStatus == 4) {
            [self doSyncPullCommand:0];
            return;
        }
        
        NSLog(@"sync pull success");
        
        id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
        [manifestService checkAndBalanceAllManifest];
        NSLog(@"fix database success");
        
        
        // 修复数据
        id<DatabaseUpgradeService> upgradeService = [[ServiceFactory sharedInstance] databaseUpgradeService];
        [upgradeService fixupDataAfterSync];
        
        //修复权限关系
        [JCHRepairDataUtility checkAndRepairPermission];
        
        // 检查是否属于当前账本，如果不属于，则退出当前账本
        [self switchIfNotBelongToAccountBook:YES];
        
        // 更新界面
        if (NO == isInAutoSyncPullMode) {
            updateTopStatisticsFlag = YES;
            [self loadData];
        }
        
        // 刷新挂单数据
        [self handleRefreshTemporaryManifestButton];
        
        if (NO == isInAutoSyncPullMode) {
            [self showSyncProgressHUD:nil message:@"数据同步成功" duration:1 mode:MBProgressHUDModeCustomView];
        }
        
        //! @note 发送通知让店员首页更新数据
        [JCHNotificationCenter postNotificationName:kShopAssistantHomepageUpdateDataNotification
                                             object:nil];
        
        //! @note 发送通知让店铺选择页面跳转页面
        [JCHNotificationCenter postNotificationName:kSwitchToShopAssistantHomepageNotification
                                             object:nil];
        
        //! @note 同步完成拉到数据后改变刷新标记的通知
        [JCHNotificationCenter postNotificationName:kChangeRefreshMarkAfterPullData
                                             object:[UIApplication sharedApplication]];
        
        //! @note 如果是自动同步完成，发出数据刷新通知
        [JCHNotificationCenter postNotificationName:kAutoSyncCompleteNotification
                                             object:[UIApplication sharedApplication]];
        
        // 获取所有账本信息
        [self doFetchAllAccountBookInfo];
    } else {
        // 在pull数据为空的情况下，获取所有账本信息并触发数据同步
        [self doFetchAllAccountBookInfo];
    }
    
    // 当前同步操作pull成功，标记同步操作已完成
    isInManualSyncProgress = NO;
    isInAutoSyncPullMode = NO;
}

//! @brief pull失败的处理逻辑
- (void)handlePullFailure:(NSInteger)responseCode error:(NSError *)error
{
    //网络错误
    if (responseCode == kNetWorkErrorCode) {
        //非自动同步提示错误信息
        if (isInAutoSyncPushMode == NO) {
            [JCHNetWorkingUtility showNetworkErrorAlert:error];
        }
    } else {
        [self checkSyncStatus:responseCode];
    }
    
    [self hideSyncProgressHUD];
    
    // 如果是自动同步PULL失败，PULL间隔*2
    if (YES == isInAutoSyncPullMode) {
        AppDelegate *theApp = [AppDelegate sharedAppDelegate];
        theApp.autoSyncPullInterval *= 2;
    }
    
    // 当前同步操作pull失败，标记同步操作已完成(中断)
    isInManualSyncProgress = NO;
    isInAutoSyncPullMode = NO;
}
#endif


#pragma mark - 扫码
- (void)handleScanQRCode
{
    JCHBarCodeScannerViewController *barCodeScanerVC = [[[JCHBarCodeScannerViewController alloc] init] autorelease];
    barCodeScanerVC.title = @"扫码";
    barCodeScanerVC.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    WeakSelf;
    barCodeScanerVC.barCodeBlock = ^(NSString *barCode){
        [weakSelf handleFinishScanQRCode:barCode
                             joinAccount:YES
                            authorizePad:YES
                                loginPad:YES];
    };
    
    [self presentViewController:barCodeScanerVC animated:YES completion:nil];
}

// 扫码成功后的处理逻辑(加店、授权收银机、登录收银机)
- (void)handleFinishScanQRCode:(NSString *)qrCode
                   joinAccount:(BOOL)joinAccount
                  authorizePad:(BOOL)authorizePad
                      loginPad:(BOOL)loginPad
{
    if ([qrCode containsString:@"authorize"]) {
        // 授权
        if (authorizePad) {
            [self showSyncProgressHUD:nil
                              message:@"请稍候..."
                             duration:1000
                                 mode:MBProgressHUDModeIndeterminate];
            NSString *qrParam = [self analyticWithURLStr:qrCode param:@"qr"];
            
            NSString *qrParamDecode = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                          (__bridge CFStringRef)qrParam,
                                                                                                          CFSTR(""),
                                                                                                          CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
            [self authorizePad:qrParamDecode];
        }
    } else if ([qrCode containsString:@"bmlogin"]) {
        // 登录
        if (loginPad) {
            [self showSyncProgressHUD:nil
                              message:@"请稍候..."
                             duration:1000
                                 mode:MBProgressHUDModeIndeterminate];
            NSString *qrParam = [self analyticWithURLStr:qrCode param:@"qr"];
            
            NSString *qrParamDecode = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                          (__bridge CFStringRef)qrParam,
                                                                                                          CFSTR(""),
                                                                                                          CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
            [self loginPad:qrParamDecode];
        }
    } else {
        //加店
        if (joinAccount) {
            [self showSyncProgressHUD:nil
                              message:@"正在加入店铺"
                             duration:1000
                                 mode:MBProgressHUDModeIndeterminate];
            [self doJoinAccountBook:qrCode];
        }
    }
}

// 解析URL参数
- (NSString *)analyticWithURLStr:(NSString *)urlStr param:(NSString *)param
{
    NSError *error;
    NSString *regTags = [[NSString alloc] initWithFormat:@"(^|&|\\?)+%@=+([^&]*)(&|$)", param];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regTags
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    // 执行匹配的过程
    NSArray *matches = [regex matchesInString:urlStr
                                      options:0
                                        range:NSMakeRange(0, [urlStr length])];
    for (NSTextCheckingResult *match in matches) {
        NSString *tagValue = [urlStr substringWithRange:[match rangeAtIndex:2]];  // 分组2所对应的串
        return tagValue;
    }
    return @"";
}

#pragma mark -
#pragma mark 扫码加店

- (void)doJoinAccountBook:(NSString *)qrCodeString
{
    NSString *qrParameter = nil;
    NSString *userID = nil;
    NSString *accountBookID = nil;
    NSString *accountBookName = nil;
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    BOOL isShopBarCode = [dataSyncService parseQRCodeString:[[NSURL URLWithString:qrCodeString] query]
                                                    qrParam:&qrParameter
                                              accountBookID:&accountBookID
                                            accountBookName:&accountBookName
                                                   userName:&userID];
    if(isShopBarCode){
        JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
        
        JoinAccountBookRequest *request = [[[JoinAccountBookRequest alloc] init] autorelease];
        request.deviceUUID = statusManager.deviceUUID;
        request.token = statusManager.syncToken;
        request.param = qrParameter;
        request.serviceURL = [NSString stringWithFormat:@"%@/terminal/join", kJCHSyncManagerServerIP];
        
        id<DataSyncService> syncService = [[ServiceFactory sharedInstance] dataSyncService];
        [syncService joinAccountBook:request responseNotification:kJCHSyncJoinCommandNotification];
    } else {
        [MBProgressHUD showHUDWithTitle:@"加入店铺失败" detail:nil duration:1.5 mode:MBProgressHUDModeText completion:nil];
        
    }
    
    return;
}

#pragma mark -
#pragma mark 扫码授权收银机

- (void)authorizePad:(NSString *)qrCodeString
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    ScanQRCodeAuthRequest *request = [[[ScanQRCodeAuthRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.token = statusManager.syncToken;
    request.userID = statusManager.userID;
    request.accountBookID = statusManager.accountBookID;
    request.serviceURL = [NSString stringWithFormat:@"%@/machine/scanAuthorize", kJCHSyncManagerServerIP];
    request.authParam = qrCodeString;
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService scanAuth:request callback:^(id response) {
        
        NSDictionary *userData = response;
        
        if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
            NSDictionary *responseData = userData[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                //! @todo
                
                NSString *message = [NSString stringWithFormat:@"%@ %ld", responseDescription, responseCode];
                [MBProgressHUD showHUDWithTitle:@"扫码授权失败"
                                         detail:message
                                       duration:kJCHDefaultShowHudTime
                                           mode:MBProgressHUDModeText
                                     completion:nil];
            } else {
                
                [MBProgressHUD showHUDWithTitle:@"扫码授权成功"
                                         detail:@""
                                       duration:kJCHDefaultShowHudTime
                                           mode:MBProgressHUDModeText
                                     completion:nil];
            }
        } else {
            NSLog(@"request fail: %@", userData[@"data"]);
            
            [MBProgressHUD showNetWorkFailedHud:nil];
        }
    }];
}

#pragma mark -
#pragma mark 扫码登录收银机

- (void)loginPad:(NSString *)qrCodeString
{
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    ScanQRCodeLoginRequest *request = [[[ScanQRCodeLoginRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.token = statusManager.syncToken;
    request.accountBookID = statusManager.accountBookID;
    request.serviceURL = [NSString stringWithFormat:@"%@/machine/scanLogin", kJCHSyncManagerServerIP];
    request.authParam = qrCodeString;
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService scanLogin:request callback:^(id response) {
        
        NSDictionary *userData = response;
        
        if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
            NSDictionary *responseData = userData[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                //! @todo
                
                NSString *message = [NSString stringWithFormat:@"%@ %ld", responseDescription, responseCode];
                [MBProgressHUD showHUDWithTitle:@"扫码登录失败"
                                         detail:message
                                       duration:kJCHDefaultShowHudTime
                                           mode:MBProgressHUDModeText
                                     completion:nil];
            } else {
                
                [MBProgressHUD showHUDWithTitle:@"扫码登录成功"
                                         detail:@""
                                       duration:kJCHDefaultShowHudTime
                                           mode:MBProgressHUDModeText
                                     completion:nil];
            }
        } else {
            NSLog(@"request fail: %@", userData[@"data"]);
            
            [MBProgressHUD showNetWorkFailedHud:nil];
        }
    }];
}



#pragma mark - 我的
- (void)handlePushToMyViewController
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (statusManager.isLogin) {
        
        JCHMyViewController *myVC = [[[JCHMyViewController alloc] init] autorelease];
        myVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:myVC animated:YES];
    } else{
        JCHLoginViewController *loginVC = [[[JCHLoginViewController alloc] init] autorelease];
        //JCHEnforceLoginViewController *enforceLoginVC = [[[JCHEnforceLoginViewController alloc] init] autorelease];
        loginVC.registButtonShow = YES;
        loginVC.hidesBottomBarWhenPushed = YES; 
        [self.navigationController pushViewController:loginVC animated:YES];
        //[self.navigationController presentViewController:enforceLoginVC animated:YES completion:nil];
    }
}

#pragma -
- (void)showSyncProgressHUD:(NSString *)title message:(NSString *)message duration:(NSInteger)duration mode:(MBProgressHUDMode)mode
{
    self.syncHUDProgressView = [MBProgressHUD showHUDWithTitle:title detail:message duration:duration mode:mode completion:nil];

    return;
}


- (void)hideSyncProgressHUD
{
    [self.syncHUDProgressView hide:YES];
    return;
}


#pragma mark -
#pragma mark 多店相关逻辑

// ========================================================================================//
- (void)handleJoinAccountBook:(NSNotification *)notify
{
    NSDictionary *userData = notify.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        NSString *responseDescription = responseData[@"desc"];
        NSString *responseStatus = responseData[@"status"];
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
        
        [MBProgressHUD showHudWithStatusCode:responseCode sceneType:kJCHMBProgressHUDSceneTypeJoinShop];
        
        if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
            //! @todo
            NSLog(@"join account book fail.");
            [self hideSyncProgressHUD];
            [self checkSyncStatus:responseCode];
            return;
        } else {
            NSDictionary *serviceResponse = responseData[@"data"];
            JoinAccountBookResponse *response = [[[JoinAccountBookResponse alloc] init] autorelease];
            response.code = responseCode;
            response.descriptionString = responseDescription;
            response.status = responseStatus;
            response.accountBookID = serviceResponse[@"id"];
            response.syncHost = serviceResponse[@"host"];
            response.interHost = serviceResponse[@"interHost"];
            response.roleUUID = serviceResponse[@"role_uuid"];
            
            self.currentJoinAccountBookInfo = response;
            
            //! @todo
            // your code here
            [self doFetchJoinedAccountBook:response.accountBookID
                            accontBookHost:response.syncHost
                             interSyncHost:response.interHost];
            
            [self showSyncProgressHUD:nil
                              message:@"正在加入店铺"
                             duration:1000
                                 mode:MBProgressHUDModeIndeterminate];
        }
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
    }
}

- (void)doFetchJoinedAccountBook:(NSString *)accountBookID
                  accontBookHost:(NSString *)accountBookHost
                   interSyncHost:(NSString *)interSyncHost
{
    NSString *emptyLatestDatabasePath = [ServiceFactory createSyncConnectNewUploadDatabase:[AppDelegate getOldVersionDatabasePath]];
    
    id<DatabaseUpgradeService> upgradeService = [[ServiceFactory sharedInstance] databaseUpgradeService];
    NSInteger databaseVersion = [upgradeService getCurrentDatabaseVersion];
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    [ServiceFactory createDirectoryForUserAccount:statusManager.userID accountBookID:accountBookID];
    NSString *downloadDatabasePath = [ServiceFactory getAccountBookDatabasePath:statusManager.userID accountBookID:accountBookID];
    
    ConnectCommandRequest *request = [[[ConnectCommandRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.syncVersion = [NSString stringWithFormat:@"%lld", (long long)databaseVersion];
    request.token = statusManager.syncToken;
    request.accountBookID = accountBookID;
    request.syncNode = @"";
    request.uploadDatabaseFile = emptyLatestDatabasePath;
    request.downloadDatabaseFile = downloadDatabasePath;
    request.serviceURL = accountBookHost;
    request.pieceServiceURL = [NSString stringWithFormat:@"%@/sync/piece", interSyncHost];
    request.dataType = JCH_DATA_TYPE;
    
    id<LargeDatabaseSyncService> largeDataSyncService = [[ServiceFactory sharedInstance] largeDatabaseSyncService];
    [largeDataSyncService connectCommand:request responseNotification:kJCHSyncJoinThenConnectCommandNotification];

    return;
}

- (void)handleFetchJoinedAccountBook:(NSNotification *)notify
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
            NSLog(@"join account book fail.");
            [self hideSyncProgressHUD];
            [self checkSyncStatus:responseCode];
            return;
        } else {
            //! @todo 这里处理加入账本成功的逻辑
            
            // 切换账本前需要查出当前的头像和昵称
            JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
            id <BookMemberService> bookMemberBeforeSyncService = [[ServiceFactory sharedInstance] bookMemberService];
            BookMemberRecord4Cocoa *bookMemberRecord = [bookMemberBeforeSyncService queryBookMemberWithUserID:statusManager.userID];
            
            if (!bookMemberRecord.userId || [bookMemberRecord.userId isEqualToString:@""]) {
                bookMemberRecord.userId = statusManager.userID;
                
            }
            bookMemberRecord.remarks = @"";
            bookMemberRecord.type = 0;
            bookMemberRecord.star = 0;
            bookMemberRecord.phone = statusManager.phoneNumber;
            
            // 切换账本        
            [self switchAccountBook:self.currentJoinAccountBookInfo.accountBookID updateRole:YES completion:^{
                // 添加店员信息
                bookMemberRecord.roleUUID = self.currentJoinAccountBookInfo.roleUUID;
                id <BookMemberService> bookMemberAfterSyncService = [[ServiceFactory sharedInstance] bookMemberService];
                [bookMemberAfterSyncService addBookMember:bookMemberRecord];
                
                //判断当前是否为店长
                statusManager.isShopManager = [ServiceFactory isShopManager:statusManager.userID
                                                              accountBookID:statusManager.accountBookID];
                
                //在新用户注册完后选择店员扫码加店的时候，在加店成功后要将登录状态和允许自动同步的状态改变改变
                statusManager.enableAutoSync = YES;
                statusManager.isLogin = YES;
                [JCHSyncStatusManager writeToFile];
                
                [self doManualDataSync];
            }];
        }
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
    }
    
    
    return;
}


#pragma mark - 切换店铺

- (void)switchAccountBook:(NSString *)accountBookID updateRole:(BOOL)updateRoleFlag completion:(CompletionBlock)completion
{
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if ([[NSString stringWithFormat:@"%@", accountBookID] isEqualToString:statusManager.accountBookID]) {
        return;
    }
    
    NSString *accountBookPath = [ServiceFactory getAccountBookDatabasePath:statusManager.userID
                                                             accountBookID:accountBookID];
    

    int status = [ServiceFactory initializeServiceFactory:accountBookPath userID:statusManager.userID appType:JCH_BOOK_TYPE];
    
    if (0 != status) {
        //! @todo handle error here
        NSLog(@"initialize database: %@, %@ fail, errno: %d", accountBookPath, statusManager.userID, status);
    } else {
        
        statusManager.accountBookID = accountBookID;
        // 切店成功
        if (completion) {
            completion();
        }
        
        // 升级数据库
        const BOOL isNeedOnLineUpgrade = [self checkOnlineUpgradeAfterSwithAccountBook];
        
        //修复权限关系
        [JCHRepairDataUtility checkAndRepairPermission];
        
        if (YES == updateRoleFlag) {
            //判断当前是否为店长
            statusManager.isShopManager = [ServiceFactory isShopManager:statusManager.userID
                                                          accountBookID:statusManager.accountBookID];
            
            id<PermissionService> permissionService = [[ServiceFactory sharedInstance] permissionService];
            RoleRecord4Cocoa *roleRecord =  [permissionService queryRoleWithByUserID:statusManager.userID];
            statusManager.roleRecord = roleRecord;
            
            
            if (statusManager.isShopManager) {
                
                //! @note 切店完成后如果还是店长，清除tabbar上页面的数据
                AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
                [appDelegate clearDataOnTabbar];
            } else {
                
                AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
                
                JCHShopAssistantHomepageViewController *shopAssistantHomePageViewController = appDelegate.shopAssistantHomepageViewController;
                
                if (![appDelegate.rootNavigationController.viewControllers containsObject:shopAssistantHomePageViewController]) {
                    [appDelegate.rootNavigationController pushViewController:shopAssistantHomePageViewController animated:YES];
                }
            }
        }
        
        // 检查当前账本是否需要进行在线升级
        if (NO == isNeedOnLineUpgrade) {
            
            if (statusManager.isShopManager) {
                // 刷新数据
                updateTopStatisticsFlag = YES;
                [self loadData];
            }
        } else {
            // 进行在线升级
            [self doOnlineUpgrade];
        }
        
        [JCHSyncStatusManager writeToFile];
        
        //切店时 刷新挂单数据
        [self handleRefreshTemporaryManifestButton];
    }
    
    return;

}

//! @note 分为两种情况
/*
    1) 如果同步成功，检查用户是否属于当前账本时，需要从当前账本的BookMember中进行检查;
    2) 如果同步失败，返回20103, 表示服务器判断当前用户不属于此账本，此时就不需要基于当前账本BookMember判断
 */
- (void)switchIfNotBelongToAccountBook:(BOOL)checkIfUserInAccountBook
{
    // 检查当前的用户是否属于这个账本
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    NSString *userID = statusManager.userID;
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    
    BOOL isMemberOfAccountBook = NO;
    if (YES == checkIfUserInAccountBook) {
        isMemberOfAccountBook = [dataSyncService isMemberOfAccountBook:userID];
    }
    
    if (NO == isMemberOfAccountBook) {
        // 通知服务器退出当前账本
        JCHDataSyncManager *dataSyncManager = [JCHDataSyncManager shareInstance];
        [dataSyncManager doLeaveAccountBook:statusManager.userID success:nil failure:nil];
        
        // 查找下一个可以切换的账本
        NSString *accountBookID = nil;
        NSString *currentBookID = [[JCHSyncStatusManager shareInstance] accountBookID];
        NSArray *accountBookList = [ServiceFactory getAllAccountBookList:userID];
        for (BookInfoRecord4Cocoa *bookInfo in accountBookList) {
            if (NO == [bookInfo.bookID isEqualToString:currentBookID]) {
                accountBookID = bookInfo.bookID;
                break;
            }
        }
        
        // 未找到下一个可以切换的账本，直接返回
        if (nil == accountBookID) {
            // 由appDelegate处理跳转页面
            // 删除当前的账本
            [ServiceFactory deleteAccountBook:userID accountBookID:currentBookID];
        } else {
            // 切换账本
            [self switchAccountBook:accountBookID updateRole:YES completion:^{
                // 删除当前的账本
                [ServiceFactory deleteAccountBook:userID accountBookID:currentBookID];
            }];
        }
        
        
        
        
        // 提醒用户他已不属于当前账本
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示"
                                                                                 message:@"你已不属于当前账本"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [JCHNotificationCenter postNotificationName:kShopAssistantHomepageLogoutNotification object:nil];
        }];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (BOOL)checkSyncStatus:(NSInteger)responseCode
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        //如果当前在后台同步，不进行验证状态码
        return YES;
    }
    
    // 如果当前账户已在其它设备登录，token失效，提示用户重新登录
    BOOL hasHandledSyncStatus = NO;
    const NSInteger kTokenInvalidCode = 20102;
    const NSInteger kTokenInvalidCodeForFetchAccountBookList = 20201;
    const NSInteger kNotBelongToAccountbookErrorCode = 20103;
    const NSInteger kNeedToUpdateAppCode = 20003;
    const NSInteger kNeedToUpdateAppCode1 = 20004;
    const NSInteger kDataErrorCode = 20105;
    if ((responseCode == kTokenInvalidCode || responseCode == kTokenInvalidCodeForFetchAccountBookList) && isInAutoSyncPullMode == NO && isInAutoSyncPushMode == NO) {
        hasHandledSyncStatus = YES;
        [MBProgressHUD showHUDWithTitle:@""
                                 detail:@"该账号已在其它设备登录，请重新登陆！"
                               duration:2
                                   mode:MBProgressHUDModeText
                             completion:^{
                                 [self hideOnlineUpgradeProgressView];
                                 
                                 [JCHUserInfoViewController clearUserLoginStatus];
                                 JCHLoginViewController *loginController = [[[JCHLoginViewController alloc] init] autorelease];
                                 loginController.showBackNavigationItem = NO;
                                 loginController.registButtonShow = YES;
                                 loginController.hidesBottomBarWhenPushed = YES;
                                 
                                 //JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
                                 //if (statusManager.isShopManager) {
                                     //[self.navigationController pushViewController:loginController animated:YES];
                                 //} else {
                                     AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
                                     [appDelegate.rootNavigationController pushViewController:loginController animated:YES];
                                 //}
                                 
                             }];
    }
    
    // 检查是否属于当前账本，如果不属于，则退出当前账本
    if (responseCode == kNotBelongToAccountbookErrorCode) {
        hasHandledSyncStatus = YES;
        [self switchIfNotBelongToAccountBook:NO];
        
        // 更新界面
        updateTopStatisticsFlag = YES;
        [self loadData];
    }
    
    if (responseCode == kDataErrorCode) {
        hasHandledSyncStatus = YES;
        [MBProgressHUD showHUDWithTitle:@"同步失败"
                                 detail:@"接口执行出错"
                               duration:2
                                   mode:MBProgressHUDModeText
                             completion:nil];
    }
    
    if (responseCode == kNeedToUpdateAppCode ||
        responseCode == kNeedToUpdateAppCode1) {
        hasHandledSyncStatus = YES;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示"
                                                                                 message:@"同步失败，您使用的版本过低，请尽快升级！"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *upgradeAction = [UIAlertAction actionWithTitle:@"升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/id1035522428"];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
        [alertController addAction:cancleAction];
        [alertController addAction:upgradeAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    return hasHandledSyncStatus;
}


- (void)doFetchAllAccountBookInfo
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    FetchExistedAccountBookRequest *request = [[[FetchExistedAccountBookRequest alloc] init] autorelease];
    request.serviceURL = [NSString stringWithFormat:@"%@/terminal/connect", kJCHSyncManagerServerIP];
    request.token = statusManager.syncToken;
    request.deviceUUID = statusManager.deviceUUID;
    request.bookType = JCH_BOOK_TYPE;
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService fetchExistedAccountBook:request responseNotification:kJCHSyncFetchAllAccountBookListCommandNotification];
    
    return;
}

- (void)handleFetchAllAccountBookInfoList:(NSNotification *)notify
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
            NSLog(@"fetch account books fail.");
            [self hideSyncProgressHUD];
            [self checkSyncStatus:responseCode];
            return;
        } else {
            JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
            NSString *imageInterHostIP = nil;
            
            NSDictionary *serviceResponse = responseData[@"data"];
            NSArray *accountBookList = serviceResponse[@"list"];
            NSMutableDictionary *accountBookStatusForBookId = [NSMutableDictionary dictionary];
            for (NSDictionary *accountBook in accountBookList) {
                NSString *accountBookID = [NSString stringWithFormat:@"%@", accountBook[@"id"]];
                NSString *interHost = accountBook[@"interHost"];
                NSString *status = [NSString stringWithFormat:@"%@", accountBook[@"status"]];
                [accountBookStatusForBookId setObject:status forKey:accountBookID];
                if ([statusManager.accountBookID isEqualToString:accountBookID]) {
                    imageInterHostIP = interHost;
                    statusManager.imageInterHostIP = imageInterHostIP;
                    [JCHSyncStatusManager writeToFile];
                    //break;
                }
            }
            
            //更新所有账本的status
            [ServiceFactory updateBookInfoInAllAccountBook:statusManager.userID block:^BookInfoRecord4Cocoa *(NSString *bookID, BookInfoRecord4Cocoa *bookInfo) {
                for (NSString *currentBookId in [accountBookStatusForBookId allKeys]) {
                    if ([bookID isEqualToString:currentBookId]) {
                        if (bookInfo.bookStatus != [accountBookStatusForBookId[currentBookId] integerValue]) {
                            bookInfo.bookStatus = [accountBookStatusForBookId[currentBookId] integerValue];
                        }
                        return bookInfo;
                    }
                }
                return bookInfo;
            }];
            
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                //! @note 账本列表信息更新完成后 更新shopsContainerView
                NSArray *accountBookList = [ServiceFactory getAllAccountBookList:statusManager.userID];
                
                // 去除默认类型的店铺
                accountBookList = [JCHShopUtility removeDefaultBookInfoRecord:accountBookList];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    CGRect frame = shopsContainerView.frame;
                    CGFloat shopsContainerViewHeight = 0;
                    if (YES == statusManager.isLogin && statusManager.isShopManager) {
                        // 如果是已登录状态
                        if (accountBookList.count > 0 && accountBookList.count < 4) {
                            shopsContainerViewHeight = [JCHSizeUtility calculateWidthWithSourceWidth:kJCHShopsComponentViewHeight];
                        } else if (accountBookList.count >= 4){
                            shopsContainerViewHeight = 2 * [JCHSizeUtility calculateWidthWithSourceWidth:kJCHShopsComponentViewHeight];
                            if (accountBookList.count >= 8) {
                                shopsContainerViewHeight += kJCHPageControlHeight;
                            }
                        } else{
                            NSLog(@"accountBookList Error!!!");
                        }
                    } else {
                        // 未登录状态
                        shopsContainerViewHeight = 0;
                    }
                    
                    frame.size.height = shopsContainerViewHeight;
                    frame.origin.y = -shopsContainerViewHeight;
                    shopsContainerView.frame = frame;
                    
                    [shopsContainerView setViewData:accountBookList];
                });
            });
            
            // 判断当前账本是否被禁用
            if ([accountBookStatusForBookId[statusManager.accountBookID] integerValue]) {
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示"
                                                                                         message:@"你已被店主禁用"
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [JCHNotificationCenter postNotificationName:kShopAssistantHomepageLogoutNotification object:nil];
                }];
                [alertController addAction:action];
                [MBProgressHUD hideAllHudsForWindow];
                [self presentViewController:alertController animated:YES completion:nil];
                return;
            }

            if (nil != imageInterHostIP) {
                JCHDataSyncManager *dataSyncManager = [JCHDataSyncManager shareInstance];
                [dataSyncManager doSyncImageFiles:imageInterHostIP];
            }
        }
        
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
    }
}


#pragma mark -
#pragma mark 进行在线升级
- (BOOL)doOnlineUpgrade
{
    //设置屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    NSInteger upgradeDatbaseVersion = 0;
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id<DatabaseUpgradeService> upgradeService = [[ServiceFactory sharedInstance] databaseUpgradeService];
    NSString *accountBookID = statusManager.accountBookID;
    if ((nil != accountBookID) &&
        (NO == [accountBookID isEqualToString:@""])) {
        NSDictionary *upgradeBookList = statusManager.upgradeAccountBooks;
        NSNumber *oldDatabaseVersion = [upgradeBookList objectForKey:accountBookID];
        if (nil != oldDatabaseVersion) {
            upgradeDatbaseVersion = [oldDatabaseVersion integerValue];
            if (0 != upgradeDatbaseVersion) {
                NSInteger databaseVersion = [upgradeService getCurrentDatabaseVersion];
                
                if (upgradeDatbaseVersion < databaseVersion) {
                    upgradeDatbaseVersion = databaseVersion;
                }
            }
        }
    }
    
    if (0 == upgradeDatbaseVersion) {
        [self hideOnlineUpgradeProgressView];
        // 不需要进行在线升级
        return NO;
    }
    
    [self showOnlineUpgradeProgressView];
    
    // 检查备份数据是否存在，如果不存在，则进行备份
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *accountBookPath = [ServiceFactory getAccountBookDatabasePath:statusManager.userID
                                                             accountBookID:accountBookID];
    NSString *backupAccountBookPath = [NSString stringWithFormat:@"%@.backup", accountBookPath];
    if (NO == [fileManager fileExistsAtPath:backupAccountBookPath]) {
        NSError *copyError = nil;
        [fileManager copyItemAtPath:accountBookPath toPath:backupAccountBookPath error:&copyError];
        
        if (nil != copyError) {
            NSLog(@"\n\n\nerror, copy fail fail: %@", copyError);
        }
    } else {
        // 备份当前的备份数据库
        NSString *tempPath = [NSString stringWithFormat:@"%@%@", backupAccountBookPath, [[NSUUID UUID] UUIDString]];
        {
            NSError *copyError = nil;
            [fileManager copyItemAtPath:backupAccountBookPath toPath:tempPath error:&copyError];
            
            if (nil != copyError) {
                NSLog(@"\n\n\nerror, copy fail fail: %@", copyError);
            }
        
        }
        
        // 如果备份数据库存在，由备份数据库恢复
        NSError *copyError = nil;
        NSURL *resultingItemURL = nil;
        [fileManager replaceItemAtURL:[NSURL URLWithString:accountBookPath]
                        withItemAtURL:[NSURL URLWithString:backupAccountBookPath]
                       backupItemName:@".temp"
                              options:0
                     resultingItemURL:&resultingItemURL
                                error:&copyError];
        if (nil != copyError) {
            NSLog(@"\n\n\nerror, copy fail fail: %@", copyError);
        }
        
        // 恢复当前的备份数据库
        {
            NSError *copyError = nil;
            [fileManager copyItemAtPath:tempPath toPath:backupAccountBookPath error:&copyError];
            
            if (nil != copyError) {
                NSLog(@"\n\n\nerror, copy fail fail: %@", copyError);
            }
            
        }
        
        // 重新打开数据库
        int status = [ServiceFactory initializeServiceFactory:accountBookPath userID:statusManager.userID appType:JCH_BOOK_TYPE];
        if (0 != status) {
            NSLog(@"\n\n\nerror, initializeServiceFactory fail: %@", copyError);
        }
    }
    
    // 当前的在线升级统一进行加锁升级
    isLockUpgradeMode = YES;
    onlineUpgradePushVersion = upgradeDatbaseVersion;
    [self onlineUpgradeDoSyncControlCommand];

    // 需要进行在线升级
    return YES;
}

- (void)onlineUpgradeDoSyncControlCommand
{
    id<DataSyncService> dataSync = [[ServiceFactory sharedInstance] dataSyncService];
    id<LargeDatabaseSyncService> largetDataSync = [[ServiceFactory sharedInstance] largeDatabaseSyncService];
    NSString *syncPushHost = [dataSync getSyncAccountBookControlHost];
    syncPushHost = [NSString stringWithFormat:@"%@/service/bookControl", syncPushHost];
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    ControlCommandRequest *request = [[[ControlCommandRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.token = statusManager.syncToken;
    request.accountBookID = statusManager.accountBookID;
    request.serviceURL = syncPushHost;
    request.userID = @"";
    request.nodeKey = [dataSync getSyncNodeID];
    request.dataType = [[ServiceFactory sharedInstance] getDBType];
    [largetDataSync controlBookCommand:request responseNotification:kJCHOnlineUpgradeDoSyncControlCommandNotification];
    
    return;
}

- (void)onlineUpgradeDoSyncReleaseCommand
{
    id<DataSyncService> dataSync = [[ServiceFactory sharedInstance] dataSyncService];
    id<LargeDatabaseSyncService> largetDataSync = [[ServiceFactory sharedInstance] largeDatabaseSyncService];
    NSString *syncPushHost = [dataSync getSyncAccountBookControlHost];
    syncPushHost = [NSString stringWithFormat:@"%@/service/bookControl", syncPushHost];    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    ControlCommandRequest *request = [[[ControlCommandRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.token = statusManager.syncToken;
    request.accountBookID = statusManager.accountBookID;
    request.serviceURL = syncPushHost;
    request.userID = @"";
    request.nodeKey = [dataSync getSyncNodeID];
    request.dataType = [[ServiceFactory sharedInstance] getDBType];
    [largetDataSync releaseBookCommand:request responseNotification:kJCHOnlineUpgradeDoSyncReleaseCommandNotification];
    
    return;
}

- (void)onlineUpgradeDoSyncReleaseCommandIgnoreResponse
{
    if (NO == isLockUpgradeMode) {
        return;
    } else {
        isLockUpgradeMode = NO;
    }
    
    id<DataSyncService> dataSync = [[ServiceFactory sharedInstance] dataSyncService];
    id<LargeDatabaseSyncService> largetDataSync = [[ServiceFactory sharedInstance] largeDatabaseSyncService];
    NSString *syncPushHost = [dataSync getSyncAccountBookControlHost];
    syncPushHost = [NSString stringWithFormat:@"%@/service/bookControl", syncPushHost];
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    ControlCommandRequest *request = [[[ControlCommandRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.token = statusManager.syncToken;
    request.accountBookID = statusManager.accountBookID;
    request.serviceURL = syncPushHost;
    request.userID = @"";
    request.nodeKey = [dataSync getSyncNodeID];
    request.dataType = [[ServiceFactory sharedInstance] getDBType];
    [largetDataSync releaseBookCommand:request
                  responseNotification:kJCHOnlineUpgradeDoSyncReleaseCommandIgnoreResponseNotification];
    
    return;
}

- (void)onlineUpgradeDoSyncPushColumnCommand:(NSInteger)databaseVersion
{
    NSString *databasePath = [ServiceFactory getSyncUploadFilePath];
    id<DatabaseUpgradeService> upgradeService = [[ServiceFactory sharedInstance] databaseUpgradeService];
    id<DataSyncService> dataSync = [[ServiceFactory sharedInstance] dataSyncService];
    id<LargeDatabaseSyncService> largetDataSync = [[ServiceFactory sharedInstance] largeDatabaseSyncService];
    
    NSInteger status = [upgradeService preparePushColumnData:databasePath];
    if (1 == status) {
        NSString *syncPushHost = [dataSync getSyncAccountBookPushHost];
        NSString *syncNodeID = [dataSync getSyncNodeID];
        
        JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
        PushCommandRequest *request = [[[PushCommandRequest alloc] init] autorelease];
        request.deviceUUID = statusManager.deviceUUID;
        request.syncVersion = [NSString stringWithFormat:@"%lld", (long long)databaseVersion];
        request.token = statusManager.syncToken;
        request.accountBookID = statusManager.accountBookID;
        request.syncNode = syncNodeID;
        request.uploadDatabaseFile = databasePath;
        request.serviceURL = syncPushHost;
        request.pieceServiceURL = [dataSync getSyncAccountBookPieceHost];
        request.checkVersion = NO;
        request.dataType = JCH_DATA_TYPE;
        
        [largetDataSync onlineUpgradePushColumnCommand:request
                                  responseNotification:kJCHOnlineUpgradeDoSyncPushColumnCommandNotification];
    } else {
        NSLog(@"warning: preparePushColumnData return: %d", (int)status);
        [self onlineUpgradeDoSyncFinalPushCommand];
    }

    return;
}

- (void)onlineUpgradeDoSyncPullColumnCommand
{
    NSString *downloadDatabasePath = [ServiceFactory getSyncDownloadFilePath];
    NSString *uploadDatabasePath = [ServiceFactory getSyncUploadFilePath];
    id<DataSyncService> dataSync = [[ServiceFactory sharedInstance] dataSyncService];
    
    //! @todo 这里需要备份数据库
    NSInteger status = [dataSync preparePullColumn:uploadDatabasePath];
    if (1 == status) {
        NSString *syncPullHost = [dataSync getSyncAccountBookPullAllHost];
        self.syncColumnFilePath = downloadDatabasePath;
        NSString *syncNodeID = [dataSync getSyncNodeID];
        
        id<DatabaseUpgradeService> upgradeService = [[ServiceFactory sharedInstance] databaseUpgradeService];
        NSInteger databaseVersion = [upgradeService getCurrentDatabaseVersion];
        JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
        
        PullCommandRequest *request = [[[PullCommandRequest alloc] init] autorelease];
        request.deviceUUID = statusManager.deviceUUID;
        request.syncVersion = [NSString stringWithFormat:@"%lld", (long long)databaseVersion];
        request.token = statusManager.syncToken;
        request.accountBookID = statusManager.accountBookID;
        request.syncNode = syncNodeID;
        request.pieceServiceURL = [dataSync getSyncAccountBookPieceHost];
        request.uploadDatabaseFile = uploadDatabasePath;
        request.downloadDatabaseFile = downloadDatabasePath;
        request.serviceURL = syncPullHost;
        request.upgradeCommand = @"partUpgrade";
        request.dataType = JCH_DATA_TYPE;
        
        id<LargeDatabaseSyncService> largeDataSync = [[ServiceFactory sharedInstance] largeDatabaseSyncService];
        [largeDataSync onlineUpgradePullColumnCommand:request responseNotification:kJCHOnlineUpgradeDoSyncPullColumnCommandNotification];
    } else {
        NSLog(@"warning: preparePullColumn return: %d", (int)status);
        [self onlineUpgradeDoSyncPullCommand];
    }

    return;
}

- (void)onlineUpgradeDoSyncPushCommand:(NSInteger)databaseVersion
{
    NSString *databasePath = [ServiceFactory getSyncUploadFilePath];
    id<DataSyncService> dataSync = [[ServiceFactory sharedInstance] dataSyncService];
    id<LargeDatabaseSyncService> largetDataSync = [[ServiceFactory sharedInstance] largeDatabaseSyncService];
    NSInteger status = [dataSync preparePushDatabase:databasePath];
    if (1 == status) {
        self.syncUploadFilePath = databasePath;
        NSString *syncPushHost = [dataSync getSyncAccountBookPushHost];
        NSString *syncNodeID = [dataSync getSyncNodeID];
        JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
        
        PushCommandRequest *request = [[[PushCommandRequest alloc] init] autorelease];
        request.deviceUUID = statusManager.deviceUUID;
        request.syncVersion = [NSString stringWithFormat:@"%lld", (long long)databaseVersion];
        request.token = statusManager.syncToken;
        request.accountBookID = statusManager.accountBookID;
        request.syncNode = syncNodeID;
        request.uploadDatabaseFile = databasePath;
        request.serviceURL = syncPushHost;
        request.pieceServiceURL = [dataSync getSyncAccountBookPieceHost];
        request.checkVersion = NO;
        request.dataType = JCH_DATA_TYPE;
        
        [largetDataSync pushCommand:request responseNotification:kJCHOnlineUpgradeDoSyncPushCommandNotification];
    } else {
        [self onlineUpgradeDoSyncPullColumnCommand];
    }
    
    return;
}


- (void)onlineUpgradeDoSyncPullCommand
{
    NSString *downloadDatabasePath = [ServiceFactory getSyncDownloadFilePath];
    NSString *uploadDatabasePath = [ServiceFactory getSyncUploadFilePath];
    id<DataSyncService> dataSync = [[ServiceFactory sharedInstance] dataSyncService];
    NSInteger pullType = 0;
    [dataSync preparePullDatabase:uploadDatabasePath pullFlag:pullType];
    
    NSString *syncPullHost = [dataSync getSyncAccountBookPullHost];
    NSString *syncPieceHost = [dataSync getSyncAccountBookPieceHost];
    self.syncDownloadFilePath = downloadDatabasePath;
    NSString *syncNodeID = [dataSync getSyncNodeID];
    
    id<DatabaseUpgradeService> upgradeService = [[ServiceFactory sharedInstance] databaseUpgradeService];
    NSInteger databaseVersion = [upgradeService getCurrentDatabaseVersion];
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id<LargeDatabaseSyncService> largeDatabaseSyncService = [[ServiceFactory sharedInstance] largeDatabaseSyncService];
    PullCommandRequest *request = [[[PullCommandRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.syncVersion = [NSString stringWithFormat:@"%lld", (long long)databaseVersion];
    request.token = statusManager.syncToken;
    request.accountBookID = statusManager.accountBookID;
    request.syncNode = syncNodeID;
    request.uploadDatabaseFile = uploadDatabasePath;
    request.downloadDatabaseFile = downloadDatabasePath;
    request.serviceURL = syncPullHost;
    request.pieceServiceURL = syncPieceHost;
    request.upgradeCommand = @"";
    request.dataType = JCH_DATA_TYPE;
    
    [largeDatabaseSyncService pullCommand:request
                     responseNotification:kJCHOnlineUpgradeDoSyncPullCommandNotification];
    
    return;
}

- (void)onlineUpgradeDoSyncFinalPushCommand
{
    NSString *databasePath = [ServiceFactory getSyncUploadFilePath];
    id<DataSyncService> dataSync = [[ServiceFactory sharedInstance] dataSyncService];
    id<LargeDatabaseSyncService> largetDataSync = [[ServiceFactory sharedInstance] largeDatabaseSyncService];
    NSInteger status = [dataSync preparePushDatabase:databasePath];
    if (1 == status) {
        self.syncUploadFilePath = databasePath;
        NSString *syncPushHost = [dataSync getSyncAccountBookPushHost];
        NSString *syncNodeID = [dataSync getSyncNodeID];
        NSInteger databaseVersion = [[[ServiceFactory sharedInstance] databaseUpgradeService] getCurrentDatabaseVersion];
        JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
        PushCommandRequest *request = [[[PushCommandRequest alloc] init] autorelease];
        request.deviceUUID = statusManager.deviceUUID;
        request.syncVersion = [NSString stringWithFormat:@"%lld", (long long)databaseVersion];
        request.token = statusManager.syncToken;
        request.accountBookID = statusManager.accountBookID;
        request.syncNode = syncNodeID;
        request.uploadDatabaseFile = databasePath;
        request.serviceURL = syncPushHost;
        request.pieceServiceURL = [dataSync getSyncAccountBookPieceHost];
        request.checkVersion = NO;
        request.dataType = JCH_DATA_TYPE;
        
        [largetDataSync pushCommand:request responseNotification:kJCHOnlineUpgradeDoSyncFinalPushCommandNotification];
    } else {
        
        // 当前账本在线升级成功, 进行标记
        [self markAccountBookUpgradeSuccess];
        
        // 释放账本控制权
        [self onlineUpgradeDoSyncReleaseCommand];
    }
    
    return;
}

- (void)handleOnlineUpgradeDoSyncFinalPushCommand:(NSNotification *)notify
{
    NSLog(@"%s\t%@", __PRETTY_FUNCTION__, notify);
    NSDictionary *userData = notify.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        
        // 检查获取控制锁状态
        if (10000 == responseCode) {
            NSLog(@"online upgrade sync final push success");
            
            // 当前账本在线升级成功, 进行标记
            [self markAccountBookUpgradeSuccess];
            
            // 释放账本控制权
            [self onlineUpgradeDoSyncReleaseCommand];
        } else {
            [self showOnlineUpgradeFailureAlert];
            [self onlineUpgradeDoSyncReleaseCommandIgnoreResponse];
            NSLog(@"online upgrade sync final push fail");
        }
    } else {
        [self showOnlineUpgradeFailureAlert];
        [self onlineUpgradeDoSyncReleaseCommandIgnoreResponse];
        NSLog(@"online upgrade sync final push fail");
    }
    
    return;
}

- (void)handleOnlineUpgradeDoSyncControlCommand:(NSNotification *)notify
{
    NSLog(@"%s\t%@", __PRETTY_FUNCTION__, notify);
    NSDictionary *userData = notify.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        
        // 检查获取控制锁状态
        if (10000 == responseCode) {
            NSLog(@"online upgrade sync control success");
            [self onlineUpgradeDoSyncPushCommand:onlineUpgradePushVersion];
        } else if (20000 == responseCode) {
            [self hideOnlineUpgradeProgressView];
            
            [MBProgressHUD showHUDWithTitle:@""
                                     detail:@"请等待其它设备升级完成(如您多次升级失败，可加QQ群481573889联系客服)，\n请勿删除应用，否则可能导致丢失数据"
                                   duration:8
                                       mode:MBProgressHUDModeText
                                 completion:^{
                                     [self hideOnlineUpgradeProgressView];
                                     
                                     [JCHUserInfoViewController clearUserLoginStatus];
                                     JCHLoginViewController *loginController = [[[JCHLoginViewController alloc] init] autorelease];
                                     loginController.showBackNavigationItem = NO;
                                     loginController.registButtonShow = YES;
                                     loginController.hidesBottomBarWhenPushed = YES;
                                     
                                     AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
                                     [appDelegate.rootNavigationController pushViewController:loginController animated:YES];                                     
                                 }];
            
        } else {
            [self hideOnlineUpgradeProgressView];
            [self checkSyncStatus:responseCode];
            // [self showOnlineUpgradeFailureAlert];
            NSLog(@"online upgrade sync control fail");
        }
    } else {
        [self showOnlineUpgradeFailureAlert];
        NSLog(@"online upgrade sync control fail");
    }
    
    return;
}

- (void)handleOnlineUpgradeDoSyncReleaseCommand:(NSNotification *)notify
{
    NSLog(@"%s\t%@", __PRETTY_FUNCTION__, notify);
    
    NSDictionary *userData = notify.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];

        [self handleOnLineUpgradeComplete];
        if (10000 == responseCode) {
            NSLog(@"online upgrade sync release success");
        } else {
            NSLog(@"online upgrade sync release fail");
        }
    } else {
        [self showOnlineUpgradeFailureAlert];
        NSLog(@"online upgrade sync release fail");
    }
    
    return;
}

- (void)handleOnlineUpgradeDoSyncPushColumnCommand:(NSNotification *)notify
{
    NSLog(@"%s\t%@", __PRETTY_FUNCTION__, notify);
    
    NSDictionary *userData = notify.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        NSString *responseDescription = responseData[@"desc"];
        
        if (10000 == responseCode) {
            [self onlineUpgradeDoSyncFinalPushCommand];
            NSLog(@"online upgrade sync push column success");
        } else {
            NSLog(@"online upgrade sync push column fail");
            [self hideOnlineUpgradeProgressView];
            [self onlineUpgradeDoSyncReleaseCommandIgnoreResponse];
            
            BOOL hasHandledSyncStatus = [self checkSyncStatus:responseCode];
            if (NO == hasHandledSyncStatus) {
                [self showOnlineUpgradeProgressView];
                [onlineUpgradeView setStatusMessage:responseDescription];
                [onlineUpgradeView showRetryButton:YES];
            }
        }
    } else {
        [self showOnlineUpgradeFailureAlert];
        [self onlineUpgradeDoSyncReleaseCommandIgnoreResponse];
        NSLog(@"online upgrade sync push column fail");
    }
    
    return;
}

- (void)handleOnlineUpgradeDoSyncPullColumnCommand:(NSNotification *)notify
{
    NSLog(@"%s\t%@", __PRETTY_FUNCTION__, notify);
    
    NSDictionary *userData = notify.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        NSString *responseDescription = responseData[@"desc"];
        
        if (0 == responseCode) {
            [self onlineUpgradeDoSyncPullCommand];
            NSLog(@"online upgrade sync pull column success");
        } else {
            NSLog(@"online upgrade sync pull column fail");
            [self hideOnlineUpgradeProgressView];
            [self onlineUpgradeDoSyncReleaseCommandIgnoreResponse];
            
            BOOL hasHandledSyncStatus = [self checkSyncStatus:responseCode];
            if (NO == hasHandledSyncStatus) {
                [self showOnlineUpgradeProgressView];
                [onlineUpgradeView setStatusMessage:responseDescription];
                [onlineUpgradeView showRetryButton:YES];
            }
        }
    } else {
        [self showOnlineUpgradeFailureAlert];
        [self onlineUpgradeDoSyncReleaseCommandIgnoreResponse];
        NSLog(@"online upgrade sync pull column fail");
    }
    
    return;
}

- (void)handleOnlineUpgradeDoSyncPushCommand:(NSNotification *)notify
{
    NSLog(@"%s\t%@", __PRETTY_FUNCTION__, notify);
    
    NSDictionary *userData = notify.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        NSString *responseDescription = responseData[@"desc"];
        
        if (10000 == responseCode) {
            // 1) 更新同步状态
            id<DataSyncService> dataSync = [[ServiceFactory sharedInstance] dataSyncService];
            [dataSync updateFromPushDatabase:self.syncUploadFilePath];
            
            // 2) 校正同步时间
            long long currentTime = [[NSDate date] timeIntervalSince1970] * 1000;
            long long serverTime = [responseData[@"data"][@"time"] longLongValue];
            [dataSync adjustSyncTime:serverTime clientTime:currentTime];
            
            // 升级数据库结构
            id<DatabaseUpgradeService> databaseUpgradeService = [[ServiceFactory sharedInstance] databaseUpgradeService];
            [databaseUpgradeService upgradeDatabase];
            onlineUpgradePushVersion = [databaseUpgradeService getCurrentDatabaseVersion];
            
            // 3) 发起pullColumnData操作
            [self onlineUpgradeDoSyncPullColumnCommand];
            NSLog(@"online upgrade sync push success");
        } else {
            NSLog(@"online upgrade sync push fail");
            [self hideOnlineUpgradeProgressView];
            [self onlineUpgradeDoSyncReleaseCommandIgnoreResponse];
            
            BOOL hasHandledSyncStatus = [self checkSyncStatus:responseCode];
            if (NO == hasHandledSyncStatus) {
                [self showOnlineUpgradeProgressView];
                [onlineUpgradeView setStatusMessage:responseDescription];
                [onlineUpgradeView showRetryButton:YES];
            }
        }
    } else {
        [self showOnlineUpgradeFailureAlert];
        [self onlineUpgradeDoSyncReleaseCommandIgnoreResponse];
        NSLog(@"online upgrade sync push fail");
    }
    
    return;
}


- (void)handleOnlineUpgradeDoSyncPullCommand:(NSNotification *)notify
{
    NSLog(@"%s\t%@", __PRETTY_FUNCTION__, notify);
    
    NSDictionary *userData = notify.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        NSString *responseDescription = responseData[@"desc"];
        
        if (0 == responseCode) {
            // 对于pull数据为空的情况，没有对应的同步下载文件, 只在数据库文件存在的情况下执行数据更新逻辑
            if (YES == [[NSFileManager defaultManager] fileExistsAtPath:self.syncDownloadFilePath]) {
                
                id<DataSyncService> dataSync = [[ServiceFactory sharedInstance] dataSyncService];
                NSInteger updatePullStatus = [dataSync updateFromPullDatabase:self.syncDownloadFilePath];
                
                //status 1成功 2部分成功 3成功，没数据
                if (updatePullStatus < 1) {
                    NSLog(@"online upgrade sync pull fail");
                }
            }
            
            NSInteger oldDatabaseVersion = 0;
            {
                JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
                NSString *accountBookID = statusManager.accountBookID;
                if ((nil != accountBookID) &&
                    (NO == [accountBookID isEqualToString:@""])) {
                    oldDatabaseVersion = [[statusManager.upgradeAccountBooks objectForKey:accountBookID] integerValue];
                }
            }
            
            id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
            [manifestService checkAndBalanceAllManifest];
            
            id<DatabaseUpgradeService> upgradeService = [[ServiceFactory sharedInstance] databaseUpgradeService];
            [upgradeService upgradeBuiltinData:oldDatabaseVersion];
            [upgradeService fixupDataAfterSync];
            
            // 更新界面
            updateTopStatisticsFlag = YES;
            // [self loadData];
            
            // 执行pushColumn
            [self onlineUpgradeDoSyncPushColumnCommand:onlineUpgradePushVersion];
            NSLog(@"online upgrade sync pull success");
            
        } else {
            NSLog(@"online upgrade sync pull fail");
            [self hideOnlineUpgradeProgressView];
            [self onlineUpgradeDoSyncReleaseCommandIgnoreResponse];
            
            BOOL hasHandledSyncStatus = [self checkSyncStatus:responseCode];
            if (NO == hasHandledSyncStatus) {
                [self showOnlineUpgradeProgressView];
                [onlineUpgradeView setStatusMessage:responseDescription];
                [onlineUpgradeView showRetryButton:YES];
            }
        }
    } else {
        NSLog(@"online upgrade sync pull fail");
        [self onlineUpgradeDoSyncReleaseCommandIgnoreResponse];
        [self showOnlineUpgradeFailureAlert];
    }
    
    return;
}

- (void)handleOnLineUpgradeComplete
{
    isLockUpgradeMode = NO;
    
    // 判断当前的在线升级是否需要进行lock操作
    id<DatabaseUpgradeService> upgradeService = [[ServiceFactory sharedInstance] databaseUpgradeService];
    BOOL isNeedLock = [upgradeService isNeedLockToUpgrade];
    if (YES == isNeedLock) {
        // 获取锁
        isLockUpgradeMode = YES;
        [self onlineUpgradeDoSyncControlCommand];
    } else {
        // 在线升级完成
        [self hideOnlineUpgradeProgressView];
        [self loadData];
    }
}

- (void)showOnlineUpgradeFailureAlert
{
    [onlineUpgradeView setStatusMessage:@"升级失败，请勿删除应用，否则可能丢失数据。\n请重新尝试，如需协助请加入QQ群:481573889"];
    [onlineUpgradeView showRetryButton:YES];
    return;
}


#pragma mark -
#pragma mark 检查是否需要进行在线升级
- (BOOL)checkIsNeedOnLineUpgrade
{
    BOOL needOnLineUpgrade = NO;
    NSInteger upgradeDatbaseVersion = 0;
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    NSString *accountBookID = statusManager.accountBookID;
    if ((nil != accountBookID) &&
        (NO == [accountBookID isEqualToString:@""])) {
        NSDictionary *upgradeBookList = statusManager.upgradeAccountBooks;
        NSNumber *oldDatabaseVersion = [upgradeBookList objectForKey:accountBookID];
        if (nil != oldDatabaseVersion) {
            upgradeDatbaseVersion = [oldDatabaseVersion integerValue];
            if (0 != upgradeDatbaseVersion) {
                needOnLineUpgrade = YES;
            }
        }
    }
    
    return needOnLineUpgrade;
}

#pragma mark -
#pragma mark 在线升级"重试按钮点击"
- (void)handleClickRetryButton
{
    [onlineUpgradeView showRetryButton:NO];
    [self doOnlineUpgrade];
    return;
}


- (BOOL)checkOnlineUpgradeAfterSwithAccountBook
{
    // 如果是第一次启动APP，则不需要进行在线升级
    BOOL isNeedFixupDatabase = YES;
    BOOL isNeedOnlineUpgradeFlag = NO;
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    // 判断当前是否需要进行在线升级，并进行标记
    id<DatabaseUpgradeService> upgradeService = [[ServiceFactory sharedInstance] databaseUpgradeService];
    BOOL isNeedUpgrade = [upgradeService isNeedUpgrade];
    if (YES == isNeedUpgrade) {
        const BOOL isNeedOnlineUpgrade = [upgradeService isNeedOnlineUpgrade];
        if (YES == isNeedOnlineUpgrade) {
            NSString *accountBookID = statusManager.accountBookID;
            if ((nil != accountBookID) &&
                (NO == [accountBookID isEqualToString:@""])) {
                if (YES == statusManager.isLogin) {
                    // 标记当前账本需要在线升级
                    NSInteger currentDatabaseVersion = [upgradeService getCurrentDatabaseVersion];
                    NSMutableDictionary *upgradeList = [NSMutableDictionary dictionaryWithDictionary:statusManager.upgradeAccountBooks];
                    [upgradeList setObject:@(currentDatabaseVersion) forKey:accountBookID];
                    statusManager.upgradeAccountBooks = upgradeList;
                    [JCHSyncStatusManager writeToFile];
                    
                    isNeedFixupDatabase = NO;
                    isNeedOnlineUpgradeFlag = YES;
                }
            }
        }
    }
    
    id<DatabaseUpgradeService> databaseUpgradeService = [[ServiceFactory sharedInstance] databaseUpgradeService];
    const NSInteger currentDatabaseVersion = [databaseUpgradeService getCurrentDatabaseVersion];
    [databaseUpgradeService upgradeDatabase];
    
    if (YES == isNeedFixupDatabase) {
        [databaseUpgradeService upgradeBuiltinData:currentDatabaseVersion];
        [databaseUpgradeService fixupDataAfterSync];
    }
    
    return isNeedOnlineUpgradeFlag;
}

- (void)showOnlineUpgradeProgressView
{
    if (nil == onlineUpgradeView) {
        CGRect popFrame = CGRectMake(0, 0, self.view.frame.size.width * 0.7, 180);
        onlineUpgradeView = [[[JCHOnlineUpgradeView alloc] initWithFrame:popFrame] autorelease];
        onlineUpgradeView.backgroundColor = [UIColor blackColor];
        onlineUpgradeView.alpha = 0.8;
        onlineUpgradeView.delegate = self;
        KLCPopup *popupView = [KLCPopup popupWithContentView:onlineUpgradeView];
        popupView.backgroundColor = [UIColor clearColor];
        popupView.dimmedMaskAlpha = 0.0f;
        popupView.shouldDismissOnBackgroundTouch = NO;
        [popupView show];
        currentPopupView = popupView;
        [onlineUpgradeView startProgressAnimation];
    }
    
    return;
}

- (void)hideOnlineUpgradeProgressView
{
    currentPopupView.hidden = YES;
    [currentPopupView dismiss:NO];
    [KLCPopup dismissAllPopups];
    onlineUpgradeView = nil;
    currentPopupView = nil;;
    
    return;
}


- (NSInteger)getMondayStartTime
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd"];
    NSString *endDate = [dateFormater stringFromDate:date];
    NSInteger endTime = [endDate stringToSecondsEndTime:YES];
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger calendarUnits = NSCalendarUnitWeekday;
    NSDateComponents *dateComponents = [calendar components:calendarUnits fromDate:date];
    
    NSInteger weakday = dateComponents.weekday;
    
    //weakday  1-周日  2-周一  3-周二 ...
    if (weakday == 1) {
        weakday = 7;
    } else {
        weakday--;
    }
    NSInteger startTime = endTime + 1 - weakday * 24 * 3600;
    
    return startTime;
}


#pragma mark - 查询经营指数
- (void)doQueryManageIndex
{
#if !DEBUG
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    EfficiencyFirstRequest *request = [[[EfficiencyFirstRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.token = statusManager.syncToken;
    request.accountBookID = statusManager.accountBookID;

    NSInteger timeInterval = [self getMondayStartTime];
    request.endDate = (NSString *)@(timeInterval);
    request.serviceURL = [NSString stringWithFormat:@"%@/first", kManageIndexServerIP];
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService requestEfficiencyFirst:request responseNotification:kJCHQueryManageIndexNotification];
#endif
}

- (void)handleQueryManageIndex:(NSNotification *)notify
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
            NSLog(@"send captcha fail.");
            
            return;
        } else {
            //! @todo
            // your code here
            //NSLog(@"doQueryManageIndex success");
            
            NSLog(@"responseData = %@", responseData);

            CGFloat manageIndex = [responseData[@"data"][@"efficiency"] doubleValue];
            self.manageIndexCache = @(manageIndex);
            [self doQueryManageIndexDetail];
        }
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
        //NSError *networkError = userData[@"data"];
        
    }
}


#pragma mark - 查询经营指数详情
- (void)doQueryManageIndexDetail
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    EfficiencySecondRequest *request = [[[EfficiencySecondRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.token = statusManager.syncToken;
    request.accountBookID = statusManager.accountBookID;

    NSInteger timeInterval = [self getMondayStartTime];
    request.endDate = (NSString *)@(timeInterval);;
    request.serviceURL = [NSString stringWithFormat:@"%@/second", kManageIndexServerIP];
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService requestEfficiencySecond:request responseNotification:kJCHQueryManageIndexDetailNotification];
}

- (void)handleQueryManageIndexDetail:(NSNotification *)notify
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
            NSLog(@"send captcha fail.");
            
            return;
        } else {
            //! @todo
            // your code here
            //NSLog(@"doQueryManageIndex success");
            NSLog(@"%@", responseData);
            
            JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
            NSString *manageIndexKey = [NSString stringWithFormat:@"%@_ManageIndex", statusManager.accountBookID];
            
            NSInteger lastUpdateManageIndexTimestamp = 0;
            NSDictionary *manageIndexData = [JCHUserDefaults objectForKey:manageIndexKey];
            
            if (nil != manageIndexData) {
                lastUpdateManageIndexTimestamp = [[manageIndexData objectForKey:@"timestamp"] integerValue];
            }
            
            
            manageIndexValue = [self.manageIndexCache doubleValue];
            
            NSArray *dataArray = responseData[@"data"];
            
            /**
             *   10 库存周转天数
                 1 资产效率
                 2 负债能力
                 3 盈利能力
                 4 现金获取
                 5 开单水平
                 52 动销率
             */
            
            CGFloat manageIndexDetail_10 = 0;
            CGFloat manageIndexDetail_52 = 0;
            CGFloat manageIndexDetail_1 = 0;
            CGFloat manageIndexDetail_2 = 0;
            CGFloat manageIndexDetail_3 = 0;
            CGFloat manageIndexDetail_4 = 0;
            CGFloat manageIndexDetail_5 = 0;
            
            for (NSDictionary *dict in dataArray) {
                
                NSInteger type = [dict[@"type"] integerValue];
                CGFloat manageIndexDetail = [dict[@"efficiency"] doubleValue];
                
                if (type == 10) {
                    manageIndexDetail_10 = manageIndexDetail;
                } else if (type == 52) {
                    manageIndexDetail_52 = manageIndexDetail;
                } else if (type == 1) {
                    manageIndexDetail_1 = manageIndexDetail;
                } else if (type == 2) {
                    manageIndexDetail_2 = manageIndexDetail;
                } else if (type == 3) {
                    manageIndexDetail_3 = manageIndexDetail;
                } else if (type == 4) {
                    manageIndexDetail_4 = manageIndexDetail;
                } else if (type == 5) {
                    manageIndexDetail_5 = manageIndexDetail;
                }
            }
            //CGFloat type10Value = responseData[]
            

            manageIndexData = @{@"manageIndex" : @(manageIndexValue),
                            @"manageIndexDetail_10" : @(manageIndexDetail_10),
                            @"manageIndexDetail_52" : @(manageIndexDetail_52),
                            @"manageIndexDetail_1"  : @(manageIndexDetail_1),
                            @"manageIndexDetail_2"  : @(manageIndexDetail_2),
                            @"manageIndexDetail_3"  : @(manageIndexDetail_3),
                            @"manageIndexDetail_4"  : @(manageIndexDetail_4),
                            @"manageIndexDetail_5"  : @(manageIndexDetail_5),
                            @"timestamp" : @([self getMondayStartTime])};
            [JCHUserDefaults setObject:manageIndexData forKey:manageIndexKey];
            [JCHUserDefaults synchronize];
            updateTimeInterval = [[NSDate date] timeIntervalSince1970] - lastUpdateManageIndexTimestamp;
            
            [self updateManageIndexUI];
        }
        
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
        //NSError *networkError = userData[@"data"];
        
    }
}

#pragma mark -
#pragma mark 标记账本升级成功
- (void)markAccountBookUpgradeSuccess
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    NSString *accountBookID = statusManager.accountBookID;
    if ((nil != accountBookID) &&
        (NO == [accountBookID isEqualToString:@""])) {
        NSMutableDictionary *upgradeList = [NSMutableDictionary dictionaryWithDictionary:statusManager.upgradeAccountBooks];
        [upgradeList setObject:@(0) forKey:accountBookID];
        statusManager.upgradeAccountBooks = upgradeList;
        [JCHSyncStatusManager writeToFile];
        
        // 删除备份数据库
        NSError *removeError = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *accountBookPath = [ServiceFactory getAccountBookDatabasePath:statusManager.userID
                                                                 accountBookID:accountBookID];
        NSString *backupAccountBookPath = [NSString stringWithFormat:@"%@.backup", accountBookPath];
        [fileManager removeItemAtPath:backupAccountBookPath error:&removeError];
        
        if (nil != removeError) {
            NSLog(@"remove backup database fail: %@", removeError);
        }
    }
    
    return;
}

@end
