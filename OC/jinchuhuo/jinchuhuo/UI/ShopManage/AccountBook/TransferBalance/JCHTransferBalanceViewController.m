//
//  JCHTransferBalanceViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/23.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTransferBalanceViewController.h"
#import "CommonHeader.h"
#import "ServiceFactory.h"
#import "AccountBalanceRecord4Cocoa.h"
#import "JCHPickerView.h"
#import <Masonry.h>

@interface JCHTransferBalanceViewController () <JCHPickerViewDelegate,
UIPickerViewDataSource,
UIPickerViewDelegate,
UIAlertViewDelegate>
{
    JCHArrowTapView *_sourceAccountTapView;
    JCHArrowTapView *_destinationAccountTapView;
    JCHTitleTextField *_amountTitleTextField;
    JCHTextView *_remarkTextView;
    JCHPickerView *_pickerView;
    JCHArrowTapView *_currentEditView;
    UIButton *_submitButton;
}

@property (nonatomic, retain) NSMutableDictionary *allBalanceDic;

@end

@implementation JCHTransferBalanceViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"余额互转";
    }
    return self;
}

- (void)dealloc
{
    [self.allBalanceDic release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createUI];
}

- (void)createUI
{
    self.backgroundScrollView.backgroundColor = JCHColorGlobalBackground;
    
    CGFloat itemHeight = 44.0f;
    CGFloat seprateViewHeight = 20.0f;
    _sourceAccountTapView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
    _sourceAccountTapView.titleLabel.text = @"源账户";
    [_sourceAccountTapView.button addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundScrollView addSubview:_sourceAccountTapView];
    
    [_sourceAccountTapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(itemHeight);
    }];
    
    _destinationAccountTapView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
    _destinationAccountTapView.titleLabel.text = @"目标账户";
    [_destinationAccountTapView.button addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundScrollView addSubview:_destinationAccountTapView];
    
    [_destinationAccountTapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.width.and.height.equalTo(_sourceAccountTapView);
        make.top.equalTo(_sourceAccountTapView.mas_bottom);
    }];
    
    _amountTitleTextField = [[[JCHTitleTextField alloc] initWithTitle:@"转入金额"
                                                                 font:[UIFont systemFontOfSize:16.0f]
                                                          placeholder:@"输入金额"
                                                            textColor:JCHColorMainBody] autorelease];
    _amountTitleTextField.bottomLine.hidden = YES;
    _amountTitleTextField.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [_amountTitleTextField.textField addTarget:self action:@selector(textFieldEditingChanged) forControlEvents:UIControlEventEditingChanged];
    [self.backgroundScrollView addSubview:_amountTitleTextField];
    
    [_amountTitleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.width.and.height.equalTo(_sourceAccountTapView);
        make.top.equalTo(_destinationAccountTapView.mas_bottom);
    }];
    
    CGFloat remarkTextViewMinHeight = 80;
    _remarkTextView = [[[JCHTextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, remarkTextViewMinHeight)] autorelease];
    _remarkTextView.font = [UIFont systemFontOfSize:16.0f];
    _remarkTextView.placeholder = @"输入备注内容";
    _remarkTextView.placeholderColor = JCHColorAuxiliary;
    _remarkTextView.minHeight = remarkTextViewMinHeight;
    //_remarkTextView.isAutoHeight = YES;
    [self.backgroundScrollView addSubview:_remarkTextView];
    
    [_remarkTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(_amountTitleTextField.mas_bottom).with.offset(seprateViewHeight);
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
    
    const CGRect pickerRect = CGRectMake(0, kScreenHeight, self.view.frame.size.width, kJCHPickerViewHeight);
    _pickerView = [[[JCHPickerView alloc] initWithFrame:pickerRect title:@"类别" showInView:self.view] autorelease];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
}

- (void)textFieldEditingChanged
{
    if (![_sourceAccountTapView.detailLabel.text isEqualToString:@""] &&
        ![_destinationAccountTapView.detailLabel.text isEqualToString:@""] &&
        ![_amountTitleTextField.textField.text isEqualToString:@""]) {
        _submitButton.enabled = YES;
    } else {
        _submitButton.enabled = NO;
    }
}

