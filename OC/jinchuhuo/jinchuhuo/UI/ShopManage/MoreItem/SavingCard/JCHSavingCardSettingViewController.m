//
//  JCHSavingCardSettingViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/5/18.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSavingCardSettingViewController.h"
#import "JCHSavingCardLadderCell.h"
#import "JCHAddSKUValueFooterView.h"
#import "CommonHeader.h"

static NSString *kSavingCardSettingCellReuseIdentifier = @"JCHSavingCardLadderCell";


typedef NS_ENUM(NSInteger, JCHDiscountWayType) {
    kJCHDiscountWayUniform,  //统一折扣
    kJCHDiscountWayLadder,   //阶梯折扣
};

@interface JCHSavingCardSettingViewController ()   <UITextFieldDelegate,
                                                    UIPickerViewDelegate,
                                                    UIPickerViewDataSource,
                                                    JCHPickerViewDelegate,
                                                    UITableViewDelegate,
                                                    UITableViewDataSource,
                                                    JCHAddSKUValueFooterViewDelegate>
{
    JCHArrowTapView *_discountWayView;
    JCHPickerView *_pickerView;
    
    UIView *_uniformContentView;  //统一折扣
    JCHTitleTextField *_discountTitleTextField;
    JCHTitleTextField *_lowestAmountTitleTextField;
    
    JCHDiscountWayType currentDiscountWayType;
}

@property (nonatomic, retain) NSArray *pickerViewDataSource;
@property (nonatomic, retain) NSMutableArray *cardDiscountRecordArray;
@end

@implementation JCHSavingCardSettingViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"储值卡设置";
        self.pickerViewDataSource = @[@"统一折扣", @"阶梯折扣"];
    }
    return self;
}

- (void)dealloc
{
    self.pickerViewDataSource = nil;
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
    [self loadData];
}

- (void)createUI
{
    UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(handleSaveRecord)] autorelease];
    self.navigationItem.rightBarButtonItem = saveButton;
    self.backgroundScrollView.contentSize = CGSizeMake(0, 0);
#if 1
    //折扣规则
    _discountWayView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
    _discountWayView.titleLabel.text = @"折扣规则";
    _discountWayView.detailLabel.text = self.pickerViewDataSource[0];
    [_discountWayView.button addTarget:self action:@selector(showPickerView) forControlEvents:UIControlEventTouchUpInside];
    [_discountWayView addSeparateLineWithMasonryTop:YES bottom:NO];
    [self.backgroundScrollView addSubview:_discountWayView];
    
    [_discountWayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.top.equalTo(self.backgroundScrollView).with.offset(kStandardSeparateViewHeight);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    const CGRect pickerRect = CGRectMake(0, kScreenHeight, self.view.frame.size.width, kJCHPickerViewHeight);
    _pickerView = [[[JCHPickerView alloc] initWithFrame:pickerRect title:@"折扣规则" showInView:self.view] autorelease];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;

    _uniformContentView = [[[UIView alloc] init] autorelease];
    [self.backgroundScrollView addSubview:_uniformContentView];
    
    [_uniformContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_discountWayView.mas_bottom);
        make.left.and.right.equalTo(_discountWayView);
        make.height.mas_equalTo(2 * kStandardItemHeight + kStandardSeparateViewHeight);
    }];
    
    
    //整单折扣
    _discountTitleTextField = [[JCHTitleTextField alloc] initWithTitle:@"整单折扣" font:JCHFontStandard placeholder:@"不打" textColor:JCHColorMainBody];
    _discountTitleTextField.bottomLine.hidden = YES;
    _discountTitleTextField.textField.keyboardType = UIKeyboardTypeNumberPad;
    _discountTitleTextField.rightViewText = @"折";
    _discountTitleTextField.textField.delegate = self;
    [_discountTitleTextField addSeparateLineWithMasonryTop:NO bottom:YES];
    [_uniformContentView addSubview:_discountTitleTextField];
    
    [_discountTitleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.height.equalTo(_discountWayView);
        make.top.equalTo(_discountWayView.mas_bottom);
    }];
    
    //最低充值金额
    _lowestAmountTitleTextField = [[JCHTitleTextField alloc] initWithTitle:@"最低充值金额" font:JCHFontStandard placeholder:@"输入金额" textColor:JCHColorMainBody];
    _lowestAmountTitleTextField.bottomLine.hidden = YES;
    [_lowestAmountTitleTextField addSeparateLineWithMasonryTop:YES bottom:YES];
    _lowestAmountTitleTextField.textField.keyboardType = UIKeyboardTypeNumberPad;
    _lowestAmountTitleTextField.rightViewText = @"元";
    [_uniformContentView addSubview:_lowestAmountTitleTextField];
    
    [_lowestAmountTitleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_discountTitleTextField.mas_bottom).with.offset(kStandardSeparateViewHeight);
        make.left.and.right.and.height.equalTo(_discountTitleTextField);
    }];
    
    

    self.tableView.hidden = YES;
    [self.tableView removeFromSuperview];
    [self.backgroundScrollView addSubview:self.tableView];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_discountWayView.mas_bottom);
        make.left.and.right.equalTo(_discountWayView);
        make.bottom.equalTo(self.view);
    }];
    
    [self.tableView registerClass:[JCHSavingCardLadderCell class] forCellReuseIdentifier:kSavingCardSettingCellReuseIdentifier];
    JCHAddSKUValueFooterView *footerView = [[[JCHAddSKUValueFooterView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kStandardItemHeight)] autorelease];
    [footerView addSeparateLineWithMasonryTop:NO bottom:YES];
    footerView.backgroundColor = [UIColor whiteColor];
    footerView.delegate = self;
    [footerView setTitleName:@"添加阶梯"];
    self.tableView.tableFooterView = footerView;
