//
//  JCHMaterialListViewController.m
//  restaurant
//
//  Created by apple on 2016/11/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHMaterialListViewController.h"
#import "JCHInventoryTableViewSectionView.h"
#import "JCHInventoryPullDownContainerView.h"
#import "JCHInventoryPullDownTableView.h"
#import "JCHInventoryPullDownCategoryView.h"
#import "JCHInventoryPullDownSKUView.h"
#import "JCHAddMaterialViewController.h"
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
#import "Masonry.h"
#import "CommonHeader.h"

@interface JCHMaterialListViewController () <JCHItemListFooterViewDelegate,
                                            JCHInventoryTableViewSectionViewDelegate,
                                            JCHInventoryPullDownContainerViewDelegate,
                                            JCHInventoryPullDownBaseViewDelegate,
                                            UITableViewDelegate,
                                            UITableViewDataSource,
                                            JCHSearchBarDelegate,
                                            UIAlertViewDelegate,
                                            JCHMenuViewDelegate>
{
    UITableView *contentTableView;
    JCHItemListFooterView *footerView;
    UIButton *editButton;
    UIButton *addButton;
    JCHPlaceholderView *placeholderView;
    
    JCHInventoryPullDownContainerView *pullDownContainerView;
    JCHInventoryPullDownCategoryView *pullDownCategoryView;
    JCHInventoryPullDownCategoryView *pullDownUnitView;
    JCHInventoryPullDownSKUView *pullDownSKUView;
    
    
    BOOL appearFromPop;
}

@property (retain, nonatomic, readwrite) NSMutableArray *productRecordArray;

@property (retain, nonatomic, readwrite) NSArray *allProductRecord;
@property (retain, nonatomic, readwrite) NSArray *allCategory;
@property (retain, nonatomic, readwrite) NSArray *allUnit;

@property (retain, nonatomic, readwrite) JCHInventoryTableViewSectionView *filterSectionView;

// 当前用于过滤的分类名称，如果分类名称为@""或者分类名称为nil，表示不进行分类过滤
@property (retain, nonatomic, readwrite) NSString *filteredCategoryName;
@property (retain, nonatomic, readwrite) NSString *filteredUnitName;

@property (retain, nonatomic, readwrite) NSArray *filteredSKUValueUUIDArray;

//保存搜索前的数据源,当取消搜索后还原数据
@property (retain, nonatomic, readwrite) NSMutableArray *productBeforeSearch;

//! @brief 商品导入消息展示hud
@property (retain, nonatomic, readwrite) MBProgressHUD *importProductHud;

@end

@implementation JCHMaterialListViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"原料列表";
        self.filteredCategoryName = @"全部类型";
        self.filteredUnitName = @"全部单位";
        appearFromPop = NO;
        
        [self registerServiceNotificationHandler];
    }
    
    return self;
}

- (void)dealloc
{
    [self unregisterServiceNotificationHandler];
    
    [self.productRecordArray release];
    [self.allProductRecord release];
    [self.allCategory release];
    [self.allUnit release];
    [self.filteredCategoryName release];
    [self.filteredUnitName release];
    [self.filteredSKUValueUUIDArray release];
    [self.filterSectionView release];
    [self.productBeforeSearch release];
    [self.importProductHud release];
    
    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
    //[self loadProductData];
    
    return;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadProductData];
    contentTableView.editing = NO;
    editButton.selected = NO;
    [footerView setData:[self calculateProductCount:self.productRecordArray]];
    [footerView hideAddButton];
    
    return;
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    editButton = [JCHUIFactory createButton:CGRectMake(0, 0, 40, 40)
                                     target:self
                                     action:@selector(handleEditMode:)
                                      title:@"编辑"
                                 titleColor:nil
                            backgroundColor:nil];
    [editButton setTitle:@"取消" forState:UIControlStateSelected];
    editButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    
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
    UIBarButtonItem *editButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:editButton] autorelease];
    
    
    self.navigationItem.rightBarButtonItems = @[flexSpacer, addItem, editButtonItem];
    
    placeholderView = [[[JCHPlaceholderView alloc] initWithFrame:CGRectZero] autorelease];
    placeholderView.hidden = YES;
    placeholderView.imageView.image = [UIImage imageNamed:@"default_goods_placeholder"];
    placeholderView.label.text = @"暂无商品";
    [self.view addSubview:placeholderView];
    
    [placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(158);
        make.width.mas_equalTo(kScreenWidth);
        make.centerY.equalTo(self.view);
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
        make.top.equalTo(self.view.mas_top).offset(kJCHTableViewSectionViewHeight);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-49);
    }];
    
    footerView = [[[JCHItemListFooterView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 64 - 49, kScreenWidth, 49)] autorelease];
    footerView.categoryName = @"原料";
    footerView.categoryUnit = @"种";
    footerView.delegate = self;
    [self.view addSubview:footerView];
    
    CGRect viewRect = CGRectMake(0, 0, kScreenWidth, kJCHTableViewSectionViewHeight);
    self.filterSectionView = [[[JCHInventoryTableViewSectionView alloc] initWithFrame:viewRect titles:@[@"分类", @"单位", @"规格"]] autorelease];
    self.filterSectionView.delegate = self;
    self.filterSectionView.searchDelegate = self;
    [self.view addSubview:self.filterSectionView];
    self.view.clipsToBounds = YES;
    
    
    CGFloat tableSectionHeight = kJCHTableViewSectionViewHeight;
    
    pullDownContainerView = [[[JCHInventoryPullDownContainerView alloc] initWithFrame:CGRectZero] autorelease];
    pullDownContainerView.delegate = self;
    pullDownContainerView.backgroundColor = [UIColor redColor];
    [self.view addSubview:pullDownContainerView];
    
    [pullDownContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentTableView.mas_top).with.offset(tableSectionHeight);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(0);
    }];
    
    pullDownUnitView = [[[JCHInventoryPullDownCategoryView alloc] initWithFrame:CGRectZero] autorelease];
    pullDownUnitView.delegate = self;
    [pullDownContainerView addSubview:pullDownUnitView];
    
    [pullDownUnitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pullDownContainerView);
        make.left.equalTo(pullDownContainerView);
        make.right.equalTo(pullDownContainerView);
        make.height.mas_equalTo(kScreenHeight);
    }];
    
    pullDownCategoryView = [[[JCHInventoryPullDownCategoryView alloc] initWithFrame:CGRectZero] autorelease];
    pullDownCategoryView.delegate = self;
    [pullDownContainerView addSubview:pullDownCategoryView];
    
    [pullDownCategoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pullDownContainerView);
        make.left.equalTo(pullDownContainerView);
        make.right.equalTo(pullDownContainerView);
        make.height.mas_equalTo(kScreenHeight);
    }];
    
    pullDownSKUView = [[[JCHInventoryPullDownSKUView alloc] initWithFrame:CGRectZero] autorelease];
    pullDownSKUView.delegate = self;
    [pullDownContainerView addSubview:pullDownSKUView];
    
    [pullDownSKUView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pullDownContainerView);
        make.left.equalTo(pullDownContainerView);
        make.right.equalTo(pullDownContainerView);
        make.height.mas_equalTo(kScreenHeight);
    }];
    
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
        [footerView setData:[self calculateProductCount:self.productRecordArray]];
    } else  {
        NSArray *selectedIndexPaths = [contentTableView indexPathsForSelectedRows];
        [footerView setData:selectedIndexPaths.count];
    }
    
    [footerView hideAddButton];
}

