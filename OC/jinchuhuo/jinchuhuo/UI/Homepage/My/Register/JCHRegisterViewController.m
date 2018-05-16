//
//  JCHRegisterViewController.m
//  jinchuhuo
//
//  Created by apple on 15/8/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHRegisterViewController.h"
#import "JCHHTMLViewController.h"
#import "JCHGuideFirstViewController.h"
#import "JCHClauseViewController.h"
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
#import "JCHControllerNavigationSettings.h"
#import "AppDelegate.h"
#import "MBProgressHUD+JCHHud.h"
#import "JCHImageUtility.h"
#import "CommonHeader.h"
#import <Masonry.h>
#import <AFNetworking.h>
#import <TTTAttributedLabel.h>

@interface JCHRegisterViewController () <TTTAttributedLabelDelegate>
{
    UIButton *_commitButton;
    UITextField *_phoneTextField;
    UITextField *_identifyCodeTextField;
    UIButton *_getCodeButton;
    UIButton *_listenCodeButton;
    UITextField *_passwordTextField;
    UIButton *_agreeAlauseButton;
    UIView *_identifyContainerView;
    UIView *_buttonIndicatorView;
    UIButton *_messageButton;
    UIButton *_voiceButton;
}

@property (nonatomic, retain) MBProgressHUD *hud;
@property (nonatomic, retain) NSTimer *getCodeButtonTimer;
@property (nonatomic, retain) NSTimer *listenCodeButtonTimer;
@property (nonatomic, assign) NSInteger getCodeCount;
@property (nonatomic, assign) NSInteger listenCodeCount;

@property (nonatomic, retain) JCHKeyboardUtility *keyboardUtility;

@end

@implementation JCHRegisterViewController

