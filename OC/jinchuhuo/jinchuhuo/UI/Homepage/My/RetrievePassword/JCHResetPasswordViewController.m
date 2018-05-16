//
//  JCHResetPasswordViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/9.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHResetPasswordViewController.h"
#import "JCHInputAccessoryView.h"
#import "JCHUIFactory.h"
#import "JCHColorSettings.h"
#import "JCHSizeUtility.h"
#import "JCHUISettings.h"
#import "JCHUISizeSettings.h"
#import "UIImage+JCHImage.h"
#import "ServiceFactory.h"
#import "JCHSyncStatusManager.h"
#import "JCHSyncServerSettings.h"
#import "JCHServiceResponseSettings.h"
#import "JCHServiceResponseNotification.h"
#import "MBProgressHUD+JCHHud.h"
#import "CommonHeader.h"
#import <Masonry.h>
#import <AFNetworking.h>

@interface JCHResetPasswordViewController ()
{
    UIButton *_loginButton;
    UITextField *_passwordTextField;
    UITextField *_passwordVerifyTextField;
}
@end

@implementation JCHResetPasswordViewController


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
    [self.phoneNumber release];
    [self.identifyCode release];
    [self unregisterResponseNotificationHandler];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;

    
    NSString *text = [NSString stringWithFormat:@"请设置密码，之后你可以使用手机号%@和密码登录买卖人。", self.phoneNumber];
    UILabel *textLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:text
                                              font:[UIFont systemFontOfSize:16]
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentLeft];
    textLabel.numberOfLines = 2;
    [self.view addSubview:textLabel];
    
    const CGFloat textLabelHeight = 50;
    const CGFloat textLabelTopOffset = 30;
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(kStandardLeftMargin);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(textLabelTopOffset);
        make.height.mas_equalTo(textLabelHeight);
    }];
    
    const CGFloat containerViewTopOffset = 20;
    const CGFloat containerViewHeight = 100;
    
    UIView *containerView = [[[UIView alloc] init] autorelease];
    containerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:containerView];
    
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textLabel.mas_bottom).with.offset(containerViewTopOffset);
        make.height.mas_equalTo(containerViewHeight);
        make.left.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];
    
    [containerView addSeparateLineWithMasonryTop:YES bottom:YES];
    
    const CGFloat userNameImageViewWidth = 80;
    UILabel *passwordTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                      title:@"密码"
                                                       font:[UIFont systemFontOfSize:17]
                                                  textColor:JCHColorMainBody
                                                     aligin:NSTextAlignmentLeft];
    [containerView addSubview:passwordTitleLabel];
    
    [passwordTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView).with.offset(kStandardLeftMargin);
        make.top.equalTo(containerView);
        make.height.mas_equalTo(containerViewHeight / 2);
        make.width.mas_equalTo(userNameImageViewWidth);
    }];
    
    UILabel *passwordVerifyTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                            title:@"确认密码"
                                                             font:[UIFont systemFontOfSize:17]
                                                        textColor:JCHColorMainBody
                                                           aligin:NSTextAlignmentLeft];
    [containerView addSubview:passwordVerifyTitleLabel];
    
    [passwordVerifyTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(passwordTitleLabel);
        make.right.equalTo(passwordTitleLabel);
        make.top.equalTo(passwordTitleLabel.mas_bottom);
        make.bottom.equalTo(containerView);
    }];
    
    const CGRect inputAccessoryFrame = CGRectMake(0, 0, self.view.frame.size.width, kJCHInputAccessoryViewHeight);
    UIFont *textFieldFont = [UIFont systemFontOfSize:16];
    _passwordTextField = [JCHUIFactory createTextField:CGRectZero placeHolder:nil textColor:JCHColorMainBody aligin:NSTextAlignmentLeft];
    _passwordTextField.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:@"请输入密码" attributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xd5d5d5), NSFontAttributeName : textFieldFont}] autorelease];
    _passwordTextField.font = textFieldFont;
    _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passwordTextField.keyboardType = UIKeyboardTypeASCIICapable;
    _passwordTextField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
    _passwordTextField.secureTextEntry = YES;
    [_passwordTextField addTarget:self action:@selector(textFieldIsEditing:) forControlEvents:UIControlEventEditingChanged];
    [containerView addSubview:_passwordTextField];
    
    [_passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(passwordTitleLabel.mas_right);
        make.top.equalTo(passwordTitleLabel);
        make.bottom.equalTo(passwordTitleLabel);
        make.right.equalTo(containerView);
    }];
    
    UIView *middleLine = [[[UIView alloc] init] autorelease];
    middleLine.backgroundColor = JCHColorSeparateLine;
    [self.view addSubview:middleLine];
    
    [middleLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(passwordTitleLabel);
        make.right.equalTo(_passwordTextField).with.offset(-kStandardLeftMargin);
        make.bottom.equalTo(_passwordTextField);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    _passwordVerifyTextField = [JCHUIFactory createTextField:CGRectZero placeHolder:nil textColor:JCHColorMainBody aligin:NSTextAlignmentLeft];
    _passwordVerifyTextField.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:@"请再次输入" attributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xd5d5d5), NSFontAttributeName : textFieldFont}] autorelease];
    _passwordVerifyTextField.font = textFieldFont;

    _passwordVerifyTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passwordVerifyTextField.keyboardType = UIKeyboardTypeASCIICapable;
    _passwordVerifyTextField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
    [_passwordVerifyTextField addTarget:self action:@selector(textFieldIsEditing:) forControlEvents:UIControlEventEditingChanged];
    _passwordVerifyTextField.secureTextEntry = YES;
    [containerView addSubview:_passwordVerifyTextField];
    
    [_passwordVerifyTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_passwordTextField);
        make.right.equalTo(_passwordTextField);
        make.top.equalTo(_passwordTextField.mas_bottom);
        make.bottom.equalTo(containerView);
    }];
    
    
    const CGFloat loginButtonTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:YES sourceHeight:18.0f];
    const CGFloat loginButtonHeight = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:YES sourceHeight:50.0f];
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
}