- (void)handleAddMode:(id)sender
{
    JCHAddMaterialViewController *addController = [[[JCHAddMaterialViewController alloc] initWithProductRecord:nil] autorelease];
    addController.productType = kJCHAddMaterialTypeAddProduct;
    [self.navigationController pushViewController:addController animated:YES];
#if 0
    CGFloat menuWidth = 100;
    CGFloat rowHeight = 44;
    JCHMenuView *topMenuView = [[[JCHMenuView alloc] initWithTitleArray:@[@"新建商品", @"导入商品"]
                                                             imageArray:nil
                                                                 origin:CGPointMake(kScreenWidth - menuWidth - 14, 60)
                                                                  width:menuWidth
                                                              rowHeight:rowHeight
                                                              maxHeight:CGFLOAT_MAX
                                                                 Direct:kRightTriangle] autorelease];
    topMenuView.delegate = self;
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    [window addSubview:topMenuView];
#endif
}

- (void)menuItemDidSelected:(JCHMenuView *)menuView indexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row) {
        self.hidesBottomBarWhenPushed = YES;
        JCHAddMaterialViewController *addController = [[[JCHAddMaterialViewController alloc] initWithProductRecord:nil] autorelease];
        addController.productType = kJCHAddMaterialTypeAddProduct;
        [self.navigationController pushViewController:addController animated:YES];
    } else if (1 == indexPath.row) {
        self.importProductHud = [MBProgressHUD showHUDWithTitle:@"正在导入商品..."
                                                         detail:@"请勿退出应用，以免导入失败"
                                                       duration:1000
                                                           mode:MBProgressHUDModeIndeterminate
                                                     completion:nil];
        
        [self fetchBatchImportProductList];
    } else {
        // pass
    }
}

