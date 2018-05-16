//
//  JCHBindingAccountViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/24.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBindingAccountViewController.h"
#import "JCHBindResultStatusAlertView.h"
#import "JCHClauseViewController.h"
#import "CommonHeader.h"
#import "ServiceFactory.h"
#import "JCHSyncStatusManager.h"
#import "AppDelegate.h"
#import <Masonry.h>
#import <TTTAttributedLabel.h>
#import <KLCPopup.h>

@interface JCHBindingAccountViewController () <TTTAttributedLabelDelegate, JCHBindResultStatusAlertViewDelegate>
{
    JCHBindResultStatusAlertView *_bindResultAlertView;
}

@property (nonatomic, retain) KLCPopup *popupView;
@end

@implementation JCHBindingAccountViewController
{
    UITextField *_weChatAccountTextField;
    UITextField *_merchantIDTextField;
    UITextField *_APIKeyTextField;
}

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
    [self.popupView release];
    
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"账户绑定";
    [self createUI];
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    CGFloat textFieldWidth = [JCHSizeUtility calculateWidthWithSourceWidth:343.0f];
    CGFloat textFieldHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:50.0f];
    
    CGFloat textFieldTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:55.0f];
    
    UIFont *titleFont = [UIFont jchSystemFontOfSize:15.0f];
    UIFont *textFieldFont = [UIFont jchSystemFontOfSize:17.0f];
    
    _weChatAccountTextField = [JCHUIFactory createTextField:CGRectZero
                                                placeHolder:@""
                                                  textColor:JCHColorMainBody
                                                     aligin:NSTextAlignmentLeft];
    _weChatAccountTextField.font = textFieldFont;
    _weChatAccountTextField.backgroundColor = [UIColor whiteColor];
    _weChatAccountTextField.text = @"微信账户";
    _weChatAccountTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _weChatAccountTextField.leftViewMode = UITextFieldViewModeAlways;
    _weChatAccountTextField.leftView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kStandardLeftMargin, textFieldHeight)] autorelease];
    _weChatAccountTextField.layer.cornerRadius = 7.0f;
    _weChatAccountTextField.clipsToBounds = YES;
    _weChatAccountTextField.layer.borderWidth = 1;
    _weChatAccountTextField.layer.borderColor = JCHColorSeparateLine.CGColor;
    [self.view addSubview:_weChatAccountTextField];
    
    [_weChatAccountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(textFieldTopOffset);
        make.width.mas_equalTo(textFieldWidth);
        make.height.mas_equalTo(textFieldHeight);
        make.centerX.equalTo(self.view);
    }];
    
    UILabel *titleLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"账户名称"
                                               font:titleFont
                                          textColor:JCHColorAuxiliary
                                             aligin:NSTextAlignmentLeft];
    [self.view addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(_weChatAccountTextField);
        make.bottom.equalTo(_weChatAccountTextField.mas_top);
        make.height.mas_equalTo(30);
    }];
    
    
    _merchantIDTextField = [JCHUIFactory createTextField:CGRectZero
                                                placeHolder:@""
                                                  textColor:JCHColorMainBody
                                                     aligin:NSTextAlignmentLeft];
    _merchantIDTextField.font = textFieldFont;
    _merchantIDTextField.backgroundColor = [UIColor whiteColor];
    _merchantIDTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _merchantIDTextField.leftViewMode = UITextFieldViewModeAlways;
    _merchantIDTextField.leftView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kStandardLeftMargin, textFieldHeight)] autorelease];
    _merchantIDTextField.layer.cornerRadius = 7.0f;
    _merchantIDTextField.clipsToBounds = YES;
    _merchantIDTextField.layer.borderWidth = 1;
    _merchantIDTextField.layer.borderColor = JCHColorSeparateLine.CGColor;
    [self.view addSubview:_merchantIDTextField];
    
    [_merchantIDTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weChatAccountTextField.mas_bottom).with.offset(textFieldTopOffset);
        make.width.mas_equalTo(textFieldWidth);
        make.height.mas_equalTo(textFieldHeight);
        make.centerX.equalTo(self.view);
    }];
    
    titleLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@"商户号"
                                      font:titleFont
                                 textColor:JCHColorAuxiliary
                                    aligin:NSTextAlignmentLeft];
    [self.view addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(_weChatAccountTextField);
        make.bottom.equalTo(_merchantIDTextField.mas_top);
        make.height.mas_equalTo(30);
    }];
    
