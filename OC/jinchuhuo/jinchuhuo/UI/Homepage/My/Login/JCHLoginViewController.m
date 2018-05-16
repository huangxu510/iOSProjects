//
//  JCHLoginViewController.m
//  jinchuhuo
//
//  Created by apple on 15/8/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHLoginViewController.h"
#import "JCHGuideFirstViewController.h"
#import "JCHShopAssistantHomepageViewController.h"
#import "JCHShopSelectViewController.h"
#import "JCHHTMLViewController.h"
#import "JCHRegisterViewController.h"
#import "JCHRetrievePasswordViewController.h"
#import "JCHInputAccessoryView.h"
#import "JCHUIFactory.h"
#import "AppDelegate.h"
#import "JCHUISettings.h"
#import "JCHUISizeSettings.h"
#import "JCHColorSettings.h"
#import "JCHSizeUtility.h"
#import "UIImage+JCHImage.h"
#import "ServiceFactory.h"
#import "JCHSyncServerSettings.h"
#import "JCHSyncStatusManager.h"
#import "JCHSettlementManager.h"
#import "JCHServiceResponseSettings.h"
#import "JCHServiceResponseNotification.h"
#import "MBProgressHUD+JCHHud.h"
#import "JCHStatisticsManager.h"
#import "JCHImageUtility.h"
#import "JCHUserInfoHelper.h"
#import "CommonHeader.h"
#import "BookInfoRecord4Cocoa.h"
#import <Masonry.h>
#import <AFNetworking.h>
#import "MiPushSDK.h"


@interface JCHLoginViewController () <UITextFieldDelegate>
{
    UIImageView *_userNameImageView;
    UIImageView *_passwordImageView;
    UITextField *_userNameTextField;
    UITextField *_passwordTextField;
    UIButton *_loginButton;
    UIButton *_weChatButton;
    UIButton *_weiboButton;
    UIButton *_qqButton;
}

@property (nonatomic, retain) MBProgressHUD *hud;
@property (retain, nonatomic, readwrite) NSArray *accountBookList;
@property (retain, nonatomic, readwrite) NSString *uploadDatabasePath;
@property (assign, nonatomic, readwrite) NSInteger currentDatabaseVersion;
@property (retain, nonatomic, readwrite) NSDictionary *accountBookStatusForBookId;
@end

@implementation JCHLoginViewController

- (id)init
{
    self = [super init];
    if (self) {
        // pass
        self.title = @"登录";
        self.showBackNavigationItem = YES;
        [self registerResponseNotificationHandler];
    }
    
    return self;
}

