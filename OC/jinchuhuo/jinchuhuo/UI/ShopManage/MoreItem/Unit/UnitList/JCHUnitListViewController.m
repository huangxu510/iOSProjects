//
//  JCHUnitListViewController.m
//  jinchuhuo
//
//  Created by apple on 15/8/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHUnitListViewController.h"
#import "JCHAddProductRecordViewController.h"
#import "JCHAddUnitViewController.h"
#import "JCHSeparateLineSectionView.h"
#import "JCHItemListFooterView.h"
#import "JCHItemListTableViewCell.h"
#import "JCHUISizeSettings.h"
#import "ServiceFactory.h"
#import "JCHUISettings.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "CommonHeader.h"
#import "Masonry.h"

@interface JCHUnitListViewController () <JCHItemListFooterViewDelegate>
{
    UITableView *_contentTableView;
    JCHUnitListType _currentType;
    UIButton *_editButton;
    JCHItemListFooterView *_footerView;
}

@property (retain, nonatomic, readwrite) NSMutableArray *unitRecordArray;

@end

@implementation JCHUnitListViewController

- (instancetype)initWithType:(JCHUnitListType)type
{
    self = [super init];
    if (self) {
        self.title = @"单位";
        _currentType = type;
    }
    
    return self;
}

- (void)dealloc
{
    [self.unitRecordArray release];
    [self.selectUnitRecord release];
    [self.sendValueBlock release];
    
    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
    
    return;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadUnitData];
    _contentTableView.editing = NO;
    _editButton.selected = NO;
    [_footerView setData:self.unitRecordArray.count];
    
    for (NSInteger i = 0; i < self.unitRecordArray.count; i++) {
        UnitRecord4Cocoa *unitRecord = self.unitRecordArray[i];
        if (_currentType == kJCHUnitListTypeSelect && [unitRecord.unitName isEqualToString:self.selectUnitRecord.unitName]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [_contentTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }
    
    return;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_contentTableView setEditing:NO];
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    
    //UIBarButtonItem *addUnitButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                   //target:self
                                                                                   //action:@selector(handleAddUnit:)] autorelease];
    
    //self.navigationItem.rightBarButtonItems = @[addUnitButton];
    
    if (_currentType == kJCHUnitListTypeNormal) {
        _editButton = [JCHUIFactory createButton:CGRectMake(0, 0, 40, 40)
                                          target:self
                                          action:@selector(handleEditMode:)
                                           title:@"编辑"
                                      titleColor:nil
                                 backgroundColor:nil];
        [_editButton setTitle:@"取消" forState:UIControlStateSelected];
        _editButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        UIBarButtonItem *editButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:_editButton] autorelease];
        
        UIBarButtonItem *flexSpacer = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                    target:self
                                                                                    action:nil] autorelease];
        flexSpacer.width = -10;
        
        self.navigationItem.rightBarButtonItems = @[flexSpacer, editButtonItem];
    }

    
    
    
    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    [self.view addSubview:_contentTableView];
    _contentTableView.delegate = self;
    _contentTableView.dataSource = self;
    _contentTableView.backgroundColor = JCHColorGlobalBackground;
    _contentTableView.tableHeaderView = [[[JCHSeparateLineSectionView alloc] initWithTopLine:NO BottomLine:YES] autorelease];
    _contentTableView.tableFooterView = [[[UIView alloc] init] autorelease];
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _contentTableView.allowsMultipleSelectionDuringEditing = YES;
    _contentTableView.tintColor = UIColorFromRGB(0x4c8cdf);
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-49);
    }];
    
    _footerView = [[[JCHItemListFooterView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 64 - 49, kScreenWidth, 49)] autorelease];
    _footerView.categoryName = @"单位";
    _footerView.categoryUnit = @"种";
    _footerView.delegate = self;
    [self.view addSubview:_footerView];
    
    return;
}