#if 0
    _APIKeyTextField = [JCHUIFactory createTextField:CGRectZero
                                             placeHolder:@""
                                               textColor:JCHColorMainBody
                                                  aligin:NSTextAlignmentLeft];
    _APIKeyTextField.font = textFieldFont;
    _APIKeyTextField.backgroundColor = [UIColor whiteColor];
    _APIKeyTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _APIKeyTextField.leftViewMode = UITextFieldViewModeAlways;
    _APIKeyTextField.leftView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kStandardLeftMargin, textFieldHeight)] autorelease];
    _APIKeyTextField.layer.cornerRadius = 7.0f;
    _APIKeyTextField.clipsToBounds = YES;
    _APIKeyTextField.layer.borderWidth = 1;
    _APIKeyTextField.layer.borderColor = JCHColorSeparateLine.CGColor;
    [self.view addSubview:_APIKeyTextField];
    
    [_APIKeyTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_merchantIDTextField.mas_bottom).with.offset(textFieldTopOffset);
        make.width.mas_equalTo(textFieldWidth);
        make.height.mas_equalTo(textFieldHeight);
        make.centerX.equalTo(self.view);
    }];
    
    titleLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@"API密钥"
                                      font:titleFont
                                 textColor:JCHColorAuxiliary
                                    aligin:NSTextAlignmentLeft];
    [self.view addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(_weChatAccountTextField);
        make.bottom.equalTo(_APIKeyTextField.mas_top);
        make.height.mas_equalTo(30);
    }];
#endif
    TTTAttributedLabel *infoLabel = [[[TTTAttributedLabel alloc] initWithFrame:CGRectZero] autorelease];
    infoLabel.font = titleFont;
    infoLabel.textColor = JCHColorBlueButton;
    infoLabel.delegate = self;
    infoLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentCenter;
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.linkAttributes =[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:(__bridge NSString *)kCTUnderlineStyleAttributeName];
    //[infoLabel setText:@"小贴士：什么是商户号？什么是API密钥？" afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        //return mutableAttributedString;
    //}];
    
    infoLabel.text = @"小贴士：什么是商户号？";
    NSRange range = [infoLabel.text rangeOfString:infoLabel.text];;
    
    //设置链接的url
    [infoLabel addLinkToURL:nil withRange:range];
    
    [self.view addSubview:infoLabel];
    
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScreenWidth - 2 * kStandardLeftMargin);
        make.centerX.equalTo(self.view);
        make.top.equalTo(_merchantIDTextField.mas_bottom).with.offset(20);
        make.height.mas_equalTo(30);
    }];
    
    CGFloat bindingButtonTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:40];
    CGFloat bindingButtonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:255.0f];
    CGFloat bindingButtonHeight = [JCHSizeUtility calculateWidthWithSourceWidth:69.0f];
    
    UIButton *bindingButton = [JCHUIFactory createButton:CGRectZero
                                                  target:self
                                                  action:@selector(handleBinding)
                                                   title:@"绑定"
                                              titleColor:[UIColor whiteColor]
                                         backgroundColor:JCHColorBlueButton];
    bindingButton.layer.cornerRadius = 5.0f;
    bindingButton.titleLabel.font = [UIFont systemFontOfSize:21.0f];
    [self.view addSubview:bindingButton];
    
    [bindingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(infoLabel.mas_bottom).with.offset(bindingButtonTopOffset);
        make.height.mas_equalTo(bindingButtonHeight);
        make.width.mas_equalTo(bindingButtonWidth);
        make.centerX.equalTo(self.view);
    }];
    
    CGFloat alertViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:307];
    CGFloat alertViewHeight = [JCHSizeUtility calculateWidthWithSourceWidth:292];
    _bindResultAlertView = [[[JCHBindResultStatusAlertView alloc] initWithFrame:CGRectMake(0, 0, alertViewWidth, alertViewHeight)] autorelease];
    _bindResultAlertView.delegate = self;
    KLCPopup *popupView = [KLCPopup popupWithContentView:_bindResultAlertView];
    popupView.backgroundColor = [UIColor clearColor];
    popupView.alpha = 0.5;
    popupView.dimmedMaskAlpha = 0.5f;
    popupView.maskType = KLCPopupMaskTypeDimmed;
    popupView.shouldDismissOnBackgroundTouch = NO;
    popupView.showType = KLCPopupShowTypeFadeIn;
    
    self.popupView = popupView;
}

- (void)handleBinding
{
    if ([_weChatAccountTextField.text isEqualToString:@""] || _weChatAccountTextField.text == nil) {
        
        [MBProgressHUD showHUDWithTitle:@"请输入账户名称"
                                 detail:@""
                               duration:1
                                   mode:MBProgressHUDModeText
                             completion:nil];
        return;
    }
    
    if ([_merchantIDTextField.text isEqualToString:@""] || _merchantIDTextField.text == nil) {
        
        [MBProgressHUD showHUDWithTitle:@"请输入商户号"
                                 detail:@""
                               duration:1
                                   mode:MBProgressHUDModeText
                             completion:nil];
        return;
    }
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager startMonitoring];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"networkChagne");
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
            
            [MBProgressHUD showNetWorkFailedHud:nil];
        } else {
            
            
            [self bindWeiXinPayAccount];
            
            [manager stopMonitoring];
            [manager setReachabilityStatusChangeBlock:nil];
        }
    }];
    
}