- (void)dealloc
{
    
    [self unregisterResponseNotificationHandler];
    [self.hud release];
    [self.accountBookList release];
    [self.uploadDatabasePath release];
    [self.accountBookStatusForBookId release];
    
    
    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    if (!self.showBackNavigationItem) {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = YES;
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [self creataUI];
    
    return;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    _userNameTextField.text = statusManager.lastUserInfo[@"userName"];
    _passwordTextField.text = @"";
    _loginButton.enabled = NO;
    [self textFieldDidEndEditing:_passwordTextField];
    if ([_userNameTextField.text isEqualToString:@""]) {
        _userNameImageView.image = [UIImage imageNamed:@"icon_phonenumber_normal"];
    } else {
        _userNameImageView.image = [UIImage imageNamed:@"icon_phonenumber_selected"];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.showBackNavigationItem) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}


- (void)creataUI
{
    const CGFloat containerViewTopOffset = 24.0f;
    const CGFloat containerViewHeight = 100.0f;
    const CGFloat userNameImageViewWidth = 54.0f;
    
    UIView *containerView = [[[UIView alloc] init] autorelease];
    containerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:containerView];
    
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(containerViewTopOffset);
        make.height.mas_equalTo(containerViewHeight);
        make.left.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];
    
    
    _userNameImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_phonenumber_normal"]] autorelease];
    [containerView addSubview:_userNameImageView];
    
    [_userNameImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView);
        make.top.equalTo(containerView);
        make.bottom.equalTo(containerView.mas_centerY);
        make.width.mas_equalTo(userNameImageViewWidth);
    }];
    
    _passwordImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_password_normal"]] autorelease];
    [containerView addSubview:_passwordImageView];
    
    [_passwordImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_userNameImageView);
        make.right.equalTo(_userNameImageView);
        make.top.equalTo(_userNameImageView.mas_bottom);
        make.bottom.equalTo(containerView);
    }];
    
    const CGRect inputAccessoryFrame = CGRectMake(0, 0, self.view.frame.size.width, kJCHInputAccessoryViewHeight);
    UIFont *textFieldFont = [UIFont jchSystemFontOfSize:16.0f];
    _userNameTextField = [JCHUIFactory createTextField:CGRectZero placeHolder:nil textColor:JCHColorMainBody aligin:NSTextAlignmentLeft];
    _userNameTextField.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:@"手机号" attributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xd5d5d5), NSFontAttributeName : textFieldFont}] autorelease];
    _userNameTextField.font = textFieldFont;
    _userNameTextField.delegate = self;
    _userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _userNameTextField.keyboardType = UIKeyboardTypeNumberPad;
    _userNameTextField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
    [_userNameTextField addTarget:self action:@selector(textFieldIsEditing:) forControlEvents:UIControlEventEditingChanged];
    [containerView addSubview:_userNameTextField];
    
    [_userNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_userNameImageView.mas_right);
        make.top.equalTo(_userNameImageView);
        make.bottom.equalTo(_userNameImageView);
        make.right.equalTo(containerView);
    }];
    
    
    UIView *middleLine = [[[UIView alloc] init] autorelease];
    middleLine.backgroundColor = JCHColorSeparateLine;
    [self.view addSubview:middleLine];
    
    [middleLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_userNameTextField);
        make.right.equalTo(containerView);
        make.bottom.equalTo(_userNameTextField);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    _passwordTextField = [JCHUIFactory createTextField:CGRectZero placeHolder:nil textColor:JCHColorMainBody aligin:NSTextAlignmentLeft];
    _passwordTextField.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:@"密码" attributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xd5d5d5), NSFontAttributeName : textFieldFont}] autorelease];
    _passwordTextField.font = textFieldFont;
    _passwordTextField.delegate = self;
    _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passwordTextField.keyboardType = UIKeyboardTypeASCIICapable;
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
    [_passwordTextField addTarget:self action:@selector(textFieldIsEditing:) forControlEvents:UIControlEventEditingChanged];
    [containerView addSubview:_passwordTextField];
    
    [_passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_userNameTextField);
        make.right.equalTo(_userNameTextField);
        make.top.equalTo(_userNameTextField.mas_bottom);
        make.bottom.equalTo(containerView);
    }];
    
    
    const CGFloat loginButtonTopOffset = 18.0f;
    const CGFloat loginButtonHeight = 50.0f;
    _loginButton = [JCHUIFactory createButton:CGRectZero
                                       target:self
                                       action:@selector(handleLogin)
                                        title:@"登录"
                                   titleColor:nil
                              backgroundColor:[UIColor whiteColor]];
    [_loginButton setTitleColor:UIColorFromRGB(0xd5d5d5) forState:UIControlStateDisabled];
    [_loginButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateDisabled];
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginButton setBackgroundImage:[UIImage imageWithColor:JCHColorHeaderBackground] forState:UIControlStateNormal];
    _loginButton.layer.cornerRadius = 4;
    _loginButton.clipsToBounds = YES;
    _loginButton.enabled = NO;
    
    [self.view addSubview:_loginButton];
    
    [_loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView).with.offset(kStandardLeftMargin);
        make.right.equalTo(containerView).with.offset(-kStandardLeftMargin);
        make.top.equalTo(containerView.mas_bottom).with.offset(loginButtonTopOffset);
        make.height.mas_equalTo(loginButtonHeight);
    }];
    
    
    const CGFloat retrieveButtonTopOffset = 9;
    const CGFloat retrieveButtonHeight = 20;
    const CGFloat retrieveButtonWidth = 100;
    
    UIButton *retrieveButton = [JCHUIFactory createButton:CGRectZero
                                                   target:self
                                                   action:@selector(handleRetrieve)
                                                    title:@"找回密码"
                                               titleColor:JCHColorAuxiliary
                                          backgroundColor:nil];
    retrieveButton.titleLabel.font = [UIFont jchSystemFontOfSize:13.0f];
    retrieveButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.view addSubview:retrieveButton];
    
    [retrieveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_loginButton);
        make.top.equalTo(_loginButton.mas_bottom).with.offset(retrieveButtonTopOffset);
        make.width.mas_equalTo(retrieveButtonWidth);
        make.height.mas_equalTo(retrieveButtonHeight);
    }];
    
    UIButton *registButton = [JCHUIFactory createButton:CGRectZero
                                                 target:self
                                                 action:@selector(handleRegist)
                                                  title:@"新用户注册"
                                             titleColor:JCHColorAuxiliary
                                        backgroundColor:nil];
    registButton.titleLabel.font = [UIFont jchSystemFontOfSize:13.0f];
    registButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.view addSubview:registButton];
    
    [registButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_loginButton);
        make.top.equalTo(retrieveButton);
        make.width.mas_equalTo(retrieveButtonWidth);
        make.height.mas_equalTo(retrieveButtonHeight);
    }];
    
    
    registButton.hidden = !self.registButtonShow;
    
    
