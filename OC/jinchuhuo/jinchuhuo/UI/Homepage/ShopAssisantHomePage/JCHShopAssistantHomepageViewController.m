//
//  JCHShopAssisantHomePageViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/4/25.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHShopAssistantHomepageViewController.h"
#import "JCHShopInfoViewController.h"
#import "JCHGroupContactsViewController.h"
#import "JCHTempManifestViewController.h"
#import "JCHGuideFirstViewController.h"
#import "JCHUserInfoViewController.h"
#import "JCHMyViewController.h"
#import "JCHLoginViewController.h"
#import "JCHBarCodeScannerViewController.h"
#import "JCHAddProductMainViewController.h"
#import "JCHInventoryViewController.h"
#import "JCHManifestViewController.h"
#import "JCHBluetoothDeviceViewController.h"
#import "JCHAllContactsViewController.h"
#import "JCHRestaurantOpenTableViewController.h"
#import "CommonHeader.h"

@implementation JCHShopAssistantHomepageViewController
{
    UIButton *_titleButton;
    UIButton *_myButton;
    UIButton *_refreshButton;
    UIButton *_temporaryManifestButton;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createUI];
    
    [self registerResponseNotificationHandler];
}

- (void)loadData
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id<BookInfoService> bookInfoService = [[ServiceFactory sharedInstance] bookInfoService];
    BookInfoRecord4Cocoa *bookInfoRecord = [bookInfoService queryBookInfo:statusManager.userID];
    [_titleButton setTitle:bookInfoRecord.bookName forState:UIControlStateNormal];
    //_titleLabel.text = bookInfoRecord.bookName;
    //self.title = bookInfoRecord.bookName;
    
    //修改用户图像
    UIImage *image = [UIImage jchAvatarImageNamed:statusManager.headImageName];
    [_myButton setImage:image forState:UIControlStateNormal];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self handleRefreshTemporaryManifestButton];
    });
}

- (void)dealloc
{
    [self unregisterResponseNotificationHandler];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //[self.navigationController.navigationBar setBarTintColor:JCHColorMainBody];
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    
    AppDelegate *theDelegate = [AppDelegate sharedAppDelegate];
    theDelegate.switchToTargetController = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}


