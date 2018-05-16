//
//  JCHIdentifyCodeViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/9.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHIdentifyCodeViewController.h"
#import "JCHResetPasswordViewController.h"
#import "JCHInputAccessoryView.h"
#import "JCHUIFactory.h"
#import "JCHUISettings.h"
#import "JCHUISizeSettings.h"
#import "JCHColorSettings.h"
#import "JCHSizeUtility.h"
#import "UIImage+JCHImage.h"
#import "JCHUserInfoHelper.h"
#import "ServiceFactory.h"
#import "JCHSyncStatusManager.h"
#import "JCHSyncServerSettings.h"
#import "JCHServiceResponseSettings.h"
#import "JCHServiceResponseNotification.h"
#import "MBProgressHUD+JCHHud.h"
#import "CommonHeader.h"
#import <Masonry.h>
#import <AFNetworking.h>

@interface JCHIdentifyCodeViewController ()
{
    UITextField *_phoneTextField;
    UITextField *_identifyCodeTextField;
    UIButton *_nextStepButton;
    UIButton *_getCodeButton;
    NSTimer *_timer;
    NSInteger _count;
}
@end

@implementation JCHIdentifyCodeViewController


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self registerResponseNotificationHandler];
        _count = 60;
        self.title = @"获取验证码";
    }
    return self;
}

- (void)dealloc
{
    [self.phoneNumber release];
    [self unregisterResponseNotificationHandler];
    
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self doSendMobileCAPTCHAForGetPassword:self.phoneNumber];

    [self createUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _getCodeButton.enabled = YES;
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;

    UILabel *textLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@"我们正在发送验证码短信至你的手机，接收短信大概需要60s。"
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
    
    UIFont *titleFont = [UIFont systemFontOfSize:16.0f];
    const CGFloat prefixLabelWidth = 60;
    
    UILabel *prefixLabel = [JCHUIFactory createLabel:CGRectZero
                                               title:@"+86"
                                                font:titleFont
                                           textColor:JCHColorMainBody
                                              aligin:NSTextAlignmentCenter];
    [containerView addSubview:prefixLabel];
    
    [prefixLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView);
        make.width.mas_equalTo(prefixLabelWidth);
        make.top.equalTo(containerView);
        make.height.mas_equalTo(containerViewHeight / 2);
    }];

    
    const CGRect inputAccessoryFrame = CGRectMake(0, 0, self.view.frame.size.width, kJCHInputAccessoryViewHeight);
    const CGFloat leftMargin = 16;
    
    UIView *horizontalLine = [[[UIView alloc] init] autorelease];
    horizontalLine.backgroundColor = JCHColorSeparateLine;
    [containerView addSubview:horizontalLine];
    
    [horizontalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView).with.offset(leftMargin);
        make.right.equalTo(containerView).with.offset(-leftMargin);
        make.top.equalTo(containerView).with.offset(containerViewHeight / 2);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    _phoneTextField = [JCHUIFactory createTextField:CGRectZero
                                        placeHolder:nil
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentLeft];
    _phoneTextField.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:@"输入手机号"
                                                                             attributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xd5d5d5), NSFontAttributeName : titleFont}] autorelease];
    _phoneTextField.font = titleFont;
    _phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_phoneTextField addTarget:self action:@selector(textFieldIsEditing:) forControlEvents:UIControlEventEditingChanged];
    _phoneTextField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
    _phoneTextField.text = self.phoneNumber;
    [containerView addSubview:_phoneTextField];
    
    [_phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(prefixLabel.mas_right).with.offset(leftMargin);
        make.right.equalTo(containerView).with.offset(-leftMargin);
        make.top.equalTo(containerView);
        make.height.mas_equalTo(containerViewHeight / 2);
    }];
    
    const CGFloat identifyCodeTextFieldWidth = [JCHSizeUtility calculateWidthWithSourceWidth:216.0f];
    _identifyCodeTextField = [JCHUIFactory createTextField:CGRectZero
                                               placeHolder:nil
                                                 textColor:JCHColorMainBody
                                                    aligin:NSTextAlignmentLeft];
    _identifyCodeTextField.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:@"输入验证码" attributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xd5d5d5), NSFontAttributeName : titleFont}] autorelease];
    _identifyCodeTextField.font = titleFont;
    _identifyCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _identifyCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _identifyCodeTextField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
    [_identifyCodeTextField addTarget:self action:@selector(textFieldIsEditing:) forControlEvents:UIControlEventEditingChanged];
    [containerView addSubview:_identifyCodeTextField];
    
    [_identifyCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView).with.offset(leftMargin);
        make.width.mas_equalTo(identifyCodeTextFieldWidth);
        make.top.equalTo(prefixLabel.mas_bottom);
        make.height.mas_equalTo(containerViewHeight / 2);
    }];
    
    
    _getCodeButton = [JCHUIFactory createButton:CGRectZero
                                                  target:self
                                                  action:@selector(getCode)
                                                   title:@"重新获取验证码"
                                              titleColor:UIColorFromRGB(0x4c8cdf)
                                         backgroundColor:nil];
    _getCodeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_getCodeButton setTitle:@"正在发送验证码" forState:UIControlStateDisabled];
    [_getCodeButton setTitleColor:JCHColorMainBody forState:UIControlStateDisabled];
    _getCodeButton.enabled = NO;
    [containerView addSubview:_getCodeButton];
    
    [_getCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_identifyCodeTextField.mas_right);
        make.right.equalTo(containerView);
        make.top.equalTo(_phoneTextField.mas_bottom);
        make.bottom.equalTo(_identifyCodeTextField);
    }];
    
    const CGFloat nextStepButtonTopOffset = 18;
    const CGFloat nextStepButtonHeight = 50;
    _nextStepButton = [JCHUIFactory createButton:CGRectZero
                                          target:self
                                          action:@selector(handleNextStep)
                                           title:@"下一步"
                                      titleColor:nil
                                 backgroundColor:[UIColor whiteColor]];
    [_nextStepButton setTitleColor:UIColorFromRGB(0xd5d5d5) forState:UIControlStateDisabled];
    [_nextStepButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateDisabled];
    [_nextStepButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_nextStepButton setBackgroundImage:[UIImage imageWithColor:JCHColorHeaderBackground] forState:UIControlStateNormal];
    _nextStepButton.layer.cornerRadius = 4;
    _nextStepButton.clipsToBounds = YES;
    _nextStepButton.enabled = NO;
    
    [self.view addSubview:_nextStepButton];
    
    [_nextStepButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(containerView.mas_bottom).with.offset(nextStepButtonTopOffset);
        make.height.mas_equalTo(nextStepButtonHeight);
        make.left.equalTo(containerView).with.offset(kStandardLeftMargin);
        make.right.equalTo(containerView).with.offset(-kStandardLeftMargin);
    }];
}