#endif
}

#pragma mark - LoadData
- (void)loadData
{
    id <CardDiscountService> cardDiscountService = [[ServiceFactory sharedInstance] cardDiscountService];
    
    NSArray *cardDiscountRecordArray = [cardDiscountService queryAllCardDiscount];
    
    self.cardDiscountRecordArray = [NSMutableArray arrayWithArray:cardDiscountRecordArray];
    
    if (self.cardDiscountRecordArray.count == 0) {
        CardDiscountRecord4Cocoa *record = [[[CardDiscountRecord4Cocoa alloc] init] autorelease];
        record.amountLower = -1;
        record.amountUpper = -1;
        record.discount = 1;
        [self.cardDiscountRecordArray addObject:record];
    } else if (self.cardDiscountRecordArray.count == 1) {
        //统一折扣
        [self showUniformContentView:YES];
        CardDiscountRecord4Cocoa *cardDiscountRecord = self.cardDiscountRecordArray[0];
        _discountTitleTextField.textField.text = [JCHSavingCardUtility switchToDiscountStringValue:cardDiscountRecord.discount];
        _lowestAmountTitleTextField.textField.text = [JCHSavingCardUtility switchToAmountStringValue:cardDiscountRecord.amountLower];
    } else {
        //阶梯折扣
        CardDiscountRecord4Cocoa *cardDiscountRecord = [self.cardDiscountRecordArray lastObject];
        if (cardDiscountRecord.amountUpper == kSavingCardAmountUpperMax) {
            cardDiscountRecord.amountUpper = -1;
        }
        [self showUniformContentView:NO];
        [self.tableView reloadData];
    }
}

- (void)showUniformContentView:(BOOL)show
{
    if (show) {
        //统一折扣
        self.tableView.hidden = YES;
        _uniformContentView.hidden = NO;
        _discountWayView.bottomLine.hidden = NO;
        currentDiscountWayType = kJCHDiscountWayUniform;
        _discountWayView.detailLabel.text = self.pickerViewDataSource[0];
    } else {
        //阶梯折扣
        self.tableView.hidden = NO;
        _uniformContentView.hidden = YES;
        _discountWayView.bottomLine.hidden = YES;
        currentDiscountWayType = kJCHDiscountWayLadder;
        _discountWayView.detailLabel.text = self.pickerViewDataSource[1];
        
        //如果只有一个record,清空此record
        if (self.cardDiscountRecordArray.count == 1) {
            CardDiscountRecord4Cocoa *record = [self.cardDiscountRecordArray lastObject];
            record.amountLower = -1;
            record.amountUpper = -1;
            record.discount = 1;
        }
        [self.tableView reloadData];
    }
}

