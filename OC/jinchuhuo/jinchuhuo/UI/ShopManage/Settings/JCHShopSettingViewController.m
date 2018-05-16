//
//  JCHShopSettingViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/1/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHShopSettingViewController.h"
#import "JCHTakeoutShopHoursSetViewController.h"
#import "JCHTakeoutShopStatusSetViewController.h"
#import "JCHWarehouseManageViewController.h"
#import "JCHGuideFirstViewController.h"
#import "JCHHomepageViewController.h"
#import "JCHShopAssistantManageViewController.h"
#import "JCHShopInfoViewController.h"
#import "JCHShopInfoEditViewController.h"
#import "JCHAboutTableViewCell.h"
#import "JCHSeparateLineSectionView.h"
#import "JCHSyncStatusManager.h"
#import "CommonHeader.h"
#import "ServiceFactory.h"
#import "MBProgressHUD+JCHHud.h"
#import <Masonry.h>



typedef NS_ENUM(NSInteger, JCHVerificationType) {
    kJCHVerificationTypeClearDatabase,
    kJCHVerificationTypeDeleteAccountBook,
};

@interface JCHShopSettingViewController ()<UIAlertViewDelegate>
{
    JCHSwitchLabelView *_autoReceiveOrderView;
    JCHArrowTapView *_shopStatusView;
}
@property (nonatomic, retain) NSString *password;
@property (nonatomic, assign) JCHVerificationType verificationType;

@end

@implementation JCHShopSettingViewController

- (instancetype)init
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
    [self.password release];
    [self.shopStatusDetailText release];
    
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"店铺设置";
    [self createUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
#if MMR_TAKEOUT_VERSION
    [self handleQuertAutoReceiveStatus];
#endif
}