- (void)createUI
{

    _myButton = [JCHUIFactory createButton:CGRectMake(kStandardLeftMargin, 27, 30, 30)
                                    target:self
                                    action:@selector(handlePushToMyViewController)
                                     title:nil
                                titleColor:nil
                           backgroundColor:nil];
    _myButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _myButton.layer.borderWidth = 1;
    _myButton.clipsToBounds = YES;
    _myButton.layer.cornerRadius = 15;
    [_myButton setImage:[UIImage imageNamed:@"homepage_avatar_default"] forState:UIControlStateNormal];
    
    UIBarButtonItem *my = [[[UIBarButtonItem alloc] initWithCustomView:_myButton] autorelease];
    
    UIBarButtonItem *fixedSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
    fixedSpace.width = 5;
    
    _refreshButton = [JCHUIFactory createButton:CGRectMake(0, 0, 29, 29)
                                         target:self
                                         action:@selector(handleRefreshData)
                                          title:nil
                                     titleColor:nil
                                backgroundColor:nil];
    [_refreshButton setBackgroundImage:[UIImage imageNamed:@"shopAssisant_synchronization_background"] forState:UIControlStateNormal];
    [_refreshButton setImage:[UIImage imageNamed:@"shopAssisant_synchronization_rotate"] forState:UIControlStateNormal];
    
    UIBarButtonItem *refresh = [[[UIBarButtonItem alloc] initWithCustomView:_refreshButton] autorelease];
    //UIBarButtonItem *refresh = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"shopAssisant_synchronization"]
                                                                 //style:UIBarButtonItemStylePlain
                                                                //target:self
                                                                //action:@selector(handleRefreshData)] autorelease];
    self.navigationItem.leftBarButtonItems = @[my];
    self.navigationItem.rightBarButtonItems = @[refresh];
    
    _titleButton = [JCHUIFactory createButton:CGRectZero
                                       target:self
                                       action:@selector(showShopInfo)
                                        title:@""
                                   titleColor:[UIColor whiteColor]
                              backgroundColor:[UIColor clearColor]];
    _titleButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    self.navigationItem.titleView = _titleButton;
    
    
    CGFloat buttonHeight = (kScreenHeight - 64) / 3;
    CGFloat buttonWidth = kScreenWidth / 2;

    
    NSArray *titleArray = @[@"扫码", @"开单", @"库存", @"订单", @"设备", @"会员"];
    NSArray *imageArray = @[@"shopAssisant_scanbarcode", @"shopAssisant_purchase", @"shopAssisant_billing", @"shopAssisant_order", @"shopAssisant_device", @"shopAssisant_member"];
    
    for (NSInteger i = 0; i < 6; i++) {
        
        CGFloat buttonX = buttonWidth * (i % 2);
        CGFloat buttonY = buttonHeight * (i / 2);
        
        
        CGRect buttonFrame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
        
        JCHButton *button = [JCHUIFactory createJCHButton:buttonFrame
                                                   target:self
                                                   action:@selector(buttonAction:)
                                                    title:titleArray[i]
                                               titleColor:[UIColor whiteColor]
                                          backgroundColor:JCHColorHeaderBackground];
        button.titleLabel.font = [UIFont jchSystemFontOfSize:22];
        button.labelVerticalOffset = -15;
        button.imageViewVerticalOffset = 15;
        button.layer.cornerRadius = 0;
        [button setImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
        
        button.tag = i;
        [self.view addSubview:button];
        
        if (i > 1) {
            [button setTitleColor:JCHColorMainBody forState:UIControlStateNormal];
            button.backgroundColor = [UIColor whiteColor];
            [button setBackgroundImage:[UIImage imageWithColor:JCHColorGlobalBackground] forState:UIControlStateHighlighted];
        } else {
            [button setBackgroundImage:[UIImage imageWithColor:JCHColorRedButtonHeighlighted] forState:UIControlStateHighlighted];
        }
        
        if (i == 1) {
            _temporaryManifestButton = [JCHUIFactory createButton:CGRectZero
                                                           target:self
                                                           action:@selector(handleShowTemporaryManifestList)
                                                            title:@""
                                                       titleColor:JCHColorHeaderBackground
                                                  backgroundColor:nil];
            [_temporaryManifestButton setBackgroundImage:[UIImage imageNamed:@"shopAssisant_bubble"] forState:UIControlStateNormal];
            [button addSubview:_temporaryManifestButton];
            _temporaryManifestButton.hidden = YES;
            _temporaryManifestButton.titleEdgeInsets = UIEdgeInsetsMake(-7, 0, 0, 0);
            
            CGFloat temporaryManifestButtonLeftOffset = [JCHSizeUtility calculateWidthWithSourceWidth:20.0f];
            CGFloat temporaryManifestButtonBottomOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:45];
            
            [_temporaryManifestButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(button.mas_centerX).with.offset(temporaryManifestButtonLeftOffset);
                make.bottom.equalTo(button.mas_centerY).with.offset(-temporaryManifestButtonBottomOffset);
                make.width.and.height.mas_equalTo(30);
            }];
            
        }
    }
    
    UIView *verticalLine = [[[UIView alloc] initWithFrame:CGRectMake(buttonWidth, buttonHeight, kSeparateLineWidth, 2 * buttonHeight)] autorelease];
    verticalLine.backgroundColor = JCHColorSeparateLine;
    [self.view addSubview:verticalLine];
    
    UIView *horizontalLine = [[[UIView alloc] initWithFrame:CGRectMake(0, 2 * buttonHeight, kScreenWidth, kSeparateLineWidth)] autorelease];
    horizontalLine.backgroundColor = JCHColorSeparateLine;
    [self.view addSubview:horizontalLine];
}

