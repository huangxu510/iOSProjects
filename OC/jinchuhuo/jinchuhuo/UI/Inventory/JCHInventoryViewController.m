//
//  JCHInventoryViewController.m
//  jinchuhuo
//
//  Created by apple on 15/8/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHInventoryViewController.h"
#import "JCHAddedServiceViewController.h"
#import "JCHAddWarehouseViewController.h"
#import "JCHTitleArrowButton.h"
#import "JCHInventoryTableViewSectionView.h"
#import "JCHInventoryPullDownContainerView.h"
#import "JCHInventoryPullDownTableView.h"
#import "JCHInventoryPullDownCategoryView.h"
#import "JCHInventoryPullDownSKUView.h"
#import "JCHInventoryTableViewCell.h"
#import "JCHInventoryStatisticsView.h"
#import "JCHProductDetailViewController.h"
#import "JCHUISizeSettings.h"
#import "JCHUISettings.h"
#import "JCHManifestUtility.h"
#import "ServiceFactory.h"
#import "JCHUIDebugger.h"
#import "JCHColorSettings.h"
#import "ServiceFactory.h"
#import "JCHImageUtility.h"
#import "JCHSizeUtility.h"
#import "JCHPerimissionUtility.h"
#import "JCHSyncStatusManager.h"
#import "JCHPinYinUtility.h"
#import "JCHTransactionUtility.h"
#import "MBProgressHUD+JCHHud.h"
#import "JCHMenuView.h"
#import "Masonry.h"
#import "CommonHeader.h"
#import <MJRefresh.h>
#import "JCHRestaurantAddProductViewController.h"
#import "JCHRestaurantSoldOutViewController.h"


enum
{
    kInventoryTopStatisticsViewHeigh = 69,
};



enum JCHInventorySortType
{
    kInventorySortByPurchasesCountDescending = 0,   // 进货量从高到低
    kInventorySortByPurchasesCountAscending,        // 进货量从低到高
    kInventorySortByShipmentCountDescending,        // 出货量从高到低
    kInventorySortByShipmentCountAscending,         // 出货量从低到高
    kInventorySortByInventoryCountDescending,       // 存货数量从高到低
    kInventorySortByInventoryCountAscending,        // 存货数量从低到高
    kInventoryNoSort, // 不排序
};

enum JCHInventoryCountType
{
    kJCHInventoryCountTypePositive = 0,             //正库存
    kJCHInventoryCountTypeZero,                     //零库存
    kJCHInventoryCountTypeNegative,                 //负库存
    kJCHInventoryCountTypeAll,                      //全部库存
};

@interface JCHInventoryViewController () <JCHInventoryTableViewSectionViewDelegate,
                                        JCHSearchBarDelegate,
                                        JCHInventoryPullDownContainerViewDelegate,
                                        JCHInventoryPullDownBaseViewDelegate,
                                        UIAlertViewDelegate, JCHMenuViewDelegate>

{
    JCHTitleArrowButton *titleButton;
    UITableView *contentTableView;
    JCHPlaceholderView *placeholderView;
    
    JCHInventoryPullDownContainerView *pullDownContainerView;
    JCHInventoryPullDownTableView *pullDownSortTableView;
    JCHInventoryPullDownCategoryView *pullDownCategoryView;
    JCHInventoryPullDownSKUView *pullDownSKUView;
    JCHInventoryPullDownTableView *pullDownInventoryCountTableView;
    
    BOOL isNeedShowHudWhenLoadData;                     // 刷新数据的时候是否要显示菊花
    
    enum JCHInventorySortType enumInventorySortType;    // 当前的排序类型
    enum JCHInventoryCountType enumInventoryCountType;  // 当前的库存数量范围类型
}

//要显示的库存
@property (retain, nonatomic, readwrite) NSArray *inventoryRecordList;

//所有库存
@property (retain, nonatomic, readwrite) NSArray *allInventory;

//所有分类
@property (retain, nonatomic, readwrite) NSArray *allCategory;

@property (retain, nonatomic, readwrite) NSArray *allWarehouseList;
@property (retain, nonatomic, readwrite) NSArray *enableWarehouseList;
@property (retain, nonatomic, readwrite) NSString *selectedWarehouseId;

@property (retain, nonatomic, readwrite) JCHInventoryTableViewSectionView *sectionView;

@property (retain, nonatomic, readwrite) JCHInventoryStatisticsView *statisticsView;

//保存搜索前的数据源,当取消搜索后还原数据
@property (retain, nonatomic, readwrite) NSArray *inventoryBeforeSearch;

@property (retain, nonatomic, readwrite) NSArray *sortTableViewData;
@property (retain, nonatomic, readwrite) NSArray *countTableViewData;

@property (retain, nonatomic, readwrite) NSMutableDictionary *productRecordForProductUUID;

@end

@implementation JCHInventoryViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"库存管理";
        
        enumInventorySortType = kInventoryNoSort;
        enumInventoryCountType = kJCHInventoryCountTypeAll;
        self.refreshUIAfterAutoSync = YES;
        isNeedShowHudWhenLoadData = YES;
        self.sortTableViewData = @[@"进货量从高到低", @"进货量从低到高", @"出货量从高到低", @"出货量从低到高", @"库存从高到低", @"库存从低到高", @"不排序"];
        self.countTableViewData = @[@"正库存", @"零库存", @"负库存", @"全部"];
        self.selectedWarehouseId = [[[ServiceFactory sharedInstance] utilityService] getDefaultWarehouseUUID];
        [self registerResponseNotificationHandler];
    }
    
    return self;
}