- (void)createUI
{
#if MMR_TAKEOUT_VERSION
    _shopStatusView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
    _shopStatusView.titleLabel.text = @"营业状态";
    [_shopStatusView.button addTarget:self action:@selector(handleShopStatus) forControlEvents:UIControlEventTouchUpInside];
    [_shopStatusView addSeparateLineWithMasonryTop:YES bottom:NO];
    _shopStatusView.detailLabel.textColor = UIColorFromRGB(0xFF6400);
    _shopStatusView.detailLabel.text = self.shopStatusDetailText;
    [self.backgroundScrollView addSubview:_shopStatusView];
    
    [_shopStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backgroundScrollView).offset(kStandardSeparateViewHeight);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    JCHArrowTapView *shopHoursView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
    shopHoursView.titleLabel.text = @"营业时间段";
    [shopHoursView.button addTarget:self action:@selector(handleShopHours) forControlEvents:UIControlEventTouchUpInside];
    [shopHoursView addSeparateLineWithMasonryTop:NO bottom:NO];
    [self.backgroundScrollView addSubview:shopHoursView];
    
    [shopHoursView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_shopStatusView.mas_bottom);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    _autoReceiveOrderView = [[[JCHSwitchLabelView alloc] initWithFrame:CGRectZero] autorelease];
    _autoReceiveOrderView.titleLabel.text = @"自动接单";
    _autoReceiveOrderView.switchButton.on = NO;
    _autoReceiveOrderView.backgroundColor = [UIColor whiteColor];
    [_autoReceiveOrderView.switchButton addTarget:self action:@selector(handleAutoReceiveOrder:) forControlEvents:UIControlEventValueChanged];
    [_autoReceiveOrderView setBottomLineHidden:YES];
    [_autoReceiveOrderView addSeparateLineWithMasonryTop:NO bottom:YES];
    [self.backgroundScrollView addSubview:_autoReceiveOrderView];
    
    [_autoReceiveOrderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(shopHoursView.mas_bottom);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    
    JCHArrowTapView *shopInfoView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
    shopInfoView.titleLabel.text = @"基本信息";
    [shopInfoView.button addTarget:self action:@selector(handleShopInfo) forControlEvents:UIControlEventTouchUpInside];
    [shopInfoView addSeparateLineWithMasonryTop:YES bottom:YES];
    [self.backgroundScrollView addSubview:shopInfoView];
    
    [shopInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_autoReceiveOrderView.mas_bottom).offset(kStandardSeparateViewHeight);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    
    [self.backgroundScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(shopInfoView);
    }];
#else
    JCHArrowTapView *shopInfoView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
    shopInfoView.titleLabel.text = @"基本信息";
    [shopInfoView.button addTarget:self action:@selector(handleShopInfo) forControlEvents:UIControlEventTouchUpInside];
    [shopInfoView addSeparateLineWithMasonryTop:YES bottom:YES];
    [self.backgroundScrollView addSubview:shopInfoView];
    
    [shopInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backgroundScrollView).offset(kStandardSeparateViewHeight);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    JCHArrowTapView *shopAssistantManageView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
    shopAssistantManageView.titleLabel.text = @"店员管理";
    [shopAssistantManageView.button addTarget:self action:@selector(handleShopAssistantManage) forControlEvents:UIControlEventTouchUpInside];
    [shopAssistantManageView addSeparateLineWithMasonryTop:YES bottom:NO];
    [self.backgroundScrollView addSubview:shopAssistantManageView];
    
    [shopAssistantManageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(shopInfoView.mas_bottom).offset(kStandardSeparateViewHeight);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    JCHArrowTapView *shopCostKeepingView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
    shopCostKeepingView.titleLabel.text = @"成本核算";
    shopCostKeepingView.detailLabel.text = @"移动加权平均法";
    [shopCostKeepingView.button addTarget:self action:@selector(handleCostKeeping) forControlEvents:UIControlEventTouchUpInside];
    [shopCostKeepingView addSeparateLineWithMasonryTop:NO bottom:YES];
    [self.backgroundScrollView addSubview:shopCostKeepingView];
    
    [shopCostKeepingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(shopAssistantManageView.mas_bottom);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    JCHArrowTapView *clearDatabaseView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
    clearDatabaseView.titleLabel.text = @"店铺数据初始化";
    [clearDatabaseView.button addTarget:self action:@selector(handleClearDatabase) forControlEvents:UIControlEventTouchUpInside];
    [clearDatabaseView addSeparateLineWithMasonryTop:YES bottom:YES];
    [self.backgroundScrollView addSubview:clearDatabaseView];
    
    [clearDatabaseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(shopCostKeepingView.mas_bottom).offset(kStandardSeparateViewHeight);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    UIButton *deleteShopButton = [JCHUIFactory createButton:CGRectMake(0, 20, kScreenWidth, kStandardButtonHeight)
                                                     target:self
                                                     action:@selector(handleDeleteShop)
                                                      title:@"删除店铺"
                                                 titleColor:JCHColorMainBody
                                            backgroundColor:[UIColor whiteColor]];
    deleteShopButton.titleLabel.font = [UIFont jchSystemFontOfSize:16.0f];
    
    
    //删除店铺按钮
    [deleteShopButton addSeparateLineWithFrameTop:YES bottom:YES];
    
    [self.backgroundScrollView addSubview:deleteShopButton];
    
    [deleteShopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(clearDatabaseView.mas_bottom).offset(kStandardSeparateViewHeight);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardButtonHeight);
    }];
    
    [self.backgroundScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(deleteShopButton);
    }];
#endif
}