#if 0
    const CGFloat otherLoginLabelTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:YES sourceHeight:38.0f];
    UILabel *otherLoginLabel = [JCHUIFactory createLabel:CGRectZero
                                                   title:@"其他快捷方式登录"
                                                    font:titleFont
                                               textColor:JCHColorAuxiliary
                                                  aligin:NSTextAlignmentLeft];
    [self.view addSubview:otherLoginLabel];
    
    [otherLoginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(registButton);
        make.top.equalTo(registButton.mas_bottom).with.offset(otherLoginLabelTopOffset);
        make.right.equalTo(self.view.mas_centerX);
        make.height.equalTo(registButton);
    }];
    
    const CGFloat bottomContainerViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:YES sourceHeight:115.0f];
    UIView *bottomContainerView = [[[UIView alloc] init] autorelease];
    bottomContainerView.backgroundColor = [UIColor whiteColor];
    bottomContainerView.layer.borderColor = JCHColorSeparateLine.CGColor;
    bottomContainerView.layer.borderWidth = kSeparateLineWidth;
    bottomContainerView.layer.cornerRadius = 3;
    bottomContainerView.clipsToBounds = YES;
    [self.view addSubview:bottomContainerView];
    
    [bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView);
        make.right.equalTo(containerView);
        make.top.equalTo(otherLoginLabel.mas_bottom).with.offset(registLabelTopOffset);
        make.height.mas_equalTo(bottomContainerViewHeight);
    }];
    
    const CGFloat weChatButtonLeftMargin = [JCHSizeUtility calculateWidthWithSourceWidth:25.0f];
    const CGFloat weCharButtonHeight = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:YES sourceHeight:63];
    const CGFloat weChatButtonTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:YES sourceHeight:15.0f];
    _weChatButton = [JCHUIFactory createButton:CGRectZero
                                        target:self
                                        action:@selector(handleOtherLogin:)
                                         title:nil
                                    titleColor:nil
                               backgroundColor:nil];
    [_weChatButton setImage:[UIImage imageNamed:@"icon_weixin"] forState:UIControlStateNormal];
    [bottomContainerView addSubview:_weChatButton];
    
    [_weChatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomContainerView).with.offset(weChatButtonLeftMargin);
        make.top.equalTo(bottomContainerView).with.offset(weChatButtonTopOffset);
        make.height.mas_equalTo(weCharButtonHeight);
        make.width.mas_equalTo(weCharButtonHeight);
    }];
    
    _weiboButton = [JCHUIFactory createButton:CGRectZero
                                       target:self
                                       action:@selector(handleOtherLogin:)
                                        title:nil
                                   titleColor:nil
                              backgroundColor:nil];
    [_weiboButton setImage:[UIImage imageNamed:@"icon_Weibo"] forState:UIControlStateNormal];
    [bottomContainerView addSubview:_weiboButton];
    
    [_weiboButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bottomContainerView);
        make.top.equalTo(_weChatButton);
        make.height.mas_equalTo(weCharButtonHeight);
        make.width.mas_equalTo(weCharButtonHeight);
    }];
    
    _qqButton = [JCHUIFactory createButton:CGRectZero
                                    target:self
                                    action:@selector(handleOtherLogin:)
                                     title:nil
                                titleColor:nil
                           backgroundColor:nil];
    [_qqButton setImage:[UIImage imageNamed:@"icon_QQ"] forState:UIControlStateNormal];
    [bottomContainerView addSubview:_qqButton];
    
    [_qqButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(bottomContainerView).with.offset(-weChatButtonLeftMargin);
        make.top.equalTo(_weChatButton);
        make.height.mas_equalTo(weCharButtonHeight);
        make.width.mas_equalTo(weCharButtonHeight);
    }];
    
    UILabel *weChatLabel = [JCHUIFactory createLabel:CGRectZero
                                               title:@"微信"
                                                font:[UIFont systemFontOfSize:[JCHSizeUtility calculateFontSizeWithSourceSize:13.0f]]
                                           textColor:JCHColorMainBody
                                              aligin:NSTextAlignmentCenter];
    [bottomContainerView addSubview:weChatLabel];
    
    [weChatLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(bottomContainerView.mas_width).multipliedBy(0.3);
        make.centerX.equalTo(_weChatButton);
        make.top.equalTo(_weChatButton.mas_bottom);
        make.bottom.equalTo(bottomContainerView);
    }];
    
    UILabel *weiboLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"微博"
                                               font:[UIFont systemFontOfSize:[JCHSizeUtility calculateFontSizeWithSourceSize:13.0f]]
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentCenter];
    [bottomContainerView addSubview:weiboLabel];
    
    [weiboLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(bottomContainerView.mas_width).multipliedBy(0.3);
        make.centerX.equalTo(_weiboButton);
        make.top.equalTo(_weChatButton.mas_bottom);
        make.bottom.equalTo(bottomContainerView);
    }];
    
    UILabel *qqLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@"QQ"
                                            font:[UIFont systemFontOfSize:[JCHSizeUtility calculateFontSizeWithSourceSize:13.0f]]
                                       textColor:JCHColorMainBody
                                          aligin:NSTextAlignmentCenter];
    [bottomContainerView addSubview:qqLabel];
    
    [qqLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(bottomContainerView.mas_width).multipliedBy(0.3);
        make.centerX.equalTo(_qqButton);
        make.top.equalTo(_weChatButton.mas_bottom);
        make.bottom.equalTo(bottomContainerView);
    }];