- (void)dealloc
{
    [self.inventoryRecordList release];
    [self.allInventory release];
    [self.allCategory release];
    [self.sectionView release];
    [self.statisticsView release];
    [self.inventoryBeforeSearch release];
    [self.sortTableViewData release];
    [self.countTableViewData release];
    [self.allWarehouseList release];
    [self.enableWarehouseList release];
    [self.productRecordForProductUUID release];
    [self unregisterResponseNotificationHandler];
    
    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];

    self.view.backgroundColor = JCHColorGlobalBackground;

    return;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    //根据权限判断是否隐藏headerView
    if (statusManager.isShopManager) {
        contentTableView.tableHeaderView = self.statisticsView;
    } else {
        contentTableView.tableHeaderView = nil;
    }
    
    if (YES == self.isNeedReloadAllData) {
        
        [self loadData];
        
        id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
        WarehouseRecord4Cocoa *warehouseRecord = [warehouseService queryWarehouseByUUID:self.selectedWarehouseId];
        [titleButton setTitle:warehouseRecord.warehouseName forState:UIControlStateNormal];
        
        //初始化
        enumInventorySortType = kInventoryNoSort;
        enumInventoryCountType = kJCHInventoryCountTypeAll;
        self.sectionView.searchBar.textField.text = @"";
        self.inventoryBeforeSearch = self.allInventory;
        
        
        if (pullDownContainerView.isShow) {
            [pullDownContainerView hideCompletion:nil];
            self.sectionView.selectedButton.selected = NO;
            contentTableView.scrollEnabled = YES;
        }
        self.isNeedReloadAllData = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [contentTableView deselectRowAtIndexPath:[contentTableView indexPathForSelectedRow] animated:YES];
    return;
}

- (void)createUI
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (statusManager.isShopManager) {
        if (self.navigationController.viewControllers.count == 1) {
            self.navigationItem.leftBarButtonItem = nil;
        }
        
        UIButton *addButton = [JCHUIFactory createButton:CGRectMake(0, 0, 30, 44)
                                                  target:self
                                                  action:@selector(showTopMenuView)
                                                   title:nil
                                              titleColor:nil
                                         backgroundColor:nil];
        [addButton setImage:[UIImage imageNamed:@"icon_account_add"] forState:UIControlStateNormal];
        UIBarButtonItem *addItem = [[[UIBarButtonItem alloc] initWithCustomView:addButton] autorelease];
        UIBarButtonItem *flexSpacer = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                    target:self
                                                                                    action:nil] autorelease];
        flexSpacer.width = -5;
        
        self.navigationItem.rightBarButtonItems = @[flexSpacer, addItem];
    }
    
    
    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
    WarehouseRecord4Cocoa *warehouseRecord = [warehouseService queryWarehouseByUUID:self.selectedWarehouseId];
    
    titleButton = [JCHTitleArrowButton buttonWithType:UIButtonTypeCustom];
    titleButton.frame = CGRectMake(0, 0, 40, 50);
    titleButton.autoReverseArrow = YES;
    titleButton.autoAdjustButtonWidth = YES;
    titleButton.maxWidth = 100;
    [titleButton setImage:[UIImage imageNamed:@"homepage_storename_open"] forState:UIControlStateNormal];
    titleButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [titleButton setTitle:warehouseRecord.warehouseName forState:UIControlStateNormal];
    [titleButton addTarget:self action:@selector(handleShowWarehouseSelectMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleButton;
   
    
    CGRect statisticsViewFrame = CGRectMake(0, 0, self.view.frame.size.width, kInventoryTopStatisticsViewHeigh);

    self.statisticsView = [[[JCHInventoryStatisticsView alloc] initWithFrame:statisticsViewFrame] autorelease];

    contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    [self.view addSubview:contentTableView];
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    contentTableView.backgroundColor = JCHColorGlobalBackground;
    contentTableView.tableFooterView = [[[UIView alloc] init] autorelease];
    contentTableView.tableHeaderView = self.statisticsView;
    contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    WeakSelf;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadData];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    contentTableView.mj_header = header;
    
    [contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    placeholderView = [[[JCHPlaceholderView alloc] initWithFrame:CGRectZero] autorelease];
    placeholderView.hidden = YES;
    placeholderView.imageView.image = [UIImage imageNamed:@"default_stock_placeholder"];
    placeholderView.label.text = @"暂无数据";
    [self.view addSubview:placeholderView];
    
    CGFloat placeholderViewTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:30];
    [placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(158);
        make.width.mas_equalTo(kScreenWidth);
        make.centerY.equalTo(self.view).offset(placeholderViewTopOffset);
    }];
    
    CGFloat tableSectionHeight = kJCHTableViewSectionViewHeight;
    
    pullDownContainerView = [[[JCHInventoryPullDownContainerView alloc] initWithFrame:CGRectZero] autorelease];
    pullDownContainerView.delegate = self;
    pullDownContainerView.backgroundColor = [UIColor redColor];
    [self.view addSubview:pullDownContainerView];
    
    [pullDownContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentTableView.mas_top).with.offset(self.statisticsView.frame.size.height + tableSectionHeight);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(0);
    }];
    
    pullDownSortTableView = [[[JCHInventoryPullDownTableView alloc] initWithFrame:CGRectZero] autorelease];
    pullDownSortTableView.delegate = self;
    pullDownSortTableView.tag = kJCHInventoryTableViewSectionViewButtonFourthTag;
    [pullDownContainerView addSubview:pullDownSortTableView];
    
    
    [pullDownSortTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pullDownContainerView);
        make.left.equalTo(pullDownContainerView);
        make.right.equalTo(pullDownContainerView);
        make.height.mas_equalTo(kScreenHeight);
    }];
    
    pullDownInventoryCountTableView = [[[JCHInventoryPullDownTableView alloc] initWithFrame:CGRectZero] autorelease];
    pullDownInventoryCountTableView.delegate = self;
    pullDownInventoryCountTableView.tag = kJCHInventoryTableViewSectionViewButtonThirdTag;
    [pullDownContainerView addSubview:pullDownInventoryCountTableView];
    
    
    [pullDownInventoryCountTableView mas_makeConstraints:^(MASConstraintMaker *make) {
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
    
    
    
    CGRect viewRect = CGRectMake(0, 0, kScreenWidth, kJCHTableViewSectionViewHeight);
    self.sectionView = [[[JCHInventoryTableViewSectionView alloc] initWithFrame:viewRect titles:@[@"分类", @"规格", @"数量", @"排序"]] autorelease];
    self.sectionView.delegate = self;
    self.sectionView.searchDelegate = self;
    
    return;
}

- (void)handleShowWarehouseSelectMenu:(UIButton *)sender
{
    sender.selected = !sender.selected;
    CGFloat menuViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:120];
    CGFloat maxHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:200];
    
    NSMutableArray *titles = [NSMutableArray array];
    for (WarehouseRecord4Cocoa *warehouseRecord in self.enableWarehouseList) {
        [titles addObject:warehouseRecord.warehouseName];
    }
    JCHMenuView *menuView = [[[JCHMenuView alloc] initWithTitleArray:titles
                                                          imageArray:nil
                                                              origin:CGPointMake(kScreenWidth / 2 - menuViewWidth / 2 - 10, 55)
                                                               width:menuViewWidth
                                                           rowHeight:kStandardItemHeight
                                                           maxHeight:maxHeight
                                                              Direct:kCenterTriangle] autorelease];
    menuView.hideAnimation = YES;
    menuView.delegate = self;
    menuView.tag = 1000;
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    [window addSubview:menuView];
}