#pragma mark - SaveRecord
- (void)handleSaveRecord
{
    id <CardDiscountService> cardDiscountService = [[ServiceFactory sharedInstance] cardDiscountService];
    id <UtilityService> utilityService = [[ServiceFactory sharedInstance] utilityService];
    
    //统一折扣
    if (currentDiscountWayType == kJCHDiscountWayUniform) {
        
        if ([_lowestAmountTitleTextField.textField.text isEqualToString:@""]) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                 message:@"请输入最低充值金额"
                                                                delegate:nil
                                                       cancelButtonTitle:@"我知道了"
                                                       otherButtonTitles:nil] autorelease];
            [alertView show];
            return;
        }
        
        if ([JCHSavingCardUtility switchToDiscountFloatValue:_discountTitleTextField.textField.text] == 0) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                 message:@"折扣不能为0，请重新输入"
                                                                delegate:nil
                                                       cancelButtonTitle:@"我知道了"
                                                       otherButtonTitles:nil] autorelease];
            [alertView show];
            return;
        }
        
        //删掉所有的record
        for (CardDiscountRecord4Cocoa *record in self.cardDiscountRecordArray) {
            if (record.recordUUID) {
                [cardDiscountService deleteAccount:record.recordUUID];
            }
        }
        //再保存一条record
        CardDiscountRecord4Cocoa *record = [[[CardDiscountRecord4Cocoa alloc] init] autorelease];
        record.recordUUID = [utilityService generateUUID];
        record.amountLower = [JCHSavingCardUtility switchToAmountFloatValue:_lowestAmountTitleTextField.textField.text];
        record.amountUpper = kSavingCardAmountUpperMax;
        record.discount = [JCHSavingCardUtility switchToDiscountFloatValue:_discountTitleTextField.textField.text];
        [cardDiscountService insertAccount:record];
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        //阶梯折扣
        
        //最后一个record如果没填价格上限，赋10000000
        CardDiscountRecord4Cocoa *lastRecord = [self.cardDiscountRecordArray lastObject];
        if (lastRecord.amountUpper == -1) {
            lastRecord.amountUpper = kSavingCardAmountUpperMax;
        }
        
        for (CardDiscountRecord4Cocoa *record in self.cardDiscountRecordArray) {
            if (record.amountLower == -1 || record.amountUpper == -1) {
                UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"阶梯价格不能为空" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil] autorelease];
                [alertView show];
                
                return;
            }
            
            if (record.amountLower != -1 && record.amountUpper != -1 && record.amountUpper <= record.amountLower) {
                UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"阶梯价格上限必须大于价格下限" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil] autorelease];
                [alertView show];
                return;
            }
            
            if (record.amountUpper > kSavingCardAmountUpperMax || record.amountLower > kSavingCardAmountUpperMax) {
                UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"阶梯价格太大，请重新填写(最大支持10000000)" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil] autorelease];
                [alertView show];
                return;
            }
            
            if (record.discount == 0) {
                UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                     message:@"折扣不能为0，请重新输入"
                                                                    delegate:nil
                                                           cancelButtonTitle:@"我知道了"
                                                           otherButtonTitles:nil] autorelease];
                [alertView show];
                return;
            }
        }
        
        //如果选的阶梯类型并且只有一个阶梯,提示用户
        if (self.cardDiscountRecordArray.count < 2) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"阶梯数量必须大于1个" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil] autorelease];
            [alertView show];
            return;
        }
        
        
        for (CardDiscountRecord4Cocoa *record in self.cardDiscountRecordArray) {
            if (record.recordUUID) {
                [cardDiscountService updateAccount:record];
            } else {
                record.recordUUID = [utilityService generateUUID];
                [cardDiscountService insertAccount:record];
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    //检测储值卡账户是否存在，不存在则创建
    id<AccountService> accountService = [[ServiceFactory sharedInstance] accountService];
    
    if (NO == [accountService isCardAccountExist]) {
        [accountService addCardAccount];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cardDiscountRecordArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHSavingCardLadderCell *cell = [tableView dequeueReusableCellWithIdentifier:kSavingCardSettingCellReuseIdentifier];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //// cell上的textField结束编辑时的block
    [cell setTextFieldDidEndEditingBlock:^(UITextField *textField, JCHSavingCardLadderCell *cell) {
        [self textFieldDidEndEditing:textField inCell:cell];
    }];
    
    //cell上的充值上限textFile正在编辑时的block
    [cell setTextFieldEditingChangedBlock:^(UITextField *textField, JCHSavingCardLadderCell *cell) {
        [self textFieldEditingChaged:textField inCell:cell];
    }];
    
    //只有第一个阶梯的充值下限可编辑
    if (indexPath.row == 0) {
        [cell setLowerLimitAmountTextFieldEnabled:YES];
    } else {
        [cell setLowerLimitAmountTextFieldEnabled:NO];
    }
    CardDiscountRecord4Cocoa *record = self.cardDiscountRecordArray[indexPath.row];
    
    JCHSavingCardLadderCellData *data = [[[JCHSavingCardLadderCellData alloc] init] autorelease];
    data.index = indexPath.row + 1;
    data.lowerLimitAmount = record.amountLower;
    
    if (record.amountUpper == kSavingCardAmountUpperMax) {
        data.upperLimitAmount = -1;
    } else {
        data.upperLimitAmount = record.amountUpper;
    }
    
    data.discount = record.discount;
    
    [cell setCellData:data];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    JCHSeparateLineSectionView *view = [[[JCHSeparateLineSectionView alloc] initWithTopLine:YES BottomLine:YES] autorelease];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kStandardSeparateViewHeight;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        id<CardDiscountService> cardDiscountService = [[ServiceFactory sharedInstance] cardDiscountService];
        
        if (indexPath.row == 0 || indexPath.row == self.cardDiscountRecordArray.count - 1) {
            //如果是第一行或最后一行直接删除
            CardDiscountRecord4Cocoa *record = self.cardDiscountRecordArray[indexPath.row];
            if (record.recordUUID) {
                [cardDiscountService deleteAccount:record.recordUUID];
            }
            [self.cardDiscountRecordArray removeObject:record];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            //如果是中间行，删除之后下一行的价格下限变为上一行的价格上限
            CardDiscountRecord4Cocoa *currentRecord = self.cardDiscountRecordArray[indexPath.row];
            CardDiscountRecord4Cocoa *lastRecord = self.cardDiscountRecordArray[indexPath.row - 1];
            CardDiscountRecord4Cocoa *nextRecord = self.cardDiscountRecordArray[indexPath.row + 1];
            
            if (currentRecord.recordUUID) {
                [cardDiscountService deleteAccount:currentRecord.recordUUID];
            }
            nextRecord.amountLower = lastRecord.amountUpper;
            [self.cardDiscountRecordArray removeObject:currentRecord];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}


#pragma mark - JCHPickerViewDelegate
- (void)pickerViewWillHide:(JCHPickerView *)pickerView
{
    if ([_discountWayView.detailLabel.text isEqualToString:self.pickerViewDataSource[0]]) {
        [self showUniformContentView:YES];
    } else {
        [self showUniformContentView:NO];
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
    return self.pickerViewDataSource[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _discountWayView.detailLabel.text = self.pickerViewDataSource[row];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.pickerViewDataSource.count;
}


#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length < 2 || [string isEqualToString:@""]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - JCHAddSKUValueFooterViewDelegate
- (void)addItem
{
    CardDiscountRecord4Cocoa *lastRecord = [self.cardDiscountRecordArray lastObject];
    CardDiscountRecord4Cocoa *newRecord = [[[CardDiscountRecord4Cocoa alloc] init] autorelease];
    newRecord.amountLower = -1;
    newRecord.amountUpper = -1;
    newRecord.discount = 1;
    
    //新加的阶梯充值下限等于上个阶梯的充值上限（如果存在）
    if (lastRecord.amountUpper != -1) {
        newRecord.amountLower = lastRecord.amountUpper;
    }
    [self.cardDiscountRecordArray addObject:newRecord];
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.cardDiscountRecordArray.count - 1 inSection:0];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)showPickerView
{
    [self.view endEditing:YES];
    [_pickerView show];
    [_pickerView.pickerView selectRow:[self.pickerViewDataSource indexOfObject:_discountWayView.detailLabel.text] inComponent:0 animated:NO];
}


// cell上的textField结束编辑时调用
- (void)textFieldDidEndEditing:(UITextField *)textField inCell:(JCHSavingCardLadderCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    CardDiscountRecord4Cocoa *cardDiscountRecord = self.cardDiscountRecordArray[indexPath.row];

    switch (textField.tag) {
        case kJCHSavingCardLadderCellDiscountTextFieldTag:
        {
            cardDiscountRecord.discount = [JCHSavingCardUtility switchToDiscountFloatValue:textField.text];
        }
            break;
            
        case kJCHSavingCardLadderCellLowerLimitAmountTextFieldTag:
        {
            cardDiscountRecord.amountLower = [JCHSavingCardUtility switchToAmountFloatValue:textField.text];
        }
            break;
            
        case kJCHSavingCardLadderCellUpperLimitAmountTextFieldTag:
        {
            cardDiscountRecord.amountUpper = [JCHSavingCardUtility switchToAmountFloatValue:textField.text];
        }
            break;
            
        default:
            break;
    }
}

//textFile正在编辑时调用
- (void)textFieldEditingChaged:(UITextField *)textField inCell:(JCHSavingCardLadderCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    CardDiscountRecord4Cocoa *currentCardDiscountRecord = self.cardDiscountRecordArray[indexPath.row];
    
    switch (textField.tag) {
        case kJCHSavingCardLadderCellDiscountTextFieldTag:
        {
            currentCardDiscountRecord.discount = [JCHSavingCardUtility switchToDiscountFloatValue:textField.text];
        }
            break;
            
        case kJCHSavingCardLadderCellLowerLimitAmountTextFieldTag:
        {
            currentCardDiscountRecord.amountLower = [JCHSavingCardUtility switchToAmountFloatValue:textField.text];
        }
            break;
            
        case kJCHSavingCardLadderCellUpperLimitAmountTextFieldTag:
        {
            CGFloat amountUpper = [JCHSavingCardUtility switchToAmountFloatValue:textField.text];
            if (amountUpper >= kSavingCardAmountUpperMax) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                    message:@"输入金额过大，请重新输入"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"我知道了"
                                                          otherButtonTitles:nil];
                [alertView show];
                textField.text = @"";
                currentCardDiscountRecord.amountUpper = -1;
            } else {
                currentCardDiscountRecord.amountUpper = [JCHSavingCardUtility switchToAmountFloatValue:textField.text];
            }
            
            //如果当前编辑的是充值上限并且下一个cell存在，则让下一个cell的充值下限和当前cell的充值上限保持一致
            if (indexPath.row < self.cardDiscountRecordArray.count - 1) {
                CardDiscountRecord4Cocoa *cardDiscountRecord = self.cardDiscountRecordArray[indexPath.row + 1];
                cardDiscountRecord.amountLower = [JCHSavingCardUtility switchToAmountFloatValue:textField.text];;
                NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
                [self.tableView reloadRowsAtIndexPaths:@[nextIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
            break;
            
        default:
            break;
    }
}


@end
