//
//  JCHManifestFilterViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/1/26.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHManifestFilterViewController.h"
#import "JCHManifestFilterConditionSelectView.h"
#import "JCHDatePickerView.h"
#import "CommonHeader.h"
#import <Masonry.h>

@interface JCHManifestFilterViewController () <JCHDatePickerViewDelegate>
{
    UIButton *_dateStartButton;
    UIButton *_dateEndButton;
    UIButton *_timeStartButton;
    UIButton *_timeEndButton;
    UITextField *_amountStartTextField;
    UITextField *_amountEndTextField;
    JCHManifestFilterConditionSelectView *_manifestTypeSelectView;
    JCHManifestFilterConditionSelectView *_manifestPayWaySelectView;
    JCHManifestFilterConditionSelectView *_manifestPayStatusSelectView;
    JCHDatePickerView *_datePickerView;
    JCHDatePickerView *_timePickerView;
    UIButton *_currentSelectedButton;
    NSDate *_startTime;
    NSDate *_endTime;
}
@end

@implementation JCHManifestFilterViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"货单筛选";
        [self initTime];
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
    self.manifestFilterCondition = nil;
    self.sendValueBlock = nil;
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.manifestFilterCondition) {

        [self clearAllOption];
    }
}

- (void)initTime
{
    _startTime = nil; [NSDate distantFuture];
    _endTime = nil; [NSDate distantFuture];
}

