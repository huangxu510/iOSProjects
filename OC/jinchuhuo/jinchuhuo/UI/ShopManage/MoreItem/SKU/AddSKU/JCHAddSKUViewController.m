//
//  JCHAddSpecificationViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/26.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHAddSKUViewController.h"
#import "JCHAddSKUValueFooterView.h"
#import "JCHAddSKUValueTableViewCell.h"
#import "JCHSeparateLineSectionView.h"
#import "JCHArrowTapView.h"
#import "JCHPickerView.h"
#import "JCHUISettings.h"
#import "JCHUISizeSettings.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHUIFactory.h"
#import "SKURecord4Cocoa.h"
#import "ServiceFactory.h"
#import "SKUService.h"
#import "JCHSizeUtility.h"
#import "CommonHeader.h"

@interface JCHAddSKUViewController () <UITableViewDataSource, UITableViewDelegate, JCHAddSKUValueFooterViewDelegate>
{
    UIBarButtonItem *_saveButton;
    JCHTitleTextField *_skuTypeTitleTextField;
    UITableView *_contentTableView;
    //NSString *_skuTypeUUID;
    UITextField *_currentInputTextfield;
    JCHSKUType _currentType;
}

@property (nonatomic, retain) NSMutableArray *dataSource;
@property (nonatomic, retain) NSString *originSKUValue;
@property (nonatomic, retain) NSMutableArray *deleteRecordArray;
@property (nonatomic, retain) SKUTypeRecord4Cocoa *skuTypeRecord;

@end

@implementation JCHAddSKUViewController

- (instancetype)initWithType:(JCHSKUType)type skuTypeRecord:(SKUTypeRecord4Cocoa *)skuTypeRecord
{
    self = [super init];
    if (self) {
        _currentType = type;
        self.skuTypeRecord = skuTypeRecord;
        self.deleteRecordArray = [[[NSMutableArray alloc] init] autorelease];
        
        if (_currentType == kJCHSKUTypeAdd) {
            self.title = @"添加规格";
        } else if (_currentType == kJCHSKUTypeModify) {
            self.title = @"编辑规格";
        }
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = [NSMutableArray array];
    [self createUI];
    [self setKeyboardObserver];
    
    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)dealloc
{
    [self.dataSource release];
    [self.originSKUValue release];

    [self.deleteRecordArray release];
    [self.skuTypeRecord release];
    
    [super dealloc];
}

- (void)createUI
{
    _saveButton = [[[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(handleSaveRecord)] autorelease];
    self.navigationItem.rightBarButtonItem = _saveButton;
    
    _skuTypeTitleTextField = [[[JCHTitleTextField alloc] initWithTitle:@"规格名称"
                                                                  font:JCHFont(17.0)
                                                           placeholder:@"如“尺码”,“颜色”"
                                                             textColor:JCHColorMainBody] autorelease];
    [_skuTypeTitleTextField addSeparateLineWithMasonryTop:YES bottom:NO];
    _skuTypeTitleTextField.bottomLine.hidden = YES;
    [_skuTypeTitleTextField.textField addTarget:self action:@selector(textFieldIsEditing) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_skuTypeTitleTextField];
    
    [_skuTypeTitleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(kStandardSeparateViewHeight);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    JCHSeparateLineSectionView *separateView = [[[JCHSeparateLineSectionView alloc] initWithTopLine:YES BottomLine:YES] autorelease];
    [self.view addSubview:separateView];
    
    [separateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_skuTypeTitleTextField.mas_bottom);
        make.left.right.equalTo(_skuTypeTitleTextField);
        make.height.mas_equalTo(kStandardSeparateViewHeight);
    }];
    
    
    
    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    _contentTableView.delegate = self;
    _contentTableView.dataSource = self;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _contentTableView.backgroundColor = JCHColorGlobalBackground;
    
    [self.view addSubview:_contentTableView];
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
#if MMR_TAKEOUT_VERSION
        make.top.equalTo(self.view);
#else
        make.top.equalTo(separateView.mas_bottom);
#endif
        make.left.right.bottom.equalTo(self.view);
    }];
    

    JCHAddSKUValueFooterView *tableFooterView = [[[JCHAddSKUValueFooterView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)] autorelease];
    tableFooterView.delegate = self;
    [tableFooterView addSeparateLineWithMasonryTop:NO bottom:YES];
    _contentTableView.tableFooterView = tableFooterView;
    
    