- (id)init
{
    self = [super init];
    if (self) {
        // pass
        [self registerResponseNotificationHandler];
    }
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [(AppDelegate *)[UIApplication sharedApplication].delegate setEnableHandlingAutoRegisterResponse:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [(AppDelegate *)[UIApplication sharedApplication].delegate setEnableHandlingAutoRegisterResponse:NO];
}

- (void)dealloc
{
    
    [self unregisterResponseNotificationHandler];
    [self.hud release];
    [self.phoneNumber release];
    [self.getCodeButtonTimer release];
    [self.listenCodeButtonTimer release];
    [self.keyboardUtility release];
    
    [super dealloc];
    return;
}

- (void)loadView
{
    CGRect viewFrame = [[UIScreen mainScreen] applicationFrame];
    viewFrame.origin = CGPointMake(0.0f, 0.0f);
    self.view = [[[UIView alloc] initWithFrame:viewFrame] autorelease];
    
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"注册";
    self.view.backgroundColor = JCHColorGlobalBackground;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    [self createUI];
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    statusManager.enableAutoSync = NO;
    
    return;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}


- (void)createUI
{
    UIFont *titleFont = [UIFont jchSystemFontOfSize:16.0f];
    CGFloat containerViewTopOffset = [JCHSizeUtility calculateHeightFor4SAndOther:8.0f];
    CGFloat containerViewBottomOffset = [JCHSizeUtility calculateHeightFor4SAndOther:20];
    CGFloat standardContainerViewHeight = [JCHSizeUtility calculateHeightFor4SAndOther:50];
    
    UILabel *phonePromptLabel = [JCHUIFactory createLabel:CGRectZero
                                                    title:@"输入手机号码"
                                                     font:[UIFont jchSystemFontOfSize:13.0f]
                                                textColor:JCHColorMainBody
                                                   aligin:NSTextAlignmentLeft];
    [self.view addSubview:phonePromptLabel];
    
    CGSize fitSize = [phonePromptLabel sizeThatFits:CGSizeZero];
    
    [phonePromptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(containerViewBottomOffset);
        make.left.equalTo(self.view).with.offset(kStandardLeftMargin);
        make.height.mas_equalTo(fitSize.height);
        make.width.mas_equalTo(fitSize.width);
    }];
    
    UIView *phoneContainerView = [[[UIView alloc] init] autorelease];
    phoneContainerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:phoneContainerView];
    
    [phoneContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(phonePromptLabel.mas_bottom).with.offset(containerViewTopOffset);
        make.height.mas_equalTo(standardContainerViewHeight);
        make.left.and.right.equalTo(self.view);
    }];
    
    [phoneContainerView addSeparateLineWithMasonryTop:YES bottom:YES];
    
    const CGFloat prefixLabelWidth = 60.0f;
    
    UILabel *prefixLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@"+86"
                                           font:titleFont
                                      textColor:JCHColorMainBody
                                         aligin:NSTextAlignmentCenter];
    [phoneContainerView addSubview:prefixLabel];
    
    [prefixLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(phoneContainerView);
        make.width.mas_equalTo(prefixLabelWidth);
        make.top.and.bottom.equalTo(phoneContainerView);
    }];
    
    const CGRect inputAccessoryFrame = CGRectMake(0, 0, self.view.frame.size.width, kJCHInputAccessoryViewHeight);

    _phoneTextField = [JCHUIFactory createTextField:CGRectZero
                                        placeHolder:nil
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentLeft];
    _phoneTextField.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:@"输入手机号" attributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xd5d5d5), NSFontAttributeName : titleFont}] autorelease];
    _phoneTextField.font = titleFont;
    _phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    _phoneTextField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
    _phoneTextField.text = self.phoneNumber;
    [_phoneTextField addTarget:self action:@selector(textFieldIsEditing:) forControlEvents:UIControlEventEditingChanged];
    [phoneContainerView addSubview:_phoneTextField];
    
    [_phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(prefixLabel.mas_right).with.offset(kStandardLeftMargin);
        make.right.equalTo(phoneContainerView).with.offset(-kStandardLeftMargin);
        make.top.and.bottom.equalTo(prefixLabel);
    }];

    
    UILabel *identifyCodePromptLabel = [JCHUIFactory createLabel:CGRectZero
                                                    title:@"选择验证码获取方式"
                                                     font:[UIFont jchSystemFontOfSize:13.0f]
                                                textColor:JCHColorMainBody
                                                   aligin:NSTextAlignmentLeft];
    [self.view addSubview:identifyCodePromptLabel];
    
    fitSize = [identifyCodePromptLabel sizeThatFits:CGSizeZero];
    
    [identifyCodePromptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(phoneContainerView.mas_bottom).with.offset(containerViewBottomOffset);
        make.left.equalTo(phonePromptLabel);
        make.height.mas_equalTo(fitSize.height);
        make.width.mas_equalTo(fitSize.width);
    }];
    
    _identifyContainerView = [[[UIView alloc] init] autorelease];
    _identifyContainerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_identifyContainerView];
    
    [_identifyContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(identifyCodePromptLabel.mas_bottom).with.offset(containerViewTopOffset);
        make.height.mas_equalTo(standardContainerViewHeight * 2);
        make.left.and.right.equalTo(self.view);
    }];
    
    [_identifyContainerView addSeparateLineWithMasonryTop:YES bottom:YES];
    
    _messageButton = [JCHUIFactory createButton:CGRectZero
                                         target:self
                                         action:@selector(handleSwitchIdentifyWay:)
                                          title:@"短信"
                                     titleColor:JCHColorAuxiliary
                                backgroundColor:nil];
    _messageButton.titleLabel.font = [UIFont jchSystemFontOfSize:16.0f];
    [_messageButton setTitleColor:JCHColorHeaderBackground forState:UIControlStateSelected];
    [_identifyContainerView addSubview:_messageButton];
    _messageButton.selected = YES;
    
    [_messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(_identifyContainerView);
        make.right.equalTo(_identifyContainerView.mas_centerX);
        make.bottom.equalTo(_identifyContainerView.mas_centerY);
    }];
    
    _voiceButton = [JCHUIFactory createButton:CGRectZero
                                       target:self
                                       action:@selector(handleSwitchIdentifyWay:)
                                        title:@"语音"
                                   titleColor:JCHColorAuxiliary
                              backgroundColor:nil];
    _voiceButton.titleLabel.font = [UIFont jchSystemFontOfSize:16.0f];
    [_voiceButton setTitleColor:JCHColorHeaderBackground forState:UIControlStateSelected];
    [_identifyContainerView addSubview:_voiceButton];
    
    [_voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.top.equalTo(_identifyContainerView);
        make.left.equalTo(_messageButton.mas_right);
        make.bottom.equalTo(_messageButton);
    }];
    
    _buttonIndicatorView = [[[UIView alloc] init] autorelease];
    _buttonIndicatorView.backgroundColor = JCHColorHeaderBackground;
    [_identifyContainerView addSubview:_buttonIndicatorView];
    
    [_buttonIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_identifyContainerView);
        make.width.mas_equalTo(_messageButton);
        make.bottom.equalTo(_messageButton);
        make.height.mas_equalTo(3);
    }];
    
    {
        UIView *horizontalLine = [[[UIView alloc] init] autorelease];
        horizontalLine.backgroundColor = JCHColorSeparateLine;
        
        [_identifyContainerView addSubview:horizontalLine];
        
        [horizontalLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(_identifyContainerView);
            make.bottom.equalTo(_messageButton);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }
    
    
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
    [_identifyContainerView addSubview:_identifyCodeTextField];
    
    [_identifyCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_identifyContainerView).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(identifyCodeTextFieldWidth);
        make.bottom.equalTo(_identifyContainerView);
        make.top.equalTo(_messageButton.mas_bottom);
    }];
    
    
    _getCodeButton = [JCHUIFactory createButton:CGRectZero
                                         target:self
                                         action:@selector(getCode:)
                                          title:@"获取验证码"
                                     titleColor:UIColorFromRGB(0x4c8cdf)
                                backgroundColor:nil];
    _getCodeButton.titleLabel.font = titleFont;
    [_getCodeButton setTitle:@"60s" forState:UIControlStateDisabled];
    [_getCodeButton setTitleColor:UIColorFromRGB(0xd5d5d5) forState:UIControlStateDisabled];
    [_identifyContainerView addSubview:_getCodeButton];
    
    [_getCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_identifyCodeTextField.mas_right);
        make.right.equalTo(_identifyContainerView);
        make.top.and.bottom.equalTo(_identifyCodeTextField);
    }];
    
    _listenCodeButton = [JCHUIFactory createButton:CGRectZero
                                            target:self
                                            action:@selector(getCode:)
                                             title:@"收听验证码"
                                        titleColor:UIColorFromRGB(0x4c8cdf)
                                   backgroundColor:nil];
    _listenCodeButton.titleLabel.font = titleFont;
    [_listenCodeButton setTitle:@"120s" forState:UIControlStateDisabled];
    [_listenCodeButton setTitleColor:UIColorFromRGB(0xd5d5d5) forState:UIControlStateDisabled];
    _listenCodeButton.hidden = YES;
    [_identifyContainerView addSubview:_listenCodeButton];
    
    [_listenCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_getCodeButton);
    }];
    

    UILabel *passwordPromptLabel = [JCHUIFactory createLabel:CGRectZero
                                                    title:@"设置登录密码"
                                                     font:[UIFont jchSystemFontOfSize:13.0f]
                                                textColor:JCHColorMainBody
                                                   aligin:NSTextAlignmentLeft];
    [self.view addSubview:passwordPromptLabel];
    
    fitSize = [passwordPromptLabel sizeThatFits:CGSizeZero];
    
    [passwordPromptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_identifyContainerView.mas_bottom).with.offset(containerViewBottomOffset);
        make.left.equalTo(self.view).with.offset(kStandardLeftMargin);
        make.height.mas_equalTo(fitSize.height);
        make.width.mas_equalTo(fitSize.width);
    }];
    
    UIView *passwordContainerView = [[[UIView alloc] init] autorelease];
    passwordContainerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:passwordContainerView];
    
    [passwordContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(passwordPromptLabel.mas_bottom).with.offset(containerViewTopOffset);
        make.height.mas_equalTo(standardContainerViewHeight);
        make.left.and.right.equalTo(self.view);
    }];
    
    [passwordContainerView addSeparateLineWithMasonryTop:YES bottom:YES];

    _passwordTextField = [JCHUIFactory createTextField:CGRectZero placeHolder:nil textColor:JCHColorMainBody aligin:NSTextAlignmentLeft];
    _passwordTextField.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:@"输入密码" attributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xd5d5d5), NSFontAttributeName : titleFont}] autorelease];
    _passwordTextField.font = titleFont;
    _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passwordTextField.keyboardType = UIKeyboardTypeASCIICapable;
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
     [_passwordTextField addTarget:self action:@selector(textFieldIsEditing:) forControlEvents:UIControlEventEditingChanged];
    [passwordContainerView addSubview:_passwordTextField];
    
    [_passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.equalTo(passwordContainerView);
        make.left.equalTo(passwordContainerView).with.offset(kStandardLeftMargin);
        make.right.equalTo(passwordContainerView).with.offset(-kStandardLeftMargin);
    }];
    
    
    const CGFloat selectedButtonTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:9.0f];
    const CGFloat selectedButtonHeight = 22.0f;
    

    _agreeAlauseButton = [JCHUIFactory createButton:CGRectZero
                                                   target:self
                                                   action:@selector(handleAgreeAlause:)
                                                    title:nil
                                               titleColor:nil
                                          backgroundColor:nil];
    [_agreeAlauseButton setImage:[UIImage imageNamed:@"register_btn_normal"] forState:UIControlStateNormal];
    [_agreeAlauseButton setImage:[UIImage imageNamed:@"register_btn_selected"] forState:UIControlStateSelected];
    _agreeAlauseButton.selected = YES;
    [self.view addSubview:_agreeAlauseButton];
    
    [_agreeAlauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(selectedButtonHeight);
        make.top.equalTo(passwordContainerView.mas_bottom).with.offset(selectedButtonTopOffset);
        make.height.mas_equalTo(selectedButtonHeight);
    }];
    
    TTTAttributedLabel *clauseLabel = [[[TTTAttributedLabel alloc] initWithFrame:CGRectZero] autorelease];
    clauseLabel.font = [UIFont systemFontOfSize:13.0f];
    clauseLabel.textColor = JCHColorMainBody;
    clauseLabel.delegate = self;
    clauseLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentCenter;
    clauseLabel.textAlignment = NSTextAlignmentLeft;
    clauseLabel.linkAttributes = @{(__bridge NSString *)kCTUnderlineStyleAttributeName : @(YES),
                                   (__bridge NSString *)kCTForegroundColorAttributeName : (id)JCHColorHeaderBackground.CGColor};
    
    
    NSString *text = @"我已阅读并同意用户隐私条款";
    clauseLabel.text = text;
    NSRange range = [clauseLabel.text rangeOfString:@"用户隐私条款"];
    
    //设置链接的url
    [clauseLabel addLinkToURL:nil withRange:range];
    
    [self.view addSubview:clauseLabel];
    
    [clauseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_agreeAlauseButton.mas_right);
        make.top.equalTo(_agreeAlauseButton);
        make.bottom.equalTo(_agreeAlauseButton);
        make.right.equalTo(self.view).with.offset(-kStandardLeftMargin);
    }];

    const CGFloat commitButtonHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:50.0f];
    _commitButton = [JCHUIFactory createButton:CGRectZero
                                       target:self
                                       action:@selector(handleCommit)
                                        title:@"提交"
                                   titleColor:nil
                              backgroundColor:[UIColor whiteColor]];
    [_commitButton setTitleColor:UIColorFromRGB(0xd5d5d5) forState:UIControlStateDisabled];
    [_commitButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateDisabled];
    [_commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_commitButton setBackgroundImage:[UIImage imageWithColor:JCHColorHeaderBackground] forState:UIControlStateNormal];
    _commitButton.layer.cornerRadius = 4;
    _commitButton.clipsToBounds = YES;
    _commitButton.enabled = NO;
    
    [self.view addSubview:_commitButton];
    
    [_commitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(clauseLabel.mas_bottom).with.offset(containerViewBottomOffset);
        make.height.mas_equalTo(commitButtonHeight);
        make.left.equalTo(self.view).with.offset(kStandardLeftMargin);
        make.right.equalTo(self.view).with.offset(-kStandardLeftMargin);
    }];
    
    self.keyboardUtility = [[[JCHKeyboardUtility alloc] init] autorelease];
    
    __block typeof(self) weakSelf = self;
    [self.keyboardUtility setAnimateWhenKeyboardAppearAutomaticAnimBlock:^(JCHKeyboardUtility *keyboardUtil) {
        [keyboardUtil adaptiveViewHandleWithController:weakSelf adaptiveView:weakSelf -> _passwordTextField, weakSelf -> _identifyCodeTextField, nil];
    }];
}