#pragma mark -
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.productRecordArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)self.productRecordArray[section] count];
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
    ProductRecord4Cocoa *productRecord = [self.productRecordArray[section] firstObject];
    
    UIView *sectionView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 28)] autorelease];
    sectionView.backgroundColor = JCHColorGlobalBackground;
    UILabel *titleLabel = [JCHUIFactory createLabel:CGRectMake(kStandardLeftMargin, 0, kScreenWidth - 2 * kStandardLeftMargin, 28)
                                              title:@""
                                               font:[UIFont jchSystemFontOfSize:15.0f]
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentLeft];
    titleLabel.text = productRecord.goods_type;
    
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
    JCHProductListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseTag];
    if (nil == cell) {
        cell = [[[JCHProductListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellReuseTag] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.autoHiddenArrowImageViewWhileEditing = YES;
    cell.arrowImageView.hidden = NO;
    [cell hideLastBottomLine:tableView indexPath:indexPath];
    
    WeakSelf;
    [cell setGoTopBlock:^(JCHItemListTableViewCell *cell) {
        [weakSelf handleGoTopCell:(JCHProductListTableViewCell *)cell];
    }];
    
    ProductRecord4Cocoa *record = self.productRecordArray[indexPath.section][indexPath.row];
    ProductInfo *info = [[[ProductInfo alloc] init] autorelease];
    info.productName = record.goods_name;
    info.productPrice = [NSString stringWithFormat:@"%.2f", record.goods_sell_price];
    info.productType = record.goods_type;
    info.sku_hidden_flag = record.sku_hiden_flag;
    // 对于多规格商品，显示售价范围
    if (NO == record.sku_hiden_flag ||
        YES == record.is_multi_unit_enable) {
        id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
        NSArray<ProductItemRecord4Cocoa *> *itemList = nil;
        
        NSMutableArray *priceArray = [NSMutableArray array];
        
        if (NO == record.sku_hiden_flag) {
            itemList = [productService querySkuGoodsItem:record.goods_uuid];
            //多规格商品，单品价格如果都为0，则显示统一出售价，单品价格如果有一个不为0，则价格范围为单品的价格范围
            
            BOOL productItemHasSet = NO;
            for (ProductItemRecord4Cocoa *productItemRecord in itemList) {
                [priceArray addObject:@(productItemRecord.itemPrice)];
                if (productItemRecord.itemPrice != 0) {
                    productItemHasSet = YES;
                }
            }
            if (!productItemHasSet) {
                [priceArray removeAllObjects];
                [priceArray addObject:@(record.goods_sell_price)];
            }
            info.productPrice = [JCHTransactionUtility getPriceStringFrowPriceArray:priceArray];
        } else if (YES == record.is_multi_unit_enable) {
            itemList = [productService queryUnitGoodsItem:record.goods_uuid];
            [priceArray addObject:@(record.goods_sell_price)];
            for (ProductItemRecord4Cocoa *productItemRecord in itemList) {
                [priceArray addObject:@(productItemRecord.itemPrice)];
            }
            info.productPrice = [JCHTransactionUtility getPriceStringFrowPriceArray:priceArray];
        } else {
            // pass
        }
    }
    
    [cell setData:info];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (contentTableView.editing) {
        
        //取消选中变为全选
        [footerView setButtonSelected:NO];
        [footerView setData:[contentTableView indexPathsForSelectedRows].count];
        
        if ([contentTableView indexPathsForSelectedRows].count == self.productRecordArray.count) {
            [footerView setButtonSelected:YES];
        }
    }
    else
    {
        [self.view endEditing:YES];
        id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
        ProductRecord4Cocoa *productRecord = [productService queryProductByUUID:[(ProductRecord4Cocoa *)(self.productRecordArray[indexPath.section][indexPath.row]) goods_uuid]];
        JCHAddMaterialViewController *modifyRecordVC = [[[JCHAddMaterialViewController alloc] initWithProductRecord:productRecord] autorelease];
        modifyRecordVC.productType = kJCHAddMaterialTypeModifyProduct;
        appearFromPop = YES;
        [self.navigationController pushViewController:modifyRecordVC animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing) {
        
        [footerView setButtonSelected:NO];
        [footerView setData:[contentTableView indexPathsForSelectedRows].count];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        JCHProductListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.editing = NO;
        [self handleDeleteProduct:indexPath];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSMutableArray *currentSectionArray = self.productRecordArray[sourceIndexPath.section];
    
    ProductRecord4Cocoa *sourceRecord = [currentSectionArray[sourceIndexPath.row] retain];
    
    [currentSectionArray removeObjectAtIndex:sourceIndexPath.row];
    [currentSectionArray insertObject:sourceRecord atIndex:destinationIndexPath.row];
    
    
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    
    NSInteger destinationSortIndex;
    if (destinationIndexPath.row == 0) {
        destinationSortIndex = 0;
    } else {
        ProductRecord4Cocoa *lastRecord = currentSectionArray[destinationIndexPath.row - 1];
        destinationSortIndex = lastRecord.sort_index + 1;
    }
    
    for (NSInteger i = destinationIndexPath.row; i < currentSectionArray.count; i++) {
        ProductRecord4Cocoa *record = currentSectionArray[i];
        record.sort_index = destinationSortIndex;
        [productService updateProductSortIndex:record.goods_uuid sortIndex:destinationSortIndex];
        destinationSortIndex++;
    }
}

//cell移动时调用，可以控制cell在同一个section内移动
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.section != sourceIndexPath.section)
    {
        return sourceIndexPath;
    }
    
    return proposedDestinationIndexPath;
}

- (void)handleGoTopCell:(JCHProductListTableViewCell *)cell
{
    NSIndexPath *indexPath = [contentTableView indexPathForCell:cell];
    NSMutableArray *currentSectionArray = self.productRecordArray[indexPath.section];
    
    ProductRecord4Cocoa *sourceRecord = [currentSectionArray[indexPath.row] retain];
    [currentSectionArray removeObjectAtIndex:indexPath.row];
    [currentSectionArray insertObject:sourceRecord atIndex:0];
    
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    
    for (NSInteger i = 0; i < currentSectionArray.count; i++) {
        ProductRecord4Cocoa *record = currentSectionArray[i];
        record.sort_index = i;
        [productService updateProductSortIndex:record.goods_uuid sortIndex:i];
    }
    [contentTableView reloadData];
}



#pragma mark - JCHProductListFooterViewDelegate
- (void)addItem
{
    self.hidesBottomBarWhenPushed = YES;
    JCHAddMaterialViewController *addController = [[[JCHAddMaterialViewController alloc] initWithProductRecord:nil] autorelease];
    addController.productType = kJCHAddMaterialTypeAddProduct;
    [self.navigationController pushViewController:addController animated:YES];
}
- (void)deleteItems
{
    NSArray *selectedIndexPaths = [contentTableView indexPathsForSelectedRows];
    if (selectedIndexPaths.count == 0) {
        return;
    }
    [MBProgressHUD showHUDWithTitle:@"删除中..." detail:@"" duration:9999 mode:MBProgressHUDModeIndeterminate completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 检查不能直接删除的商品列表
        NSMutableArray<NSString *> *canNotDeleteProductList = [[[NSMutableArray alloc] init] autorelease];
        for (NSIndexPath *indexPath in selectedIndexPaths) {
            
            ProductRecord4Cocoa *currentProduct = self.productRecordArray[indexPath.section][indexPath.row];
            
            BOOL showAlertForDeleteProduct = [self showAlertForDeleteProduct:currentProduct.goods_uuid
                                                                 productName:currentProduct.goods_name];
            if (NO == showAlertForDeleteProduct) {
                [canNotDeleteProductList addObject:currentProduct.goods_name];
            }
        }
        
        if (0 != canNotDeleteProductList.count) {
            [MBProgressHUD hideAllHudsForWindow];
            
            NSString *alertMessage = @"";
            if (1 == canNotDeleteProductList.count) {
                alertMessage = [NSString stringWithFormat:@"有%d个商品有库存（%@)，是否删除？商品库存将盘点为0",
                                (int)canNotDeleteProductList.count,
                                canNotDeleteProductList[0]];
            } else if (2 == canNotDeleteProductList.count) {
                alertMessage = [NSString stringWithFormat:@"有%d个商品有库存（%@, %@)，是否删除？商品库存将盘点为0",
                                (int)canNotDeleteProductList.count,
                                canNotDeleteProductList[0],
                                canNotDeleteProductList[1]];
                
            } else if (3 == canNotDeleteProductList.count){
                alertMessage = [NSString stringWithFormat:@"有%d个商品有库存（%@, %@, %@)，是否删除？商品库存将盘点为0",
                                (int)canNotDeleteProductList.count,
                                canNotDeleteProductList[0],
                                canNotDeleteProductList[1],
                                canNotDeleteProductList[2]];
                
            } else {
                alertMessage = [NSString stringWithFormat:@"有%d个商品有库存（%@, %@, %@, ...)，是否删除？商品库存将盘点为0",
                                (int)canNotDeleteProductList.count,
                                canNotDeleteProductList[0],
                                canNotDeleteProductList[1],
                                canNotDeleteProductList[2]];
            }
            
            UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"强制删除"
                                                                   style:UIAlertActionStyleDestructive
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                     [self deleteAllSelectedProduct:selectedIndexPaths];
                                                                 }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                     [self handleEditMode:editButton];
                                                                 }];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:deleteAction];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    });
}
- (void)selectAll:(UIButton *)button
{
    if (button.selected) {
        //取消选中
        [contentTableView reloadData];
    }
    else
    {
        //选中所有
        for (NSInteger i = 0; i < self.productRecordArray.count; i++) {
            NSArray *productRecordInSection = self.productRecordArray[i];
            for (NSInteger j = 0; j < productRecordInSection.count; j++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                [contentTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
    //刷新footerView数据
    [footerView setData:[contentTableView indexPathsForSelectedRows].count];
}

- (void)handleDeleteProduct:(NSIndexPath *)indexPath
{
    ProductRecord4Cocoa *currentProduct = self.productRecordArray[indexPath.section][indexPath.row];
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    BOOL showAlertForDeleteProduct = [self showAlertForDeleteProduct:currentProduct.goods_uuid
                                                         productName:currentProduct.goods_name];
    if (NO == showAlertForDeleteProduct) {
        NSString *alertMessage = [NSString stringWithFormat:@"\"%@\" 商品有库存，是否删除？商品库存将盘点为0", currentProduct.goods_name];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"强制删除"
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self clearProductInventory:currentProduct.goods_uuid];
                                                                 [productService deleteProduct:currentProduct.goods_uuid];
                                                                 
                                                                 [MBProgressHUD showHUDWithTitle:@"删除成功" detail:@"" duration:kJCHDefaultShowHudTime mode:MBProgressHUDModeText completion:^{
                                                                     [self loadProductData];
                                                                 }];
                                                             }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [contentTableView reloadRowsAtIndexPaths:@[indexPath]
                                                                                         withRowAnimation:UITableViewRowAnimationNone];
                                                             }];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:deleteAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [productService deleteProduct:currentProduct.goods_uuid];
        [self loadProductData];
    }
    
    return;
}

