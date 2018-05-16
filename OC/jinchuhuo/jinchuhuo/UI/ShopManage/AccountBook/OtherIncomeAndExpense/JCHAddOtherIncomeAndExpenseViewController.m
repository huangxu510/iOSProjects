//
//  JCHAddOtherIncomeAndExpenseViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/10/18.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAddOtherIncomeAndExpenseViewController.h"
#import "JCHJournalAccountViewController.h"
#import "JCHSettleAccountsKeyboardView.h"
#import "JCHIconTextTapView.h"
#import "JCHDatePickerView.h"
#import "JCHInputView.h"
#import "JCHItemSelectButton.h"
#import "CommonHeader.h"

#define kDefaultRemark @"添加备注信息"

@interface JCHAddOtherIncomeAndExpenseViewController () <JCHSettleAccountsKeyboardViewDelegate,
                                                        JCHDatePickerViewDelegate,
                                                        JCHInputViewDelegate,
                                                        UIScrollViewDelegate>
{
    UISegmentedControl *_segmentedControl;
    JCHLengthLimitTextField *_amountTextField;
    JCHSettleAccountsKeyboardView *_keyboard;
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    JCHIconTextTapView *_dateSelectView;
    JCHIconTextTapView *_remarkView;
    JCHDatePickerView *_datePickerView;
    JCHInputView *_inputView;
}

@property (nonatomic, retain) NSArray *incomeRecordList;
@property (nonatomic, retain) NSArray *expenseRecordList;
@property (nonatomic, retain) JCHItemSelectButton *selectedButton;
@property (nonatomic, assign) JCHIncomeExpenseOperation currentOperationType;
@property (nonatomic, retain) AccountTransactionRecord4Cocoa *currentManifestRecord;


@end

@implementation JCHAddOtherIncomeAndExpenseViewController