- (void)handleSwitchIdentifyWay:(UIButton *)sender
{
    CGRect frame = _buttonIndicatorView.frame;
    if (sender == _messageButton) {
        _messageButton.selected = YES;
        _voiceButton.selected = NO;
        _listenCodeButton.hidden = YES;
        _getCodeButton.hidden = NO;
        if (frame.origin.x == _voiceButton.frame.origin.x) {
            frame.origin.x = 0;
            _buttonIndicatorView.frame = frame;
        }
    } else {
        _messageButton.selected = NO;
        _voiceButton.selected = YES;
        _listenCodeButton.hidden = NO;
        _getCodeButton.hidden = YES;
        if (frame.origin.x == 0) {
            frame.origin.x = _voiceButton.frame.origin.x;
            _buttonIndicatorView.frame = frame;
        }
    }
}

- (void)handleCommit
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
            self.hud = [MBProgressHUD showHUDWithTitle:nil detail:@"请稍候..." duration:1000 mode:MBProgressHUDModeIndeterminate completion:nil];
            

#if MMR_BASE_VERSION

            // 如果用户已注册，然后退出登录，并再次进行新的用户注册操作，那么在退出登录时，userID会置空
            // 其它情况下，在注册界面，userID不为空
            
            // 基础版要先跑自动注册
            JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
            if ([statusManager.userID isEqualToString:@""] ||
                statusManager.userID == nil) {
                AppDelegate *theApp = [AppDelegate sharedAppDelegate];
                [theApp doAutoSilentUserRegister];
            } else {
                if (YES == statusManager.hasUserAutoSilentRegisteredOnThisDevice) {
                    [self doUserRegisterByMobile:_phoneTextField.text password:_passwordTextField.text captchaCode:_identifyCodeTextField.text];
                } else {
                    //正在进行自动注册，自动注册完成之后，会在消息通知处理中调用 注册流程:doUserRegisterByMobile
                }
            }