#endif
}

//注册
- (void)handleRegist
{
    self.hidesBottomBarWhenPushed = YES;
    JCHRegisterViewController *registerVC = [[[JCHRegisterViewController alloc] init] autorelease];
    
    [self.navigationController pushViewController:registerVC animated:YES];
}

//登录
- (void)handleLogin
{
    [self.view endEditing:YES];
    
    NSPredicate *phonePredicate = [NSPredicate predicateWithFormat:@"self matches %@", kPhoneNumberPredicate];
    if (![phonePredicate evaluateWithObject:_userNameTextField.text]) {
        [MBProgressHUD showHUDWithTitle:nil detail:@"手机号码有误！" duration:1 mode:MBProgressHUDModeText completion:nil];
        return;
    }
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager startMonitoring];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"networkChagne");
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
            NSLog(@"没有网络");
            [MBProgressHUD showNetWorkFailedHud:nil];
        } else {
            NSLog(@"有网络");
          
            self.hud = [MBProgressHUD showHUDWithTitle:@"登录中..."
                                                detail:nil
                                              duration:1000
                                                  mode:MBProgressHUDModeIndeterminate
                                            completion:nil];
            
            [self doUserLogin:_userNameTextField.text password:_passwordTextField.text];
            [manager stopMonitoring];
            [manager setReachabilityStatusChangeBlock:nil];
        }
    }];
}

