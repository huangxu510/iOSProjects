//
//  JCHDeskListViewController.m
//  restaurant
//
//  Created by apple on 2016/11/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHDeskListViewController.h"
#import "JCHInventoryTableViewSectionView.h"
#import "JCHInventoryPullDownContainerView.h"
#import "JCHInventoryPullDownTableView.h"
#import "JCHInventoryPullDownCategoryView.h"
#import "JCHInventoryPullDownSKUView.h"
#import "JCHAddDeskViewController.h"
#import "JCHSeparateLineSectionView.h"
#import "JCHUISizeSettings.h"
#import "ServiceFactory.h"
#import "JCHUISettings.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHItemListFooterView.h"
#import "JCHProductListTableViewCell.h"
#import "JCHUIFactory.h"
#import "JCHMenuView.h"
#import "MBProgressHUD+JCHHud.h"
#import "JCHPinYinUtility.h"
#import "JCHTransactionUtility.h"
#import "MBProgressHUD+JCHHud.h"
#import "JCHDeskListTableViewCell.h"
#import "Masonry.h"
#import "JCHSearchBar.h"
#import "CommonHeader.h"

@interface JCHDeskListViewController () <JCHItemListFooterViewDelegate,
                                        UITableViewDelegate,
                                        UITableViewDataSource,
                                        JCHSearchBarDelegate,
                                        UIAlertViewDelegate,
                                        JCHMenuViewDelegate>
{
    UITableView *contentTableView;
    JCHSearchBar *searchBar;
    JCHItemListFooterView *footerView;
    UIButton *editButton;
    UIButton *addButton;
    JCHPlaceholderView *placeholderView;
    
    BOOL appearFromPop;
}

@property (retain, nonatomic, readwrite) NSArray *deskRecordArray;

@end

@implementation JCHDeskListViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"桌台列表";
        appearFromPop = NO;
    }
    
    return self;
}

- (void)dealloc
{
    self.deskRecordArray = nil;
    
    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    [self loadProductData];
    [self createUI];
    
    return;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadProductData];
    contentTableView.editing = NO;
    editButton.selected = NO;
    [footerView setData:[self calculateProductCount:self.deskRecordArray]];
    [footerView hideAddButton];
    
    return;
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    addButton = [JCHUIFactory createButton:CGRectMake(0, 0, 30, 44)
                                    target:self
                                    action:@selector(handleAddMode:)
                                     title:nil
                                titleColor:nil
                           backgroundColor:nil];
    [addButton setImage:[UIImage imageNamed:@"icon_account_add"] forState:UIControlStateNormal];
    UIBarButtonItem *addItem = [[[UIBarButtonItem alloc] initWithCustomView:addButton] autorelease];
    
    //空白弹簧
    UIBarButtonItem *flexSpacer = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:self
                                                                                action:nil] autorelease];
    flexSpacer.width = -10;
    self.navigationItem.rightBarButtonItems = @[flexSpacer, addItem];
    
    placeholderView = [[[JCHPlaceholderView alloc] initWithFrame:CGRectZero] autorelease];
    placeholderView.hidden = YES;
    placeholderView.imageView.image = [UIImage imageNamed:@"default_goods_placeholder"];
    placeholderView.label.text = @"暂无桌台";
    [self.view addSubview:placeholderView];
    
    [placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(158);
        make.width.mas_equalTo(kScreenWidth);
        make.centerY.equalTo(self.view);
    }];
    
    UIView *searchBackgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [self.view addSubview:searchBackgroundView];
    searchBackgroundView.backgroundColor = [UIColor whiteColor];
    [searchBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.equalTo(self.view);
        make.height.mas_equalTo(kJCHTableViewSectionViewHeight);
    }];
    
    searchBar = [[[JCHSearchBar alloc] initWithFrame:CGRectZero] autorelease];
    [searchBackgroundView addSubview:searchBar];
    searchBar.delegate = self;
    [searchBar showCancelButton:NO];
    [searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(searchBackgroundView);
        make.left.equalTo(searchBackgroundView).offset(kStandardLeftMargin);
        make.right.equalTo(searchBackgroundView).offset(-kStandardRightMargin);
        make.height.mas_equalTo(kJCHTableViewSectionViewHeight);
    }];
    
    contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    [self.view addSubview:contentTableView];
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    //contentTableView.tableHeaderView = [[[JCHSeparateLineSectionView alloc] initWithTopLine:NO BottomLine:YES] autorelease];
    contentTableView.tableFooterView = [[[UIView alloc] init] autorelease];
    contentTableView.backgroundColor = JCHColorGlobalBackground;
    contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    contentTableView.allowsMultipleSelectionDuringEditing = YES;
    contentTableView.tintColor = UIColorFromRGB(0x4c8cdf);
    
    [contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(searchBackgroundView.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-49);
    }];
    
    footerView = [[[JCHItemListFooterView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 64 - 49, kScreenWidth, 49)] autorelease];
    footerView.categoryName = @"";
    footerView.categoryUnit = @"桌";
    footerView.delegate = self;
    [self.view addSubview:footerView];
    
    return;
}