#else
            // 非基础版直接注册
            [self doUserRegisterByMobile:_phoneTextField.text password:_passwordTextField.text captchaCode:_identifyCodeTextField.text];
#endif
            
        }
        
        [manager setReachabilityStatusChangeBlock:nil];
        [manager stopMonitoring];
    }];


   
}

//弹出用户隐私条款
- (void)handleAlauseAlert
{
    //@"privacy_agreement"  @"用户隐私条款"
    JCHClauseViewController *clauseVC = [[[JCHClauseViewController alloc] initWithHTMLName:@"privacy_agreement" title:@"用户隐私条款"] autorelease];
    [self.navigationController pushViewController:clauseVC animated:YES];
}

- (void)handleAgreeAlause:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if ([_phoneTextField.text isEqualToString:@""] || [_passwordTextField.text isEqualToString:@""] || [_identifyCodeTextField.text isEqualToString:@""] || !_agreeAlauseButton.selected) {
        _commitButton.enabled = NO;
    }
    else
    {
        _commitButton.enabled = YES;
    }
}

//获取验证码
- (void)getCode:(UIButton *)sender
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
            
            BOOL isVoiceCAPTCHA = NO;
            
            if (sender == _listenCodeButton) {
                isVoiceCAPTCHA = YES;
            }
            
            [self doSendMobileCAPTCHAForRegister:_phoneTextField.text isVoiceCAPTCHA:isVoiceCAPTCHA];
            [manager stopMonitoring];
            [manager setReachabilityStatusChangeBlock:nil];
        }
    }];

    return;
}