- (void)showTopMenuView
{
#if MMR_RESTAURANT_VERSION || MMR_TAKEOUT_VERSION
    // 餐饮版
    CGFloat menuWidth = 100;
    CGFloat rowHeight = 44;
    JCHMenuView *topMenuView = [[[JCHMenuView alloc] initWithTitleArray:@[@"原料盘点", @"原料损耗", @"菜品估清", @"取消估清"]
                                                             imageArray:nil
                                                                 origin:CGPointMake(kScreenWidth - menuWidth - kStandardLeftMargin * 1.5, 64)
                                                                  width:menuWidth
                                                              rowHeight:rowHeight
                                                              maxHeight:CGFLOAT_MAX
                                                                 Direct:kRightTriangle] autorelease];
    topMenuView.delegate = self;
    topMenuView.tag = 2000;
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    [window addSubview:topMenuView];
    
#else
    // 通用版
    CGFloat menuWidth = 100;
    CGFloat rowHeight = 44;
    JCHMenuView *topMenuView = [[[JCHMenuView alloc] initWithTitleArray:@[@"商品移库", @"商品拼装", @"商品拆装", @"商品盘点", @"新建仓库"]   // @"商品拼装", @"商品拆卸",
                                                             imageArray:nil
                                                                 origin:CGPointMake(kScreenWidth - menuWidth - kStandardLeftMargin * 1.5, 64)
                                                                  width:menuWidth
                                                              rowHeight:rowHeight
                                                              maxHeight:CGFLOAT_MAX
                                                                 Direct:kRightTriangle] autorelease];
    topMenuView.delegate = self;
    topMenuView.tag = 2000;
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    [window addSubview:topMenuView];
    
#endif
}

#pragma mark - ClearData
- (void)clearData
{
    NSLog(@"ClearInventoryData");
    JCHInventoryStatisticsViewData *viewData = [[[JCHInventoryStatisticsViewData alloc] init] autorelease];
    viewData.shipmentCount = @"0.00";
    viewData.inventoryCount = @"0.00";
    viewData.purchasesCount = @"0.00";
    [self.statisticsView setViewData:viewData];
    
    //self.allInventory = @[];
    self.inventoryRecordList = @[];
    self.selectedWarehouseId = [[[ServiceFactory sharedInstance] utilityService] getDefaultWarehouseUUID];
    isNeedShowHudWhenLoadData = YES;
    self.isNeedReloadAllData = YES;
    [contentTableView reloadData];
}

#pragma mark - LoadData

- (void)loadData
{
    NSLog(@"LoadInventoryData");
    if (isNeedShowHudWhenLoadData) {
        [MBProgressHUD showHUDWithTitle:@"加载中..."
                                 detail:nil
                               duration:100
                                   mode:MBProgressHUDModeIndeterminate
                              superView:self.view
                             completion:nil];
        isNeedShowHudWhenLoadData = NO;
    }
    
    id <FinanceCalculateService> calculateService = [[ServiceFactory sharedInstance] financeCalculateService];
    id <ProductService> productService = [[ServiceFactory sharedInstance] productService];
    id <SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    id<CategoryService> categoryService = [[ServiceFactory sharedInstance] categoryService];
    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *allInventory = [calculateService calculateAllInventory:self.selectedWarehouseId];
        NSArray *allProduct = [productService queryAllProduct];
        self.allCategory = [categoryService queryAllCategory];
        self.allInventory = allInventory;
        NSArray *allSKUType = nil;
        [skuService queryAllSKUType:&allSKUType];
        
        NSMutableArray *allSKUValueToType = [NSMutableArray array];
        
        for (SKUTypeRecord4Cocoa *skuTypeRecord in allSKUType) {
            NSArray *skuValueArray = nil;
            [skuService querySKUWithType:skuTypeRecord.skuTypeUUID skuRecordVector:&skuValueArray];
            NSDictionary *skuValueToType = @{skuTypeRecord.skuTypeName : skuValueArray};
            [allSKUValueToType addObject:skuValueToType];
        }
        
        

        const double thisMonthShipmentAmount = [calculateService calculateThisMonthShipmentAmount];
        const double totalInventorytAmount = [calculateService calculateTotalInventoryAmount:self.selectedWarehouseId];
        const double thisPurchasesAmount = [calculateService calculateThisMonthPurchaseAmount];
        
        NSArray *warehouseArray = [warehouseService queryAllWarehouse];
        self.allWarehouseList = warehouseArray;
        NSMutableArray *enableWarehouseArray = [NSMutableArray array];
        for (WarehouseRecord4Cocoa *warehouseRecord in warehouseArray) {
            if (warehouseRecord.warehouseStatus == 0) {
                [enableWarehouseArray addObject:warehouseRecord];
            }
        }
        self.enableWarehouseList = enableWarehouseArray;
#if 1
        // 商品当前单位和库存单位不同并且数量为0不显示
        NSMutableArray *allInventoryWithoutSpecialInventory = [NSMutableArray array];
        for (InventoryDetailRecord4Cocoa *record in allInventory) {
            ProductRecord4Cocoa *currentProductRecord = [productService queryProductByUUID:record.productNameUUID];
           
            if ((![record.productUnitUUID isEqualToString:currentProductRecord.goods_unit_uuid] && (record.currentInventoryCount == 0))) {
                continue;
            } else {
                [allInventoryWithoutSpecialInventory addObject:record];
            }
            
        }
        self.allInventory = allInventoryWithoutSpecialInventory;
#endif
        for (InventoryDetailRecord4Cocoa *record in self.allInventory)
        {
            record.productNamePinYin = [JCHPinYinUtility getFirstPinYinLetterForProductName:record.productName];
            for (ProductRecord4Cocoa *product in allProduct) {
                if ([product.goods_uuid isEqualToString:record.productNameUUID]) {
                    record.unitDigits = product.goods_unit_digits;
                }
            }
        }
        
        self.allInventory = [self.allInventory sortedArrayUsingComparator:^NSComparisonResult(InventoryDetailRecord4Cocoa *obj1, InventoryDetailRecord4Cocoa *obj2) {
            return obj1.productLatestPurchaseTime < obj2.productLatestPurchaseTime;
        }];
        
        self.inventoryRecordList = self.allInventory;
        
        //商品缓存
        NSMutableDictionary *productRecordForProductUUID = [NSMutableDictionary dictionary];
        for (ProductRecord4Cocoa *productRecord in allProduct) {
            [productRecordForProductUUID setObject:productRecord forKey:productRecord.goods_uuid];
        }
        self.productRecordForProductUUID = productRecordForProductUUID;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self searchBarTextChanged:self.sectionView.searchBar];
            [self showPlaceholderView];
            
           
            JCHInventoryStatisticsViewData *viewData = [[[JCHInventoryStatisticsViewData alloc] init] autorelease];
            viewData.shipmentCount = [NSString stringWithFormat:@"%.2f", thisMonthShipmentAmount];
            viewData.inventoryCount = [NSString stringWithFormat:@"%.2f", totalInventorytAmount];
            viewData.purchasesCount = [NSString stringWithFormat:@"%.2f", thisPurchasesAmount];
            [self.statisticsView setViewData:viewData];
            
            [contentTableView reloadData];
            
            [pullDownCategoryView setData:self.allCategory];

            [pullDownSortTableView setData:self.sortTableViewData];
            
            [pullDownInventoryCountTableView setData:self.countTableViewData];
            
            //data : @[@{skuTypeName : @[skuValueRecord, ...]}, ...];
            [pullDownSKUView setData:allSKUValueToType];
            [MBProgressHUD hideHUDForView:self.view animated:NO];

            [contentTableView.mj_header endRefreshing];
        });
    });
    
 
    return;
}