#pragma mark - LoadData

- (void)loadProductData
{
    [MBProgressHUD showHUDWithTitle:@"加载中..."
                             detail:nil
                           duration:100
                               mode:MBProgressHUDModeIndeterminate
                          superView:self.view
                         completion:nil];
    
    id <ProductService> productService = [[ServiceFactory sharedInstance] productService];
    id <CategoryService> categoryService = [[ServiceFactory sharedInstance] categoryService];
    id <UnitService> unitService = [[ServiceFactory sharedInstance] unitService];
    id <SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        self.allProductRecord = [productService queryAllProduct];
        self.allCategory = [categoryService queryAllCategory];
        self.allUnit = [unitService queryAllUnit];
        
        for (ProductRecord4Cocoa *record in self.allProductRecord){
            record.productNamePinYin = [JCHPinYinUtility getFirstPinYinLetterForProductName:record.goods_name];
        }
        //self.productRecordArray = self.allProductRecord;
        
        //将所有商品数组转换为 二维数组（按类型分类）
        self.productRecordArray = [self subSectionProductArray:self.allProductRecord];
        
        NSArray *allSKUType = nil;
        [skuService queryAllSKUType:&allSKUType];
        
        NSMutableArray *allSKUValueToType = [NSMutableArray array];
        
        for (SKUTypeRecord4Cocoa *skuTypeRecord in allSKUType) {
            NSArray *skuValueArray = nil;
            [skuService querySKUWithType:skuTypeRecord.skuTypeUUID skuRecordVector:&skuValueArray];
            NSDictionary *skuValueToType = @{skuTypeRecord.skuTypeName : skuValueArray};
            [allSKUValueToType addObject:skuValueToType];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self.allProductRecord.count == 0)
            {
                contentTableView.hidden = YES;
                editButton.hidden = YES;
                placeholderView.hidden = NO;
            }
            else
            {
                contentTableView.hidden = NO;
                editButton.hidden = NO;
                placeholderView.hidden = YES;
            }
            
            [contentTableView reloadData];
            
            if (!appearFromPop) {
                [pullDownCategoryView setData:self.allCategory];
                [pullDownUnitView setData:self.allUnit];
                
                //data : @[@{skuTypeName : @[skuValueRecord, ...]}, ...];
                [pullDownSKUView setData:allSKUValueToType];
            }
            
            
            [self reloadWithSortAndFilt];
            
            if (self.filterSectionView.searchBar.textField.text && ![self.filterSectionView.searchBar.textField.text isEmptyString]) {
                [self searchBarTextChanged:self.filterSectionView.searchBar];
            }
            
            if (self.filteredSKUValueUUIDArray && self.filteredSKUValueUUIDArray.count > 0) {
                [self filterAction:self.filteredSKUValueUUIDArray];
            }
            
            [MBProgressHUD hideHUDForView:self.view animated:NO];
            
            //如果没有商品,footerView切换模式
            if (self.allProductRecord.count == 0) {
                [footerView changeUI:YES];
                [footerView hideAddButton];
                contentTableView.editing = NO;
                editButton.selected = NO;
            }
            if (contentTableView.isEditing) {
                [footerView setData:[contentTableView indexPathsForSelectedRows].count];
            } else {
                [footerView setData:[self calculateProductCount:self.productRecordArray]];
            }
        });
    });
    
    return;
}

//按照商品类型分类 传入的商品数组 返回二维数组
- (NSMutableArray *)subSectionProductArray:(NSArray *)productArray
{
    NSMutableArray *allProductToCategory = [NSMutableArray array];
    //[allProductToCategory addObject:@[]];
    for (CategoryRecord4Cocoa *categoryRecord in self.allCategory) {
        NSMutableArray *productsInCategory = [NSMutableArray array];
        for (ProductRecord4Cocoa *productReceord in productArray) {
            if ([productReceord.goods_type isEqualToString:categoryRecord.categoryName]) {
                [productsInCategory addObject:productReceord];
            }
        }
        if (productsInCategory.count > 0) {
            [allProductToCategory addObject:productsInCategory];
        }
    }
    return allProductToCategory;
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

- (void)reloadWithSortAndFilt
{
    NSMutableArray *productInCategory = [NSMutableArray array];
    NSArray *catetegoryFiltedResultArray = nil;
    if (self.filteredCategoryName) {
        if ([self.filteredCategoryName isEqualToString:@"全部类型"]) {
            catetegoryFiltedResultArray = self.allProductRecord;
        } else {
            
            for (ProductRecord4Cocoa *record in self.allProductRecord){
                if ([record.goods_type isEqualToString:self.filteredCategoryName]) {
                    [productInCategory addObject:record];
                }
            }
            catetegoryFiltedResultArray = productInCategory;
        }
    }
    
    
    if (self.filteredUnitName) {
        if ([self.filteredUnitName isEqualToString:@"全部单位"]) {
            self.productRecordArray = [self subSectionProductArray:catetegoryFiltedResultArray];
        } else {
            
            NSMutableArray *productInUnit = [NSMutableArray array];
            for (ProductRecord4Cocoa *record in catetegoryFiltedResultArray) {
                if ([record.goods_unit isEqualToString:self.filteredUnitName]) {
                    [productInUnit addObject:record];
                }
            }
            self.productRecordArray = [self subSectionProductArray:productInUnit];
        }
    }
    
    [contentTableView reloadData];
    [footerView setData:[self calculateProductCount:self.productRecordArray]];
}

- (BOOL)showAlertForDeleteProduct:(NSString *)productUUID productName:(NSString *)productName
{
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    BOOL canBeDeleted = NO;
    [productService isProductCanBeDeleted:productUUID canBeDeleted:&canBeDeleted];
    return canBeDeleted;
}

- (void)showPullDownView:(JCHInventoryPullDownBaseView *)view
{
    //如果这次点击的button和上次的不一样
    if (self.filterSectionView.selectedButtonChanged) {
        if (pullDownContainerView.isShow) {
            [pullDownContainerView hideCompletion:^{
                [pullDownContainerView show:view];
            }];
        } else {
            [pullDownContainerView show:view];
        }
    } else {
        
        if (pullDownContainerView.isShow) {
            [pullDownContainerView hideCompletion:nil];
        } else {
            [pullDownContainerView show:view];
        }
    }
}

#pragma mark - JCHInventoryTableViewSectionViewDelegate

- (void)handleButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    if (!pullDownContainerView.isShow) {
        [pullDownContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(self.filterSectionView.frame.size.height);
        }];
        
        [self.view layoutIfNeeded];
    }
    
    switch (sender.tag) {
            
            //分类
        case kJCHInventoryTableViewSectionViewButtonFirstTag:
        {
            [self showPullDownView:pullDownCategoryView];
        }
            break;
            
            //按进货量排序
        case kJCHInventoryTableViewSectionViewButtonSecondTag:
        {
            [self showPullDownView:pullDownUnitView];
        }
            break;
            
            //SKU
        case kJCHInventoryTableViewSectionViewButtonThirdTag:
        {
            [self showPullDownView:pullDownSKUView];
        }
            break;
            
            //搜索
        case kJCHInventoryTableViewSectionViewSearchButtonTag:
        {
            
            [pullDownContainerView hideCompletion:^{
                [self.filterSectionView showSearchBar:YES];
                
                //保存搜索之前的数据源,当搜索完后还原
                self.productBeforeSearch = self.productRecordArray;
                //点击搜索后数据源为全部库存
                self.productRecordArray = [self subSectionProductArray:self.allProductRecord];
                [contentTableView reloadData];
            }];
        }
            break;
            
        default:
            break;
    }
    
    //if (pullDownContainerView.isShow) {
    //contentTableView.scrollEnabled = NO;
    //} else {
    //contentTableView.scrollEnabled = YES;
    //}
}