- (void)handlePopAction
{
    if (self.navigationController.presentingViewController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//三方登录
- (void)handleOtherLogin:(UIButton *)sender
{
    
}

//找回密码
- (void)handleRetrieve
{
    JCHRetrievePasswordViewController *retrieveVC = [[[JCHRetrievePasswordViewController alloc] init] autorelease];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:retrieveVC animated:YES];
}
- (void)handleDismissAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)textFieldIsEditing:(UITextField *)textField
{
    if ([_userNameTextField.text isEqualToString:@""] || [_passwordTextField.text isEqualToString:@""]) {
        _loginButton.enabled = NO;
    }
    else
    {
        _loginButton.enabled = YES;
    }
}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _userNameTextField) {
        _userNameImageView.image = [UIImage imageNamed:@"icon_phonenumber_selected"];
    }
    else
    {
        _passwordImageView.image = [UIImage imageNamed:@"icon_password_selected"];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _userNameTextField) {
        if ([textField.text isEqualToString:@""]) {
            _userNameImageView.image = [UIImage imageNamed:@"icon_phonenumber_normal"];
        }
    }
    else
    {
        if ([textField.text isEqualToString:@""]) {
            _passwordImageView.image = [UIImage imageNamed:@"icon_password_normal"];
        }
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
                           selector:@selector(handleFetchAllUserAccountBooks:)
                               name:kJCHSyncFetchAccountBooksCommandNotification
                             object:[UIApplication sharedApplication]];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleFetchAllAccountBookList:)
                               name:kJCHSyncConnectCommandNotification
                             object:[UIApplication sharedApplication]];
    
    
    [notificationCenter addObserver:self
                           selector:@selector(handleQueryUserProfile:)
                               name:kJCHSyncQueryUserProfileCommandNotification
                             object:[UIApplication sharedApplication]];
    
    
    // 自动注册消息响应
    [notificationCenter addObserver:self
                           selector:@selector(handleAutoRegisterCompleteInAppDelegate:)
                               name:kJCHSyncAutoRegisterCompleteNotification
                             object:[UIApplication sharedApplication]];
    
    //自动注册失败消息相应
    [notificationCenter addObserver:self
                           selector:@selector(handleAutoRegisterFailedInAppDelegate:)
                               name:kAutoRegisterFailedNotification
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
                                  name:kJCHUserLoginNotification
                                object:[UIApplication sharedApplication]];
    
    [notificationCenter removeObserver:self
                                  name:kJCHSyncFetchAccountBooksCommandNotification
                                object:[UIApplication sharedApplication]];
    
    
    [notificationCenter removeObserver:self
                                  name:kJCHSyncConnectCommandNotification
                                object:[UIApplication sharedApplication]];
    
    // 用户信息相关
    [notificationCenter removeObserver:self
                                  name:kJCHSyncQueryUserProfileCommandNotification
                                object:[UIApplication sharedApplication]];
    
    [notificationCenter removeObserver:self
                                  name:kJCHSyncAutoRegisterCompleteNotification
                                object:[UIApplication sharedApplication]];
    
    [notificationCenter removeObserver:self
                                  name:kAutoRegisterFailedNotification
                                object:[UIApplication sharedApplication]];
    
    [notificationCenter removeObserver:self
                                  name:kJCHQueryAddedServiceInfoNotification
                                object:[UIApplication sharedApplication]];
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
            [MBProgressHUD showHudWithStatusCode:responseCode sceneType:kJCHMBProgressHUDSceneTypeLogin];
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
            statusManager.phoneNumber = _userNameTextField.text;
            
            NSDictionary *lastUserInfo = @{@"userName" : _userNameTextField.text, @"password" : _passwordTextField.text};
            statusManager.lastUserInfo = lastUserInfo;
            
            [JCHSyncStatusManager writeToFile];
            
            //! @todo
            // your code here
            
            [self doFetchAllUserAccountBooks];
        }
        
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
        [MBProgressHUD showNetWorkFailedHud:@"登录失败"];
    }
}


// 拉取用户最新的账本列表
- (void)doFetchAllUserAccountBooks
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    FetchExistedAccountBookRequest *request = [[[FetchExistedAccountBookRequest alloc] init] autorelease];
    request.serviceURL = [NSString stringWithFormat:@"%@/terminal/connect", kJCHSyncManagerServerIP];
    request.token = statusManager.syncToken;
    request.deviceUUID = statusManager.deviceUUID;
    request.bookType = JCH_BOOK_TYPE;
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService fetchExistedAccountBook:request responseNotification:kJCHSyncFetchAccountBooksCommandNotification];
    
    return;
}

- (void)handleFetchAllUserAccountBooks:(NSNotification *)notify
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
            [MBProgressHUD showHUDWithTitle:@"登录失败"
                                     detail:@"获取账本列表失败"
                                   duration:2
                                       mode:MBProgressHUDModeText
                                 completion:nil];
            return;
        } else {
            FetchExistedAccountBookResponse *response = [[[FetchExistedAccountBookResponse alloc] init] autorelease];
            response.accountBookList = [[[NSMutableArray alloc] init] autorelease];
            
            NSDictionary *serviceResponse = responseData[@"data"];
            NSArray *accountBookList = serviceResponse[@"list"];
            NSMutableDictionary *accountBookStatusForBookId = [NSMutableDictionary dictionary];
            for (NSDictionary *accountBook in accountBookList) {
                NSString *accountBookID = [NSString stringWithFormat:@"%@", accountBook[@"id"]];
                NSString *syncHost = accountBook[@"host"];
                NSString *innerHost = accountBook[@"interHost"];
                NSString *status = [NSString stringWithFormat:@"%@", accountBook[@"status"]];
                [accountBookStatusForBookId setObject:status forKey:accountBookID];
                FetchExistedAccountBookRecord *bookRecord = [[[FetchExistedAccountBookRecord alloc] init] autorelease];
                bookRecord.accountBookID = accountBookID;
                bookRecord.accountBookSyncHost = syncHost;
                bookRecord.innerSyncHost = innerHost;
                [response.accountBookList addObject:bookRecord];
            }
            self.accountBookStatusForBookId = accountBookStatusForBookId;
            
            //! @todo
            // your code here
            
            // 创建 一个最新库表结构的空数据
            NSString *emptyLatestDatabasePath = [ServiceFactory createSyncConnectNewUploadDatabase:[AppDelegate getOldVersionDatabasePath]];
            
            id<DatabaseUpgradeService> upgradeService = [[ServiceFactory sharedInstance] databaseUpgradeService];
            NSInteger databaseVersion = [upgradeService getCurrentDatabaseVersion];
            
            self.uploadDatabasePath = emptyLatestDatabasePath;
            self.currentDatabaseVersion = databaseVersion;
            self.accountBookList = response.accountBookList;
            
            // 获取账本
            [self doFetchAllAccountBookList:response.accountBookList
                         uploadDatabasePath:emptyLatestDatabasePath
                            databaseVersion:databaseVersion];
        }
        
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
        [MBProgressHUD showNetWorkFailedHud:@"登录失败"];
    }
}