- (void)reloadWithSortAndFilter:(NSInteger)sectionMenuTag
{
    
    switch (sectionMenuTag) {
            
        case kJCHInventoryTableViewSectionViewButtonFirstTag:
        {
            [self clearOtherSectionMenu:pullDownCategoryView];
            [self filterCategory];
        }
            break;
            
        case kJCHInventoryTableViewSectionViewButtonFourthTag:
        {
            [self clearOtherSectionMenu:pullDownSortTableView];
            [self sortData];
        }
            break;
            
        case kJCHInventoryTableViewSectionViewButtonSecondTag:
        {
            
        }
            break;
            
        case kJCHInventoryTableViewSectionViewButtonThirdTag:
        {
            [self clearOtherSectionMenu:pullDownInventoryCountTableView];
            [self filterInventoryCount];
        }
            break;
            
        default:
            break;
    }
}

- (void)sortData
{
    switch (enumInventorySortType) {
        case kInventoryNoSort:
        {
            
        }
            break;
        case kInventorySortByPurchasesCountDescending:
        {
            self.inventoryRecordList = [self.inventoryRecordList sortedArrayUsingComparator:^NSComparisonResult(InventoryDetailRecord4Cocoa *obj1, InventoryDetailRecord4Cocoa *obj2) {
                return obj1.currentTotalPurchasesCount < obj2.currentTotalPurchasesCount;
            }];
        }
            break;
        case kInventorySortByPurchasesCountAscending:
        {
            self.inventoryRecordList = [self.inventoryRecordList sortedArrayUsingComparator:^NSComparisonResult(InventoryDetailRecord4Cocoa *obj1, InventoryDetailRecord4Cocoa *obj2) {
                return obj1.currentTotalPurchasesCount > obj2.currentTotalPurchasesCount;
            }];
        }
            break;
        case kInventorySortByShipmentCountDescending:
        {
            self.inventoryRecordList = [self.inventoryRecordList sortedArrayUsingComparator:^NSComparisonResult(InventoryDetailRecord4Cocoa *obj1, InventoryDetailRecord4Cocoa *obj2) {
                return obj1.currentTotalShipmentCount < obj2.currentTotalShipmentCount;
            }];
        }
            break;
        case kInventorySortByShipmentCountAscending:
        {
            self.inventoryRecordList = [self.inventoryRecordList sortedArrayUsingComparator:^NSComparisonResult(InventoryDetailRecord4Cocoa *obj1, InventoryDetailRecord4Cocoa *obj2) {
                return obj1.currentTotalShipmentCount > obj2.currentTotalShipmentCount;
            }];
        }
            break;
        case kInventorySortByInventoryCountDescending:
        {
            self.inventoryRecordList = [self.inventoryRecordList sortedArrayUsingComparator:^NSComparisonResult(InventoryDetailRecord4Cocoa *obj1, InventoryDetailRecord4Cocoa *obj2) {
                return obj1.currentInventoryCount < obj2.currentInventoryCount;
            }];
        }
            break;
        case kInventorySortByInventoryCountAscending:
        {
            self.inventoryRecordList = [self.inventoryRecordList sortedArrayUsingComparator:^NSComparisonResult(InventoryDetailRecord4Cocoa *obj1, InventoryDetailRecord4Cocoa *obj2) {
                return obj1.currentInventoryCount > obj2.currentInventoryCount;
            }];
        }
            break;
            
            
        default:
            break;
    }

    [self showPlaceholderView];
    [contentTableView reloadData];
    //enumInventorySortType = kInventoryNoSort;
}

//筛选库存数量
- (void)filterInventoryCount
{
    switch (enumInventoryCountType) {
        case kJCHInventoryCountTypeAll:             //所有库存
        {
            self.inventoryRecordList = self.allInventory;
        }
            break;
            
        case kJCHInventoryCountTypePositive:        //正库存
        {
            NSMutableArray *tempArray = [NSMutableArray array];
            for (InventoryDetailRecord4Cocoa *record in self.allInventory)
            {
                if (record.currentInventoryCount > 0) {
                    [tempArray addObject:record];
                }
            }
            self.inventoryRecordList = tempArray;
        }
            break;
            
        case kJCHInventoryCountTypeNegative:        //负库存
        {
            NSMutableArray *tempArray = [NSMutableArray array];
            for (InventoryDetailRecord4Cocoa *record in self.allInventory)
            {
                if (record.currentInventoryCount < 0) {
                    [tempArray addObject:record];
                }
            }
            self.inventoryRecordList = tempArray;
        }
            break;
            
        case kJCHInventoryCountTypeZero:            //零库存
        {
            NSMutableArray *tempArray = [NSMutableArray array];
            for (InventoryDetailRecord4Cocoa *record in self.allInventory)
            {
                if (record.currentInventoryCount == 0) {
                    [tempArray addObject:record];
                }
            }
            self.inventoryRecordList = tempArray;
        }
            break;
            
        default:
            break;
    }
    
    enumInventoryCountType = kJCHInventoryCountTypeAll;
    [self sortData];
}