#pragma mark - 营业状态
- (void)handleShopStatus
{
    WeakSelf;
    JCHTakeoutShopStatusSetViewController *viewController = [[[JCHTakeoutShopStatusSetViewController alloc] init] autorelease];
    viewController.shopStatusChangeBlock = ^(BOOL status) {
        if (status) {
            weakSelf -> _shopStatusView.detailLabel.text = @"营业中";
        } else {
            weakSelf -> _shopStatusView.detailLabel.text = @"未营业";
        }
    };
    self.navigationController.navigationBarHidden = NO;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - 营业时间段
- (void)handleShopHours
{
    JCHTakeoutShopHoursSetViewController *viewController = [[[JCHTakeoutShopHoursSetViewController alloc] init] autorelease];
    self.navigationController.navigationBarHidden = NO;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - 基本信息
- (void)handleShopInfo
{
    JCHShopInfoViewController *viewController = [[[JCHShopInfoViewController alloc] initWithType:kJCHShopInfoViewControllerTypeShopManager] autorelease];
    self.navigationController.navigationBarHidden = NO;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - 店员管理
- (void)handleShopAssistantManage
{
    JCHShopAssistantManageViewController *viewController = [[[JCHShopAssistantManageViewController alloc] init] autorelease];
    self.navigationController.navigationBarHidden = NO;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - 成本核算
- (void)handleCostKeeping
{
    [MBProgressHUD showHUDWithTitle:@""
                             detail:@"其它成本核算方法暂未开放，敬请期待!"
                           duration:kJCHDefaultShowHudTime
                               mode:MBProgressHUDModeText
                         completion:nil];
}


#pragma mark - 数据初始化
- (void)handleClearDatabase
{
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"请输入账户密码"
                                                  message:nil
                                                 delegate:self
                                        cancelButtonTitle:@"取消"
                                        otherButtonTitles:@"确定", nil] autorelease];
    av.tag = 10000;
    [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *textField = [av textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeASCIICapable;
    textField.secureTextEntry = YES;
    [av show];
    
    return;
    
}

#pragma mark - 删除店铺
- (void)handleDeleteShop
{
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"请输入账户密码"
                                                  message:nil
                                                 delegate:self
                                        cancelButtonTitle:@"取消"
                                        otherButtonTitles:@"确定", nil] autorelease];
    av.tag = 10002;
    [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *textField = [av textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeASCIICapable;
    textField.secureTextEntry = YES;
    [av show];
}

#pragma mark - 自动接单
- (void)handleAutoReceiveOrder:(UISwitch *)sender
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    
    SetAutoReceiveOrderRequest *request = [[[SetAutoReceiveOrderRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.serviceURL = [NSString stringWithFormat:@"%@/book/autoReceive", kTakeoutServerIP];
    request.status = sender.on;
    
    [takeoutService setAutoReceiveOrder:request callback:^(id response) {
        
        NSDictionary *data = response;
        
        if (kJCHServiceSuccess == [data[@"status"] integerValue]) {
            NSDictionary *responseData = data[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                //! @todo
                if (responseCode == 22000) {
                    [MBProgressHUD showHUDWithTitle:@"用户验证失败"
                                             detail:@"请重新登录"
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                          superView:self.view
                                         completion:nil];
                } else {
                    [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"%ld", responseCode]
                                             detail:responseDescription
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                          superView:self.view
                                         completion:nil];
                }
                sender.on = !sender.on;
            } else {
                NSLog(@"responseData = %@", responseData);
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
                
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            [MBProgressHUD showNetWorkFailedHud:@""
                                      superView:self.view];
            sender.on = !sender.on;
        }
    }];
}

#pragma mark - 查询自动接单状态
- (void)handleQuertAutoReceiveStatus
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    
    QueryAutoReceiveOrderRequest *request = [[[QueryAutoReceiveOrderRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.serviceURL = [NSString stringWithFormat:@"%@/book/queryAuto", kTakeoutServerIP];
    
    [takeoutService queryAutoReceiveOrder:request callback:^(id response) {
        
        NSDictionary *data = response;
        
        if (kJCHServiceSuccess == [data[@"status"] integerValue]) {
            NSDictionary *responseData = data[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                //! @todo

            } else {
                NSLog(@"responseData = %@", responseData);
                
                BOOL status = [responseData[@"data"][@"auto"] boolValue];
                _autoReceiveOrderView.switchButton.on = status;
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
        }
    }];
}

- (void)handleMakeSureDeleteAccountBook
{
    //1) 判断是否为店长
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (!statusManager.isShopManager) {
        return;
    }
    
    [MBProgressHUD showHUDWithTitle:@"删除店铺中..."
                             detail:@""
                           duration:1000
                               mode:MBProgressHUDModeText
                         completion:nil];
    //2) 请求服务器删除店铺
    [self doDeleteAccountBook];
    
    //3) 切店(如果还有店)或者创建店铺并进行角色引导(没有店铺)
    //4) 关闭数据库并清理本地文件
}

- (void)doDeleteAccountBook
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    DeleteAccountBookRequest *request = [[[DeleteAccountBookRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.token = statusManager.syncToken;
    request.accountBookID = statusManager.accountBookID;
    request.serviceURL = [NSString stringWithFormat:@"%@/terminal/delBook", kJCHSyncManagerServerIP];
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService deleteAccountBook:request responseNotification:kJCHDeleteAccountBookNotification];
}

- (void)handleDeleteAccountBook:(NSNotification *)notify
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
            NSLog(@"delete account book fail.");
            
            [MBProgressHUD showHudWithStatusCode:responseCode
                                       sceneType:kJCHMBProgressHUDSceneTypeDeleteAccountBook];
            
            return;
        } else {
            
            JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
            
            [ServiceFactory deleteAccountBook:statusManager.userID
                                accountBookID:statusManager.accountBookID];
            
            statusManager.accountBookID = nil;
            [JCHSyncStatusManager writeToFile];
            
            AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
            UITabBarController *rootTabBarController = (UITabBarController *)appDelegate.rootNavigationController.topViewController;
            rootTabBarController.selectedIndex = 0;
            
            [appDelegate switchToHomePage:self completion:^{
                
            }];
            
            //服务器删店成功,切店
            [MBProgressHUD showHUDWithTitle:@"店铺删除成功" detail:@"" duration:kJCHDefaultShowHudTime mode:MBProgressHUDModeText completion:^{
                [self.navigationController popToRootViewControllerAnimated:NO];
            }];
        }
        
    } else {
        
        [MBProgressHUD showNetWorkFailedHud:nil];
    }
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10000) {
        
        if (buttonIndex == 1) {
        
            UITextField *textField = [alertView textFieldAtIndex:0];
            if ([textField.text isEqualToString:@""]) {
                [MBProgressHUD showHUDWithTitle:@"密码不能为空" detail:nil duration:1 mode:MBProgressHUDModeText completion:nil];
            } else {
                self.password = textField.text;
                self.verificationType = kJCHVerificationTypeClearDatabase;
                [self handleLogin];
            }
        }
    } else if (alertView.tag == 10001) {
        //清除店铺数据
        if (1 == buttonIndex) {
            [MBProgressHUD showHUDWithTitle:nil detail:@"请稍候..." duration:2 mode:MBProgressHUDModeIndeterminate completion:^{
            [MBProgressHUD showHUDWithTitle:@"删除成功" detail:nil duration:1 mode:MBProgressHUDModeText completion:nil];
            }];
            [[ServiceFactory sharedInstance] clearDatabase];
            
            AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
            
            //! @note 清除tabbar上每个页面的数据
            [appDelegate clearDataOnTabbar];
        }
    } else if (alertView.tag == 10002) {
        
        if (buttonIndex == 1) {
            UITextField *textField = [alertView textFieldAtIndex:0];
            if ([textField.text isEqualToString:@""]) {
                [MBProgressHUD showHUDWithTitle:@"密码不能为空" detail:nil duration:1 mode:MBProgressHUDModeText completion:nil];
            } else {
                self.password = textField.text;
                self.verificationType = kJCHVerificationTypeDeleteAccountBook;
                [textField resignFirstResponder];
                [self handleLogin];
            }
        }
    } else if (alertView.tag == 10003) {
        if (buttonIndex == 1) {
            [self handleMakeSureDeleteAccountBook];
        }
    }
    
    return;
}



//登录
- (void)handleLogin
{
    [self.view endEditing:YES];

    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager startMonitoring];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"networkChagne");
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
            NSLog(@"没有网络");
            [MBProgressHUD showNetWorkFailedHud:nil];
        } else {
            NSLog(@"有网络");
            [MBProgressHUD showHUDWithTitle:@"验证中..." detail:nil duration:100 mode:MBProgressHUDModeText completion:nil];
            JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
            [self doUserLogin:statusManager.phoneNumber password:self.password];
            [manager stopMonitoring];
            [manager setReachabilityStatusChangeBlock:nil];
        }
    }];
}

- (void)doUserLogin:(NSString *)userName password:(NSString *)password
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    UserLoginRequest *request = [[[UserLoginRequest alloc] init] autorelease];
    request.serviceURL = [NSString stringWithFormat:@"%@/terminal/login", kJCHUserManagerServerIP];
    request.userName = userName;
    request.userPassword = password;
    request.deviceUUID = statusManager.deviceUUID;
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService userLogin:request responseNotification:kJCHUserLoginNotification];
    
    return;
}