- (void)doFetchAllAccountBookList:(NSArray *)accountBookList
               uploadDatabasePath:(NSString *)uploadDatabasePath
                  databaseVersion:(NSInteger)databaseVersion
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
//    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    
    BOOL hasFetchAllAccountBooks = YES;
    
    for (FetchExistedAccountBookRecord *record in accountBookList) {
        NSString *accountBookID = record.accountBookID;
        [ServiceFactory createDirectoryForUserAccount:statusManager.userID accountBookID:accountBookID];
        NSString *downloadDatabasePath = [ServiceFactory getAccountBookDatabasePath:statusManager.userID accountBookID:accountBookID];
        
        if (YES == [fileManager fileExistsAtPath:downloadDatabasePath]) {
            continue;
        }
        
        hasFetchAllAccountBooks = NO;
        
        ConnectCommandRequest *request = [[[ConnectCommandRequest alloc] init] autorelease];
        request.deviceUUID = statusManager.deviceUUID;
        request.syncVersion = [NSString stringWithFormat:@"%lld", (long long)databaseVersion];
        request.token = statusManager.syncToken;
        request.accountBookID = accountBookID;
        request.syncNode = @"";
        request.uploadDatabaseFile = uploadDatabasePath;
        request.downloadDatabaseFile = downloadDatabasePath;
        request.serviceURL = record.accountBookSyncHost;
        request.pieceServiceURL = [NSString stringWithFormat:@"%@/sync/piece", record.innerSyncHost];
        request.dataType = JCH_DATA_TYPE;
        
        id<LargeDatabaseSyncService> largeDataSyncService = [[ServiceFactory sharedInstance] largeDatabaseSyncService];
        [largeDataSyncService connectCommand:request responseNotification:kJCHSyncConnectCommandNotification];
        
        break;
    }

    
    // 已获取所有的账本数据，完成登录操作
    if (YES == hasFetchAllAccountBooks) {
        
        //更新对应账本的状态
        [ServiceFactory updateBookInfoInAllAccountBook:statusManager.userID block:^BookInfoRecord4Cocoa *(NSString *bookID, BookInfoRecord4Cocoa *bookInfo) {
            for (NSString *currentBookId in [self.accountBookStatusForBookId allKeys]) {
                if ([bookID isEqualToString:currentBookId]) {
                    if (bookInfo.bookStatus != [self.accountBookStatusForBookId[currentBookId] integerValue]) {
                        bookInfo.bookStatus = [self.accountBookStatusForBookId[currentBookId] integerValue];
                    }
                    return bookInfo;
                }
            }
            return bookInfo;
        }];
        

        
        //查询增值服务购买信息
        [self doQueryAddedServiceInfo];
    }
}

- (void)handleFetchAllAccountBookList:(NSNotification *)notify
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
            NSLog(@"connect account books fail.");
            [MBProgressHUD showHUDWithTitle:@"登录失败"
                                     detail:responseDescription
                                   duration:2
                                       mode:MBProgressHUDModeText
                                 completion:nil];
            return;
        } else {
            //! @todo
            // your code here
            
            // 获取账本
            [self doFetchAllAccountBookList:self.accountBookList
                         uploadDatabasePath:self.uploadDatabasePath
                            databaseVersion:self.currentDatabaseVersion];
            
            NSLog(@"sucess.");
        }
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
        [MBProgressHUD showNetWorkFailedHud:@"登录失败"];
    }
}