- (void)handleSubmit
{
    
    NSString *alertMessage = nil;
    if ([_sourceAccountTapView.detailLabel.text isEqualToString:@""]) {
        alertMessage = @"请选择源账户";
    }
    
    if ([_destinationAccountTapView.detailLabel.text isEqualToString:@""]) {
        alertMessage = @"请选择目标账户";
    }
    
    if (alertMessage) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:alertMessage
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:_amountTitleTextField.textField.text];
    
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
    
    CGFloat amount = [_amountTitleTextField.textField.text doubleValue];
    
    
    
    NSString *sourceAccountUUID = nil;
    NSString *destinationAccountUUID = nil;
    
    for (AccountBalanceRecord4Cocoa *balanceRecord in self.allBalanceDic.allValues) {
        if ([_sourceAccountTapView.detailLabel.text isEqualToString:balanceRecord.accountName]) {
            sourceAccountUUID = balanceRecord.accountUUID;
        }
        
        if ([_destinationAccountTapView.detailLabel.text isEqualToString:balanceRecord.accountName]) {
            destinationAccountUUID = balanceRecord.accountUUID;
        }
    }
    
    id<AccountService> accountService = [[ServiceFactory sharedInstance] accountService];
    [accountService transferAccount:sourceAccountUUID
                      toAccountUUID:destinationAccountUUID
                             amount:amount
                             remark:_remarkTextView.text];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadData
{
    id <FinanceCalculateService> financeCalculateService = [[ServiceFactory sharedInstance] financeCalculateService];
    id <ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    NSArray *allBalanceRecordForTransfer = [financeCalculateService calculateAccountBalance];
    
    
    NSMutableDictionary *allBalanceDic = [NSMutableDictionary dictionary];
    for (AccountBalanceRecord4Cocoa *balanceRecord in allBalanceRecordForTransfer) {
        
        if ([balanceRecord.accountName isEqualToString:@"现金"]) {
            [allBalanceDic setObject:balanceRecord forKey:@"现金"];
        }
        if ([balanceRecord.accountName isEqualToString:@"微信"]) {
            [allBalanceDic setObject:balanceRecord forKey:@"微信"];
        }
    }
    
    if (![allBalanceDic objectForKey:@"现金"]) {
        AccountBalanceRecord4Cocoa *balanceRecord = [[[AccountBalanceRecord4Cocoa alloc] init] autorelease];
        balanceRecord.accountName = @"现金";
        balanceRecord.balance = 0.0f;
        balanceRecord.accountUUID = [manifestService getDefaultCashRMBAccountUUID];
        [allBalanceDic setObject:balanceRecord forKey:@"现金"];
    }
    
    if (![allBalanceDic objectForKey:@"微信"]) {
        AccountBalanceRecord4Cocoa *balanceRecord = [[[AccountBalanceRecord4Cocoa alloc] init] autorelease];
        balanceRecord.accountName = @"微信";
        balanceRecord.balance = 0.0f;
        balanceRecord.accountUUID = [manifestService getWeiXinPayAccountUUID];
        [allBalanceDic setObject:balanceRecord forKey:@"微信"];
    }
    
    self.allBalanceDic = allBalanceDic;
}

- (void)showPickerView:(UIButton *)sender
{
    if (_sourceAccountTapView.button == sender) {
        [_pickerView setTitle:@"源账户"];
        _currentEditView = _sourceAccountTapView;
    } else {
        [_pickerView setTitle:@"目标账户"];
        _currentEditView = _destinationAccountTapView;
    }
    [_pickerView show];
    [_pickerView.pickerView reloadAllComponents];
    if (![_currentEditView.detailLabel.text isEqualToString:@""]) {
        [_pickerView.pickerView selectRow:[self.allBalanceDic.allKeys indexOfObject:_currentEditView.detailLabel.text] inComponent:0 animated:NO];
    } else {
        [_pickerView.pickerView selectRow:0 inComponent:0 animated:NO];
    }
}



#pragma mark - JCHPickerViewDelegate

- (void)pickerViewWillHide:(JCHPickerView *)pickerView
{
    if ([_currentEditView.detailLabel.text isEqualToString:@""]) {
        _currentEditView.detailLabel.text = self.allBalanceDic.allKeys[0];
    }
    
    if ([_sourceAccountTapView.detailLabel.text isEqualToString:_destinationAccountTapView.detailLabel.text]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:@"源账户和目标账户不能相同"
                                                           delegate:self
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    if (![_sourceAccountTapView.detailLabel.text isEqualToString:@""] &&
        ![_destinationAccountTapView.detailLabel.text isEqualToString:@""] &&
        ![_amountTitleTextField.textField.text isEqualToString:@""]) {
        _submitButton.enabled = YES;
    } else {
        _submitButton.enabled = NO;
    }
}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return self.view.frame.size.width;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return kJCHPickerViewRowHeight;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.allBalanceDic.allKeys[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _currentEditView.detailLabel.text = self.allBalanceDic.allKeys[row];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.allBalanceDic.allKeys.count;
}


- (void)handlePopAction
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [_pickerView show];
    if (![_currentEditView.detailLabel.text isEqualToString:@""]) {
        [_pickerView.pickerView selectRow:[self.allBalanceDic.allKeys indexOfObject:_currentEditView.detailLabel.text] inComponent:0 animated:NO];
    } else {
        [_pickerView.pickerView selectRow:0 inComponent:0 animated:NO];
    }
}

@end