- (void)bindWeiXinPayAccount
{
    id <AccountService> accountService = [[ServiceFactory sharedInstance] accountService];
    
    BOOL isWeixinAccountExist = [accountService isWeixinAccountExist];
    
    if (isWeixinAccountExist) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:@"您已绑定过微信账户"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id <OnlineSettlement> settltmentService = [[ServiceFactory sharedInstance] onlineSettlementService];
    id <ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    
    NSString *weiXinPayUUID = [manifestService getWeiXinPayAccountUUID];
    
    BindWeiXinPayAccountRequest *request = [[[BindWeiXinPayAccountRequest alloc] init] autorelease];
    
    request.token = statusManager.syncToken;
    request.deviceUUID = statusManager.deviceUUID;
    request.serviceURL = [NSString stringWithFormat:@"%@/weixin/sl/account/bind", kPaySystemServerIP];
    request.bindID = [NSString stringWithFormat:@"%@_%@", statusManager.accountBookID, weiXinPayUUID];
    request.merchantID = _merchantIDTextField.text;
    [settltmentService bindWeiXinPayAccount:request response:kJCHBindWeiXinAccountNotification];
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    JCHClauseViewController *clauseVC = [[[JCHClauseViewController alloc] initWithHTMLName:@"tips" title:@"小贴士"] autorelease];
    [self.navigationController pushViewController:clauseVC animated:YES];
}

#pragma mark - QueryWeiXinAccountBindNotificationAndMethod

- (void)registerResponseNotificationHandler
{
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleBindWeiXinAccount:)
                                  name:kJCHBindWeiXinAccountNotification
                                object:[UIApplication sharedApplication]];
}

- (void)unregisterResponseNotificationHandler
{
    [JCHNotificationCenter removeObserver:self
                                     name:kJCHBindWeiXinAccountNotification
                                   object:[UIApplication sharedApplication]];
    
}


- (void)handleBindWeiXinAccount:(NSNotification *)notify
{
    NSLog(@"%@", notify);
    NSDictionary *userData = notify.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        NSString *responseDescription = responseData[@"desc"];
        NSString *responseStatus = responseData[@"status"];
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
        
        if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
            // fail
            
            JCHBindResultStatusAlertViewData *data = [[[JCHBindResultStatusAlertViewData alloc] init] autorelease];
            data.imageName = @"icon_checkout_popwindow_fail";
            data.titleText = @"绑定失败!";
            data.detailText = @"如需要帮助，可登录产品论坛找客服协助。论坛网址：http://bbs.maimairen.com/";
            data.buttonTitle = @"重新绑定";
            [_bindResultAlertView setViewData:data];
            _bindResultAlertView.resultStatus = 0;
            [_popupView show];
            
            return;
        } else {
            // success
            
            JCHBindResultStatusAlertViewData *data = [[[JCHBindResultStatusAlertViewData alloc] init] autorelease];
            data.imageName = @"icon_checkout_popwindow_success";
            data.titleText = @"绑定成功!";
            data.detailText = @"您可以在以后的交易中使用微信扫码或是微信条码收款了。也可以在账户里面查看微信账户的交易流水。";
            data.buttonTitle = @"好的";
            [_bindResultAlertView setViewData:data];
            _bindResultAlertView.resultStatus = 1;
            [_popupView show];
            
            id <AccountService> accountService = [[ServiceFactory sharedInstance] accountService];
            
            BOOL accountExist = NO;
            [accountService addWeiXinAccount:_weChatAccountTextField.text
                              alreadyExisted:&accountExist];
            
        }
    } else {
        // network error
        [MBProgressHUD showNetWorkFailedHud:@"绑定失败"];
    }
    
    return;
}

#pragma mark - JCHBindResultStatusAlertViewDelegate

- (void)handleButtonClick:(JCHBindResultStatusAlertView *)alertView
{
    if (alertView.resultStatus == 1) {
        [_popupView setDidFinishDismissingCompletion:^{
            // 插入微信账户后，必须自动同步，确保用户在更换设备后微信支付时有微信账户
            AppDelegate *theApp = [AppDelegate sharedAppDelegate];
            [theApp.homePageController doManualDataSync];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        [_popupView setDidFinishDismissingCompletion:nil];
    }
    [_popupView dismiss:YES];
}


@end