//筛选类型
- (void)filterCategory
{
    NSMutableArray *inventoryInCategory = [NSMutableArray array];
    if ([pullDownCategoryView getSelectButtonTitle]) {
        if ([[pullDownCategoryView getSelectButtonTitle] isEqualToString:@"全部"]) {
            self.inventoryRecordList = self.allInventory;
        }
        else
        {
            for (InventoryDetailRecord4Cocoa *record in self.allInventory)
            {
                if ([record.productCategory isEqualToString:[pullDownCategoryView getSelectButtonTitle]]) {
                    [inventoryInCategory addObject:record];
                }
            }
            self.inventoryRecordList = inventoryInCategory;
        }
    }
    [self sortData];
}

- (void)showPlaceholderView
{
    if (self.inventoryRecordList.count == 0) {
        //contentTableView.hidden = YES;
        placeholderView.hidden = NO;
    }
    else
    {
        //contentTableView.hidden = NO;
        placeholderView.hidden = YES;
    }
}

- (void)clearOtherSectionMenu:(UIView *)view
{
    if ([view isKindOfClass:[JCHInventoryPullDownCategoryView class]]) {
        
        [pullDownSKUView clearOption];
        [pullDownInventoryCountTableView selectCell:self.countTableViewData.count - 1];
        enumInventoryCountType = kJCHInventoryCountTypeAll;
    } else if ([view isKindOfClass:[JCHInventoryPullDownSKUView class]]) {
        
        [pullDownCategoryView selectButton:0];
        [pullDownInventoryCountTableView selectCell:self.countTableViewData.count - 1];
        enumInventoryCountType = kJCHInventoryCountTypeAll;
    } else if ([view isKindOfClass:[JCHInventoryPullDownTableView class]]) {
        
        if (view.tag == kJCHInventoryTableViewSectionViewButtonThirdTag) {
            [pullDownCategoryView selectButton:0];
            [pullDownSKUView clearOption];
        } else if (view.tag == kJCHInventoryTableViewSectionViewButtonFourthTag) {
            //pass
        } else {
            
        }
    } else {
        //pass
    }
}

- (void)switchToPhotoBrowser:(NSIndexPath *)indexPath
{
    InventoryDetailRecord4Cocoa *inventoryDetail = self.inventoryRecordList[indexPath.row];
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    
    ProductRecord4Cocoa *productRecord = [productService queryProductByUUID:inventoryDetail.productNameUUID];
    
    [JCHImageUtility showPhotoBrowser:productRecord viewController:self];
}


#pragma mark -
#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)self.inventoryRecordList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kInventoryTableViewCellTag = @"kInventoryTableViewCellTag";
    JCHInventoryTableViewCell *tableCell = [tableView dequeueReusableCellWithIdentifier:kInventoryTableViewCellTag];
    if (nil == tableCell) {
        tableCell = [[[JCHInventoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:kInventoryTableViewCellTag] autorelease];
    }
    
    WeakSelf;
    [tableCell setTapBlock:^(JCHInventoryTableViewCell *cell) {
        [weakSelf switchToPhotoBrowser:indexPath];
    }];
    
    InventoryDetailRecord4Cocoa *inventoryRecord = [self.inventoryRecordList objectAtIndex:indexPath.row];
    InventoryInfo *inventoryInfo = [[[InventoryInfo alloc] init] autorelease];
    inventoryInfo.productName = inventoryRecord.productName;
    inventoryInfo.productLogoName = inventoryRecord.productImageName;
    inventoryInfo.productPrice = [NSString stringWithFormat:@"%.2f", inventoryRecord.averageCostPrice];
    inventoryInfo.isShopManager = [[JCHSyncStatusManager shareInstance] isShopManager];

    ProductRecord4Cocoa *productRecord = self.productRecordForProductUUID[inventoryRecord.productNameUUID];
    inventoryInfo.isSKUProduct = !productRecord.sku_hiden_flag;
    if (inventoryRecord.unitDigits == 0)
    {
        inventoryInfo.inventoryCount = [NSString stringWithFormat:@"%g", inventoryRecord.currentInventoryCount];
    }
    else
    {
        inventoryInfo.inventoryCount = [NSString stringWithFormat:@"%.2f", inventoryRecord.currentInventoryCount];
    }
    inventoryInfo.inventoryUnit = inventoryRecord.productUnit;

    [tableCell setData:inventoryInfo];

    //每段最后一行的底线与左侧边无间隔
    if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        [tableCell moveBottomLineLeft:YES];
    }
    else
    {
        [tableCell moveBottomLineLeft:NO];
    }
    
    return tableCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (contentTableView == tableView) {
        return self.sectionView;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kJCHTableViewSectionViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kJCHTableViewRowHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[[UIView alloc] init] autorelease];
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //防止键盘未回收push动画变形
    [self.view endEditing:YES];
    
    InventoryDetailRecord4Cocoa *inventoryRecord = [self.inventoryRecordList objectAtIndex:indexPath.row];
    NSString *productUUID = inventoryRecord.productNameUUID;
    
    
    JCHProductDetailViewController *detailController = [[[JCHProductDetailViewController alloc] initWithName:productUUID unitUUID:inventoryRecord.productUnitUUID warehouseID:self.selectedWarehouseId] autorelease];
    detailController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailController animated:YES];
    
    return;
}

#pragma mark - JCHInventoryPullDownContainerViewDelegate

- (void)clickMaskView
{
    [self.sectionView handleButtonClickAction:self.sectionView.selectedButton];
}

- (void)showAlertView
{
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                         message:@"您当前还未添加规格"
                                                        delegate:self
                                               cancelButtonTitle:@"我知道了"
                                               otherButtonTitles:nil] autorelease];
    [alertView show];
}

#pragma mark - JCHAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.sectionView.selectedButton.selected = NO;
}