- (id)initWithType:(JCHIncomeExpenseOperation)operationType transaction:(AccountTransactionRecord4Cocoa *)record
{
    self = [super init];
    if (self) {
        self.currentOperationType = operationType;
        self.currentManifestRecord = record;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
}


- (void)dealloc
{
    self.currentManifestRecord = nil;
    self.incomeRecordList = nil;
    self.expenseRecordList = nil;
    self.selectedButton = nil;
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)createUI
{
    CGFloat amountTextFieldHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:65.0f];
    
    if (self.currentOperationType == kCreateIncomeExpense) {
        _segmentedControl = [[[UISegmentedControl alloc] initWithItems:@[@"支出", @"收入"]] autorelease];
        _segmentedControl.frame = CGRectMake(0, 0, 140, 30);
        _segmentedControl.selectedSegmentIndex = 0;
        [_segmentedControl addTarget:self action:@selector(switchIncomeExpense:) forControlEvents:UIControlEventValueChanged];
        self.navigationItem.titleView = _segmentedControl;
    } else if (self.currentOperationType == kModifyIncomeExpense) {
        if (self.currentManifestRecord.manifestType == kJCHManifestExtraIncome) {
            self.navigationItem.title = @"编辑收入流水";
        } else if (self.currentManifestRecord.manifestType == kJCHManifestExtraExpenses) {
            self.navigationItem.title = @"编辑支出流水";
        }
    }
    
    UIView *topContainerView = [[[UIView alloc] init] autorelease];
    topContainerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topContainerView];
    
    [topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(amountTextFieldHeight);
    }];
    
    _amountTextField = [JCHUIFactory createLengthLimitTextField:CGRectZero
                                                    placeHolder:@""
                                                      textColor:JCHColorMainBody
                                                         aligin:NSTextAlignmentRight];
    _amountTextField.keyboardType = UIKeyboardTypeNumberPad;
    _amountTextField.inputAccessoryView = nil;
    _amountTextField.font = [UIFont systemFontOfSize:24.0f];
    _amountTextField.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:@"请输入金额" attributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xd5d5d5), NSFontAttributeName : [UIFont systemFontOfSize:20.0f]}] autorelease];
    [_amountTextField becomeFirstResponder];
    [topContainerView addSubview:_amountTextField];
    
    [_amountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(topContainerView).with.offset(-kStandardLeftMargin);
        make.top.and.bottom.equalTo(topContainerView);
        make.left.equalTo(topContainerView).with.offset(kStandardLeftMargin);
    }];
    
    CGFloat middleContainerViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:320.0f];
    CGFloat keyboardHeight = kScreenHeight - 64 - amountTextFieldHeight - middleContainerViewHeight;
    _keyboard = [[[JCHSettleAccountsKeyboardView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, keyboardHeight)
                                                       keyboardHeight:keyboardHeight
                                                              topView:nil
                                               topContainerViewHeight:0] autorelease];
    _keyboard.delegate = self;
    _amountTextField.inputView = _keyboard;
    
    UIView *middleContainerView = [[[UIView alloc] init] autorelease];
    middleContainerView.backgroundColor = JCHColorGlobalBackground;
    [self.view addSubview:middleContainerView];
    
    [middleContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topContainerView.mas_bottom);
        make.left.right.equalTo(topContainerView);
        make.height.mas_equalTo(middleContainerViewHeight);
    }];
    
    CGFloat remarkViewHeight = 35;
    CGFloat pageControlHeight = 35;
    CGFloat remarkViewBottomOffset = 20;
    CGFloat scrollViewHeight = middleContainerViewHeight - 2 * remarkViewHeight - pageControlHeight - remarkViewBottomOffset;
    _scrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, scrollViewHeight)] autorelease];
    _scrollView.bounces = YES;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    [middleContainerView addSubview:_scrollView];
    
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(middleContainerView);
        make.height.mas_equalTo(scrollViewHeight);
    }];
    
    
    
    _pageControl = [[[UIPageControl alloc] init] autorelease];
    _pageControl.pageIndicatorTintColor = UIColorFromRGB(0xd5d5d5);
    _pageControl.currentPageIndicatorTintColor = JCHColorMainBody;
    _pageControl.enabled = NO;
    [middleContainerView addSubview:_pageControl];
    
    [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_scrollView.mas_bottom);
        make.left.right.equalTo(_scrollView);
        make.height.mas_equalTo(pageControlHeight);
    }];
    
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    NSDate *date = [NSDate date];
    _dateSelectView = [[[JCHIconTextTapView alloc] initWithFrame:CGRectZero] autorelease];
    _dateSelectView.iconImageView.image = [UIImage imageNamed:@"otherIncomeAndExpense_date"];
    _dateSelectView.textLabel.text = [dateFormater stringFromDate:date];
    _dateSelectView.textLabel.font = JCHFont(12);
    WeakSelf;
    [_dateSelectView setTapBlock:^{
        [weakSelf selectDate];
    }];
    [middleContainerView addSubview:_dateSelectView];
    
    [_dateSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(middleContainerView);
        make.top.equalTo(_pageControl.mas_bottom);
        make.height.mas_equalTo(remarkViewHeight);
    }];
    
    _remarkView = [[[JCHIconTextTapView alloc] initWithFrame:CGRectZero] autorelease];
    _remarkView.textLabel.text = kDefaultRemark;
    _remarkView.textLabel.font = JCHFont(12);
    _remarkView.iconImageView.image = [UIImage imageNamed:@"otherIncomeAndExpense_remark"];
    [_remarkView setTapBlock:^{
        [weakSelf editRemark];
    }];
    [middleContainerView addSubview:_remarkView];
    
    [_remarkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(_dateSelectView);
        make.top.equalTo(_dateSelectView.mas_bottom);
    }];
    
    // 如果为编辑流水，恢复UI状态
    if (kModifyIncomeExpense == self.currentOperationType) {
        _amountTextField.text = [NSString stringWithFormat:@"¥ %.2f", fabs(self.currentManifestRecord.amount)];
        if (![self.currentManifestRecord.remark isEmptyString] ) {
            _remarkView.textLabel.text = self.currentManifestRecord.remark;
        }
        
        NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormater setDateFormat:@"yyyy年MM月dd日 HH:mm"];
        
        NSDate *manifestDate = [NSDate dateWithTimeIntervalSince1970:self.currentManifestRecord.transTime];
        NSString *selectedDateString = [dateFormater stringFromDate:manifestDate];
        _dateSelectView.textLabel.text = selectedDateString;
    }
}

