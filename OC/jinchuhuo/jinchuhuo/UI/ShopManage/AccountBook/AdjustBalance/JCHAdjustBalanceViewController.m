//
//  JCHAdjustBalanceViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/23.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAdjustBalanceViewController.h"
#import "CommonHeader.h"
#import "ServiceFactory.h"
#import <Masonry.h>

@interface JCHAdjustBalanceViewController ()
{
    JCHTitleTextField *_currentBalanceTitleTextField;
    JCHTitleTextField *_adjustBalanceTitleTextField;
    JCHTextView *_remarkTextView;
    UIButton *_submitButton;
    CGFloat _currentBalanceAmount;
}
@property (nonatomic, retain) NSString *accountUUID;
@end

@implementation JCHAdjustBalanceViewController

- (instancetype)initWithAccountUUID:(NSString *)accountUUID
               currentBalanceAmount:(CGFloat)currentBalanceAmount
{
    self = [super init];
    if (self) {
        self.title = @"余额调整";
        _currentBalanceAmount = currentBalanceAmount;
        self.accountUUID = accountUUID;
    }
    return self;
}

- (void)dealloc
{
    self.accountUUID = nil;
    self.needReloadDataBlock = nil;
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createUI];
}

- (void)createUI
{
    self.backgroundScrollView.backgroundColor = JCHColorGlobalBackground;
    
    _backBtn = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_close"] style:UIBarButtonItemStylePlain target:self action:@selector(handlePopAction)] autorelease];
    self.navigationItem.leftBarButtonItem = _backBtn;
    
    _currentBalanceTitleTextField = [[[JCHTitleTextField alloc] initWithTitle:@"当前余额"
                                                                         font:[UIFont systemFontOfSize:16.0f]
                                                                  placeholder:@""
                                                                    textColor:JCHColorMainBody] autorelease];
    _currentBalanceTitleTextField.textField.text = [JCHFinanceCalculateUtility convertFloatAmountToString:_currentBalanceAmount];
    _currentBalanceTitleTextField.textField.enabled = NO;
    [self.backgroundScrollView addSubview:_currentBalanceTitleTextField];
    
    [_currentBalanceTitleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    _adjustBalanceTitleTextField =  [[[JCHTitleTextField alloc] initWithTitle:@"调整余额"
                                                                         font:[UIFont systemFontOfSize:16.0f]
                                                                  placeholder:@"输入金额"
                                                                    textColor:JCHColorMainBody
                                                       isLengthLimitTextField:YES] autorelease];
    _adjustBalanceTitleTextField.bottomLine.hidden = YES;
    _adjustBalanceTitleTextField.titleLabel.text = @"调整余额";
    [_adjustBalanceTitleTextField.textField addTarget:self action:@selector(textFieldEditingChanged) forControlEvents:UIControlEventEditingChanged];
    _adjustBalanceTitleTextField.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [self.backgroundScrollView addSubview:_adjustBalanceTitleTextField];
    
    [_adjustBalanceTitleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.top.equalTo(_currentBalanceTitleTextField.mas_bottom);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    _remarkTextView = [[[JCHTextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 80.0f)] autorelease];
    _remarkTextView.font = [UIFont systemFontOfSize:16.0f];
    _remarkTextView.placeholder = @"输入备注内容";
    _remarkTextView.placeholderColor = JCHColorAuxiliary;
    _remarkTextView.minHeight = 80.0f;
    //_remarkTextView.isAutoHeight = YES;
    [self.backgroundScrollView addSubview:_remarkTextView];
    
    [_remarkTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(_adjustBalanceTitleTextField.mas_bottom).with.offset(kStandardSeparateViewHeight);
        make.height.mas_equalTo(80);
    }];
    
    _submitButton = [JCHUIFactory createButton:CGRectZero
                                                 target:self
                                                 action:@selector(handleSubmit)
                                                  title:@"完成"
                                             titleColor:[UIColor whiteColor]
                                        backgroundColor:JCHColorBlueButton];
    [_submitButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xd5d5d5)] forState:UIControlStateDisabled];
    _submitButton.enabled = NO;
    [self.backgroundScrollView addSubview:_submitButton];
    
    CGFloat submitButtonTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:49.0f];
    CGFloat submitButtonHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:69.0f];
    CGFloat submitButtonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:255.0f];
    
    [_submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_remarkTextView.mas_bottom).with.offset(submitButtonTopOffset);
        make.width.mas_equalTo(submitButtonWidth);
        make.height.mas_equalTo(submitButtonHeight);
        make.centerX.equalTo(self.backgroundScrollView);
    }];
    
    [self.backgroundScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_submitButton);
    }];
}

- (void)textFieldEditingChanged
{
    if (![_adjustBalanceTitleTextField.textField.text isEqualToString:@""]) {
        _submitButton.enabled = YES;
    } else {
        _submitButton.enabled = NO;
    }
}

- (void)handleSubmit
{
    NSScanner *scanner = [NSScanner scannerWithString:_adjustBalanceTitleTextField.textField.text];
    
    double val;
    BOOL isFloat = [scanner scanDouble:&val];
    
    if (!isFloat) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"请输入正确的金额"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    CGFloat adjustBalance = [_adjustBalanceTitleTextField.textField.text doubleValue];
    
    
    
    CGFloat modifyAmount = adjustBalance - _currentBalanceAmount;
    
    id<AccountService> accountService = [[ServiceFactory sharedInstance] accountService];
    [accountService modifyBeginningBalance:self.accountUUID
                              modifyAmount:modifyAmount
                                    remark:_remarkTextView.text];
    if (self.needReloadDataBlock) {
        self.needReloadDataBlock(YES);
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)handlePopAction
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