- (void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    UIFont *titleFont = [UIFont jchSystemFontOfSize:15.0f];
    
    CGFloat titleLabelWidth = 70;
    CGFloat buttonSpacing = 24;
    CGFloat buttonWidth = (kScreenWidth - titleLabelWidth - buttonSpacing - 3 * kStandardLeftMargin) / 2;
    CGFloat titleLabelHeight = 44;
    CGFloat buttonHeight = titleLabelHeight - 14;
    
    UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(commitOption)] autorelease];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    //开单日期
    UILabel *manifestDateTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                  title:@"开单日期"
                                                   font:titleFont
                                              textColor:JCHColorMainBody
                                                 aligin:NSTextAlignmentLeft];
    [self.view addSubview:manifestDateTitleLabel];
    
    [manifestDateTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(titleLabelWidth);
        make.height.mas_equalTo(titleLabelHeight);
    }];
    
    
    _dateStartButton = [JCHUIFactory createButton:CGRectZero
                                                    target:self
                                                    action:@selector(showDatePickerView:)
                                                     title:@""
                                                titleColor:JCHColorMainBody
                                           backgroundColor:JCHColorGlobalBackground];
    _dateStartButton.layer.cornerRadius = 3;
    _dateStartButton.clipsToBounds = YES;
    _dateStartButton.titleLabel.font = titleFont;
    [self.view addSubview:_dateStartButton];
    
    [_dateStartButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(manifestDateTitleLabel.mas_right).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(buttonHeight);
        make.centerY.equalTo(manifestDateTitleLabel);
    }];
    
    _dateEndButton = [JCHUIFactory createButton:CGRectZero
                                                    target:self
                                                    action:@selector(showDatePickerView:)
                                                     title:@""
                                                titleColor:JCHColorMainBody
                                           backgroundColor:JCHColorGlobalBackground];
    _dateEndButton.layer.cornerRadius = 3;
    _dateEndButton.clipsToBounds = YES;
    _dateEndButton.titleLabel.font = titleFont;
    [self.view addSubview:_dateEndButton];
    
    [_dateEndButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_dateStartButton.mas_right).with.offset(buttonSpacing);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(buttonHeight);
        make.centerY.equalTo(manifestDateTitleLabel);
    }];
    
    //开单时间
    UILabel *manifestTimeTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                          title:@"开单时间"
                                                           font:titleFont
                                                      textColor:JCHColorMainBody
                                                         aligin:NSTextAlignmentLeft];
    [self.view addSubview:manifestTimeTitleLabel];
    
    [manifestTimeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(manifestDateTitleLabel.mas_bottom);
        make.left.equalTo(manifestDateTitleLabel);
        make.width.mas_equalTo(titleLabelWidth);
        make.height.mas_equalTo(titleLabelHeight);
    }];
    
    _timeStartButton = [JCHUIFactory createButton:CGRectZero
                                           target:self
                                           action:@selector(showDatePickerView:)
                                            title:@""
                                       titleColor:JCHColorMainBody
                                  backgroundColor:JCHColorGlobalBackground];
    _timeStartButton.layer.cornerRadius = 3;
    _timeStartButton.clipsToBounds = YES;
    _timeStartButton.titleLabel.font = titleFont;
    [self.view addSubview:_timeStartButton];
    
    [_timeStartButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(manifestTimeTitleLabel.mas_right).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(buttonHeight);
        make.centerY.equalTo(manifestTimeTitleLabel);
    }];
    
    _timeEndButton = [JCHUIFactory createButton:CGRectZero
                                         target:self
                                         action:@selector(showDatePickerView:)
                                          title:@""
                                     titleColor:JCHColorMainBody
                                backgroundColor:JCHColorGlobalBackground];
    _timeEndButton.layer.cornerRadius = 3;
    _timeEndButton.clipsToBounds = YES;
    _timeEndButton.titleLabel.font = titleFont;
    [self.view addSubview:_timeEndButton];
    
    [_timeEndButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_dateEndButton);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(buttonHeight);
        make.centerY.equalTo(manifestTimeTitleLabel);
    }];
    
    //开单金额
    UILabel *manifestAmountTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                  title:@"开单金额"
                                                   font:titleFont
                                              textColor:JCHColorMainBody
                                                 aligin:NSTextAlignmentLeft];
    [self.view addSubview:manifestAmountTitleLabel];
    
    [manifestAmountTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.height.equalTo(manifestDateTitleLabel);
        make.top.equalTo(manifestTimeTitleLabel.mas_bottom);
    }];
    
    _amountStartTextField = [JCHUIFactory createTextField:CGRectZero
                                              placeHolder:@"最小金额"
                                                textColor:JCHColorMainBody
                                                   aligin:NSTextAlignmentCenter];
    _amountStartTextField.font = titleFont;
    _amountStartTextField.backgroundColor = JCHColorGlobalBackground;
    _amountStartTextField.layer.cornerRadius = 3;
    _amountStartTextField.clipsToBounds = YES;
    _amountStartTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:_amountStartTextField];
    
    [_amountStartTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(manifestAmountTitleLabel.mas_right).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(buttonHeight);
        make.centerY.equalTo(manifestAmountTitleLabel);
    }];
    
    
    _amountEndTextField = [JCHUIFactory createTextField:CGRectZero
                                            placeHolder:@"最大金额"
                                              textColor:JCHColorMainBody
                                                 aligin:NSTextAlignmentCenter];
    _amountEndTextField.font = titleFont;
    _amountEndTextField.backgroundColor = JCHColorGlobalBackground;
    _amountEndTextField.layer.cornerRadius = 3;
    _amountEndTextField.clipsToBounds = YES;
    _amountEndTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:_amountEndTextField];
    
    [_amountEndTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_dateEndButton);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(buttonHeight);
        make.centerY.equalTo(manifestAmountTitleLabel);
    }];
    
    //货单类型
    UILabel *manifestTypeTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                          title:@"货单类型"
                                                           font:titleFont
                                                      textColor:JCHColorMainBody
                                                         aligin:NSTextAlignmentLeft];
    [self.view addSubview:manifestTypeTitleLabel];
    
    [manifestTypeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.height.equalTo(manifestDateTitleLabel);
        make.top.equalTo(manifestAmountTitleLabel.mas_bottom);
    }];
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    NSArray *manifestTypeArray = @[@"全部", @"进货单", @"出货单", @"进货退单", @"出货退单"];
    
    if (statusManager.isShopManager == NO) {
        manifestTypeArray = @[@"全部", @"出货单", @"出货退单"];;
    }
    
    CGRect frame = CGRectMake(0, 0, kScreenWidth - titleLabelWidth - 2 * kStandardLeftMargin, titleLabelHeight);
    _manifestTypeSelectView = [[[JCHManifestFilterConditionSelectView alloc] initWithFrame:frame] autorelease];
    [self.view addSubview:_manifestTypeSelectView];
    [_manifestTypeSelectView setData:manifestTypeArray];
    
    [_manifestTypeSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_amountStartTextField);
        make.right.equalTo(self.view);
        make.top.equalTo(manifestTypeTitleLabel);
        make.height.mas_equalTo(_manifestTypeSelectView.viewHeight);
    }];
    
    //结算方式
    UILabel *payWayTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                    title:@"结算方式"
                                                     font:titleFont
                                                textColor:JCHColorMainBody
                                                   aligin:NSTextAlignmentLeft];
    [self.view addSubview:payWayTitleLabel];
    
    [payWayTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.height.equalTo(manifestDateTitleLabel);
        make.top.equalTo(_manifestTypeSelectView.mas_bottom);
    }];

    NSArray *manifestPayWayArray = @[@"全部", @"现金", @"赊欠", @"微信"];
    _manifestPayWaySelectView = [[[JCHManifestFilterConditionSelectView alloc] initWithFrame:frame] autorelease];
    [self.view addSubview:_manifestPayWaySelectView];
    [_manifestPayWaySelectView setData:manifestPayWayArray];
    
    [_manifestPayWaySelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_manifestTypeSelectView);
        make.right.equalTo(self.view);
        make.top.equalTo(payWayTitleLabel);
        make.height.mas_equalTo(_manifestPayWaySelectView.viewHeight);
    }];

    //赊欠状态
    UILabel *payStatusTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                    title:@"赊欠状态"
                                                     font:titleFont
                                                textColor:JCHColorMainBody
                                                   aligin:NSTextAlignmentLeft];
    [self.view addSubview:payStatusTitleLabel];
    
    [payStatusTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.height.equalTo(manifestDateTitleLabel);
        make.top.equalTo(_manifestPayWaySelectView.mas_bottom);
    }];
    
    NSArray *manifestPayStatusArray = @[@"全部", @"未收款", @"未付款", @"已收款", @"已付款"];
    if (statusManager.isShopManager == NO) {
        manifestPayStatusArray = @[@"全部", @"未收款", @"已收款"];
    }
    
    _manifestPayStatusSelectView = [[[JCHManifestFilterConditionSelectView alloc] initWithFrame:frame] autorelease];
    [self.view addSubview:_manifestPayStatusSelectView];
    [_manifestPayStatusSelectView setData:manifestPayStatusArray];
    
    [_manifestPayStatusSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_manifestTypeSelectView);
        make.right.equalTo(self.view);
        make.top.equalTo(payStatusTitleLabel);
        make.height.mas_equalTo(_manifestPayStatusSelectView.viewHeight);
    }];
    
    

    UIButton *clearButton = [JCHUIFactory createButton:CGRectZero
                                                target:self
                                                action:@selector(clearAllOption)
                                                 title:@"清除选项"
                                            titleColor:UIColorFromRGB(0xdd4041)
                                       backgroundColor:[UIColor whiteColor]];
    clearButton.layer.cornerRadius = 3;
    clearButton.clipsToBounds = YES;
    clearButton.layer.borderColor = UIColorFromRGB(0xdd4041).CGColor;
    clearButton.layer.borderWidth = 1;
    clearButton.titleLabel.font = titleFont;
    [self.view addSubview:clearButton];
    
    [clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(85);
        make.centerX.equalTo(self.view);
        make.top.equalTo(_manifestPayStatusSelectView.mas_bottom).with.offset(20);
        make.height.mas_equalTo(30);
    }];
    
    
    {
        UIView *separateLine = [[[UIView alloc] init] autorelease];
        separateLine.backgroundColor = JCHColorSeparateLine;
        [self.view addSubview:separateLine];
        
        [separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.view);
            make.bottom.equalTo(manifestDateTitleLabel);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
        
        separateLine = [[[UIView alloc] init] autorelease];
        separateLine.backgroundColor = JCHColorSeparateLine;
        [self.view addSubview:separateLine];
        
        [separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.view);
            make.bottom.equalTo(manifestTimeTitleLabel);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
        
        separateLine = [[[UIView alloc] init] autorelease];
        separateLine.backgroundColor = JCHColorSeparateLine;
        [self.view addSubview:separateLine];
        
        [separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.view);
            make.bottom.equalTo(manifestAmountTitleLabel);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
        
        separateLine = [[[UIView alloc] init] autorelease];
        separateLine.backgroundColor = JCHColorSeparateLine;
        [self.view addSubview:separateLine];
        
        [separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.view);
            make.bottom.equalTo(_manifestTypeSelectView);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];

        separateLine = [[[UIView alloc] init] autorelease];
        separateLine.backgroundColor = JCHColorSeparateLine;
        [self.view addSubview:separateLine];
        
        [separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.view);
            make.bottom.equalTo(_manifestPayWaySelectView);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
        
        separateLine = [[[UIView alloc] init] autorelease];
        separateLine.backgroundColor = JCHColorSeparateLine;
        [self.view addSubview:separateLine];
        
        [separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.view);
            make.bottom.equalTo(_manifestPayStatusSelectView);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];

        separateLine = [[[UIView alloc] init] autorelease];
        separateLine.backgroundColor = [UIColor grayColor];
        [self.view addSubview:separateLine];
        
        [separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_dateStartButton.mas_right).with.offset(kStandardLeftMargin / 2);
            make.right.equalTo(_dateEndButton.mas_left).with.offset(-kStandardLeftMargin / 2);
            make.centerY.equalTo(_dateStartButton);
            make.height.mas_equalTo(1);
        }];
        
        separateLine = [[[UIView alloc] init] autorelease];
        separateLine.backgroundColor = [UIColor grayColor];
        [self.view addSubview:separateLine];
        
        [separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_timeStartButton.mas_right).with.offset(kStandardLeftMargin / 2);
            make.right.equalTo(_timeEndButton.mas_left).with.offset(-kStandardLeftMargin / 2);
            make.centerY.equalTo(_timeStartButton);
            make.height.mas_equalTo(1);
        }];
        
        separateLine = [[[UIView alloc] init] autorelease];
        separateLine.backgroundColor = [UIColor grayColor];
        [self.view addSubview:separateLine];
        
        [separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_amountStartTextField.mas_right).with.offset(kStandardLeftMargin / 2);
            make.right.equalTo(_amountEndTextField.mas_left).with.offset(-kStandardLeftMargin / 2);
            make.centerY.equalTo(_amountStartTextField);
            make.height.mas_equalTo(1);
        }];
    }
    
    const CGFloat kUIDatePickerViewHeight = 240;
    CGRect pickerViewFrame = CGRectMake(0, 0, self.view.frame.size.width, kUIDatePickerViewHeight);
    _datePickerView = [[[JCHDatePickerView alloc] initWithFrame:pickerViewFrame
                                                         title:@"请选择货单日期"] autorelease];
    _datePickerView.delegate = self;
    _datePickerView.datePickerMode = UIDatePickerModeDate;
    [_datePickerView hide];
    
    _timePickerView = [[[JCHDatePickerView alloc] initWithFrame:pickerViewFrame
                                                          title:@"请选择货单时间"] autorelease];
    _timePickerView.delegate = self;
    _timePickerView.datePickerMode = UIDatePickerModeTime;
    [_timePickerView hide];
}