//从服务器获取用户信息
- (void)doQueryUserProfile
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    QueryUserProfileRequest *request = [[[QueryUserProfileRequest alloc] init] autorelease];
    request.serviceURL = [NSString stringWithFormat:@"%@/terminal/profile", kJCHUserManagerServerIP];
    request.token = statusManager.syncToken;
    request.deviceUUID = statusManager.deviceUUID;
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService queryUserProfile:request responseNotification:kJCHSyncQueryUserProfileCommandNotification];
    
    return;
}

- (void)handleQueryUserProfile:(NSNotification *)notify
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
            NSLog(@"query user profile fail.");
            [MBProgressHUD showHUDWithTitle:@"登录失败"
                                     detail:@"获取用户信息失败"
                                   duration:2
                                       mode:MBProgressHUDModeText
                                 completion:nil];
            return;
        } else {
            NSDictionary *serviceResponse = responseData[@"data"];
            
            QueryUserProfileResponse *response = [[[QueryUserProfileResponse alloc] init] autorelease];
            response.cellphone = serviceResponse[@"cellphone"];                   // 手机
            response.email = serviceResponse[@"email"];                           // 邮箱
            response.nickname = serviceResponse[@"nickname"];                     // 昵称
            response.avatarUrl = serviceResponse[@"avatarUrl"];                   // 头像地址
            response.realname = serviceResponse[@"realname"];                     // 真实姓名
            response.signature = serviceResponse[@"signature"];                   // 签名
            response.province = serviceResponse[@"province"];                     // 省
            response.city = serviceResponse[@"city"];                             // 市
            response.district = serviceResponse[@"district"];                     // 区
            response.job = serviceResponse[@"job"];                               // 工作
            response.genderType = [serviceResponse[@"gender"] integerValue];      // 性别，0为男，1为女
            
            
            JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
            statusManager.userName = response.nickname;
            statusManager.headImageName = [JCHImageUtility getAvatarImageNameFromAvatarUrl:response.avatarUrl];
            statusManager.hasUserAutoSilentRegisteredOnThisDevice = YES;
            [JCHSyncStatusManager writeToFile];
            
            JCHUserInfoHelper *userInfoHelper = [JCHUserInfoHelper shareHelper];
            NSMutableArray *userIDs = [NSMutableArray arrayWithArray:[userInfoHelper getUserInfo]];
            if (![userIDs containsObject:statusManager.userID]) {
                [userIDs addObject:statusManager.userID];
            }
            [userInfoHelper setUserInfo:userIDs];
            
            //FIXME: UserInfo
            //根据从服务器获取的用户信息更新bookMember中的用户信息
#if 0
            id <BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
            BookMemberRecord4Cocoa *bookMemberRecord = [bookMemberService queryBookMemberWithUserID:statusManager.userID];
            bookMemberRecord.avatarUrl      = response.avatarUrl;      // 成员头像地址
            bookMemberRecord.nickname       = response.nickname;       // 昵称
            bookMemberRecord.phone          = response.cellphone;      // 手机联系方式
            bookMemberRecord.province       = response.province;       // 所在省份
            bookMemberRecord.city           = response.city;           // 所在城市
            bookMemberRecord.region         = response.district;       // 所在区
            bookMemberRecord.signature      = response.signature;      // 个性签名
            bookMemberRecord.email          = response.email;          // 联系邮箱
            [ServiceFactory updateBookMemberInAllAccountBook:statusManager.userID bookMember:bookMemberRecord];
#endif
            if (self.accountBookList.count != 0) {
                
                [self handleSwitchController];

            } else {
                
#if MMR_BASE_VERSION
                [self handleSwitchController];
#else
                // 行业版查询账本权限
                [MBProgressHUD hideAllHudsForWindow];
                [self handleQueryVIPAccountBookAuthority];
#endif
            }
            
            return;
        }

    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
        [MBProgressHUD showNetWorkFailedHud:@"登录失败"];
    }
}