#pragma mark - JCHInventoryPullDownContainerViewDelegate

- (void)clickMaskView
{
    [self.filterSectionView handleButtonClickAction:self.filterSectionView.selectedButton];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}

#pragma mark - JCHInventoryPullDownBaseViewDelegate

- (void)filteredSKUValueUUIDArray:(NSArray *)filteredSKUValueUUIDArray
{
    self.filteredSKUValueUUIDArray = filteredSKUValueUUIDArray;
    
    //规格筛选和其他筛选不组合，当点击规格筛选后，初始化其他筛选条件
    [pullDownCategoryView selectButton:0];
    [pullDownUnitView selectButton:0];
    self.filteredCategoryName = @"全部类型";
    self.filteredUnitName = @"全部单位";
    
    [self clickMaskView];
    [MBProgressHUD showHUDWithTitle:@"筛选中..."
                             detail:@""
                           duration:1000
                               mode:MBProgressHUDModeIndeterminate
                         completion:nil];
    [self performSelector:@selector(filterAction:) withObject:filteredSKUValueUUIDArray afterDelay:0.01];
}

- (void)filterAction:(NSArray *)filteredSKUValueUUIDArray
{
    NSMutableArray *filteredProductRecord = [NSMutableArray array];
    
    if (filteredSKUValueUUIDArray == nil || filteredSKUValueUUIDArray.count == 0) {
        [filteredProductRecord addObjectsFromArray:self.allProductRecord];
    } else {
        NSMutableDictionary *cacheGoodsSKURecord = [[[NSMutableDictionary alloc] init] autorelease];
        
        for (ProductRecord4Cocoa *productRecord in self.allProductRecord) {
            
            GoodsSKURecord4Cocoa *skuRecord = [cacheGoodsSKURecord objectForKey:productRecord.goods_sku_uuid];
            if (nil == skuRecord) {
                id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
                [skuService queryGoodsSKU:productRecord.goods_sku_uuid skuArray:&skuRecord];
                [cacheGoodsSKURecord setObject:skuRecord forKey:productRecord.goods_sku_uuid];
            }
            
            for (NSArray *filterSKUValueUUIDSubArray in filteredSKUValueUUIDArray) {
                
                NSSet *filteredSkuValueUUIDSet = [NSSet setWithArray:filterSKUValueUUIDSubArray];
                
                NSMutableArray *skuValueRecord = [NSMutableArray array];
                for (NSDictionary *dict in skuRecord.skuArray) {
                    [skuValueRecord addObject:[dict allValues][0]];
                }
                
                NSDictionary *skuValuedDict = [JCHTransactionUtility getTransactionsWithData:skuValueRecord];
                
                //一种商品的所有单品组合
                NSArray *skuValueUUIDArray = [skuValuedDict allKeys][0];
                
                for (NSArray *subSKUValueUUIDArray in skuValueUUIDArray) {
                    NSSet *skuValueSet = [NSSet setWithArray:subSKUValueUUIDArray];
                    if ([filteredSkuValueUUIDSet isSubsetOfSet:skuValueSet]) {
                        [filteredProductRecord addObject:productRecord];
                        goto label;
                    }
                    
                }
            }
            label : NSLog(@"goto");
        }
    }
    
    self.productRecordArray = [self subSectionProductArray:filteredProductRecord];
    [contentTableView reloadData];
    [footerView setData:[self calculateProductCount:self.productRecordArray]];
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].windows[0] animated:YES];
}


- (void)pullDownView:(JCHInventoryPullDownBaseView *)view buttonSelected:(NSInteger)buttonTag
{
    [pullDownSKUView clearOption];
    if (view == pullDownCategoryView) {
        
        if (buttonTag == kCategoryButtonTagBase) { //全部分类
            self.filteredCategoryName = @"全部类型";
        } else {
            NSInteger i = buttonTag - kCategoryButtonTagBase - 1;
            CategoryRecord4Cocoa *record = self.allCategory[i];
            self.filteredCategoryName = record.categoryName;
        }
    } else if (view == pullDownUnitView) {
        
        if (buttonTag == kCategoryButtonTagBase) { //全部单位
            self.filteredUnitName = @"全部单位";
        } else {
            NSInteger i = buttonTag - kCategoryButtonTagBase - 1;
            UnitRecord4Cocoa *record = self.allUnit[i];
            self.filteredUnitName = record.unitName;
        }
    } else {
        //pass
    }
    
    [self clickMaskView];
    [self reloadWithSortAndFilt];
}

#pragma mark - JCHSearchBarDelegate

- (void)searchBarCancelButtonClicked:(JCHSearchBar *)searchBar
{
    searchBar.textField.text = @"";
    [self.filterSectionView showSearchBar:NO];
    
    self.productRecordArray = self.productBeforeSearch;
    [contentTableView reloadData];
    
    if ([contentTableView isEditing]) {
        [footerView setData:[contentTableView indexPathsForSelectedRows].count];
    } else {
        [footerView setData:[self calculateProductCount:self.productRecordArray]];
    }
}

