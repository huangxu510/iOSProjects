//
//  RetrievePasswordViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/9.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHRetrievePasswordViewController.h"
#import "JCHIdentifyCodeViewController.h"
#import "JCHInputAccessoryView.h"
#import "JCHUIFactory.h"
#import "JCHColorSettings.h"
#import "JCHSizeUtility.h"
#import "JCHUISettings.h"
#import "JCHUISizeSettings.h"
#import "UIImage+JCHImage.h"
#import "ServiceFactory.h"
#import "JCHSyncStatusManager.h"
#import "JCHServiceResponseSettings.h"
#import "JCHServiceResponseNotification.h"
#import "MBProgressHUD+JCHHud.h"
#import "CommonHeader.h"
#import <Masonry.h>

@interface JCHRetrievePasswordViewController ()
{
    UITextField *_phoneTextField;
    UIButton *_nextStepButton;
}
@end

@implementation JCHRetrievePasswordViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"找回密码";
    [self createUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    UILabel *textLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@"请确认你的注册手机号，我们将以短信验证的方式来完成密码重置。"
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
    const CGFloat containerViewHeight = 50;
    
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
        make.height.mas_equalTo(containerViewHeight);
    }];
    
    
    const CGRect inputAccessoryFrame = CGRectMake(0, 0, self.view.frame.size.width, kJCHInputAccessoryViewHeight);
    const CGFloat leftMargin = 16;
    
    _phoneTextField = [JCHUIFactory createTextField:CGRectZero
                                        placeHolder:nil
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentLeft];
    _phoneTextField.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:@"输入手机号"
                                                                             attributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xd5d5d5), NSFontAttributeName : titleFont}] autorelease];
    _phoneTextField.font = titleFont;
    _phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    _phoneTextField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
    [_phoneTextField addTarget:self action:@selector(textFieldIsEditing:) forControlEvents:UIControlEventEditingChanged];
    [containerView addSubview:_phoneTextField];
    
    [_phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(prefixLabel.mas_right).with.offset(leftMargin);
        make.right.equalTo(containerView).with.offset(-leftMargin);
        make.top.equalTo(containerView);
        make.height.mas_equalTo(containerViewHeight);
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
    NSPredicate *phonePredicate = [NSPredicate predicateWithFormat:@"self matches %@", kPhoneNumberPredicate];
    if (![phonePredicate evaluateWithObject:_phoneTextField.text]) {
        [MBProgressHUD showHUDWithTitle:nil detail:@"手机号码有误！" duration:1.5 mode:MBProgressHUDModeText completion:nil];
        return;
    }
    
    JCHIdentifyCodeViewController *identifyCodeVC = [[[JCHIdentifyCodeViewController alloc] init] autorelease];
    identifyCodeVC.phoneNumber = _phoneTextField.text;
    [self.navigationController pushViewController:identifyCodeVC animated:YES];
    
    return;
}

- (void)textFieldIsEditing:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""]) {
        _nextStepButton.enabled = YES;
    }
    else
    {
        _nextStepButton.enabled = NO;
    }
}


@end