- (void)createItem
{
    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    
    NSString *dictPath = [[NSBundle mainBundle] pathForResource:@"OtherIncomeExpenseIconNameMap.plist" ofType:@""];
    NSDictionary *iconNameDict = [[[NSDictionary alloc] initWithContentsOfFile:dictPath] autorelease];
    
    CGRect scrollViewRect = _scrollView.frame;
    
    NSArray *recordList = nil;
    if (kCreateIncomeExpense == self.currentOperationType) {
        if (_segmentedControl.selectedSegmentIndex == 0) {
            recordList = self.expenseRecordList;
        } else {
            recordList = self.incomeRecordList;
        }
    } else if (kModifyIncomeExpense == self.currentOperationType) {
        if (self.currentManifestRecord.manifestType == kJCHManifestExtraExpenses) {
            recordList = self.expenseRecordList;
        } else if (self.currentManifestRecord.manifestType == kJCHManifestExtraIncome) {
            recordList = self.incomeRecordList;
        }
    }

    NSInteger numberItemPerPage = 10;
    NSInteger numberOfPages = ceil((CGFloat)recordList.count / numberItemPerPage);
    _pageControl.numberOfPages = numberOfPages;
    if (numberOfPages == 1) {
        _pageControl.hidden = YES;
    } else {
        _pageControl.hidden = NO;
    }
    _scrollView.contentSize = CGSizeMake(numberOfPages * scrollViewRect.size.width, 0);
    for (NSInteger i = 0; i < numberOfPages; i++) {
        
        CGFloat containerViewWidth = scrollViewRect.size.width;
        CGFloat containerViewHeight = scrollViewRect.size.height;
        CGFloat containerViewX = containerViewWidth * i;
        CGFloat containerViewY = 0;
        
        
        UIView *subContainerView = [[[UIView alloc] init] autorelease];
        subContainerView.frame = CGRectMake(containerViewX, containerViewY, containerViewWidth, containerViewHeight);
        [_scrollView addSubview:subContainerView];
        
        NSInteger numberItemThisPage = 10;
        if (i == numberOfPages - 1) {
            numberItemThisPage = recordList.count % numberItemPerPage;
        }
        
        
        CGFloat buttonTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:25.0f];
        for (NSInteger j = 0; j < numberItemThisPage; j++) {
            
            CGFloat itemWidth = containerViewWidth / 5;
            CGFloat itemHeight = containerViewHeight / 2 - buttonTopOffset;
            CGFloat itemX = j % 5 * itemWidth;
            CGFloat itemY = j / 5 * (itemHeight + buttonTopOffset) + buttonTopOffset;
            
            JCHItemSelectButton *button = [[[JCHItemSelectButton alloc] initWithFrame:CGRectMake(itemX, itemY, itemWidth, itemHeight)] autorelease];
            button.imageViewBackgroundColorWhenSelected = JCHColorHeaderBackground;
            button.tag = j + i * numberItemPerPage;
            [button addTarget:self action:@selector(selectCategory:) forControlEvents:UIControlEventTouchUpInside];
            
            AccountRecord4Cocoa *accountRecord = recordList[button.tag];
            [button setTitle:accountRecord.accountName forState:UIControlStateNormal];
            NSString *iconName = iconNameDict[accountRecord.accountName];
            [button setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
            button.titleLabel.font = JCHFont(12);
            
            [subContainerView addSubview:button];
            
            // 如果为编辑流水，恢复UI状态
            if (kModifyIncomeExpense == self.currentOperationType) {
                if ([accountRecord.accountName isEqualToString:self.currentManifestRecord.recordDescription]) {
                    button.selected = YES;
                    self.selectedButton = button;
                }
            }
        }
    }
}

#pragma mark - LoadData
- (void)loadData
{
    id<AccountService> accountService = [[ServiceFactory sharedInstance] accountService];
    NSArray *incomeRecordList = nil;
    NSArray *expenseRecordList = nil;
    [accountService queryExtraIncomeExpenseAccount:&incomeRecordList expenseAccount:&expenseRecordList];
    
    //将其它费用和其它收入排到后面
    NSMutableArray *incomeRecordListMutable = [NSMutableArray arrayWithArray:incomeRecordList];
    AccountRecord4Cocoa *otherIncomeRecord = nil;
    for (AccountRecord4Cocoa *accountRecord in incomeRecordListMutable) {
        if ([accountRecord.accountName isEqualToString:@"其它收入"]) {
            otherIncomeRecord = accountRecord;
            break;
        }
    }
    
    if (otherIncomeRecord) {
        [incomeRecordListMutable removeObject:otherIncomeRecord];
        [incomeRecordListMutable addObject:otherIncomeRecord];
    }
    
    
    NSMutableArray *expenseRecordListMutable = [NSMutableArray arrayWithArray:expenseRecordList];
    AccountRecord4Cocoa *otherExpenseRecord = nil;
    for (AccountRecord4Cocoa *accountRecord in expenseRecordListMutable) {
        if ([accountRecord.accountName isEqualToString:@"其它费用"]) {
            otherExpenseRecord = accountRecord;
            break;
        }
    }
    
    if (otherExpenseRecord) {
        [expenseRecordListMutable removeObject:otherExpenseRecord];
        [expenseRecordListMutable addObject:otherExpenseRecord];
    }
    
    self.incomeRecordList = incomeRecordListMutable;
    self.expenseRecordList = expenseRecordListMutable;
    
    [self createItem];
}

