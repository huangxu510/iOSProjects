//
//  JCHAddProductShoppingCartListView.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/11.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHAddProductShoppingCartListView.h"
#import "JCHAddProductShoppingCartListSectionView.h"
#import "JCHAddProductShoppingCartListTableViewCell.h"
#import "JCHUIFactory.h"
#import "JCHColorSettings.h"
#import "UIView+JCHView.h"
#import "JCHSizeUtility.h"
#import "JCHManifestMemoryStorage.h"
#import "JCHUISettings.h"
#import <Masonry.h>

@interface JCHAddProductShoppingCartListView () <UITableViewDataSource, UITableViewDelegate, JCHAddProductShoppingCartListTableViewCellDelegate>
{
    UITableView *_contentTableView;
    CGFloat _rowHeight;
    CGFloat _sectionHeight;
    CGFloat _headerViewHeight;
    enum JCHOrderType _currentManifestType;
}

@property (nonatomic, retain) NSMutableArray *dataSource;

@end
@implementation JCHAddProductShoppingCartListView

- (instancetype)initWithFrame:(CGRect)frame manifestType:(enum JCHOrderType)manifestType
{
    self = [super initWithFrame:frame];
    if (self) {

        self.dataSource = [NSMutableArray array];
        _rowHeight = 40.0f;
        _sectionHeight = 40.0f;
        _headerViewHeight = 18.0f;
        _currentManifestType = manifestType;
        [self loadData];
        [self createUI];
        [_contentTableView reloadData];
        self.viewHeight = _contentTableView.contentSize.height + _headerViewHeight;
    }
    return self;
}

- (void)dealloc
{
    [self.dataSource release];
    
    [super dealloc];
}

- (void)createUI
{
    UIButton *headerView = [JCHUIFactory createButton:CGRectZero
                                               target:self
                                               action:@selector(handleFoldView)
                                                title:nil
                                           titleColor:nil
                                      backgroundColor:JCHColorGlobalBackground];
    [headerView setImage:[UIImage imageNamed:@"addgoods_btn_pulldown"] forState:UIControlStateNormal];
    [self addSubview:headerView];
    
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.top.equalTo(self);
        make.height.mas_equalTo(_headerViewHeight);
    }];
    
    [headerView addSeparateLineWithMasonryTop:NO bottom:YES];
    
    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    _contentTableView.delegate = self;
    _contentTableView.dataSource = self;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:_contentTableView];
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView.mas_bottom);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
}

- (void)handleFoldView
{
    if ([self.delegate respondsToSelector:@selector(handleHideListView:)]) {
        [self.delegate handleHideListView:self];
    }
}