#pragma mark - JCHInventoryPullDownBaseViewDelegate

- (void)handleButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    if (!pullDownContainerView.isShow) {
        [pullDownContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            if (contentTableView.contentOffset.y > contentTableView.tableHeaderView.frame.size.height) {
                make.top.equalTo(contentTableView.mas_top).with.offset(self.sectionView.frame.size.height);
            } else {
                make.top.equalTo(contentTableView.mas_top).with.offset(contentTableView.tableHeaderView.frame.size.height + self.sectionView.frame.size.height - contentTableView.contentOffset.y);
            }
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
            
        //SKU
        case kJCHInventoryTableViewSectionViewButtonSecondTag:
        {
            [self showPullDownView:pullDownSKUView];
        }
            break;
            
        case kJCHInventoryTableViewSectionViewButtonThirdTag:
        {
            [self showPullDownView:pullDownInventoryCountTableView];
        }
            break;
            
            //按进货量排序
        case kJCHInventoryTableViewSectionViewButtonFourthTag:
        {
            [self showPullDownView:pullDownSortTableView];
        }
            break;
            
        //搜索
        case kJCHInventoryTableViewSectionViewSearchButtonTag:
        {
            
            [pullDownContainerView hideCompletion:^{
                [self.sectionView showSearchBar:YES];
                
                //保存搜索之前的数据源,当搜索完后还原
                self.inventoryBeforeSearch = self.inventoryRecordList;
                //点击搜索后数据源为全部库存
                self.inventoryRecordList = self.allInventory;
                [contentTableView reloadData];
            }];
        }
            break;

        default:
            break;
    }

    if (pullDownContainerView.isShow) {
        contentTableView.scrollEnabled = NO;
    } else {
        contentTableView.scrollEnabled = YES;
    }
}

- (void)showPullDownView:(JCHInventoryPullDownBaseView *)view
{
    //如果这次点击的button和上次的不一样
    if (self.sectionView.selectedButtonChanged) {
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

- (void)pullDownView:(JCHInventoryPullDownBaseView *)view buttonSelected:(NSInteger)buttonTag
{
    [self clickMaskView];
    [self reloadWithSortAndFilter:kJCHInventoryTableViewSectionViewButtonFirstTag];
}

- (void)selectedRow:(NSInteger)row buttonTag:(NSInteger)tag
{
    if (tag == kJCHInventoryTableViewSectionViewButtonFourthTag) {
        
        enumInventorySortType = (enum JCHInventorySortType)row;
    } else if (tag == kJCHInventoryTableViewSectionViewButtonThirdTag){
        
        enumInventoryCountType = (enum JCHInventoryCountType)row;
    } else {
        //pass
    }
    
    [self clickMaskView];
    [self reloadWithSortAndFilter:tag];
}

- (void)filteredSKUValueUUIDArray:(NSArray *)filteredSKUValueUUIDArray
{
    [self clickMaskView];
    
    [self clearOtherSectionMenu:pullDownSKUView];
    

    
    [MBProgressHUD showHUDWithTitle:@"筛选中..."
                             detail:@""
                           duration:1000
                               mode:MBProgressHUDModeIndeterminate
                         completion:nil];

    [self performSelector:@selector(filterSKU:) withObject:filteredSKUValueUUIDArray afterDelay:0.01];
}

- (void)filterSKU:(NSArray *)filteredSKUValueUUIDArray
{
    NSMutableArray *filteredInventoryRecord = [NSMutableArray array];

    if (filteredSKUValueUUIDArray == nil || filteredSKUValueUUIDArray.count == 0) {
        [filteredInventoryRecord addObjectsFromArray:self.allInventory];
    } else {
        
        int queryCount = 0;
        NSMutableDictionary *cacheGoodsSKURecord = [[[NSMutableDictionary alloc] init] autorelease];
        
        id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
        id<FinanceCalculateService> calculateService = [[ServiceFactory sharedInstance] financeCalculateService];
        
        //遍历所有库存
        for (NSInteger i = 0; i < self.allInventory.count; i++) {
            
            InventoryDetailRecord4Cocoa *inventoryDetailRecord = self.allInventory[i];

            //查询所有有规格的商品对应的goodsSKURecord的集合
            NSArray *allGoodsSKURecordArray = nil;
            [skuService queryAllGoodsSKU:&allGoodsSKURecordArray];
            
            BOOL productHasSKU = NO;
            for (GoodsSKURecord4Cocoa *goodsSKURecord in allGoodsSKURecordArray) {
                if ([inventoryDetailRecord.productSKUUUID isEqualToString:goodsSKURecord.goodsSKUUUID]) {
                    productHasSKU = YES;
                    break;
                }
            }
            
            //如果该商品没有规格，则跳过
            if (!productHasSKU) {
                NSLog(@"%@ 没有规格", inventoryDetailRecord.productName);
                continue;
            }

            
            TICK;
            InventoryDetailRecord4Cocoa *inventoryDetailRecordWithSKUUUIDArray = [calculateService calculateInventoryFor:inventoryDetailRecord.productNameUUID
                                                                                                                unitUUID:inventoryDetailRecord.productUnitUUID warehouseUUID:@"0"];
            TOCK(@"calculateInventoryForProduct");
            
            for (NSArray *filteredSKUValueUUIDSubArray in filteredSKUValueUUIDArray) {
                
                NSSet *filteredSkuValueUUIDSet = [NSSet setWithArray:filteredSKUValueUUIDSubArray];
                
                for (SKUInventoryRecord4Cocoa *skuInventoryRecord in inventoryDetailRecordWithSKUUUIDArray.productSKUInventoryArray) {
                    GoodsSKURecord4Cocoa *record = [cacheGoodsSKURecord objectForKey:skuInventoryRecord.productSKUUUID];
                    if (nil == record) {
                        [skuService queryGoodsSKU:skuInventoryRecord.productSKUUUID skuArray:&record];
                        
                        [cacheGoodsSKURecord setObject:record forKey:skuInventoryRecord.productSKUUUID];
                        ++queryCount;
                        NSLog(@"query count: %d", queryCount);
                    }
                    
                    NSMutableArray *skuValueRecord = [NSMutableArray array];
                    for (NSDictionary *dict in record.skuArray) {
                        [skuValueRecord addObject:[dict allValues][0]];
                    }
                    
                    NSDictionary *skuValuedDict = [JCHTransactionUtility getTransactionsWithData:skuValueRecord];
                    
                    //一种商品的所有单品组合
                    NSArray *skuValueUUIDArray = [skuValuedDict allKeys][0];
                    
                    for (NSArray *subSKUValueArray in skuValueUUIDArray) {
                        NSSet *skuValueSet = [NSSet setWithArray:subSKUValueArray];
                        if ([filteredSkuValueUUIDSet isSubsetOfSet:skuValueSet]) {
                            [filteredInventoryRecord addObject:inventoryDetailRecord];
                            
                            goto label;
                        }
                    }
                }
            }

            label : NSLog(@"goto");
            
        }
        NSLog(@"query count: %d", queryCount);
    }
    
    self.inventoryRecordList = filteredInventoryRecord;
    
    [self sortData];
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].windows[0] animated:YES];
}