- (void)switchIncomeExpense:(UISegmentedControl *)sender
{
    [self createItem];
}

#pragma - SaveData
- (void)saveData
{
    if (self.selectedButton == nil) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"未选择费用类型"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    if ([_amountTextField.text isEmptyString]) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"请输入金额"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    
    //货单类型
    NSInteger manifestType = kJCHManifestExtraIncome;
    //金额
    CGFloat amount = [[_amountTextField.text stringByReplacingOccurrencesOfString:@"¥ " withString:@""] doubleValue];
    
    //时间
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    NSDate *date = [dateFormater dateFromString:_dateSelectView.textLabel.text];
    NSInteger manifestTime = [date timeIntervalSince1970];
    
    //操作人id
    NSInteger operatorID = [[[JCHSyncStatusManager shareInstance] userID] integerValue];
    
    //fromUUID & toUUID
    NSString *fromUUID = @"";
    NSString *toUUID = @"";
    AccountRecord4Cocoa *accountRecord = nil;
    
    if (self.currentOperationType == kCreateIncomeExpense) {
        if (_segmentedControl.selectedSegmentIndex == 0) {
            //支出
            manifestType = kJCHManifestExtraExpenses;
            accountRecord = self.expenseRecordList[self.selectedButton.tag];
            fromUUID = [manifestService getDefaultCashRMBAccountUUID];
            toUUID = accountRecord.accountUUID;
        } else {
            //收入
            manifestType = kJCHManifestExtraIncome;
            accountRecord = self.incomeRecordList[self.selectedButton.tag];
            fromUUID = accountRecord.accountUUID;
            toUUID = [manifestService getDefaultCashRMBAccountUUID];
        }
    } else if (self.currentOperationType == kModifyIncomeExpense) {
        if (kJCHManifestExtraIncome == self.currentManifestRecord.manifestType) {
            manifestType = kJCHManifestExtraIncome;
            accountRecord = self.incomeRecordList[self.selectedButton.tag];
            fromUUID = accountRecord.accountUUID;
            toUUID = [manifestService getDefaultCashRMBAccountUUID];
        } else if (kJCHManifestExtraExpenses == self.currentManifestRecord.manifestType) {
            manifestType = kJCHManifestExtraExpenses;
            accountRecord = self.expenseRecordList[self.selectedButton.tag];
            fromUUID = [manifestService getDefaultCashRMBAccountUUID];
            toUUID = accountRecord.accountUUID;
        }
    }

    //备注
    NSString *remark = [_remarkView.textLabel.text isEqualToString:kDefaultRemark] ? @"" : _remarkView.textLabel.text;
    
    int status = 0;
    if (self.currentOperationType == kCreateIncomeExpense) {
        status = [manifestService insertIncomeExpenses:manifestType
                                                amount:amount
                                          manifestTime:manifestTime
                                       fromAccountUUID:fromUUID
                                         toAccountUUID:toUUID
                                            operatorID:operatorID
                                                remark:remark];
    } else if (self.currentOperationType == kModifyIncomeExpense) {
        status = [manifestService updateIncomeExpenses:manifestType
                                            manifestID:self.currentManifestRecord.manifestID
                                                amount:amount
                                          manifestTime:manifestTime
                                       fromAccountUUID:fromUUID
                                         toAccountUUID:toUUID
                                            operatorID:operatorID
                                                remark:remark];
    }
    
    NSString *message = @"";
    if (status == 0) {
        message = @"保存成功";
    } else {
        message = @"保存失败";
    }
    [MBProgressHUD showHUDWithTitle:message
                             detail:@""
                           duration:kJCHDefaultShowHudTime
                               mode:MBProgressHUDModeText
                         completion:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
    NSArray *viewControllers = self.navigationController.viewControllers;
    if ([viewControllers[viewControllers.count - 1] isKindOfClass:[JCHJournalAccountViewController class]]) {
        JCHJournalAccountViewController *vc = (JCHJournalAccountViewController *)viewControllers[viewControllers.count - 1];
        vc.isNeedReloadAllData = YES;
    }
}

- (void)selectCategory:(JCHItemSelectButton *)sender
{
    NSLog(@"tag = %ld", sender.tag);
    sender.selected = !sender.selected;
    
    if (sender != self.selectedButton) {
        self.selectedButton.selected = NO;
        self.selectedButton = sender;
    } else {
        if (!sender.selected) {
            self.selectedButton = nil;
        }
    }
}

- (void)selectDate
{
    [_amountTextField resignFirstResponder];
    
    const CGFloat kUIDatePickerViewHeight = 240;
    CGRect pickerViewFrame = CGRectMake(0, 0, self.view.frame.size.width, kUIDatePickerViewHeight);
    _datePickerView = [[[JCHDatePickerView alloc] initWithFrame:pickerViewFrame
                                                         title:@"请选时间"] autorelease];
    _datePickerView.delegate = self;
    _datePickerView.datePickerMode = UIDatePickerModeDateAndTime;
    
    [_datePickerView show];
}

- (void)editRemark
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    _inputView = [[[JCHInputView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 44)] autorelease];
    
    _inputView.delegate = self;
    [_inputView show];
    
    _inputView.textView.returnKeyType = UIReturnKeyDone;
    [_amountTextField resignFirstResponder];
}