- (void)handleNextStep
{
    [self.view endEditing:YES];
    [self doVerifyMobileCAPTCHA:_phoneTextField.text captchaCode:_identifyCodeTextField.text];
}

- (void)textFieldIsEditing:(UITextField *)textField
{
    if (![_phoneTextField.text isEqualToString:@""] && ![_identifyCodeTextField.text isEqualToString:@""]) {
        _nextStepButton.enabled = YES;
    }
    else
    {
        _nextStepButton.enabled = NO;
    }
}

- (void)getCode
{
    
    [self.view endEditing:YES];
    
    NSPredicate *phonePredicate = [NSPredicate predicateWithFormat:@"self matches %@", kPhoneNumberPredicate];
    if (![phonePredicate evaluateWithObject:_phoneTextField.text]) {
        [MBProgressHUD showHUDWithTitle:nil detail:@"手机号码有误！" duration:1 mode:MBProgressHUDModeText completion:nil];
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
            
            [self doSendMobileCAPTCHAForGetPassword:_phoneTextField.text];
            [manager stopMonitoring];
            [manager setReachabilityStatusChangeBlock:nil];
        }
    }];
}

- (void)handleCountdown
{
    if (_count == 0) {
        _getCodeButton.enabled = YES;
        [_timer invalidate];
        _timer = nil;
    }
    else
    {
        NSString *text = [NSString stringWithFormat:@"%lds", (long)_count];
        [_getCodeButton setTitle:text forState:UIControlStateDisabled];
    }
    _count--;
}

#pragma mark - IdentifyCodeNotificationAndMethod

