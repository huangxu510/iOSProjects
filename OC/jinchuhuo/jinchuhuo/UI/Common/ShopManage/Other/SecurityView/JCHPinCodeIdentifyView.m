//
//  JCHPinCodeIdentifyView.m
//  jinchuhuo
//
//  Created by huangxu on 16/4/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHPinCodeIdentifyView.h"
#import "JCHPinCodeView.h"
#import "CommonHeader.h"
#import "JCHUserInfoHelper.h"
#import "JCHSyncStatusManager.h"
#import "MBProgressHUD+JCHHud.h"
#import "JCHPinCodeViewController.h"

@interface JCHPinCodeIdentifyView ()
{
    JCHPinCodeView *_codeView;
    UITextField *_textField;
    
    BOOL _secondInput;
}
@property (nonatomic, retain) NSString *lastCode;
@end

@implementation JCHPinCodeIdentifyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _secondInput = NO;
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    UIView *navigationView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)] autorelease];
    navigationView.backgroundColor = JCHColorHeaderBackground;
    [self addSubview:navigationView];
    
    UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, 44)] autorelease];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"请输入密码";
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:titleLabel];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    _textField.hidden = YES;
    [_textField becomeFirstResponder];
    _textField.keyboardType = UIKeyboardTypeNumberPad;
    [_textField addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:_textField];
    
    _codeView = [[JCHPinCodeView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64)];
    _codeView.backgroundColor = JCHColorGlobalBackground;
    _codeView.codeLength = 0;
    _codeView.leftMargin = 90;
    _codeView.diameter = 15;
    _codeView.topMargin = 150;
    [self addSubview:_codeView];
    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showKeyboard)] autorelease];
    [self addGestureRecognizer:tap];
}

- (void)dealloc
{
    [self.lastCode release];
    
    [super dealloc];
}

- (void)editingChanged:(UITextField *)textField
{
    if (textField.text.length <= 4) {
        _codeView.codeLength = textField.text.length;
        [_codeView setNeedsDisplay];
        
        if (textField.text.length == 4) {
            
            [self performSelector:@selector(inputOver) withObject:nil afterDelay:0.15];
        }
    }
    else
    {
        textField.text = [textField.text substringToIndex:3];
    }
}

- (void)inputOver
{
    //NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //NSString *securityCode = [userDefaults objectForKey:@"securityCode"];
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    JCHUserInfoHelper *userInfoHelper = [JCHUserInfoHelper shareHelper];
    NSMutableDictionary *securityCodeForUserID = [NSMutableDictionary dictionaryWithDictionary:[userInfoHelper getsecurityCodeForUserID]];
    NSMutableDictionary *securityCodeDict = securityCodeForUserID[statusManager.userID];
    if (securityCodeDict == nil) {
        securityCodeDict = [NSMutableDictionary dictionary];
    }
    
    NSString *securityCode = securityCodeDict[kSecurityCode];
    
    //进入程序验证密码
    
    if ([_textField.text isEqualToString: securityCode]) { //密码输入正确
        [_textField resignFirstResponder];
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    } else {
        //密码输入错误
        [MBProgressHUD showHUDWithTitle:@"密码错误!" detail:nil duration:1 mode:MBProgressHUDModeText completion:nil];
        _codeView.codeLength = 0;
        _textField.text = @"";
    }
    
    [_codeView setNeedsDisplay];
}

- (void)showKeyboard
{
    [_textField becomeFirstResponder];
}

@end