- (void)handleSwitchController
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    //由appDelegate处理跳转页面
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    [appDelegate switchToHomePage:self completion:nil];
    
    NSString *imageInterHostIP = nil;
    for (FetchExistedAccountBookRecord *record in self.accountBookList) {
        NSString *accountBookID = record.accountBookID;
        NSString *interHost = record.innerSyncHost;
        if ([statusManager.accountBookID isEqualToString:accountBookID]) {
            imageInterHostIP = interHost;
            statusManager.imageInterHostIP = imageInterHostIP;
            [JCHSyncStatusManager writeToFile];
        }
    }
    //同步图片
    JCHDataSyncManager *dataSyncManager = [JCHDataSyncManager shareInstance];
    [dataSyncManager doSyncImageFiles:imageInterHostIP];
    
    //从金融页面验证失败后跳转过来，登录成功后发送通知
    [JCHNotificationCenter postNotificationName:kJCHHTMLViewControllerLoginSuccessNotification object:nil];
    
    // 发送用户登录统计
    [[JCHStatisticsManager sharedInstance] loginStatistics];
    
    // 登录成功，启动自动同步
    [appDelegate stopAutoSyncTimer];
    [appDelegate startAutoSyncTimer];
    [MBProgressHUD showHUDWithTitle:@"登录成功" detail:nil duration:1 mode:MBProgressHUDModeText completion:nil];
    
#if MMR_TAKEOUT_VERSION
    // 登录成功，设置推送账号
    [MiPushSDK setAccount:statusManager.accountBookID];
#endif
}

#pragma mark - // ===================================== 同步管理服务器 - 获取会员的账本权限 ===================== //
- (void)handleQueryVIPAccountBookAuthority
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    QueryVIPAccountBookAuthorityRequest *request = [[[QueryVIPAccountBookAuthorityRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.token = statusManager.syncToken;
    request.bookType = JCH_BOOK_TYPE;
    request.serviceURL = [NSString stringWithFormat:@"%@/terminal/memberConfig", kJCHSyncManagerServerIP];
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService queryVIPAccountBookAuthority:request callback:^(id response) {
        
        NSDictionary *data = response;
        
        if (kJCHServiceSuccess == [data[@"status"] integerValue]) {
            NSDictionary *responseData = data[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                //! @todo
                [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"%ld", responseCode]
                                         detail:responseDescription
                                       duration:kJCHDefaultShowHudTime
                                           mode:MBProgressHUDModeText
                                     completion:nil];
            } else {
                NSLog(@"responseData = %@", responseData);
                
                NSInteger bookCount = [responseData[@"data"][@"bookCount"] integerValue];
                if (bookCount == 0) {
                    [MBProgressHUD hideAllHudsForWindow];
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您暂无行业版使用权限，请登录买卖人官网www.maimairen.com进行购买" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        [JCHSyncStatusManager clearStatus];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }];
                    UIAlertAction *switchAction = [UIAlertAction actionWithTitle:@"购买" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        NSURL *url = [NSURL URLWithString:@"http://www.maimairen.com"];
                        if ([[UIApplication sharedApplication] canOpenURL:url]) {
                            [[UIApplication sharedApplication] openURL:url];
                        }
                    }];
                    [alertController addAction:cancelAction];
                    [alertController addAction:switchAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                } else {
                    [self handleSwitchController];
                }
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            [MBProgressHUD showNetWorkFailedHud:nil];
        }
    }];
}


// 自动注册完成，跳转页面
- (void)handleAutoRegisterCompleteInAppDelegate:(NSNotification *)notify
{
    [MBProgressHUD hideAllHudsForWindow];
    [self doFetchAllUserAccountBooks];
}

- (void)handleAutoRegisterFailedInAppDelegate:(NSNotification *)notify
{
    if ([MBProgressHUD getHudShowingStatus]) {
        [MBProgressHUD showHUDWithTitle:@""
                                 detail:@"登录失败，请重试"
                               duration:kJCHDefaultShowHudTime
                                   mode:MBProgressHUDModeText
                             completion:nil];
    }
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    statusManager.userID = @"";
    [JCHSyncStatusManager writeToFile];
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
            
        } else {
            //! @todo
            NSDictionary *serviceResponse = responseData[@"data"];
            NSInteger level = [[NSString stringWithFormat:@"%@", serviceResponse[@"level"]] integerValue];
            NSString *endTime = [NSString stringWithFormat:@"%@", serviceResponse[@"endTime"]];
            
            JCHAddedServiceManager *addedServiceManager = [JCHAddedServiceManager shareInstance];
            addedServiceManager.level = level;
            addedServiceManager.endTime = endTime;
        }
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
    }
    
    //从服务器获取用户信息
    [self doQueryUserProfile];
}


- (void)handleApplicationWillEnterForeground
{
    [super handleApplicationWillEnterForeground];
    
    if (![_userNameTextField.text isEmptyString] && ![_passwordTextField.text isEmptyString]) {
        [self handleLogin];
    }
}



@end