- (void)searchBarTextChanged:(JCHSearchBar *)searchBar
{
    //搜索的数据源是所有的商品，不是已经筛选过的
    if ([searchBar.textField.text isEqualToString:@""]) {
        self.productRecordArray = [self subSectionProductArray:self.allProductRecord];
    } else {
        NSPredicate *predicate = nil;
        NSMutableArray *resultArr = [NSMutableArray array];
        //商品名称首字母
        {
            predicate = [NSPredicate predicateWithFormat:@"self.productNamePinYin contains[c] %@", searchBar.textField.text];
            [resultArr addObjectsFromArray:[self.allProductRecord filteredArrayUsingPredicate:predicate]];
        }
        
        //商品名称
        {
            predicate = [NSPredicate predicateWithFormat:@"self.goods_name contains[c] %@", searchBar.textField.text];
            [resultArr addObjectsFromArray:[self.allProductRecord filteredArrayUsingPredicate:predicate]];
        }
        //过滤重复
        resultArr = [resultArr valueForKeyPath:@"@distinctUnionOfObjects.self"];
        
        NSMutableArray *resultMutableArr = [NSMutableArray arrayWithArray:resultArr];
        [resultMutableArr sortUsingComparator:^NSComparisonResult(ProductRecord4Cocoa *obj1, ProductRecord4Cocoa *obj2) {
            return [obj1.goods_name compare:obj2.goods_name];
        }];
        self.productRecordArray = [self subSectionProductArray:resultMutableArr];
    }
    
    [contentTableView reloadData];
    [footerView setData:[self calculateProductCount:self.productRecordArray]];
    
    //[searchBar assignFirstResponser];
}

- (void)fetchBatchImportProductList
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    FetchBatchImportProductListRequest *request = [[[FetchBatchImportProductListRequest alloc] init] autorelease];
    request.accountBookID = statusManager.accountBookID;
    request.token = statusManager.syncToken;
    request.deviceUUID = statusManager.deviceUUID;
    request.serviceURL = kBatchImportProductServiceIP;
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService fetchBatchImportProductList:request
                            responseNotification:kJCHFetchBatchImportProductListNotification];
}

- (void)registerServiceNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleFetchBatchImportProductList:)
                               name:kJCHFetchBatchImportProductListNotification
                             object:[UIApplication sharedApplication]];
}

- (void)unregisterServiceNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter removeObserver:self
                                  name:kJCHFetchBatchImportProductListNotification
                                object:[UIApplication sharedApplication]];
}

- (void)handleFetchBatchImportProductList:(NSNotification *)notification
{
    NSDictionary *userData = notification.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSInteger responseCode = [userData[@"data"][@"code"] integerValue];
        if (10000 != responseCode) {
            [self.importProductHud hide:NO];
            [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                     detail:@"请重新登录"
                                   duration:2
                                       mode:MBProgressHUDModeText
                                 completion:nil];
            
            return;
        }
        
        NSArray *goodsList = userData[@"data"][@"data"][@"goods"];
        if (0 == goodsList.count) {
            [self.importProductHud hide:NO];
            [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                     detail:@"没有可导入的商品数据"
                                   duration:2
                                       mode:MBProgressHUDModeText
                                 completion:nil];
            
            return;
        }
        
        
        BOOL status = [self storeImportProductList:goodsList];
        
        if (YES == status) {
            
            //导入成功后做一次push操作，不管push成功或者失败，均提示导入成功
            JCHDataSyncManager *dataSyncManager = [JCHDataSyncManager shareInstance];
            TICK;
            [dataSyncManager doSyncPushCommand:^(NSInteger pushFlag, NSInteger pullFlag, NSDictionary *responseData) {
                [self loadProductData];
                [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                         detail:@"商品导入成功"
                                       duration:2
                                           mode:MBProgressHUDModeText
                                     completion:nil];
                TOCK(@"商品导入成功 PULL");
                
            } failure:^(NSInteger responseCode, NSError *error) {
                [self loadProductData];
                [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                         detail:@"商品导入成功"
                                       duration:2
                                           mode:MBProgressHUDModeText
                                     completion:nil];
                TOCK(@"商品导入成功 PULL");
            }];
        } else {
            [self.importProductHud hide:NO];
            [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                     detail:@"商品导入失败，请重试"
                                   duration:2
                                       mode:MBProgressHUDModeText
                                 completion:nil];
        }
    } else {
        [self.importProductHud hide:NO];
        [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                 detail:@"商品导入失败，请重试"
                               duration:2
                                   mode:MBProgressHUDModeText
                             completion:nil];
        NSLog(@"request fail: %@", userData[@"data"]);
    }
}