- (void)handlePopAction
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)commitOption
{
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSString *dateStartString = _dateStartButton.currentTitle;
    NSString *dateEndString = _dateEndButton.currentTitle;
    NSString *timeStartString = [[dateFormater stringFromDate:_startTime] substringFromIndex:11];
    NSString *timeEndString = [[dateFormater stringFromDate:_endTime] substringFromIndex:11];
    NSString *amountStartString = _amountStartTextField.text;
    NSString *amountEndString = _amountEndTextField.text;
    
#if 1
    if (![dateEndString isEqualToString:@""] && ![dateStartString isEqualToString:@""]) {
        NSComparisonResult comparisonResult = [dateStartString compare:dateEndString];
        if (comparisonResult == NSOrderedDescending) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                 message:@"日期范围选择有误"
                                                                delegate:nil
                                                       cancelButtonTitle:@"我知道了"
                                                       otherButtonTitles:nil] autorelease];
            [alertView show];
            
            return;
        }
    }
    
    if (![timeEndString isEqualToString:@""] && ![timeStartString isEqualToString:@""]) {
        NSComparisonResult comparisonResult = [timeStartString compare:timeEndString];
        if (comparisonResult == NSOrderedDescending) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                 message:@"时间范围选择有误"
                                                                delegate:nil
                                                       cancelButtonTitle:@"我知道了"
                                                       otherButtonTitles:nil] autorelease];
            [alertView show];
            
            return;
        }
    }