- (void)handleCountdown
{
    if (!_getCodeButton.hidden) {
        if (self.getCodeCount == 0) {
            _getCodeButton.enabled = YES;
            [self.getCodeButtonTimer invalidate];
            self.getCodeButtonTimer = nil;
        } else {
            NSString *text = [NSString stringWithFormat:@"%lds", (long)self.getCodeCount];
            [_getCodeButton setTitle:text forState:UIControlStateDisabled];
        }
        self.getCodeCount--;
    } else {
        if (self.listenCodeCount == 0) {
            _listenCodeButton.enabled = YES;
            [self.listenCodeButtonTimer invalidate];
            self.listenCodeButtonTimer = nil;
        } else {
            NSString *text = [NSString stringWithFormat:@"%lds", (long)self.listenCodeCount];
            [_listenCodeButton setTitle:text forState:UIControlStateDisabled];
        }
        self.listenCodeCount--;
    }
}

- (void)handlePopAction
{
    [self.getCodeButtonTimer invalidate];
    [self.listenCodeButtonTimer invalidate];
    self.getCodeButtonTimer = nil;
    self.listenCodeButtonTimer = nil;
    
    [JCHSyncStatusManager clearStatus];
    
    if (self.navigationController.presentingViewController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)textFieldIsEditing:(UITextField *)textField
{
    if ([_phoneTextField.text isEqualToString:@""] ||
        [_passwordTextField.text isEqualToString:@""] ||
        [_identifyCodeTextField.text isEqualToString:@""] ||
        !_agreeAlauseButton.selected) {
        
        _commitButton.enabled = NO;
    } else {
        _commitButton.enabled = YES;
    }
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    JCHClauseViewController *clauseVC = [[[JCHClauseViewController alloc] initWithHTMLName:@"privacy_agreement" title:@"用户隐私条款"] autorelease];
    [self.navigationController pushViewController:clauseVC animated:YES];
}


#pragma mark - RegisterNotificationAndMethod

- (void)registerResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(handleSendMobileCAPTCHA:)
                               name:kJCHSendMobileCAPTCHANotification
                             object:[UIApplication sharedApplication]];

    [notificationCenter addObserver:self
                           selector:@selector(handleUserRegisterByMobile:)
                               name:kJCHUserRegisterByMobileNotification
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
}