- (BOOL)storeImportProductList:(NSArray *)goodsList
{
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    NSArray *allProductList = [productService queryAllProduct];
    
    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
    NSArray *warehouseList = [warehouseService queryAllWarehouse];
    
    for (NSDictionary *goods in goodsList) {
        CGFloat beginAmount = [goods[@"beginAmount"] doubleValue];
        CGFloat beginNum = [goods[@"beginNum"] doubleValue];
        NSString *goodsBarCode = goods[@"goodsBarCode"];
        NSString *goodsCategoryUuid = goods[@"goodsCategoryUuid"];
        NSString *goodsMemo = goods[@"goodsMemo"];
        NSString *goodsMerchantCode = goods[@"goodsMerchantCode"];
        NSString *goodsName = goods[@"goodsName"];
        CGFloat goodsSellPrice = [goods[@"goodsSellPrice"] doubleValue];
        NSString *goodsType = goods[@"goodsType"];
        NSString *goodsUnit = goods[@"goodsUnit"];
        NSString *goodsUnitUuid = goods[@"goodsUnitUuid"];
        BOOL goodsStatus = ([goods[@"status"] integerValue] == 0);
        
        ProductRecord4Cocoa *productRecord = productRecord = [[[ProductRecord4Cocoa alloc] init] autorelease];
        productRecord.goods_domain = @"";
        productRecord.goods_name = goodsName;
        productRecord.goods_type = goodsType;
        productRecord.goods_memo = goodsMemo;
        productRecord.goods_property = @"";
        productRecord.goods_unit = goodsUnit;
        productRecord.goods_code = @"";
        productRecord.goods_category_path = @"";
        productRecord.goods_sell_price = goodsSellPrice;
        productRecord.goods_currency = @"人民币";
        productRecord.goods_hiden_flag = goodsStatus;
        productRecord.goods_image_name = @"";
        productRecord.goods_image_name2 = @"";
        productRecord.goods_image_name3 = @"";
        productRecord.goods_image_name4 = @"";
        productRecord.goods_image_name5 = @"";
        productRecord.goods_bar_code = goodsBarCode;
        productRecord.goods_merchant_code = goodsMerchantCode;
        productRecord.goods_sku_uuid = [[[ServiceFactory sharedInstance] utilityService] generateUUID];;
        productRecord.sku_hiden_flag = YES;
        productRecord.is_multi_unit_enable = NO;
        productRecord.goods_uuid = [[[ServiceFactory sharedInstance] utilityService] generateUUID];
        productRecord.goods_category_uuid = goodsCategoryUuid;
        productRecord.goods_unit_uuid = goodsUnitUuid;
        
        //期初库存相关
        NSString *kDefaultWarehouseID = @"0";
        NSMutableArray *beginInventoryRecordsArray = [NSMutableArray array];
        BeginningInventoryInfoRecord4Cocoa *record = [[[BeginningInventoryInfoRecord4Cocoa alloc] init] autorelease];
        record.skuUUIDVector = @[];
        record.beginningPrice = beginAmount;
        record.beginningCount = beginNum;
        record.unitUUID = goodsUnitUuid;
        record.unitName = goodsUnit;
        record.warehouseUUID = kDefaultWarehouseID;
        [beginInventoryRecordsArray addObject:record];
        
        for (WarehouseRecord4Cocoa *warehouse in warehouseList) {
            if ([warehouse.warehouseID isEqualToString:kDefaultWarehouseID]) {
                continue;
            }
            
            BeginningInventoryInfoRecord4Cocoa *emptyInventoryRecord = [[[BeginningInventoryInfoRecord4Cocoa alloc] init] autorelease];
            emptyInventoryRecord.skuUUIDVector = @[];
            emptyInventoryRecord.beginningPrice = 0;
            emptyInventoryRecord.beginningCount = 0;
            emptyInventoryRecord.unitUUID = goodsUnitUuid;
            emptyInventoryRecord.unitName = goodsUnit;
            emptyInventoryRecord.warehouseUUID = warehouse.warehouseID;
            [beginInventoryRecordsArray addObject:emptyInventoryRecord];
        }
        
        // 判断当前的商品是否已存在
        BOOL isDuplicateProduct = NO;
        for (ProductRecord4Cocoa *product in allProductList) {
            if ([product.goods_name isEqualToString:productRecord.goods_name] &&
                [product.goods_type isEqualToString:productRecord.goods_type]) {
                isDuplicateProduct = YES;
                break;
            }
        }
        
        // 重复导入，忽略当前导入的商品
        if (isDuplicateProduct) {
            continue;
        }
        
        int status = [productService addProduct:productRecord recordVector:beginInventoryRecordsArray];
        if (status) {
            NSLog(@"import product fail");
        }
    }
    
    return YES;
}

#pragma mark -
#pragma mark 基于盘点的方式将当前商品的库存清空
- (void)clearProductInventory:(NSString *)productUUID
{
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    ProductRecord4Cocoa *product = [productService queryProductByUUID:productUUID];
    
    if (YES == product.sku_hiden_flag) {
        if (YES == product.is_multi_unit_enable) {
            // 主辅单位
            [self clearMultiUnitProductInventory:product];
        } else {
            // 无规格
            [self clearNoSkuProductInventory:product];
        }
    } else {
        if (YES == product.is_multi_unit_enable) {
            // 数据错误
            NSLog(@"invalid product mode");
        } else {
            // 多规格
            [self clearMultiSkuProductInventory:product];
        }
    }
}

#pragma mark -
#pragma mark 清空无规格商品库存
- (void)clearNoSkuProductInventory:(ProductRecord4Cocoa *)product
{
    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
    id<FinanceCalculateService> calculateService = [[ServiceFactory sharedInstance] financeCalculateService];
    NSArray<WarehouseRecord4Cocoa *> *warehouseList = [warehouseService queryAllWarehouse];
    
    for (WarehouseRecord4Cocoa *warehouse in warehouseList) {
        InventoryDetailRecord4Cocoa *inventory = [calculateService calculateInventoryFor:product.goods_uuid
                                                                                unitUUID:product.goods_unit_uuid
                                                                           warehouseUUID:warehouse.warehouseID];
        
        NSMutableArray<CountingTransactionRecord4Cocoa *> *transactionList = [[[NSMutableArray alloc] init] autorelease];
        CountingTransactionRecord4Cocoa *record = [[[CountingTransactionRecord4Cocoa alloc] init] autorelease];
        record.productUUID = product.goods_uuid;
        record.productName = product.goods_name;
        record.productSKUUUIDVector = @[];
        record.productCountBefore = inventory.currentInventoryCount;
        record.averagePriceBefore = inventory.averageCostPrice;
        record.productCountAfter = 0;
        record.averagePriceAfter = inventory.averageCostPrice;
        record.productCategory = product.goods_type;
        record.productCategoryUUID = product.goods_category_uuid;
        record.unitUUID = product.goods_unit_uuid;
        record.productUnit = product.goods_unit;
        record.productImageName = product.goods_image_name;
        record.warehouseID = warehouse.warehouseID;
        record.unitDigits = (int)product.goods_unit_digits;
        
        [transactionList addObject:record];
        
        time_t manifestTime = [[NSDate date] timeIntervalSince1970];
        int operatorID = [[[JCHSyncStatusManager shareInstance] userID] intValue];
        id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
        NSString *manifestID = [manifestService createManifestID:kJCHManifestInventory];
        
        [self countingManifest:manifestID
                  manifestTime:manifestTime
                   warehouseID:warehouse.warehouseID
                manifestRemark:@""
                    operatorID:operatorID
               transactionList:transactionList];
    }
}

