//
//  JCHAddProductSKUListTableVIew.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/7.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHAddProductSKUListView.h"
#import "JCHAddProductSKUListSectionView.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "SKURecord4Cocoa.h"
#import "CommonHeader.h"
#import <Masonry.h>

@interface JCHAddProductSKUListView () <UITableViewDataSource, UITableViewDelegate, JCHAddProductSKUListTableViewCellDelegate, SWTableViewCellDelegate>
{
    UITableView *_contentTableView;
    UIButton *_closeButton;
    NSString *_productName;
    enum JCHOrderType _currentManifestType;
}

@property (nonatomic, retain) NSMutableDictionary *buttonStatusForRow;  //记录每行对应的button的状态
@property (nonatomic, retain) NSMutableDictionary *labelEditedTagForRow;
@property (nonatomic, retain) JCHAddProductSKUListSectionView *sectionView;

@property (nonatomic, assign) BOOL initFlag;

@end

@implementation JCHAddProductSKUListView

- (instancetype)initWithFrame:(CGRect)frame
                  productName:(NSString *)productName
                 manifestType:(enum JCHOrderType)manifestType
                   dataSource:(NSArray *)dataSource
{
    self = [super initWithFrame:frame];
    if (self) {
        _productName = productName;
        _currentManifestType = manifestType;
        self.dataSource = dataSource;
        self.buttonStatusForRow = [NSMutableDictionary dictionary];
        self.labelEditedTagForRow = [NSMutableDictionary dictionary];
        self.selectedData = [NSMutableArray array];
        self.currentEditLabelTag = kJCHAddProductSKUListTableViewCellCountLableTag;
        self.initFlag = YES;
        [self createUI];
    }
    return self;
}


- (void)dealloc
{
    [self.dataSource release];
    [self.selectedData release];
    [self.buttonStatusForRow release];
    [self.singleEditingData release];
    [self.sectionView release];
    
    [super dealloc];
}

- (void)createUI
{
    self.sectionView = [[[JCHAddProductSKUListSectionView alloc] initWithFrame:CGRectZero manifestType:_currentManifestType] autorelease];
    self.sectionView.frame = CGRectMake(0, 0, kScreenWidth, 50 + kSKUListSectionHeight);
    self.sectionView.titleLabel.text = _productName;
    [self.sectionView.selectedAllButton addTarget:self action:@selector(handleSelectedAll:) forControlEvents:UIControlEventTouchUpInside];
    
    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    _contentTableView.delegate = self;
    _contentTableView.dataSource = self;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (_currentManifestType == kJCHOrderPurchases || _currentManifestType == kJCHOrderShipment || _currentManifestType == kJCHRestaurntManifestOpenTable) {
        _contentTableView.allowsMultipleSelection = YES;
    } else if (_currentManifestType == kJCHManifestInventory || _currentManifestType == kJCHManifestMigrate) {
        _contentTableView.allowsSelection = NO;
    }
    
    [self addSubview:_contentTableView];
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    
    
    _closeButton = [JCHUIFactory createButton:CGRectZero
                                       target:self
                                       action:@selector(handleCloseView)
                                        title:nil
                                   titleColor:nil
                              backgroundColor:nil];
    [_closeButton setImage:[UIImage imageNamed:@"addgoods_btn_keyboardclose"] forState:UIControlStateNormal];
    [self addSubview:_closeButton];
    
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.right.equalTo(self);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo([JCHSizeUtility calculateWidthWithSourceWidth:52.0f]);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
 
    [self setDefaultFocus];
}