- (void)unregisterResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self
                                  name:kJCHSendMobileCAPTCHANotification
                                object:[UIApplication sharedApplication]];
    
    [notificationCenter removeObserver:self
                                  name:kJCHUserRegisterByMobileNotification
                                object:[UIApplication sharedApplication]];
    
    [notificationCenter removeObserver:self
                                  name:kJCHSyncAutoRegisterCompleteNotification
                                object:[UIApplication sharedApplication]];
    
    [notificationCenter removeObserver:self
                                  name:kAutoRegisterFailedNotification
                                object:[UIApplication sharedApplication]];
}

#pragma mark - // ===================================== 用户管理服务器 - 获取验证码 ========================= //
- (void)doSendMobileCAPTCHAForRegister:(NSString *)phoneNumber isVoiceCAPTCHA:(BOOL)isVoiceCAPTCHA
{
    SendCAPTCHARequest *request = [[[SendCAPTCHARequest alloc] init] autorelease];
    request.serviceURL = [NSString stringWithFormat:@"%@/terminal/code", kJCHUserManagerServerIP];
    request.phoneNumber = phoneNumber;
    request.requestType = @"regist";  // regist、getpwd
    request.isVoiceCAPTCHA = isVoiceCAPTCHA;
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService sendMobileCAPTCHA:request responseNotification:kJCHSendMobileCAPTCHANotification];
    
    return;
}

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

        
        if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
            //! @todo
            NSLog(@"send captcha fail.");
            [MBProgressHUD showHudWithStatusCode:responseCode sceneType:kJCHMBProgressHUDSceneTypeCaptchaCode];
            return;
        } else {
            SendCAPTCHAResponse *response = [[[SendCAPTCHAResponse alloc] init] autorelease];
            response.code = responseCode;
            response.descriptionString = responseDescription;
            response.status = responseStatus;
            
            //! @todo
            // your code here
            
            [MBProgressHUD showHUDWithTitle:nil detail:[NSString stringWithFormat:@"验证码已发送至%@", _phoneTextField.text] duration:1.5 mode:MBProgressHUDModeText completion:nil];
            
            //开始倒计时
            
            if (!_getCodeButton.hidden) {
                self.getCodeCount = 60;
                _getCodeButton.enabled = NO;
                [self handleCountdown];
                self.getCodeButtonTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                                           target:self
                                                                         selector:@selector(handleCountdown)
                                                                         userInfo:nil
                                                                          repeats:YES];
            } else {
                self.listenCodeCount = 120;
                _listenCodeButton.enabled = NO;
                [self handleCountdown];
                self.listenCodeButtonTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                                              target:self
                                                                            selector:@selector(handleCountdown)
                                                                            userInfo:nil
                                                                             repeats:YES];
            }
            
        }
    
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
    }
}


#pragma mark - // ===================================== 用户管理服务器 - 通过手机号注册 ===================== //
- (void)doUserRegisterByMobile:(NSString *)userName password:(NSString *)password captchaCode:(NSString *)captchaCode
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    RegisterByMobileRequest *request = [[[RegisterByMobileRequest alloc] init] autorelease];
    request.serviceURL = [NSString stringWithFormat:@"%@/terminal/reg1", kJCHUserManagerServerIP];