- (void)handleEditMode:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    //如果当前某个cell处于左滑状态，tableView也处于editing状态，则要先将tableView的editing置为NO
    if (sender.selected && contentTableView.editing) {
        [contentTableView setEditing:NO animated:NO];
    }
    
    [footerView changeUI:contentTableView.isEditing];
    [footerView hideAddButton];
    [contentTableView setEditing:sender.selected animated:YES];
    if (!contentTableView.isEditing) {
        [footerView setData:[self calculateProductCount:self.deskRecordArray]];
    } else  {
        NSArray *selectedIndexPaths = [contentTableView indexPathsForSelectedRows];
        [footerView setData:selectedIndexPaths.count];
    }
    
    [footerView hideAddButton];
}

- (void)handleAddMode:(id)sender
{
    JCHAddDeskViewController *addController = [[[JCHAddDeskViewController alloc] init] autorelease];
    [self.navigationController pushViewController:addController animated:YES];
}

#pragma mark -
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.deskRecordArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)self.deskRecordArray[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 28;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DiningTableRecord4Cocoa *tableRecord = [self.deskRecordArray[section] firstObject];
    
    UIView *sectionView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 28)] autorelease];
    sectionView.backgroundColor = JCHColorGlobalBackground;
    UILabel *titleLabel = [JCHUIFactory createLabel:CGRectMake(kStandardLeftMargin, 0, kScreenWidth - 2 * kStandardLeftMargin, 28)
                                              title:@""
                                               font:[UIFont jchSystemFontOfSize:15.0f]
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentLeft];
    titleLabel.text = [NSString stringWithFormat:@"%@ (%d桌)", tableRecord.regionName, (int)[self.deskRecordArray[section] count]];
    
    [sectionView addSubview:titleLabel];
    
    if (section == 0) {
        [sectionView addSeparateLineWithFrameTop:NO bottom:YES];
    } else {
        [sectionView addSeparateLineWithFrameTop:YES bottom:YES];
    }
    
    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *kCellReuseTag = @"kCellReuseTag";
    JCHDeskListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseTag];
    if (nil == cell) {
        cell = [[[JCHDeskListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellReuseTag] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
//    cell.autoHiddenArrowImageViewWhileEditing = YES;
//    cell.arrowImageView.hidden = NO;
//    [cell hideLastBottomLine:tableView indexPath:indexPath];

    DiningTableRecord4Cocoa *record = self.deskRecordArray[indexPath.section][indexPath.row];
    
    [cell setData:record];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DiningTableRecord4Cocoa *record = self.deskRecordArray[indexPath.section][indexPath.row];
    JCHAddDeskViewController *modifyRecordVC = [[[JCHAddDeskViewController alloc] init] autorelease];
    modifyRecordVC.enumAddType = kJCHAddDeskTypeModify;
    modifyRecordVC.currentTableRecord = record;
    [self.navigationController pushViewController:modifyRecordVC animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        JCHProductListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.editing = NO;
        [self handleDeleteProduct:indexPath];
        [self loadProductData];
        [contentTableView reloadData];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}


#pragma mark - JCHProductListFooterViewDelegate
- (void)addItem
{
    self.hidesBottomBarWhenPushed = YES;
    JCHAddDeskViewController *addController = [[[JCHAddDeskViewController alloc] init] autorelease];
    addController.enumAddType = kJCHAddDeskTypeAdd;
    [self.navigationController pushViewController:addController animated:YES];
}

- (void)handleDeleteProduct:(NSIndexPath *)indexPath
{
    DiningTableRecord4Cocoa *record = self.deskRecordArray[indexPath.section][indexPath.row];
    id<DiningTableService> diningTableService = [[ServiceFactory sharedInstance] diningTableService];
    [diningTableService deleteDiningTable:record.tableID];
}

#pragma mark - LoadData

- (void)loadProductData
{
    id<DiningTableService> diningTableService = [[ServiceFactory sharedInstance] diningTableService];
    NSArray *allTableArray = [diningTableService queryDiningTable];
    self.deskRecordArray = [self subSectionProductArray:allTableArray];
    
    [contentTableView reloadData];
    [footerView setData:[self calculateProductCount:self.deskRecordArray]];
    
    return;
}

//按照商品类型分类 传入的商品数组 返回二维数组
- (NSArray *)subSectionProductArray:(NSArray *)deskArray
{
    NSMutableDictionary *regionMap = [[[NSMutableDictionary alloc] init] autorelease];
    for (DiningTableRecord4Cocoa *record in deskArray) {
        NSMutableArray *subArray = regionMap[record.regionName];
        if (nil == subArray) {
            subArray = [[[NSMutableArray alloc] init] autorelease];
            [regionMap setObject:subArray forKey:record.regionName];
        }
        
        [subArray addObject:record];
        [subArray sortUsingComparator:^NSComparisonResult(DiningTableRecord4Cocoa*  _Nonnull obj1, DiningTableRecord4Cocoa*  _Nonnull obj2) {
            return [obj1.tableName compare:obj2.tableName];
        }];
    }
    
    return [regionMap allValues];
}

//根据传入的二维数组计算总商品个数
- (NSInteger)calculateProductCount:(NSArray *)productArray;
{
    NSInteger count = 0;
    for (NSArray *subArray in productArray) {
        if ([subArray isKindOfClass:[NSArray class]]) {
            count += subArray.count;
        }
    }
    return count;
}

- (BOOL)showAlertForDeleteProduct:(NSString *)productUUID productName:(NSString *)productName
{
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    BOOL canBeDeleted = NO;
    [productService isProductCanBeDeleted:productUUID canBeDeleted:&canBeDeleted];
    return canBeDeleted;
}

#pragma mark - JCHSearchBarDelegate

- (void)searchBarCancelButtonClicked:(JCHSearchBar *)theSearchBar
{
    theSearchBar.textField.text = @"";
    [searchBar showCancelButton:NO];
    [self loadProductData];
}

- (void)searchBarTextChanged:(JCHSearchBar *)theSearchBar
{
    NSString *searchText = theSearchBar.textField.text;
    if (nil == searchText ||
        [searchText isEmptyString]) {
        [searchBar showCancelButton:NO];
        [self loadProductData];
        return;
    }
    
    id<DiningTableService> diningTableService = [[ServiceFactory sharedInstance] diningTableService];
    NSArray *allTableArray = [diningTableService queryDiningTable];
    NSMutableArray *filtTableArray = [[[NSMutableArray alloc] init] autorelease];
    for (DiningTableRecord4Cocoa *table in allTableArray) {
        if ([table.tableName rangeOfString:searchText].location != NSNotFound) {
            [filtTableArray addObject:table];
        }
    }
    
    self.deskRecordArray = [self subSectionProductArray:filtTableArray];
    
    [contentTableView reloadData];
    [footerView setData:[self calculateProductCount:self.deskRecordArray]];
}

- (void)searchBarDidBeginEditing:(JCHSearchBar *)theSearchBar
{
    [searchBar showCancelButton:YES];
}

- (void)searchBarDidEndEditing:(JCHSearchBar *)theSearchBar
{
    [searchBar showCancelButton:NO];
}

@end