#if MMR_TAKEOUT_VERSION
    [_skuTypeTitleTextField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    [separateView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    _contentTableView.tableHeaderView = [[[JCHSeparateLineSectionView alloc] initWithTopLine:NO BottomLine:YES] autorelease];
#endif
}

- (void)textFieldIsEditing
{
    if ([_skuTypeTitleTextField.textField.text isEqualToString:@""]) {
        _saveButton.enabled = NO;
    } else {
        _saveButton.enabled = YES;
    }
}

- (void)deleteSKUValue:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
    SKUValueRecord4Cocoa *record = self.dataSource[indexPath.row];
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    
    if (nil == record.skuValueUUID) {
        [self.dataSource removeObjectAtIndex:indexPath.row];

        [_contentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [_contentTableView reloadRowsAtIndexPaths:[_contentTableView indexPathsForVisibleRows]
                                 withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    BOOL canBeDeleted = [skuService isSKUValueCanBeDeleted:record.skuValueUUID];
    if (canBeDeleted) {
        [skuService deleteSKUValue:record.skuValueUUID];
        [self.dataSource removeObjectAtIndex:indexPath.row];
        

        [_contentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        //! @note 删除某一行时，如果不刷新其他row，其他行的indexPath不刷新，后续操作会出现crash
        [_contentTableView reloadRowsAtIndexPaths:[_contentTableView indexPathsForVisibleRows]
                                 withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"该属性下有关联的商品，不能删除" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil] autorelease];
        
        [av show];
        
    }
}

#pragma mark - SaveRecord
- (void)handleSaveRecord
{
    [_currentInputTextfield resignFirstResponder];
    [_skuTypeTitleTextField.textField resignFirstResponder];
    
    //1) 检查异常
    if ([_skuTypeTitleTextField.textField.text isEmptyString]) {
        return;
    }
    
    // 检查当前的属性值是否重复, 跟datasource比较，判断当前的属性是否有两个相同的
    NSMutableArray *assistArr = [NSMutableArray array];
    for (SKUValueRecord4Cocoa *record in self.dataSource) {
        for (SKUValueRecord4Cocoa *assistRecord in assistArr) {
            if ([record.skuValue isEqualToString:assistRecord.skuValue]) {
                NSString *alertMessage = [NSString stringWithFormat:@"重复添加\"%@\"属性", record.skuValue];
                UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:alertMessage delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil] autorelease];
                [av show];
                return;
            }
        }
        [assistArr addObject:record];
    }
    
    
    //2) 保存规格类型
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    NSArray *allSKUType = nil;
    [skuService queryAllSKUType:&allSKUType];

    //新添加规格
    if (_currentType == kJCHSKUTypeAdd) {
        
        // 检查当前添加的规格类型是否已存在于数据库中
        for (SKUTypeRecord4Cocoa *sku in allSKUType) {
            if ([sku.skuTypeName isEqualToString:_skuTypeTitleTextField.textField.text]) {
                [self showDuplicateSKUTypeAlert];
                return;
            }
        }
        
        self.skuTypeRecord.skuTypeName = _skuTypeTitleTextField.textField.text;
        if (allSKUType.count == 0) {
            self.skuTypeRecord.skuSortIndex = 0;
        } else {
            SKUTypeRecord4Cocoa *lastRecord = allSKUType[allSKUType.count - 1];
            self.skuTypeRecord.skuSortIndex = lastRecord.skuSortIndex + 1;
        }
        
        [skuService addSKUType:self.skuTypeRecord];
    } else if (_currentType == kJCHSKUTypeModify){ //修改规格
        //检查规格类型是否已存在于数据库中
        for (SKUTypeRecord4Cocoa *sku in allSKUType) {
            if (![self.skuTypeRecord.skuTypeUUID isEqualToString:sku.skuTypeUUID] && [sku.skuTypeName isEqualToString:_skuTypeTitleTextField.textField.text]) {
                [self showDuplicateSKUTypeAlert];
                return;
            }
        }
        self.skuTypeRecord.skuTypeName = _skuTypeTitleTextField.textField.text;
        [skuService updateSKUType:self.skuTypeRecord];
    }
    
    
    //3) 保存规格属性
    NSArray *recordInDatabase = nil;
    [skuService querySKUWithType:self.skuTypeRecord.skuTypeUUID skuRecordVector:&recordInDatabase];
    
    for (SKUValueRecord4Cocoa *record in self.dataSource) {
        NSString *recordUUID = record.skuValueUUID;
        NSString *recordValue = record.skuValue;
        BOOL findRecord = NO;
        for (SKUValueRecord4Cocoa *temp in recordInDatabase) {
            if ([recordUUID isEqualToString:temp.skuValueUUID]) {
                findRecord = YES;
                if ([recordValue isEqualToString:temp.skuValue]) {
                    // 没有任何改动
                    break;
                } else {
                    // 改动名字
                    // update
                    
                    [skuService updateSKUValue:record];
                }
            }
        }
        
        if (NO == findRecord) {
            // 新增一条记录
            [skuService addSKUValue:record];
        }
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showDuplicateSKUTypeAlert
{
    [MBProgressHUD showHUDWithTitle:@"温馨提示" detail:@"您添加的规格已存在" duration:2 mode:MBProgressHUDModeText completion:nil];
    return;
}


#pragma mark - LoadData
- (void)loadData
{
    NSArray *skuValues = nil;
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    id<UtilityService> utilityService = [[ServiceFactory sharedInstance] utilityService];
    
    if (_currentType == kJCHSKUTypeModify) {
        [skuService querySKUWithType:self.skuTypeRecord.skuTypeUUID skuRecordVector:&skuValues];
        _skuTypeTitleTextField.textField.text = self.skuTypeRecord.skuTypeName;
        [self.dataSource addObjectsFromArray:skuValues];
    } else if (_currentType == kJCHSKUTypeAdd){
        
        NSString *skuTypeName = _skuTypeTitleTextField.textField.text;
        SKUTypeRecord4Cocoa *record = [[[SKUTypeRecord4Cocoa alloc] init] autorelease];
        record.skuTypeName = skuTypeName;
        record.skuTypeUUID = [utilityService generateUUID];
        self.skuTypeRecord = record;
    }
    
    [_contentTableView reloadData];
}

- (void)setKeyboardObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSValue *rectObj = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [rectObj CGRectValue];
    
    //判断每个输入框是否被键盘遮挡
    CGFloat tableViewTopOffset = kStandardItemHeight + kStandardSeparateViewHeight;
    
    if([_currentInputTextfield isFirstResponder])
    {
        CGRect cellFrame = CGRectMake(0, 44 * _currentInputTextfield.tag + tableViewTopOffset, kScreenWidth, 44);
        if (_currentInputTextfield.tag == self.dataSource.count - 1) {
            cellFrame.origin.y += 44;
        }
        if ([JCHSizeUtility viewIsCoveredByKeyboard:cellFrame KeyboardHeight:keyboardFrame.size.height])
        {
            if (_currentInputTextfield.tag == self.dataSource.count - 1) {
                cellFrame.origin.y -= 44;
            }
            CGRect viewFrame = self.view.frame;
           
            viewFrame.origin.y = -(keyboardFrame.size.height - (self.view.frame.size.height - CGRectGetMaxY(cellFrame) + _contentTableView.contentOffset.y));
            if (CGRectGetMaxY(viewFrame) <= CGRectGetMinY(keyboardFrame)) {
                viewFrame.origin.y = CGRectGetMinY(keyboardFrame) - viewFrame.size.height;
            }
            
            [UIView animateWithDuration:0.25 animations:^{
                    self.view.frame = viewFrame;
            } completion:^(BOOL finished) {
                CGRect footerFrame = CGRectMake(0, 44 * self.dataSource.count + 44, kScreenWidth, 44);
                [_contentTableView scrollRectToVisible:footerFrame animated:YES];
            }];   
        }
    }
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y = 64;
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = viewFrame;
    }];
    
     CGRect footerFrame = CGRectMake(0, 44 * self.dataSource.count + 44, kScreenWidth, 44);
    [_contentTableView scrollRectToVisible:footerFrame animated:NO];
}