#pragma mark - JCHSearchBarDelegate
- (void)searchBarCancelButtonClicked:(JCHSearchBar *)searchBar
{
    searchBar.textField.text = @"";
    [self.sectionView showSearchBar:NO];
    contentTableView.scrollEnabled = YES;
    
    self.inventoryRecordList = self.inventoryBeforeSearch;
    [contentTableView reloadData];
}

- (void)searchBarTextChanged:(JCHSearchBar *)searchBar
{
    if ([searchBar.textField.text isEqualToString:@""]) {
        self.inventoryRecordList = self.allInventory;
    }
    else
    {
        NSPredicate *predicate = nil;
        NSMutableArray *resultArr = [NSMutableArray array];
        //商品名称首字母
        {
            predicate = [NSPredicate predicateWithFormat:@"self.productNamePinYin contains[c] %@", searchBar.textField.text];
            [resultArr addObjectsFromArray:[self.allInventory filteredArrayUsingPredicate:predicate]];
        }
        
        //商品名称
        {
            predicate = [NSPredicate predicateWithFormat:@"self.productName contains[c] %@", searchBar.textField.text];
            [resultArr addObjectsFromArray:[self.allInventory filteredArrayUsingPredicate:predicate]];
        }
        
        //过滤重复
        resultArr = [resultArr valueForKeyPath:@"@distinctUnionOfObjects.self"];
        NSMutableArray *resultMutableArr = [NSMutableArray arrayWithArray:resultArr];
        [resultMutableArr sortUsingComparator:^NSComparisonResult(InventoryDetailRecord4Cocoa *obj1, InventoryDetailRecord4Cocoa *obj2) {
            return [obj1.productName compare:obj2.productName];
        }];
        self.inventoryRecordList = resultMutableArr;
    }
    [contentTableView reloadData];
}

#pragma mark - JCHMenuViewDelegate

- (void)menuItemDidSelected:(JCHMenuView *)menuView indexPath:(NSIndexPath *)indexPath
{
    if (menuView.tag == 1000) {
        WarehouseRecord4Cocoa *warehouseRecord = self.enableWarehouseList[indexPath.row];
        
        if ([warehouseRecord.warehouseID isEqualToString:self.selectedWarehouseId]) {
            return;
        }
        
        self.selectedWarehouseId = warehouseRecord.warehouseID;
        
        [titleButton setTitle:warehouseRecord.warehouseName forState:UIControlStateNormal];
        titleButton.selected = NO;
        self.isNeedReloadAllData = YES;
        isNeedShowHudWhenLoadData = YES;
        [self loadData];
    } else {
        JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
        
        if (statusManager.isShopManager) {
            AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
            appDelegate.switchToTargetController = self;
        }

#if MMR_RESTAURANT_VERSION || MMR_TAKEOUT_VERSION
        // 餐饮版
        [self handleMenuItemDidSelectedForRestaurant:indexPath];
#else
        // 通用版
        [self handleMenuItemDidSelectedForJCH:indexPath];
#endif
    }
}

// 通用版
- (void)handleMenuItemDidSelectedForJCH:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:         //商品移库
        {
            if (self.enableWarehouseList.count > 1) {
                // 仓库数量大于1，进入移库界面
                JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
                id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
                [manifestStorage clearData];
                
                manifestStorage.currentManifestID = [manifestService createManifestID:kJCHManifestMigrate];
                manifestStorage.currentManifestDate = [JCHManifestUtility getOrderDate];
                manifestStorage.currentManifestType = kJCHManifestMigrate;
                
                JCHAddProductMainViewController *addProductViewController = [[[JCHAddProductMainViewController alloc] init] autorelease];
                addProductViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:addProductViewController animated:YES];
            } else {
                
                JCHAddedServiceManager *addedServiceManager = [JCHAddedServiceManager shareInstance];
                if (addedServiceManager.level != kJCHAddedServiceSiverLevel && addedServiceManager.level != kJCHAddedServiceGoldLevel) {
                    // 提示用户购买会
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"很抱歉，您只有1个仓库，无法完成移库。购买仓库立即升级银麦会员享专线服务" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                    UIAlertAction *addedServiceAction = [UIAlertAction actionWithTitle:@"购买" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        JCHAddedServiceViewController *addedServiceVC = [[[JCHAddedServiceViewController alloc] init] autorelease];
                        addedServiceVC.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:addedServiceVC animated:YES];
                    }];
                    [alertController addAction:cancleAction];
                    [alertController addAction:addedServiceAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                } else {
                    // 提示用户新增仓库
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"很抱歉，您只有1个仓库，无法完成移库。立即新建仓库" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                    UIAlertAction *addWarehouseAction = [UIAlertAction actionWithTitle:@"新建" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        JCHAddWarehouseViewController *viewController = [[[JCHAddWarehouseViewController alloc] initWithWarehouseID:@"-1"
                                                                                                                     controllerMode:kAddWarehouse] autorelease];
                        viewController.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:viewController animated:YES];
                    }];
                    [alertController addAction:cancleAction];
                    [alertController addAction:addWarehouseAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
            }
        }
            break;