#if MMR_BASE_VERSION
    request.userID = statusManager.userID;
#else
    request.userID = @"0";
#endif
    
    request.userName = userName;
    request.userPassword = password;
    request.captchaCode = captchaCode;
    request.deviceUUID = statusManager.deviceUUID;
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService userRegisterByMobile:request responseNotification:kJCHUserRegisterByMobileNotification];
    
    return;
}


- (void)handleUserRegisterByMobile:(NSNotification *)notify
{
    NSDictionary *userData = notify.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        NSString *responseDescription = responseData[@"desc"];
        NSString *responseStatus = responseData[@"status"];
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
        [self.hud hide:YES];
        
        
        if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
            //! @todo
            NSLog(@"register by mobile fail.");
            // request fail
            [MBProgressHUD showHudWithStatusCode:responseCode sceneType:kJCHMBProgressHUDSceneTypeRegister];
            return;
        } else {
            NSDictionary *serviceResponse = responseData[@"data"];
            NSString *userID = serviceResponse[@"id"];
            NSString *token = serviceResponse[@"token"];
            
            RegisterByMobileResponse *response = [[[RegisterByMobileResponse alloc] init] autorelease];
            response.code = responseCode;
            response.descriptionString = responseDescription;
            response.status = responseStatus;
            response.userID = userID;
            response.token = token;
            
            JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
            statusManager.userID = userID;
            statusManager.syncToken = token;
            statusManager.phoneNumber = _phoneTextField.text;
            statusManager.isShopManager = YES;
            statusManager.isLogin = YES;
            [JCHSyncStatusManager writeToFile];
            
            NSDictionary *lastUserInfo = @{@"userName" : _phoneTextField.text, @"password" : _passwordTextField.text};
            statusManager.lastUserInfo = lastUserInfo;
            
            id <BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
            BookMemberRecord4Cocoa *bookMemberRecord = [bookMemberService queryBookMemberWithUserID:[NSString stringWithFormat:@"%@", userID]];
            
            bookMemberRecord.phone = _phoneTextField.text;
            //更新所有账本中的book member信息
            [ServiceFactory updateBookMemberInAllAccountBook:[NSString stringWithFormat:@"%@", userID] bookMember:bookMemberRecord];
            
            statusManager.headImageName = [JCHImageUtility getAvatarImageNameFromAvatarUrl:bookMemberRecord.avatarUrl];
            
#if MMR_BASE_VERSION
            //强制注册 更新店铺类型为“系统注册初始化001”
            id <BookInfoService> bookInfoService = [[ServiceFactory sharedInstance] bookInfoService];
            BookInfoRecord4Cocoa *bookInfoRecord = [bookInfoService queryBookInfo:statusManager.userID];
            bookInfoRecord.bookType = kJCHDefaultShopType;
            [bookInfoService updateBookInfo:bookInfoRecord];
            
            
            //! @todo
            // your code here
            // request success
            id<PermissionService> permissionService = [[ServiceFactory sharedInstance] permissionService];
            [permissionService checkAndRepairPermission:statusManager.userID phoneNumber:statusManager.phoneNumber];
            
            RoleRecord4Cocoa *roleRecord =  [permissionService queryRoleWithByUserID:statusManager.userID];
            statusManager.roleRecord = roleRecord;
            
            [JCHSyncStatusManager writeToFile];
            
        
            //由appDelegate处理跳转页面
            AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
            [appDelegate switchToHomePage:self completion:nil];
            
            [MBProgressHUD showHUDWithTitle:@"注册成功"
                                     detail:nil
                                   duration:1
                                       mode:MBProgressHUDModeText
                                 completion:nil];
            
            [appDelegate.homePageController doManualDataSync];
            
            // 开启自动同步
            [appDelegate stopAutoSyncTimer];
            [appDelegate startAutoSyncTimer];
#else
            [MBProgressHUD showHUDWithTitle:@"注册成功"
                                     detail:nil
                                   duration:1
                                       mode:MBProgressHUDModeText
                                 completion:^{
                                     [MBProgressHUD showHUDWithTitle:@""
                                                              detail:@"正在查询激活状态"
                                                            duration:9999
                                                                mode:MBProgressHUDModeIndeterminate
                                                          completion:nil];
                                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                         [self handleQueryVIPAccountBookAuthority];
                                     });
                                 }];