#pragma mark - JCHAddSpecificationFooterViewDelegate

- (void)addItem
{
    if ([_skuTypeTitleTextField.textField.text isEmptyString]) {
        return;
    }
    SKUValueRecord4Cocoa *record = [[[SKUValueRecord4Cocoa alloc] init] autorelease];
    [self.dataSource addObject:record];
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0];
    
    [_contentTableView beginUpdates];
    [_contentTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [_contentTableView endUpdates];
    
    JCHAddSKUValueTableViewCell *insertCell = [_contentTableView cellForRowAtIndexPath:newIndexPath];
    [insertCell.attributeNameTextField becomeFirstResponder];
    //[insertCell.attributeNameTextField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:1];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kJCHAddSpecificationTableViewCellTag = @"kJCHAddSpecificationTableViewCellTag";
    
    JCHAddSKUValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJCHAddSpecificationTableViewCellTag];
    
    if (cell == nil) {
        cell = [[[JCHAddSKUValueTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kJCHAddSpecificationTableViewCellTag] autorelease];
        cell.attributeNameTextField.delegate = self;
    }
    if (self.dataSource.count != indexPath.row)
    {
        SKUValueRecord4Cocoa *record = self.dataSource[indexPath.row];
        cell.attributeNameTextField.text = record.skuValue;
    }
    WeakSelf;
    [cell setDeleteAction:^{
        [weakSelf deleteSKUValue:indexPath];
    }];
    cell.attributeNameTextField.tag = indexPath.row;
   
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _currentInputTextfield = textField;
    self.originSKUValue = textField.text;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *currentSKUValue = textField.text;
    //UIAlertView *av = nil;
    // 属性值不能为空
    if (nil == currentSKUValue ||
        [currentSKUValue isEqualToString:@""]) {
   
        return;
    }


    // 如果重复，或者为空，直接返回
    if (nil == currentSKUValue ||
        [currentSKUValue isEqualToString:@""]) {
        
        return;
    }
    
    
    // 如果是新增
    if (nil == self.originSKUValue ||
        [self.originSKUValue isEqualToString:@""]) {
        // 调用insert接口
        id<UtilityService> utilityService = [[ServiceFactory sharedInstance] utilityService];
        SKUValueRecord4Cocoa *record = [[[SKUValueRecord4Cocoa alloc] init] autorelease];
        record.skuTypeUUID = self.skuTypeRecord.skuTypeUUID;
        record.skuValue = currentSKUValue;
        record.skuValueUUID = [utilityService generateUUID];
        
        [self.dataSource replaceObjectAtIndex:textField.tag withObject:record];
    } else {
        // 调用update接口
        SKUValueRecord4Cocoa *updateRecord = self.dataSource[textField.tag];
        updateRecord.skuValue = currentSKUValue;
        updateRecord.skuTypeUUID = self.skuTypeRecord.skuTypeUUID;
        [self.dataSource replaceObjectAtIndex:textField.tag withObject:updateRecord];
    }
}


@end