- (void)handleLogin
{
    [self.view endEditing:YES];
    
    if (![_passwordTextField.text isEqualToString:_passwordVerifyTextField.text]) {
       
        [MBProgressHUD showHUDWithTitle:nil detail:@"两次密码输入不一致,请重新输入!" duration:1 mode:MBProgressHUDModeText completion:nil];
        return;
    }
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager startMonitoring];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"networkChagne");
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
            NSLog(@"没有网络");
            [MBProgressHUD showHUDWithTitle:@"网络错误" detail:@"请检查当前网络状况" duration:1 mode:MBProgressHUDModeText completion:nil];
        } else {
            NSLog(@"有网络");
            
            [self doModifyLoginPassword:self.phoneNumber password:_passwordTextField.text captchaCode:self.identifyCode];
            
            [manager stopMonitoring];
            [manager setReachabilityStatusChangeBlock:nil];
        }
    }];
    
}

- (void)textFieldIsEditing:(UITextField *)textField
{
    if (![_passwordTextField.text isEqualToString:@""] && ![_passwordVerifyTextField.text isEqualToString:@""])
    {
        _loginButton.enabled = YES;
    }
    else
    {
        _loginButton.enabled = NO;
    }
}


#pragma mark - ResetPasswordNotificationAndMethod

- (void)registerResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
   
    [notificationCenter addObserver:self
                           selector:@selector(handleModifyLoginPassword:)
                               name:kJCHModifyLoginPasswordNotification
                             object:[UIApplication sharedApplication]];
}

- (void)unregisterResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter removeObserver:self
                                  name:kJCHModifyLoginPasswordNotification
                                object:[UIApplication sharedApplication]];
}

// ===================================== 用户管理服务器 - 修改密码 ========================== //
- (void)doModifyLoginPassword:(NSString *)userName password:(NSString *)password captchaCode:(NSString *)captchaCode
{
    ModifyLoginPasswordRequest *request = [[[ModifyLoginPasswordRequest alloc] init] autorelease];
    request.serviceURL = [NSString stringWithFormat:@"%@/terminal/pwd1", kJCHUserManagerServerIP];
    request.userName = userName;
    request.userPassword = password;
    request.captchaCode = captchaCode;
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService modifyLoginPassword:request responseNotification:kJCHModifyLoginPasswordNotification];
    
    return;
}


- (void)handleModifyLoginPassword:(NSNotification *)notify
{
    NSDictionary *userData = notify.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        NSString *responseDescription = responseData[@"desc"];
        NSString *responseStatus = responseData[@"status"];
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
        
        [MBProgressHUD showHudWithStatusCode:responseCode sceneType:kJCHMBProgressHUDSceneTypeResetPassword];
      
        
        if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
            //! @todo
            NSLog(@"ModifyLoginPassword fail.");

            return;
        } else {
            ModifyLoginPasswordResponse *response = [[[ModifyLoginPasswordResponse alloc] init] autorelease];
            response.code = responseCode;
            response.descriptionString = responseDescription;
            response.status = responseStatus;
            
            JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
            statusManager.lastUserInfo = @{@"userName" : self.phoneNumber, @"password" : @""};
            [JCHSyncStatusManager writeToFile];
            //! @todo
            // your code here
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            [MBProgressHUD showHUDWithTitle:@"重置密码成功" detail:nil duration:1 mode:MBProgressHUDModeText completion:nil];
        }
        
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
        [MBProgressHUD showNetWorkFailedHud:@"重置密码失败"];
    }
}


@end