#pragma mark -
#pragma mark 清空多规格商品库存
- (void)clearMultiSkuProductInventory:(ProductRecord4Cocoa *)product
{
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
    id<FinanceCalculateService> calculateService = [[ServiceFactory sharedInstance] financeCalculateService];
    NSArray<WarehouseRecord4Cocoa *> *warehouseList = [warehouseService queryAllWarehouse];
    
    for (WarehouseRecord4Cocoa *warehouse in warehouseList) {
        InventoryDetailRecord4Cocoa *inventory = [calculateService calculateInventoryFor:product.goods_uuid
                                                                                unitUUID:product.goods_unit_uuid
                                                                           warehouseUUID:warehouse.warehouseID];
        
        NSMutableArray<CountingTransactionRecord4Cocoa *> *transactionList = [[[NSMutableArray alloc] init] autorelease];
        
        for (SKUInventoryRecord4Cocoa *item in inventory.productSKUInventoryArray) {
            CountingTransactionRecord4Cocoa *record = [[[CountingTransactionRecord4Cocoa alloc] init] autorelease];
            record.productUUID = product.goods_uuid;
            record.productName = product.goods_name;
            
            {
                GoodsSKURecord4Cocoa *skuRecord = nil;
                [skuService queryGoodsSKU:item.productSKUUUID skuArray:&skuRecord];
                NSMutableArray *skuValueRecord = [NSMutableArray array];
                for (NSDictionary *dict in skuRecord.skuArray) {
                    [skuValueRecord addObject:[[dict allValues][0][0] skuValueUUID]];
                }
                
                record.productSKUUUIDVector = skuValueRecord;
            }
            
            record.productCountBefore = item.currentInventoryCount;
            record.averagePriceBefore = item.averageCostPrice;
            record.productCountAfter = 0;
            record.averagePriceAfter = item.averageCostPrice;
            record.productCategory = product.goods_type;
            record.productCategoryUUID = product.goods_category_uuid;
            record.unitUUID = product.goods_unit_uuid;
            record.productUnit = product.goods_unit;
            record.productImageName = product.goods_image_name;
            record.warehouseID = warehouse.warehouseID;
            record.unitDigits = (int)product.goods_unit_digits;
            
            [transactionList addObject:record];
        }
        
        time_t manifestTime = [[NSDate date] timeIntervalSince1970];
        int operatorID = [[[JCHSyncStatusManager shareInstance] userID] intValue];
        id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
        NSString *manifestID = [manifestService createManifestID:kJCHManifestInventory];
        
        [self countingManifest:manifestID
                  manifestTime:manifestTime
                   warehouseID:warehouse.warehouseID
                manifestRemark:@""
                    operatorID:operatorID
               transactionList:transactionList];
    }
}

#pragma mark -
#pragma mark 清空主辅单位商品库存
- (void)clearMultiUnitProductInventory:(ProductRecord4Cocoa *)product
{
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
    id<FinanceCalculateService> calculateService = [[ServiceFactory sharedInstance] financeCalculateService];
    NSArray<WarehouseRecord4Cocoa *> *warehouseList = [warehouseService queryAllWarehouse];
    NSArray<ProductItemRecord4Cocoa *> *productUnitArray = [productService queryUnitGoodsItem:product.goods_uuid];
    
    for (WarehouseRecord4Cocoa *warehouse in warehouseList) {
        NSMutableArray<CountingTransactionRecord4Cocoa *> *transactionList = [[[NSMutableArray alloc] init] autorelease];
        for (ProductItemRecord4Cocoa *unit in productUnitArray) {
            InventoryDetailRecord4Cocoa *inventory = [calculateService calculateInventoryFor:product.goods_uuid
                                                                                    unitUUID:unit.goodsUnitUUID
                                                                               warehouseUUID:warehouse.warehouseID];
            
            CountingTransactionRecord4Cocoa *record = [[[CountingTransactionRecord4Cocoa alloc] init] autorelease];
            record.productUUID = product.goods_uuid;
            record.productName = product.goods_name;
            record.productSKUUUIDVector = @[];
            record.productCountBefore = inventory.currentInventoryCount;
            record.averagePriceBefore = inventory.averageCostPrice;
            record.productCountAfter = 0;
            record.averagePriceAfter = inventory.averageCostPrice;
            record.productCategory = product.goods_type;
            record.productCategoryUUID = product.goods_category_uuid;
            record.unitUUID = unit.goodsUnitUUID;
            record.productUnit = unit.unitName;
            record.productImageName = unit.imageName1;
            record.warehouseID = warehouse.warehouseID;
            record.unitDigits = (int)unit.unitDigits;
            
            [transactionList addObject:record];
        }
        
        {
            InventoryDetailRecord4Cocoa *inventory = [calculateService calculateInventoryFor:product.goods_uuid
                                                                                    unitUUID:product.goods_unit_uuid
                                                                               warehouseUUID:warehouse.warehouseID];
            
            CountingTransactionRecord4Cocoa *record = [[[CountingTransactionRecord4Cocoa alloc] init] autorelease];
            record.productUUID = product.goods_uuid;
            record.productName = product.goods_name;
            record.productSKUUUIDVector = @[];
            record.productCountBefore = inventory.currentInventoryCount;
            record.averagePriceBefore = inventory.averageCostPrice;
            record.productCountAfter = 0;
            record.averagePriceAfter = inventory.averageCostPrice;
            record.productCategory = product.goods_type;
            record.productCategoryUUID = product.goods_category_uuid;
            record.unitUUID = product.goods_unit_uuid;
            record.productUnit = product.goods_unit;
            record.productImageName = product.goods_image_name;
            record.warehouseID = warehouse.warehouseID;
            record.unitDigits = (int)product.goods_unit_digits;
            
            [transactionList addObject:record];
        }
        
        time_t manifestTime = [[NSDate date] timeIntervalSince1970];
        int operatorID = [[[JCHSyncStatusManager shareInstance] userID] intValue];
        id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
        NSString *manifestID = [manifestService createManifestID:kJCHManifestInventory];
        
        [self countingManifest:manifestID
                  manifestTime:manifestTime
                   warehouseID:warehouse.warehouseID
                manifestRemark:@""
                    operatorID:operatorID
               transactionList:transactionList];
    }
}

#pragma mark -
#pragma mark 删除所有选中的商品
- (void)deleteAllSelectedProduct:(NSArray *)selectedIndexPaths
{
    [MBProgressHUD showHUDWithTitle:@"删除中..." detail:@"" duration:9999 mode:MBProgressHUDModeIndeterminate completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
        for (NSIndexPath *indexPath in selectedIndexPaths) {
            ProductRecord4Cocoa *currentProduct = self.productRecordArray[indexPath.section][indexPath.row];
            [self clearProductInventory:currentProduct.goods_uuid];
            [productService deleteProduct:currentProduct.goods_uuid];
        }
        
        [MBProgressHUD showHUDWithTitle:@"删除成功" detail:@"" duration:kJCHDefaultShowHudTime mode:MBProgressHUDModeText completion:^{
            [self loadProductData];
        }];
    });
}

#pragma mark -
#pragma mark 商品盘点
- (void)countingManifest:(NSString *)manifestID
            manifestTime:(time_t)manifestTime
             warehouseID:(NSString *)warehouseID
          manifestRemark:(NSString *)remark
              operatorID:(int)operatorID
         transactionList:(NSArray *)transactionList
{
    NSMutableArray *tempArray = [[[NSMutableArray alloc] init] autorelease];
    for (CountingTransactionRecord4Cocoa *record in transactionList) {
        if (fabs(record.productCountBefore) <= 0.00001) {
            continue;
        } else {
            [tempArray addObject:record];
        }
    }
    
    if (0 == tempArray.count) {
        return;
    }
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    [manifestService countingManifest:manifestID
                         manifestTime:manifestTime
                          warehouseID:warehouseID
                       manifestRemark:remark
                           operatorID:operatorID
                      transactionList:tempArray];
}



@end



