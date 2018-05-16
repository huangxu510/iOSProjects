//
//  JCHAddAccountBookViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/7.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAddAccountBookViewController.h"
#import "JCHPickerView.h"
#import "JCHTextView.h"
#import "JCHArrowTapView.h"
#import "CommonHeader.h"
#import <Masonry.h>

@interface JCHAddAccountBookViewController () <JCHPickerViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    //UIScrollView *self.backgroundScrollView;
    UITextField *_accountBookNameTextField;
    UITextField *_amountTextField;
    JCHArrowTapView *_currencyView;
    JCHTextView *_remarkTextView;
    JCHPickerView *_pickerView;
}
@property (nonatomic, retain) NSArray *currencys;
@end

@implementation JCHAddAccountBookViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.currencys = @[@"人民币(CNY)", @"美元", @"欧元", @"英镑"];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createUI];
}
- (void)dealloc
{
    [self.currencys release];
    
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGSize contentSize = self.backgroundScrollView.contentSize;
    CGFloat height = MAX(kScreenHeight - 64 + 1, contentSize.height);
    contentSize.height = height;
    self.backgroundScrollView.contentSize = contentSize;
}

- (void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    UIFont *textFont = [UIFont systemFontOfSize:16.0f];
    CGFloat separateViewHeight = 20.0f;
    CGFloat titleLabelWidth = 80;
    CGFloat titleLabelHeight = 44;
    CGFloat remarkTextViewMinHeight = 80.0f;
    
    //self.backgroundScrollView = [[[UIScrollView alloc] initWithFrame:CGRectZero] autorelease];
    //[self.backgroundScrollView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    //[self.view addSubview:self.backgroundScrollView];
    
    //[self.backgroundScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.top.equalTo(self.view);
        //make.bottom.equalTo(self.view);
        //make.left.equalTo(self.view);
        //make.right.equalTo(self.view);
    //}];
    
    UILabel *accountBookNameTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                             title:@"账户名"
                                                              font:textFont
                                                         textColor:JCHColorMainBody
                                                            aligin:NSTextAlignmentLeft];
    [self.backgroundScrollView addSubview:accountBookNameTitleLabel];
    
    [accountBookNameTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(80);
        make.top.equalTo(self.backgroundScrollView).with.offset(separateViewHeight);
        make.height.mas_equalTo(titleLabelHeight);
    }];
    
    _accountBookNameTextField = [JCHUIFactory createTextField:CGRectZero
                                                  placeHolder:@"输入名称"
                                                    textColor:JCHColorMainBody
                                                       aligin:NSTextAlignmentRight];
    [self.backgroundScrollView addSubview:_accountBookNameTextField];
    
    [_accountBookNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(accountBookNameTitleLabel.mas_right).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(kScreenWidth - 3 * kStandardLeftMargin - titleLabelWidth);
        make.top.and.bottom.equalTo(accountBookNameTitleLabel);
    }];
    
    UILabel *amountTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                    title:@"金额"
                                                     font:textFont
                                                textColor:JCHColorMainBody
                                                   aligin:NSTextAlignmentLeft];
    [self.backgroundScrollView addSubview:amountTitleLabel];
    
    [amountTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.width.and.height.equalTo(accountBookNameTitleLabel);
        make.top.equalTo(accountBookNameTitleLabel.mas_bottom);
    }];
    
    _amountTextField = [JCHUIFactory createTextField:CGRectZero
                                         placeHolder:@"输入金额"
                                           textColor:JCHColorMainBody
                                              aligin:NSTextAlignmentRight];
    [self.backgroundScrollView addSubview:_amountTextField];
    
    [_amountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(accountBookNameTitleLabel.mas_right).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(kScreenWidth - 3 * kStandardLeftMargin - titleLabelWidth);
        make.top.and.bottom.equalTo(amountTitleLabel);
    }];
    
    _currencyView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
    [_currencyView.button addTarget:self action:@selector(handleCurrencySelect) forControlEvents:UIControlEventTouchUpInside];
    _currencyView.titleLabel.text = @"币种";
    _currencyView.detailLabel.text = self.currencys[0];
    [self.backgroundScrollView addSubview:_currencyView];
    
    [_currencyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(amountTitleLabel.mas_bottom);
        make.height.mas_equalTo(titleLabelHeight);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
    }];
    
    _remarkTextView = [[[JCHTextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 100)] autorelease];
    _remarkTextView.textColor = JCHColorMainBody;
    _remarkTextView.font = textFont;
    _remarkTextView.placeholder = @"添加备注信息";
    _remarkTextView.placeholderColor = UIColorFromRGB(0xd5d5d5);
    //_remarkTextView.layoutManager.allowsNonContiguousLayout = NO;
    _remarkTextView.isAutoHeight = YES;
    _remarkTextView.minHeight = remarkTextViewMinHeight;
    [self.backgroundScrollView addSubview:_remarkTextView];
    
    [_remarkTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_currencyView.mas_bottom).with.offset(separateViewHeight);
        make.height.mas_equalTo(remarkTextViewMinHeight);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
    }];
    
    
    const CGRect pickerRect = CGRectMake(0, kScreenHeight, self.view.frame.size.width, kJCHPickerViewHeight);
    _pickerView = [[[JCHPickerView alloc] initWithFrame:pickerRect title:@"类别" showInView:self.view] autorelease];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    
    UIView *separateLine = [[[UIView alloc] init] autorelease];
    separateLine.backgroundColor = JCHColorSeparateLine;
    [self.backgroundScrollView addSubview:separateLine];
    
    [separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(accountBookNameTitleLabel);
        make.width.mas_equalTo(kScreenWidth - kStandardLeftMargin);
        make.bottom.equalTo(accountBookNameTitleLabel);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    separateLine = [[[UIView alloc] init] autorelease];
    separateLine.backgroundColor = JCHColorSeparateLine;
    [self.backgroundScrollView addSubview:separateLine];
    
    [separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(accountBookNameTitleLabel);
        make.width.mas_equalTo(kScreenWidth - kStandardLeftMargin);
        make.bottom.equalTo(amountTitleLabel);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    UIView *separateView = [[[UIView alloc] init] autorelease];
    separateView.backgroundColor = JCHColorGlobalBackground;
    [self.backgroundScrollView addSubview:separateView];
    
    [separateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(self.backgroundScrollView);
        make.height.mas_equalTo(separateViewHeight);
    }];
    
    separateView = [[[UIView alloc] init] autorelease];
    separateView.backgroundColor = JCHColorGlobalBackground;
    [self.backgroundScrollView addSubview:separateView];
    
    [separateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(_currencyView.mas_bottom);
        make.height.mas_equalTo(separateViewHeight);
    }];
    
    separateView = [[[UIView alloc] init] autorelease];
    separateView.backgroundColor = JCHColorGlobalBackground;
    [self.backgroundScrollView addSubview:separateView];
    
    [separateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(_remarkTextView.mas_bottom);
        make.height.mas_equalTo(kScreenHeight);
    }];
    
    [self.backgroundScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_remarkTextView.mas_bottom).with.offset(separateViewHeight);
    }];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


- (void)handleCurrencySelect
{
    [_pickerView show];
    
    [_pickerView.pickerView selectRow:[self.currencys indexOfObject:_currencyView.detailLabel.text] inComponent:0 animated:YES];
}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return kJCHPickerViewRowHeight;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.currencys[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _currencyView.detailLabel.text = self.currencys[row];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.currencys.count;
}


@end