- (void)handleUserLogin:(NSNotification *)notify
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
            NSLog(@"Login fail.");
            [MBProgressHUD showHUDWithTitle:@"验证失败" detail:nil duration:1 mode:MBProgressHUDModeText completion:nil];
            return;
        } else {
            NSDictionary *serviceResponse = responseData[@"data"];
            NSString *userID = serviceResponse[@"id"];
            NSString *token = serviceResponse[@"token"];
            
            UserLoginResponse *response = [[[UserLoginResponse alloc] init] autorelease];
            response.code = responseCode;
            response.descriptionString = responseDescription;
            response.status = responseStatus;
            response.userID = [NSString stringWithFormat:@"%@", userID];
            response.token = token;
            
            JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
            statusManager.userID = [NSString stringWithFormat:@"%@", userID];
            statusManager.syncToken = token;
            
            NSDictionary *lastUserInfo = @{@"userName" : statusManager.phoneNumber, @"password" : self.password};
            statusManager.lastUserInfo = lastUserInfo;
            
            [JCHSyncStatusManager writeToFile];
            
            //! @todo
            // your code here
            [MBProgressHUD hideAllHudsForWindow];
            if (self.verificationType == kJCHVerificationTypeClearDatabase) {
                
                UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"验证成功"
                                                                     message:@"您确定要删除数据库中所有的货单和库存数据吗?"
                                                                    delegate:self
                                                           cancelButtonTitle:@"取消"
                                                           otherButtonTitles:@"确定", nil] autorelease];
                alertView.tag = 10001;
                [alertView show];
            } else if (self.verificationType == kJCHVerificationTypeDeleteAccountBook) {
                
                UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"验证成功"
                                                                     message:@"您确定要删除当前店铺?"
                                                                    delegate:self
                                                           cancelButtonTitle:@"取消"
                                                           otherButtonTitles:@"确定", nil] autorelease];
                alertView.tag = 10003;
                [alertView show];
            } else {
                //pass
            }
        }
        
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
        [MBProgressHUD showNetWorkFailedHud:@"验证失败"];
    }
}


#pragma mark - LonginNotificationAndMethod

- (void)registerResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleUserLogin:)
                               name:kJCHUserLoginNotification
                             object:[UIApplication sharedApplication]];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleDeleteAccountBook:)
                               name:kJCHDeleteAccountBookNotification
                             object:[UIApplication sharedApplication]];
    
}

- (void)unregisterResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter removeObserver:self
                                  name:kJCHUserLoginNotification
                                object:[UIApplication sharedApplication]];
    
    [notificationCenter removeObserver:self
                                  name:kJCHDeleteAccountBookNotification
                                object:[UIApplication sharedApplication]];
}



@end