#endif
            
        }
        
       
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
        [MBProgressHUD showNetWorkFailedHud:nil];
        // userData[@"data"] ==> NSError
        // network error
    }
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
        [MBProgressHUD hideAllHudsForWindow];
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
                    //强制注册 更新店铺类型为“系统注册初始化001”
                    id <BookInfoService> bookInfoService = [[ServiceFactory sharedInstance] bookInfoService];
                    BookInfoRecord4Cocoa *bookInfoRecord = [bookInfoService queryBookInfo:statusManager.userID];
                    bookInfoRecord.bookType = kJCHDefaultShopType;
                    [bookInfoService updateBookInfo:bookInfoRecord];
                    
                    
                    //! @todo
                    // your code here
                    // request success
                    id<PermissionService> permissionService = [[ServiceFactory sharedInstance] permissionService];
                    [permissionService checkAndRepairPermission:statusManager.userID phoneNumber:statusManager.phoneNumber];
                    
                    RoleRecord4Cocoa *roleRecord =  [permissionService queryRoleWithByUserID:statusManager.userID];
                    statusManager.roleRecord = roleRecord;
                    
                    [JCHSyncStatusManager writeToFile];
                    
                    
                    //由appDelegate处理跳转页面
                    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
                    [appDelegate switchToHomePage:self completion:nil];
                    
                    
                    // 开启自动同步
                    [appDelegate stopAutoSyncTimer];
                    [appDelegate startAutoSyncTimer];
                }
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            [MBProgressHUD showNetWorkFailedHud:nil];
        }
    }];
}


#pragma mark - // ===================================== 用户管理服务器 - 验证验证码 ======================== //
- (void)doVerifyMobileCAPTCHA:(NSString *)phoneNumber captchaCode:(NSString *)captchaCode
{
    VerifyMobileCAPTCHARequest *request = [[[VerifyMobileCAPTCHARequest alloc] init] autorelease];
    request.serviceURL = [NSString stringWithFormat:@"%@/terminal/codeCheck", kJCHUserManagerServerIP];
    request.phoneNumber = phoneNumber;
    request.requestType = @"????";
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
        
        if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
            //! @todo
            NSLog(@"verify mobile captcha fail.");
            return;
        } else {
            NSDictionary *serviceResponse = responseData[@"data"];
            NSInteger code = [serviceResponse[@"code"] integerValue];
            
            VerifyMobileCAPTCHAResponse *response = [[[VerifyMobileCAPTCHAResponse alloc] init] autorelease];
            response.code = responseCode;
            response.descriptionString = responseDescription;
            response.status = responseStatus;
            response.code = code;
            
            
            //! @todo
            // your code here
        }
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
        [MBProgressHUD showNetWorkFailedHud:nil];
    }
}


#pragma mark - // ===================================== 用户管理服务器 - 修改密码 ========================== //
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
        
        if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
            //! @todo
            NSLog(@"modify password fail.");
            return;
        } else {
            ModifyLoginPasswordResponse *response = [[[ModifyLoginPasswordResponse alloc] init] autorelease];
            response.code = responseCode;
            response.descriptionString = responseDescription;
            response.status = responseStatus;
            
            //! @todo
            // your code here
        }
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
        [MBProgressHUD showNetWorkFailedHud:nil];
    }
}

- (void)handleAutoRegisterCompleteInAppDelegate:(NSNotification *)notify
{
    [self doUserRegisterByMobile:_phoneTextField.text password:_passwordTextField.text captchaCode:_identifyCodeTextField.text];
}
     
- (void)handleAutoRegisterFailedInAppDelegate:(NSNotification *)notify
{
    if ([MBProgressHUD getHudShowingStatus]) {
        [MBProgressHUD showHUDWithTitle:@""
                                 detail:@"注册失败，请重试"
                               duration:1.5
                                   mode:MBProgressHUDModeText
                             completion:nil];
    }
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    statusManager.userID = @"";
    [JCHSyncStatusManager writeToFile];
}

- (void)handleApplicationWillEnterForeground
{
    [super handleApplicationWillEnterForeground];
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (statusManager.userID && ![statusManager.userID isEmptyString]) {
        [self handleQueryVIPAccountBookAuthority];
    }
}



@end