- (void)setDefaultFocus
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorage.currentManifestType == kJCHManifestAssembling || manifestStorage.currentManifestType == kJCHManifestDismounting) {
        [self.sectionView hideSelectAllButton];
        JCHAddProductSKUListTableViewCell *cell = [_contentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cell setDefaultFocus];
    } else {
        //当只有一种规格时，默认将交点放在数量上
        if (self.dataSource.count == 1)
        {
            [self.sectionView hideSelectAllButton];
            
            JCHAddProductSKUListTableViewCell *cell = [_contentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [cell setDefaultFocus];
        }
        
        //当有多个规格时，默认选中第一条规格，并且将焦点放在数量上
        if (self.dataSource.count > 1) {
            
            if (_currentManifestType == kJCHManifestInventory || _currentManifestType == kJCHManifestMigrate) {
                [self.sectionView hideSelectAllButton];
            }
            JCHAddProductSKUListTableViewCell *cell = [_contentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            
            if (self.initFlag) {
                [cell handleSelect:cell.selectButton];
                self.initFlag = NO;
            }
            
            [cell setDefaultFocus];
        }
    }
}

- (void)reloadData
{
    NSArray *selectedRows = [_contentTableView indexPathsForSelectedRows];
    [_contentTableView reloadData];
    for (NSIndexPath *indexPath in selectedRows) {
        [_contentTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)handleCloseView
{
    if ([self.delegate respondsToSelector:@selector(handleHideView:)]) {
        [self.delegate handleHideView:self];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorage.currentManifestType == kJCHManifestAssembling || manifestStorage.currentManifestType == kJCHManifestDismounting) {
        return 1;
    } else {
        return self.dataSource.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cellIdentifier";
    JCHAddProductSKUListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[JCHAddProductSKUListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier manifestType:_currentManifestType] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.cellDelegate = self;
        cell.delegate = self;
    }
    [cell hideLastBottomLine:_contentTableView indexPath:indexPath];
    
    [self createCellData:cell indexPath:indexPath];
    
    return cell;
}

- (void)createCellData:(JCHAddProductSKUListTableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    if (_currentManifestType == kJCHManifestDismounting || _currentManifestType == kJCHManifestAssembling) {
        
        NSMutableArray *cellDataArray = [NSMutableArray array];
        for (ManifestTransactionDetail *detail in self.dataSource) {
            JCHAddProductSKUListTableViewCellData *data = [[[JCHAddProductSKUListTableViewCellData alloc] init] autorelease];
            data.skuTypeName = detail.skuValueCombine;
            data.productCount = detail.productCount;
            data.productUnit = detail.productUnit;
            data.productPrice = detail.productPrice;
            data.sku_hidden_flag = detail.skuHidenFlag;
            data.productName = detail.productName;
            data.productUnit_digits = detail.productUnit_digits;
            data.inventoryCount = detail.productInventoryCount;
            //主副单位的标记和换算率
            data.isMainUnit = detail.isMainUnit;
            data.unitRatio = detail.ratio;
            
            [cellDataArray addObject:data];
        }
        
        [cell setAssemblingAndDismoutingData:cellDataArray];
    } else {
        ManifestTransactionDetail *detail = self.dataSource[indexPath.row];
        JCHAddProductSKUListTableViewCellData *data = [[[JCHAddProductSKUListTableViewCellData alloc] init] autorelease];
        data.skuTypeName = detail.skuValueCombine;
        data.productCount = detail.productCount;
        data.productUnit = detail.productUnit;
        data.productPrice = detail.productPrice;
        data.sku_hidden_flag = detail.skuHidenFlag;
        data.productName = detail.productName;
        data.productUnit_digits = detail.productUnit_digits;
        data.inventoryCount = detail.productInventoryCount;
        
        if (detail.productUnit_digits == 0) {
            data.totalAmount = [NSString stringWithFormat:@"%.2f", detail.productCountFloat * detail.productPrice.doubleValue];
        } else {
            data.totalAmount = detail.productTotalAmount ? detail.productTotalAmount : [NSString stringWithFormat:@"%.2f", detail.productCountFloat * detail.productPrice.doubleValue];
        }
        
        if (self.dataSource.count == 1) {
            data.sku_hidden_flag = YES;
            if (![detail.skuValueCombine isEqualToString:@""]) {
                data.productName = detail.skuValueCombine;
            }
        }
        
        
        if (_currentManifestType == kJCHManifestInventory) {
            //盘点单当盘后数量小于盘前数量时，不可编辑价格
            if ([detail.productCount doubleValue] <= [detail.productInventoryCount doubleValue]) {
                data.disabledPriceButton = YES;
            } else {
                data.disabledPriceButton = NO;
            }
        } else if (_currentManifestType == kJCHOrderShipment || _currentManifestType == kJCHOrderPurchases || _currentManifestType == kJCHRestaurntManifestOpenTable) {
            //进出货单如果单位为整数则不可编辑金额
            if (data.productUnit_digits == 0) {
                data.disabledTotalAmoutButton = YES;
            } else {
                data.disabledTotalAmoutButton = NO;
            }
        }
        
        
        NSNumber *selectedNumber = [self.buttonStatusForRow objectForKey:@(indexPath.row)];
        if (selectedNumber == nil) {
            data.buttonSelected = NO;
        } else {
            data.buttonSelected = selectedNumber.boolValue;
        }
        
        [cell setData:data];
        NSNumber *labelTag = [self.labelEditedTagForRow objectForKey:@(indexPath.row)];
        if (labelTag == nil) {
            [cell setLabelSelected:kJCHAddProductSKUListTableViewCellLableTagNone];
        } else {
            NSInteger tag = [labelTag integerValue];
            [cell setLabelSelected:tag];
        }
        
        [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:65];
    }
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightButtons = [NSMutableArray array];
    
    JCHManifestMemoryStorage *storage = [JCHManifestMemoryStorage sharedInstance];
    if (storage.currentManifestType == kJCHOrderShipment || storage.currentManifestType == kJCHOrderPurchases || storage.currentManifestType == kJCHRestaurntManifestOpenTable) {
        [rightButtons sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f) icon:[UIImage imageNamed:@"more_open_free"]];
        UIButton *freeButton = [rightButtons lastObject];
        freeButton.tag = 1000;
    }
    
    
    if (self.dataSource.count > 1) {
        [rightButtons sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f) icon:[UIImage imageNamed:@"manifest_more_open_delete"]];
        UIButton *deleteButton = [rightButtons lastObject];
        deleteButton.tag = 1001;
    }
    
    return rightButtons;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorage.currentManifestType == kJCHManifestAssembling) {
        return (self.dataSource.count - 1) * kSKUListRowHeight;
    } else {
        return kSKUListRowHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kSKUListRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kSKUListSectionHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.sectionView;
}

#pragma mark - JCHAddProductSKUListTableViewCellDelegate

- (void)handleLabelTaped:(JCHAddProductSKUListTableViewCell *)cell editLabel:(UILabel *)editLabel
{
    if ([self.delegate respondsToSelector:@selector(skuListView:labelTaped:)]) {
        [self.delegate skuListView:self labelTaped:editLabel];
    }
    
    // 拼装单不需要后面的逻辑
    if (_currentManifestType == kJCHManifestAssembling || _currentManifestType == kJCHManifestDismounting) {
        self.singleEditing = YES;
        self.singleEditingData = self.dataSource[cell.tag];
    } else {
        self.currentEditLabelTag = editLabel.tag;
        NSArray *selectedRows = [_contentTableView indexPathsForSelectedRows];
        if (selectedRows == nil) {
            self.singleEditing = YES;
        }
        //判断点击的cell在不在已经选中的cell里面
        BOOL tappedCellInSelectedCells = NO;
        for (NSIndexPath *indexPath in selectedRows) {
            JCHAddProductSKUListTableViewCell *selectedCell = [_contentTableView cellForRowAtIndexPath:indexPath];
            if (cell == selectedCell) {
                tappedCellInSelectedCells = YES;
                break;
            }
        }
        //如果不在已选中的cell里面,则单独操作这个cell 并将已选中cell的状态还原
        if (!tappedCellInSelectedCells) {
            
            if (self.singleEditing) {
                NSInteger row = [self.dataSource indexOfObject:self.singleEditingData];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                
                [self resetLabelEditedTagForRow:indexPath tag:kJCHAddProductSKUListTableViewCellLableTagNone selectRow:NO];
            }
            
            //        [cell setLabelSelected:labelTag];
            NSIndexPath *indexPath = [_contentTableView indexPathForRowAtPoint:cell.center];
            [self.labelEditedTagForRow setObject:@(self.currentEditLabelTag) forKey:@(indexPath.row)];
            [_contentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            
            self.singleEditingData = self.dataSource[indexPath.row];
            self.singleEditing = YES;
            
            for (NSIndexPath *indexPath in selectedRows) {
                
                [self resetLabelEditedTagForRow:indexPath tag:kJCHAddProductSKUListTableViewCellLableTagNone selectRow:YES];
            }
        }
        else //在已选中的cell里面 改变已选中的cell的label的状态 并将上次单独操作的cell的状态还原
        {
            self.singleEditing = NO;
            for (NSIndexPath *indexPath in selectedRows) {
                
                [self resetLabelEditedTagForRow:indexPath tag:self.currentEditLabelTag selectRow:YES];
            }
            
            if (self.singleEditingData) {
                NSInteger row = [self.dataSource indexOfObject:self.singleEditingData];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                
                if ([selectedRows containsObject:indexPath]) {
                    return;
                }
                
                [self resetLabelEditedTagForRow:indexPath tag:kJCHAddProductSKUListTableViewCellLableTagNone selectRow:NO];
                self.singleEditingData = nil;
            }
        }

    }
}

- (void)handleSelectCell:(JCHAddProductSKUListTableViewCell *)cell button:(UIButton *)button
{
    NSIndexPath *indexPath = [_contentTableView indexPathForCell:cell];
    [self.buttonStatusForRow setObject:@(button.selected) forKey:@(indexPath.row)];
    
    ManifestTransactionDetail *detail = self.dataSource[indexPath.row];
    
    if (button.selected) {
        [self.selectedData addObject:detail];
        
        //如果之前是单独操作，则将之前单独操作的cell上的label的状态还原
        if (self.singleEditing) {
            NSInteger index = [self.dataSource indexOfObject:self.singleEditingData];
            NSIndexPath *singleIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self resetLabelEditedTagForRow:singleIndexPath tag:kJCHAddProductSKUListTableViewCellLableTagNone selectRow:NO];
        }
        //选中当前行
        [_contentTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        
        //如果当前是多选操作 则设置所有已选cell的状态
        for (NSIndexPath *indexPath in [_contentTableView indexPathsForSelectedRows]) {
             [self resetLabelEditedTagForRow:indexPath tag:self.currentEditLabelTag selectRow:YES];
        }
        self.singleEditing = NO;
    }
    else{
        
        self.sectionView.selectedAllButton.selected = NO;
        [self.selectedData removeObject:detail];
        [_contentTableView deselectRowAtIndexPath:indexPath animated:NO];
        
        //如果当前是多选操作 则让取消选择的cell中label的状态恢复
        if (!self.singleEditing) {
             [self resetLabelEditedTagForRow:indexPath tag:kJCHAddProductSKUListTableViewCellLableTagNone selectRow:NO];
        }
    }
    if (self.selectedData.count == 0) {
        self.currentEditLabelTag = kJCHAddProductSKUListTableViewCellCountLableTag;
    }
}

- (void)handleSelectedAll:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    if (sender.selected) { //全选
        self.singleEditing = NO;
        [self.selectedData removeAllObjects];
        [self.selectedData addObjectsFromArray:self.dataSource];
        for (NSInteger i = 0; i < self.dataSource.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
           
            [self.buttonStatusForRow setObject:@(YES) forKey:@(indexPath.row)];
            [self resetLabelEditedTagForRow:indexPath tag:self.currentEditLabelTag selectRow:YES];
        }
    }
    else //取消全选
    {
        [self.selectedData removeAllObjects];
        for (NSInteger i = 0; i < self.dataSource.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            
            [self.buttonStatusForRow setObject:@(NO) forKey:@(indexPath.row)];
            [self resetLabelEditedTagForRow:indexPath tag:kJCHAddProductSKUListTableViewCellLableTagNone selectRow:NO];
        }
        
        self.currentEditLabelTag = kJCHAddProductSKUListTableViewCellCountLableTag;
    }
}

//重新设置当前行的编辑状态并刷新改行
- (void)resetLabelEditedTagForRow:(NSIndexPath *)indexPath tag:(NSInteger)tag selectRow:(BOOL)selected
{
    [self.labelEditedTagForRow setObject:@(tag) forKey:@(indexPath.row)];
    [_contentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    if (selected) {
        [_contentTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    else
    {
         [_contentTableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
}


#pragma mark - SWTableViewCellDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [_contentTableView indexPathForCell:cell];
    UIButton *rightButton = cell.rightUtilityButtons[index];
    switch (rightButton.tag) {
        case 1000:
        {
            [cell hideUtilityButtonsAnimated:YES];
            ManifestTransactionDetail *productDetail = [self.dataSource objectAtIndex:indexPath.row];
            productDetail.productPrice = @"0.0";
            [_contentTableView reloadData];
        }
            break;
            
    
        case 1001:
        {
            NSMutableArray *dataSource = [NSMutableArray arrayWithArray:self.dataSource];
            [dataSource removeObjectAtIndex:indexPath.row];
            self.dataSource = dataSource;

            //[_contentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

            [self.buttonStatusForRow removeAllObjects];
            [self.labelEditedTagForRow removeAllObjects];
            [self.buttonStatusForRow setObject:@(1) forKey:@(0)];
            [self.labelEditedTagForRow setObject:@(1) forKey:@(0)];
            
            NSArray *indexPaths = [_contentTableView indexPathsForSelectedRows];
            for (NSIndexPath *indexPath in indexPaths) {
                JCHAddProductSKUListTableViewCell *cell = [_contentTableView cellForRowAtIndexPath:indexPath];
                cell.selectButton.selected = NO;
            }
            [_contentTableView reloadData];
            [_contentTableView layoutIfNeeded];
            CGRect frame = self.frame;
            if (_contentTableView.contentSize.height < frame.size.height) {
                frame.origin.y += frame.size.height - _contentTableView.contentSize.height;
                frame.size.height = _contentTableView.contentSize.height;
            }
            [UIView animateWithDuration:0.25 animations:^{
                self.frame = frame;
            } completion:^(BOOL finished) {
                [_contentTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }];
        }
            break;
        default:
            break;
    }
}


- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}


@end
