//
//  JCHPinCodeViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/16.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHPinCodeViewController.h"
#import "JCHPinCodeView.h"
#import "CommonHeader.h"
#import "JCHUserInfoHelper.h"
#import "JCHSyncStatusManager.h"
#import "MBProgressHUD+JCHHud.h"

@interface JCHPinCodeViewController ()
{
    JCHPinCodeView *_codeView;
    UITextField *_textField;
    
    BOOL _secondInput;
}

@property (nonatomic, retain) NSString *lastCode;

@end

@implementation JCHPinCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"请输入密码";
    if (self.type == kJCHPinCodeViewControllerTypeIdentify) {
        self.navigationController.navigationBarHidden = NO;
        self.navigationItem.leftBarButtonItem = nil; //隐藏系统返回按钮
        self.navigationItem.hidesBackButton = YES;   //隐藏自己的返回按钮
    }
    
    _secondInput = NO;
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    _textField.hidden = YES;
    [_textField becomeFirstResponder];
    _textField.keyboardType = UIKeyboardTypeNumberPad;
    [_textField addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_textField];
    
    _codeView = [[JCHPinCodeView alloc] initWithFrame:self.view.bounds];
    _codeView.backgroundColor = JCHColorGlobalBackground;
    _codeView.codeLength = 0;
    _codeView.leftMargin = 90;
    _codeView.diameter = 15;
    _codeView.topMargin = 150;
    [self.view addSubview:_codeView];
    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showKeyboard)] autorelease];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.type == kJCHPinCodeViewControllerTypeIdentify) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
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
    
    if (self.type == kJCHPinCodeViewControllerTypeClose) { //关闭密码的验证
        if ([_textField.text isEqualToString: securityCode]) { //密码输入正确
            //[userDefaults setBool:NO forKey:@"securityCodeStatus"];
            [securityCodeDict setObject:@(NO) forKey:kSecurityCodeStatus];
            [self.navigationController popViewControllerAnimated:YES];
            
            [securityCodeForUserID setObject:securityCodeDict forKey:statusManager.userID];
            [userInfoHelper setSecurityCodeForUserID:securityCodeForUserID];
        }
        else //密码输入错误
        {
            [MBProgressHUD showHUDWithTitle:@"密码错误!" detail:nil duration:1 mode:MBProgressHUDModeText completion:nil];
            _codeView.codeLength = 0;
            _textField.text = @"";
        }
    }
    else if (self.type == kJCHPinCodeViewControllerTypeSet)//设置密码
    {
        if (_secondInput) { //再次输入密码
            if ([self.lastCode isEqualToString:_textField.text]) {
                //[userDefaults setObject:_textField.text forKey:@"securityCode"];
                //[userDefaults setBool:YES forKey:@"securityCodeStatus"];
                [securityCodeDict setObject:_textField.text forKey:kSecurityCode];
                [securityCodeDict setObject:@(YES) forKey:kSecurityCodeStatus];
                [self.navigationController popViewControllerAnimated:YES];
                
                [securityCodeForUserID setObject:securityCodeDict forKey:statusManager.userID];
                [userInfoHelper setSecurityCodeForUserID:securityCodeForUserID];
            }
            else
            {
                [MBProgressHUD showHUDWithTitle:@"两次密码不一致，请重新输入" detail:nil duration:1 mode:MBProgressHUDModeText completion:nil];
                _codeView.codeLength = 0;
                _textField.text = @"";
                _secondInput = NO;
                self.title = @"请输入密码";
            }
        }
        else //第一次输入密码
        {
            self.lastCode = _textField.text;
            self.title = @"请再次输入密码";
            _codeView.codeLength = 0;
            _textField.text = @"";
            _secondInput = YES;
        }
    }
    else //进入程序验证密码
    {
        if ([_textField.text isEqualToString: securityCode]) { //密码输入正确
            [self.navigationController popViewControllerAnimated:YES];
        }
        else //密码输入错误
        {
            [MBProgressHUD showHUDWithTitle:@"密码错误!" detail:nil duration:1 mode:MBProgressHUDModeText completion:nil];
            _codeView.codeLength = 0;
            _textField.text = @"";
        }
    }
    [_codeView setNeedsDisplay];
}

- (void)showKeyboard
{
    [_textField becomeFirstResponder];
}

@end