- (void)keyboardShow:(NSNotification *)note
{
    CGRect keyBoardRect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat deltaY = keyBoardRect.size.height;
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        _inputView.transform = CGAffineTransformMakeTranslation(0, -deltaY - 44);
    }];

    _inputView.textView.text = [_remarkView.textLabel.text isEqualToString:kDefaultRemark] ? @"" : _remarkView.textLabel.text;
}

- (void)keyboardHide:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_amountTextField becomeFirstResponder];
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        _inputView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [_amountTextField becomeFirstResponder];
    }];
}

#pragma mark - JCHInputViewDelegate
- (void)inputViewWillHide:(JCHInputView *)theInputView textView:(UITextView *)contentTextView
{
    _remarkView.textLabel.text = [contentTextView.text isEmptyString] ? kDefaultRemark : contentTextView.text;
}


#pragma mark - JCHDatePickerViewDelegate
- (void)handleDatePickerViewDidHide:(JCHDatePickerView *)datePicker selectedDate:(NSDate *)selectedDate;
{
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    NSString *selectedDateString = [dateFormater stringFromDate:selectedDate];
    _dateSelectView.textLabel.text = selectedDateString;
    
    return;
}

- (void)handleDatePickerViewWillHide:(JCHDatePickerView *)datePicker
{
    [_amountTextField becomeFirstResponder];
}

#pragma mark - JCHSettleAccountsKeyboardViewDelegate

- (void)keyboardViewInputNumber:(NSString *)number
{
    NSString *text = [_amountTextField.text stringByReplacingOccurrencesOfString:@"¥ " withString:@""];
    _amountTextField.text = [NSString stringWithFormat:@"¥ %@", [text stringByAppendingString:number]];
}

- (void)keyboardViewFunctionButtonClick:(NSInteger)buttonTag;
{
    NSString *text = [_amountTextField.text stringByReplacingOccurrencesOfString:@"¥ " withString:@""];
    
    switch (buttonTag) {
        case kJCHSettleAccountsKeyboardViewButtonTagDot:
        {
            _amountTextField.text = [NSString stringWithFormat:@"¥ %@", [text stringByAppendingString:@"."]];
        }
            break;
        case kJCHSettleAccountsKeyboardViewButtonTagBackSpace:
        {
            if (text.length == 0) {
                return;
            }
            if (text.length != 1) {
                _amountTextField.text = [NSString stringWithFormat:@"¥ %@", [text substringToIndex:text.length - 1]];
            } else {
                _amountTextField.text = @"";
            }
        }
            break;
        case kJCHSettleAccountsKeyboardViewButtonTagClear:
        {
            _amountTextField.text = @"";
        }
            break;
        case kJCHSettleAccountsKeyboardViewButtonTagOK:
        {
            [self saveData];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = (NSInteger)scrollView.contentOffset.x / (NSInteger)scrollView.frame.size.width;
    _pageControl.currentPage = index;
}

@end