- (void)handleEditMode:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [_footerView changeUI:_contentTableView.isEditing];
    [_contentTableView setEditing:!_contentTableView.isEditing animated:YES];
    if (!_contentTableView.isEditing) {
        [_footerView setData:self.unitRecordArray.count];
    }else {
        NSArray *selectedIndexPaths = [_contentTableView indexPathsForSelectedRows];
        [_footerView setData:selectedIndexPaths.count];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)self.unitRecordArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self handleDeleteUnit:indexPath];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *kCellReuseTag = @"kCellReuseTag";
    JCHItemListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseTag];
    if (nil == cell) {
        cell = [[[JCHItemListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellReuseTag] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
        cell.textLabel.textColor = JCHColorMainBody;
        cell.arrowImageView.hidden = NO;
        
        if (_currentType == kJCHUnitListTypeSelect) {
            cell.autoHiddenArrowImageViewWhileEditing = NO;
            cell.arrowImageView.hidden = YES;
        } else if (_currentType == kJCHUnitListTypeNormal) {
            cell.autoHiddenArrowImageViewWhileEditing = YES;
            cell.arrowImageView.hidden = NO;
        }
    }
    
    //每段最后一行的底线与左侧边无间隔
    [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
    WeakSelf;
    [cell setGoTopBlock:^(JCHItemListTableViewCell *cell) {
        [weakSelf handleGoTopCell:cell];
    }];
    UnitRecord4Cocoa *unitRecord = [self.unitRecordArray objectAtIndex:indexPath.row];
    if (_currentType == kJCHUnitListTypeSelect && [unitRecord.unitName isEqualToString:self.selectUnitRecord.unitName]) {
        cell.selectImageView.hidden = NO;
    } else {
        cell.selectImageView.hidden = YES;
    }
    cell.textLabel.text = unitRecord.unitName;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_contentTableView.isEditing) {
        
        //取消选中 变为 全选
        [_footerView setButtonSelected:NO];
        [_footerView setData:[_contentTableView indexPathsForSelectedRows].count];
        
        if ([_contentTableView indexPathsForSelectedRows].count == self.unitRecordArray.count) {
            [_footerView setButtonSelected:YES];
        }
    }
    else
    {
        UnitRecord4Cocoa *unitRecord = self.unitRecordArray[indexPath.row];
        if (_currentType == kJCHUnitListTypeSelect) {
            for (NSInteger i = 0; i < self.unitRecordArray.count; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                JCHItemListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.selectImageView.hidden = YES;
            }
            JCHItemListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.selectImageView.hidden = NO;
            if (self.sendValueBlock) {
                self.sendValueBlock(unitRecord);
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        } else if (_currentType == kJCHUnitListTypeNormal) {
            
            JCHAddUnitViewController *addController = [[[JCHAddUnitViewController alloc] initWithTitle:@"修改单位"] autorelease];
            addController.unitRecord = unitRecord;
            addController.unitType = kJCHUnitTypeModifyUnit;
            [self.navigationController pushViewController:addController animated:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_contentTableView.isEditing) {
        
        [_footerView setButtonSelected:NO];
        [_footerView setData:[_contentTableView indexPathsForSelectedRows].count];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    UnitRecord4Cocoa *sourceRecord = [self.unitRecordArray[sourceIndexPath.row] retain];
    
    [self.unitRecordArray removeObjectAtIndex:sourceIndexPath.row];
    [self.unitRecordArray insertObject:sourceRecord atIndex:destinationIndexPath.row];
    
    id<UnitService> unitService = [[ServiceFactory sharedInstance] unitService];
    
    
    NSInteger destinationSortIndex;
    if (destinationIndexPath.row == 0) {
        destinationSortIndex = 0;
    } else {
        UnitRecord4Cocoa *lastRecord = self.unitRecordArray[destinationIndexPath.row - 1];
        destinationSortIndex = lastRecord.sortIndex + 1;
    }
    
    
    for (NSInteger i = destinationIndexPath.row; i < self.unitRecordArray.count; i++) {
        UnitRecord4Cocoa *record = self.unitRecordArray[i];
        
        record.sortIndex = destinationSortIndex;
        destinationSortIndex++;
        [unitService updateUnit:record];
    }
}

- (void)handleGoTopCell:(JCHItemListTableViewCell *)cell
{
    NSIndexPath *indexPath = [_contentTableView indexPathForCell:cell];
    UnitRecord4Cocoa *sourceRecord = [self.unitRecordArray[indexPath.row] retain];
    [self.unitRecordArray removeObjectAtIndex:indexPath.row];
    [self.unitRecordArray insertObject:sourceRecord atIndex:0];
    
    id<UnitService> unitService = [[ServiceFactory sharedInstance] unitService];
    
    for (NSInteger i = 0; i < self.unitRecordArray.count; i++) {
        UnitRecord4Cocoa *record = self.unitRecordArray[i];
        
        record.sortIndex = i;
        [unitService updateUnit:record];
    }
    [_contentTableView reloadData];
}

- (void)loadUnitData
{
    [MBProgressHUD showHUDWithTitle:@"加载中..."
                             detail:nil
                           duration:100
                               mode:MBProgressHUDModeIndeterminate
                          superView:self.view
                         completion:nil];
    
    id<UnitService> unitService = [[ServiceFactory sharedInstance] unitService];
   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *unitRecordArray = [unitService queryAllUnit];
        self.unitRecordArray = [NSMutableArray arrayWithArray:unitRecordArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [MBProgressHUD hideHUDForView:self.view animated:NO];
            [_footerView setData:self.unitRecordArray.count];
            [_contentTableView reloadData];
        });
    });
    
    return;
}

- (void)handleDeleteUnit:(NSIndexPath *)indexPath
{
    UnitRecord4Cocoa *unitRecord = [self.unitRecordArray objectAtIndex:indexPath.row];
    id<UnitService> unitService = [[ServiceFactory sharedInstance] unitService];
    BOOL showAlertForDeleteProduct = [self showAlertForDeleteProduct:unitRecord.unitUUID
                                                            unitName:unitRecord.unitName];
    
    if (YES == showAlertForDeleteProduct) {
        return;
    }
    
    [unitService deleteUnit:unitRecord.unitUUID];
    
    [self loadUnitData];
    return;
}

- (BOOL)showAlertForDeleteProduct:(NSString *)unitUUID unitName:(NSString *)unitName
{
    id<UnitService> unitService = [[ServiceFactory sharedInstance] unitService];
    
    BOOL canBeDelete = [unitService isUnitCanBeDelete:unitUUID];
    
    //如果当前单位被商品选择，但是商品未保存，也不能删除
    if ([unitName isEqualToString:self.selectUnitRecord.unitName]) {
        canBeDelete = NO;
    }
    
    if (!canBeDelete) {
        NSString *alertMessage = [NSString stringWithFormat:@"单位 \"%@\" 已经被使用，不能删除", unitName];
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:alertMessage
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
    }
    
    return !canBeDelete;
}

#pragma mark - JCHItemListFooterViewDelegate
- (void)addItem
{
    WeakSelf;
    
    JCHAddUnitViewController *addController = [[[JCHAddUnitViewController alloc] initWithTitle:@"添加单位"] autorelease];
    
    if (self.sendValueBlock) {
        [addController setSendValueBlock:^(NSString *unit) {
            [weakSelf sendRecord:unit]; 
        }];
    }
    
    [self.navigationController pushViewController:addController animated:YES];
}

- (void)sendRecord:(NSString *)unit
{
    //由于传过来的record的uuid和保存之后的uuid不一样，所以这里要根据名字重新查询该record
    id<UnitService> unitService = [[ServiceFactory sharedInstance] unitService];
    NSArray *allUnitRecords = [unitService queryAllUnit];
    
    for (UnitRecord4Cocoa *unitRecord in allUnitRecords) {
        if ([unitRecord.unitName isEqualToString:unit]) {
            if (self.sendValueBlock) {
                self.sendValueBlock(unitRecord);
            }
            break;
        }
    }
}

- (void)deleteItems
{
    id<UnitService> unitService = [[ServiceFactory sharedInstance] unitService];
    NSArray *selectedIndexPaths = [_contentTableView indexPathsForSelectedRows];
    for (NSIndexPath *indexPath in selectedIndexPaths) {
        
        UnitRecord4Cocoa *unitRecord = [self.unitRecordArray objectAtIndex:indexPath.row];
        
        BOOL showAlertForDeleteProduct = [self showAlertForDeleteProduct:unitRecord.unitUUID
                                                                unitName:unitRecord.unitName];
        if (YES == showAlertForDeleteProduct) {
            return;
        }
        
        [unitService deleteUnit:unitRecord.unitUUID];
    }
    
    [self loadUnitData];
    
    //如果单位全部删除完,footerView切换模式
    if (self.unitRecordArray.count == 0) {
        [_footerView changeUI:YES];
    }
    [_footerView setData:[_contentTableView indexPathsForSelectedRows].count];
}

- (void)selectAll:(UIButton *)button
{
    if (button.selected) {
        //取消选中
        [_contentTableView reloadData];
    }
    else
    {
        //选中所有
        for (NSInteger i = 0; i < self.unitRecordArray.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [_contentTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    }
    //刷新footerView数据
    [_footerView setData:[_contentTableView indexPathsForSelectedRows].count];
}


@end