- (void)loadData
{
    JCHManifestMemoryStorage *storage = [JCHManifestMemoryStorage sharedInstance];
    NSArray *transactionList = [storage getAllManifestRecord];
    
    NSMutableArray *productList = [NSMutableArray array];
    
    for (ManifestTransactionDetail *detail in transactionList) {
        BOOL productListContainsDetail = NO;
        for (NSDictionary *goodsNameDict in productList) {
            if ([[goodsNameDict allKeys][0] isEqualToString:detail.goodsNameUUID]) {
                productListContainsDetail = YES;
            }
        }
        
        if (!productListContainsDetail) {
            [productList addObject:@{detail.goodsNameUUID : detail.productName}];
        }
    }
    
    NSMutableArray *dataSource = [NSMutableArray array];
    for (NSDictionary *productDict in productList) {
        NSMutableArray *transactionInProduct = [NSMutableArray array];
        
        for (ManifestTransactionDetail *detail in transactionList) {
            if ([[productDict allKeys][0] isEqualToString:detail.goodsNameUUID]) {
                [transactionInProduct addObject:detail];
            }
        }
        [dataSource addObject:transactionInProduct];
    }
    
//    self.viewHeight = dataSource.count * _sectionHeight + transactionList.count * _rowHeight + 18.0f;
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:dataSource];
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = self.dataSource[section];

    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"JCHAddProductShoppingCartListTableViewCell";
    JCHAddProductShoppingCartListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[JCHAddProductShoppingCartListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier manifestType:_currentManifestType] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        cell.clipsToBounds = YES;
    }
    
    ManifestTransactionDetail *detail = self.dataSource[indexPath.section][indexPath.row];
    JCHAddProductShoppingCartListTableViewCellData *data = [[[JCHAddProductShoppingCartListTableViewCellData alloc] init] autorelease];
    data.skuCombine = detail.skuValueCombine;
    data.count = [NSString stringWithFormat:@"%@%@", detail.productCount, detail.productUnit];
    data.price = detail.productPrice;
    data.discount = detail.productDiscount;
    
    [cell setData:data];
    
    if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        [cell hideBottomLine:YES];
    }
    else
    {
        [cell hideBottomLine:NO];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    JCHAddProductShoppingCartListSectionView *view = [[[JCHAddProductShoppingCartListSectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, _sectionHeight) manifestType:_currentManifestType] autorelease];
    ManifestTransactionDetail *detail = self.dataSource[section][0];
    view.section = section;
    if (detail.skuHidenFlag) {
        JCHAddProductShoppingCartListSectionViewData *data = [[[JCHAddProductShoppingCartListSectionViewData alloc] init] autorelease];
        data.productName = detail.productName;
        data.productCount = [NSString stringWithFormat:@"%@%@", detail.productCount, detail.productUnit];
        data.productPrice = detail.productPrice;
        data.productDiscount = detail.productDiscount;
        [view setData:data];
    }
    else
    {
        view.productNameLabel.text = detail.productName;
    }
    
    [view.deletaButton addTarget:self action:@selector(handleDeleteSection:) forControlEvents:UIControlEventTouchUpInside];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return _sectionHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ManifestTransactionDetail *detail = self.dataSource[indexPath.section][indexPath.row];
    if (detail.skuHidenFlag) {
        return 0;
    }
    
    return _rowHeight;
}


#pragma mark - JCHAddProductShoppingCartListTableViewCellDelegate

- (void)handleDeleteTransaction:(JCHAddProductShoppingCartListTableViewCell *)cell
{
    cell.contentView.backgroundColor = JCHColorGlobalBackground;
    NSIndexPath *indexPath = [_contentTableView indexPathForCell:cell];
    ManifestTransactionDetail *detail = self.dataSource[indexPath.section][indexPath.row];
    JCHManifestMemoryStorage *storage = [JCHManifestMemoryStorage sharedInstance];
    [storage removeManifestRecord:detail];


    [self.dataSource[indexPath.section] removeObject:detail];
    
    [_contentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];

    //deleteRow后tableView不会立即更新contentSize
    self.viewHeight = _contentTableView.contentSize.height + _headerViewHeight - _rowHeight;

    if ([self.delegate respondsToSelector:@selector(handleDeleteTransaction:)]) {
        [self.delegate handleDeleteTransaction:self];
    }
}

- (void)handleDeleteSection:(UIButton *)button
{
    JCHAddProductShoppingCartListSectionView *sectionView = (JCHAddProductShoppingCartListSectionView *)button.superview;
    sectionView.backgroundColor = JCHColorGlobalBackground;
    NSInteger section = sectionView.section;
    NSArray *sectionArr = self.dataSource[section];

    JCHManifestMemoryStorage *storage = [JCHManifestMemoryStorage sharedInstance];
    for (ManifestTransactionDetail *detail in self.dataSource[section]) {
        [storage removeManifestRecord:detail];
    }
    

    [self.dataSource removeObject:sectionArr];
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    [_contentTableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationNone];

    [_contentTableView reloadData];

    self.viewHeight = _contentTableView.contentSize.height + _headerViewHeight;
    
    if ([self.delegate respondsToSelector:@selector(handleDeleteTransaction:)]) {
        [self.delegate handleDeleteTransaction:self];
    }
}

@end