- (void)registerResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter addObserver:self
                           selector:@selector(handleSendMobileCAPTCHA:)
                               name:kJCHSendMobileCAPTCHANotification
                             object:[UIApplication sharedApplication]];

    [notificationCenter addObserver:self
                           selector:@selector(handleVerifyMobileCAPTCHA:)
                               name:kJCHVerifyMobileCAPTCHANotification
                             object:[UIApplication sharedApplication]];
}

- (void)unregisterResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter removeObserver:self
                                  name:kJCHSendMobileCAPTCHANotification
                                object:[UIApplication sharedApplication]];

    [notificationCenter removeObserver:self
                                  name:kJCHVerifyMobileCAPTCHANotification
                                object:[UIApplication sharedApplication]];
}

// ===================================== 用户管理服务器 - 获取验证码 ========================= //

- (void)doSendMobileCAPTCHAForGetPassword:(NSString *)phoneNumber
{
    SendCAPTCHARequest *request = [[[SendCAPTCHARequest alloc] init] autorelease];
    request.serviceURL = [NSString stringWithFormat:@"%@/terminal/code", kJCHUserManagerServerIP];
    request.phoneNumber = phoneNumber;
    request.requestType = @"getpwd";  // regist、getpwd
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService sendMobileCAPTCHA:request responseNotification:kJCHSendMobileCAPTCHANotification];
    
    return;
}

- (void)handleSendMobileCAPTCHA:(NSNotification *)notify
{
    NSDictionary *userData = notify.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        NSString *responseDescription = responseData[@"desc"];
        NSString *responseStatus = responseData[@"status"];
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
        
        [MBProgressHUD showHudWithStatusCode:responseCode
                                   sceneType:kJCHMBProgressHUDSceneTypeCaptchaCode];

        if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
            //! @todo
            NSLog(@"send captcha fail.");
            
            
            
            if (_timer.valid) {
                [_timer invalidate];
                _timer = nil;
            }
            
            _getCodeButton.enabled = YES;
            
            return;
        } else {
            SendCAPTCHAResponse *response = [[[SendCAPTCHAResponse alloc] init] autorelease];
            response.code = responseCode;
            response.descriptionString = responseDescription;
            response.status = responseStatus;
            
            //! @todo
            // your code here
            
            //倒计时
            _count = 60;
            _getCodeButton.enabled = NO;
            [self handleCountdown];
            
            if (_timer.valid) {
                [_timer invalidate];
                _timer = nil;
            }
            _timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                      target:self
                                                    selector:@selector(handleCountdown)
                                                    userInfo:nil
                                                     repeats:YES];
        }
        
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
    }
}

// ===================================== 用户管理服务器 - 验证验证码 ======================== //
- (void)doVerifyMobileCAPTCHA:(NSString *)phoneNumber captchaCode:(NSString *)captchaCode
{
    VerifyMobileCAPTCHARequest *request = [[[VerifyMobileCAPTCHARequest alloc] init] autorelease];
    request.serviceURL = [NSString stringWithFormat:@"%@/terminal/codeCheck", kJCHUserManagerServerIP];
    request.phoneNumber = phoneNumber;
    request.requestType = @"getpwd";
    request.captchaCode = captchaCode;
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService verifyMobileCAPTCHA:request responseNotification:kJCHVerifyMobileCAPTCHANotification];
    
    return;
}


- (void)handleVerifyMobileCAPTCHA:(NSNotification *)notify
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
            NSLog(@"verifyMobileCaptcha fail.");
            [MBProgressHUD showHudWithStatusCode:responseCode sceneType:kJCHMBProgressHUDSceneTypeCaptchaCode];
            return;
        } else {
            NSDictionary *serviceResponse = responseData[@"data"];
            NSString *code = serviceResponse[@"code"];
            
            VerifyMobileCAPTCHAResponse *response = [[[VerifyMobileCAPTCHAResponse alloc] init] autorelease];
            response.code = responseCode;
            response.descriptionString = responseDescription;
            response.status = responseStatus;
            response.captchaCode = code;
            
            
            //! @todo
            // your code here
            JCHResetPasswordViewController *resetPasswordVC = [[[JCHResetPasswordViewController alloc] init] autorelease];
            resetPasswordVC.phoneNumber = _phoneTextField.text;
            resetPasswordVC.identifyCode = code;
            [self.navigationController pushViewController:resetPasswordVC animated:YES];
        }
        

    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
        [MBProgressHUD showNetWorkFailedHud:@"验证失败"];
    }
}

@end