#endif
    if (![amountStartString isEqualToString:@""] && ![amountEndString isEqualToString:@""]) {
        if (amountStartString.doubleValue >= amountEndString.doubleValue) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                 message:@"金额范围有误"
                                                                delegate:nil
                                                       cancelButtonTitle:@"我知道了"
                                                       otherButtonTitles:nil] autorelease];
            [alertView show];
            
            return;
        }
    }
    
    NSInteger manifestType = _manifestTypeSelectView.selectedTag;
    NSInteger manifestPayWay = _manifestPayWaySelectView.selectedTag;
    NSInteger manifestPayStatus = _manifestPayStatusSelectView.selectedTag;
    
    //处理店员筛选tag对应问题
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (statusManager.isShopManager == NO) {
        if (manifestType == 0) {
            manifestType = 1;
        } else if (manifestType == 1) {
            manifestType = 3;
        }
        
        if (manifestPayStatus == 1) {
            manifestPayStatus = 2;
        }
    }
    
    NSDictionary *filterCondition = @{kManifestDateStartKey   : dateStartString,
                                      kManifestDateEndKey     : dateEndString,
                                      kManifestTimeStartKey   : timeStartString ? timeStartString : @"",
                                      kManifestTimeEndKey     : timeEndString ? timeEndString : @"",
                                      kManifestAmountStartKey : amountStartString ,
                                      kManifestAmountEndKey   : amountEndString,
                                      kManifestTypeKey        : @(manifestType),
                                      kManifestPayWayKey      : @(manifestPayWay),
                                      kManifestPayStatusKey   : @(manifestPayStatus)};
    self.manifestFilterCondition = filterCondition;
    
    if (self.sendValueBlock) {
        self.sendValueBlock(YES);
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)clearAllOption
{
    [_dateStartButton setTitle:@"" forState:UIControlStateNormal];
    [_dateEndButton setTitle:@"" forState:UIControlStateNormal];
    [_timeStartButton setTitle:@"" forState:UIControlStateNormal];
    [_timeEndButton setTitle:@"" forState:UIControlStateNormal];
    [self initTime];

    _amountStartTextField.text = @"";
    _amountEndTextField.text = @"";
    _manifestTypeSelectView.selectedTag = kJCHManifestSeletedTypeAll;
    _manifestPayWaySelectView.selectedTag = kJCHManifestPayWayAll;
    _manifestPayStatusSelectView.selectedTag = kJCHManifestPayStatusAll;
}

- (void)showDatePickerView:(UIButton *)sender
{
    [self.view endEditing:YES];
    _currentSelectedButton = sender;
    
    if (sender == _dateStartButton || sender == _dateEndButton) {
        [_datePickerView show];
    } else {
        [_timePickerView show];
    }
}

#pragma mark - JCHDatePickerViewDeletgate
- (void)handleDateChanged:(JCHDatePickerView *)datePicker selectedDate:(NSDate *)selectedDate
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    if (_currentSelectedButton == _dateStartButton || _currentSelectedButton == _dateEndButton) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    } else {
        [dateFormatter setDateFormat:@"HH:mm"];
    }
    
    NSString *dateString = [dateFormatter stringFromDate:selectedDate];
    [_currentSelectedButton setTitle:dateString forState:UIControlStateNormal];
    
    if (_currentSelectedButton == _timeStartButton) _startTime = selectedDate;
    if (_currentSelectedButton == _timeEndButton) _endTime = selectedDate;
}

@end