- (void)buttonAction:(UIButton *)sender
{
    UIViewController *viewController = nil;
    switch (sender.tag) {
        case 0:
        {
            JCHBarCodeScannerViewController *barCodeScanerVC = [[[JCHBarCodeScannerViewController alloc] init] autorelease];
            barCodeScanerVC.title = @"扫码";
            barCodeScanerVC.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
            
            AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
            barCodeScanerVC.barCodeBlock = ^(NSString *code){
                [appDelegate.homePageController handleFinishScanQRCode:code
                                                           joinAccount:YES
                                                          authorizePad:YES
                                                              loginPad:YES];
            };
            [self presentViewController:barCodeScanerVC animated:YES completion:nil];
        }
            break;
            
        case 1:
        {
#if MMR_RESTAURANT_VERSION
            // 餐饮版
            JCHRestaurantOpenTableViewController *openTableController = [[[JCHRestaurantOpenTableViewController alloc] initWithOperationType:kJCHRestaurantOpenTableOperationTypeOpenTable tableRecord:nil] autorelease];
            openTableController.hidesBottomBarWhenPushed = YES;
            
            viewController = openTableController;
#else
            JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
            id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
            [manifestStorage clearData];
            
            manifestStorage.currentManifestID = [manifestService createManifestID:kJCHOrderShipment];
            manifestStorage.currentManifestDate = [JCHManifestUtility getOrderDate];
            manifestStorage.currentManifestDiscount = 1.0f;
            manifestStorage.currentManifestType = kJCHOrderShipment;
            
            viewController = [[[JCHAddProductMainViewController alloc] init] autorelease];
#endif
        }
            break;
            
        case 2:
        {
            viewController = [[[JCHInventoryViewController alloc] init] autorelease];
        }
            break;
            
        case 3:
        {
            viewController = [[[JCHManifestViewController alloc] init] autorelease];
        }
            break;
#if !TARGET_OS_SIMULATOR
        case 4:
        {
            viewController = [[[JCHBluetoothDeviceViewController alloc] init] autorelease];
        }
            break;
#endif
        case 5:
        {
            viewController = [[[JCHGroupContactsViewController alloc] initWithType:kJCHGroupContactsClient selectMember:NO] autorelease];
        }
            break;
            
        default:
            break;
            
    }
    
    if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - 店铺信息
- (void)showShopInfo
{
    JCHShopInfoViewController *shopInfoViewController = [[[JCHShopInfoViewController alloc] initWithType:kJCHShopInfoViewControllerTypeShopAssistant] autorelease];
    [self.navigationController pushViewController:shopInfoViewController animated:YES];
}

#pragma mark - 我的
- (void)handlePushToMyViewController
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (statusManager.isLogin) {
        
        JCHMyViewController *myVC = [[[JCHMyViewController alloc] init] autorelease];
        [self.navigationController pushViewController:myVC animated:YES];
    } else{
        JCHLoginViewController *loginVC = [[[JCHLoginViewController alloc] init] autorelease];
        //JCHEnforceLoginViewController *enforceLoginVC = [[[JCHEnforceLoginViewController alloc] init] autorelease];
        loginVC.registButtonShow = YES;
        [self.navigationController pushViewController:loginVC animated:YES];
        //[self.navigationController presentViewController:enforceLoginVC animated:YES completion:nil];
    }
    
}

#pragma mark - 同步
- (void)handleRefreshData
{
    UIImageView *imageView = _refreshButton.imageView;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationRepeatCount:6];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    imageView.transform = CGAffineTransformRotate(imageView.transform, M_PI);
    [UIView commitAnimations];
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    [appDelegate.homePageController doManualDataSync];
}

- (void)registerResponseNotificationHandler
{
    [JCHNotificationCenter addObserver:self selector:@selector(loadData) name:kShopAssistantHomepageUpdateDataNotification object:nil];
    [JCHNotificationCenter addObserver:self selector:@selector(logout) name:kShopAssistantHomepageLogoutNotification object:nil];
}

- (void)unregisterResponseNotificationHandler
{
    [JCHNotificationCenter removeObserver:self name:kShopAssistantHomepageUpdateDataNotification object:nil];
    [JCHNotificationCenter removeObserver:self name:kShopAssistantHomepageLogoutNotification object:nil];
}


- (void)logout
{
    [JCHUserInfoViewController clearUserLoginStatus];
    JCHLoginViewController *loginController = [[[JCHLoginViewController alloc] init] autorelease];
    loginController.registButtonShow = YES;
    loginController.showBackNavigationItem = NO;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:loginController animated:YES];
}

//刷新挂单数据
- (void)handleRefreshTemporaryManifestButton
{
    //挂单按钮相关    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    NSInteger manifestCount = [manifestService calculateStashManifestCount:NO];
    if (manifestCount > 0) {
        NSString *title = [NSString stringWithFormat:@"%ld", manifestCount];
        if (manifestCount > 9) {
            title = @"9+";
        }
        
        _temporaryManifestButton.hidden = NO;
        NSString *currentTitle = _temporaryManifestButton.currentTitle;
        [_temporaryManifestButton setTitle:title forState:UIControlStateNormal];
        if (![currentTitle isEqualToString:title]) {
            
            _temporaryManifestButton.transform = CGAffineTransformMakeTranslation(0, -40);
            [UIView animateWithDuration:0.6
                                  delay:0
                 usingSpringWithDamping:0.4
                  initialSpringVelocity:1
                                options:0
                             animations:^{
                                 
                                 _temporaryManifestButton.transform = CGAffineTransformIdentity;
                             } completion:nil];
        }
    } else {
        [_temporaryManifestButton setTitle:@"" forState:UIControlStateNormal];
        _temporaryManifestButton.hidden = YES;
    }
}

#pragma mark - 挂单相应事件
- (void)handleShowTemporaryManifestList
{
    JCHTempManifestViewController *tempManifestViewController = [[[JCHTempManifestViewController alloc] init] autorelease];
    
    [self.navigationController pushViewController:tempManifestViewController animated:YES];
}

@end