#if 1
        case 1:         //商品拼装
        {
            JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
            id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
            [manifestStorage clearData];
            
            manifestStorage.currentManifestID = [manifestService createManifestID:kJCHManifestAssembling];
            manifestStorage.currentManifestDate = [JCHManifestUtility getOrderDate];
            manifestStorage.currentManifestType = kJCHManifestAssembling;
            
            JCHAddProductMainViewController *addProductViewController = [[[JCHAddProductMainViewController alloc] init] autorelease];
            addProductViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:addProductViewController animated:YES];
        }
            break;
            
        case 2:         //商品拆装
        {
            JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
            id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
            [manifestStorage clearData];
            
            manifestStorage.currentManifestID = [manifestService createManifestID:kJCHManifestDismounting];
            manifestStorage.currentManifestDate = [JCHManifestUtility getOrderDate];
            manifestStorage.currentManifestType = kJCHManifestDismounting;
            
            JCHAddProductMainViewController *addProductViewController = [[[JCHAddProductMainViewController alloc] init] autorelease];
            addProductViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:addProductViewController animated:YES];
        }
            break;
#endif
        case 3:         //商品盘点
        {
            JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
            id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
            [manifestStorage clearData];
            
            manifestStorage.currentManifestID = [manifestService createManifestID:kJCHManifestInventory];
            manifestStorage.currentManifestDate = [JCHManifestUtility getOrderDate];
            manifestStorage.currentManifestType = kJCHManifestInventory;
            
            JCHAddProductMainViewController *addProductViewController = [[[JCHAddProductMainViewController alloc] init] autorelease];
            addProductViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:addProductViewController animated:YES];
        }
            break;
            
        case 4:         //新建仓库
        {
            JCHAddedServiceManager *addedServiceManager = [JCHAddedServiceManager shareInstance];
            if (addedServiceManager.level != kJCHAddedServiceSiverLevel && addedServiceManager.level != kJCHAddedServiceGoldLevel) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"很抱歉，普通用户仅支持默认仓库，无法新建！购买仓库立即升级银麦会员享专线服务" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *addedServiceAction = [UIAlertAction actionWithTitle:@"购买" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    JCHAddedServiceViewController *addedServiceVC = [[[JCHAddedServiceViewController alloc] init] autorelease];
                    addedServiceVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:addedServiceVC animated:YES];
                }];
                [alertController addAction:cancleAction];
                [alertController addAction:addedServiceAction];
                [self presentViewController:alertController animated:YES completion:nil];
            } else {
                
                JCHAddWarehouseViewController *viewController = [[[JCHAddWarehouseViewController alloc] initWithWarehouseID:@"-1"
                                                                                                             controllerMode:kAddWarehouse] autorelease];
                viewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }
            break;
        default:
            break;
    }
}

#if MMR_RESTAURANT_VERSION || MMR_TAKEOUT_VERSION

// 餐饮版
- (void)handleMenuItemDidSelectedForRestaurant:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:         // 原料盘点
        {
            JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
            id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
            [manifestStorage clearData];
            
            manifestStorage.currentManifestID = [manifestService createManifestID:kJCHManifestInventory];
            manifestStorage.currentManifestDate = [JCHManifestUtility getOrderDate];
            manifestStorage.currentManifestType = kJCHManifestInventory;
            manifestStorage.enumRestaurantManifestType = kJCHRestaurantMaterialInventory;
            
            JCHRestaurantAddProductViewController *addProductViewController = [[[JCHRestaurantAddProductViewController alloc] init] autorelease];
            addProductViewController.hidesBottomBarWhenPushed = YES;
            addProductViewController.enumManifestType = kJCHRestaurantMaterialInventory;
            [self.navigationController pushViewController:addProductViewController animated:YES];
        }
            break;
            
        case 1:         // 菜品损耗
        {
            JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
            id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
            [manifestStorage clearData];
            
            manifestStorage.currentManifestID = [manifestService createManifestID:kJCHManifestInventory];
            manifestStorage.currentManifestDate = [JCHManifestUtility getOrderDate];
            manifestStorage.currentManifestType = kJCHManifestMaterialWastage;
            manifestStorage.enumRestaurantManifestType = kJCHRestaurantMaterialWastage;
            
            JCHRestaurantAddProductViewController *addProductViewController = [[[JCHRestaurantAddProductViewController alloc] init] autorelease];
            addProductViewController.hidesBottomBarWhenPushed = YES;
            addProductViewController.enumManifestType = kJCHManifestMaterialWastage;
            [self.navigationController pushViewController:addProductViewController animated:YES];
        }
            break;
            
        case 2:         // 菜品估清
        {
            JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
            id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
            [manifestStorage clearData];
            
            manifestStorage.currentManifestID = [manifestService createManifestID:kJCHManifestInventory];
            manifestStorage.currentManifestDate = [JCHManifestUtility getOrderDate];
            manifestStorage.currentManifestType = kJCHManifestInventory;
            manifestStorage.enumRestaurantManifestType = kJCHRestaurantDishesMarkSold;
            
            JCHRestaurantSoldOutViewController *addProductViewController = [[[JCHRestaurantSoldOutViewController alloc] init] autorelease];
            addProductViewController.hidesBottomBarWhenPushed = YES;
            addProductViewController.enumManifestType = kJCHRestaurantDishesMarkSold;
            [self.navigationController pushViewController:addProductViewController animated:YES];
        }
            break;
            
        case 3:         // 取消估清
        {
            JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
            id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
            [manifestStorage clearData];
            
            manifestStorage.currentManifestID = [manifestService createManifestID:kJCHManifestInventory];
            manifestStorage.currentManifestDate = [JCHManifestUtility getOrderDate];
            manifestStorage.currentManifestType = kJCHManifestInventory;
            manifestStorage.enumRestaurantManifestType = kJCHRestaurantDishesUnmarkSold;
            
            JCHRestaurantSoldOutViewController *addProductViewController = [[[JCHRestaurantSoldOutViewController alloc] init] autorelease];
            addProductViewController.hidesBottomBarWhenPushed = YES;
            addProductViewController.enumManifestType = kJCHRestaurantDishesUnmarkSold;
            [self.navigationController pushViewController:addProductViewController animated:YES];
        }
            break;
            
        default:
            break;
    }
}


#endif


- (void)menuViewDidHide
{
    titleButton.selected = NO;
}

- (void)reloadTableView
{
    //图片同步完刷新一下
    [contentTableView reloadData];
}

- (void)registerResponseNotificationHandler
{
    [JCHNotificationCenter addObserver:self selector:@selector(reloadTableView) name:kAllImageDownloadNotification object:[UIApplication sharedApplication]];
}

- (void)unregisterResponseNotificationHandler
{
    [JCHNotificationCenter removeObserver:self];
}

@end
