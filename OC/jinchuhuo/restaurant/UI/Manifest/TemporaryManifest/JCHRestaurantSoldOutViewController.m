//
//  JCHRestaurantSoldOutViewController.m
//  jinchuhuo
//
//  Created by apple on 2016/12/3.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHRestaurantSoldOutViewController.h"
#import "JCHAddedServiceViewController.h"
#import "JCHAddWarehouseViewController.h"
#import "JCHTitleArrowButton.h"
#import "JCHInventoryTableViewSectionView.h"
#import "JCHInventoryTableViewCell.h"
#import "JCHProductDetailViewController.h"
#import "JCHSettleAccountsViewController.h"
#import "JCHCreateManifestViewController.h"
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
#import "JCHAddProductTableViewCell.h"
#import "JCHAddProductFooterView.h"
#import "JCHMenuView.h"
#import "JCHInputView.h"
#import "Masonry.h"
#import "CommonHeader.h"
#import <MJRefresh.h>
#import "JCHAddProductMainAuxiliaryUnitSelectView.h"
#import "JCHAddProductChildViewController.h"
#import "JCHFiltDataSectionView.h"
#import "JCHSoldOutTableViewCell.h"

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

@interface JCHRestaurantSoldOutViewController () <UIAlertViewDelegate,
                                                    JCHMenuViewDelegate,
                                                    UITableViewDelegate,
                                                    UITableViewDataSource,
                                                    JCHFiltDataSectionViewDelegate,
                                                    JCHAddProductFooterViewDelegate,
                                                    JCHSettleAccountsKeyboardViewDelegate>

{
    JCHTitleArrowButton *titleButton;
    UITableView *contentTableView;
    JCHPlaceholderView *placeholderView;
    
    JCHAddProductFooterView *_footerView;
    JCHInputView *_inputView;
    JCHAddProductSKUListView *_skuListView;
    JCHSettleAccountsKeyboardView *_keyboardView;
    
    BOOL isNeedShowHudWhenLoadData;                     // 刷新数据的时候是否要显示菊花
    
    enum JCHInventorySortType enumInventorySortType;    // 当前的排序类型
    enum JCHInventoryCountType enumInventoryCountType;  // 当前的库存数量范围类型
    
    BOOL hasCreateUI;                                   // 是否已创建
}

//! @brief 左边的分类名称数组以及对应的右边的属于左边分类的商品列表

//! @brief @{productNameUUID_productUnitUUID : InventoryDetailRecord4Cocoa, @{productNameUUID : @[InvenyoryDetailRecord4Cocoa, ...]}}
@property (retain, nonatomic, readwrite) NSMutableDictionary *inventoryMap;

//! @brief 保存所有的goodsSKURecord
@property (retain, nonatomic, readwrite) NSArray *allGoodsSKURecordArray;

// 当前显示的商品列表
@property (retain, nonatomic, readwrite) NSArray *productRecordList;

// 单品列表
@property (retain, nonatomic, readwrite) NSArray *productItemRecordList;

// 所有的商品列表
@property (retain, nonatomic, readwrite) NSArray *allProductRecordList;

// 所有库存商品列表
@property (retain, nonatomic, readwrite) NSArray *allInventoryRecordList;

// 商品库存列表
@property (retain, nonatomic, readwrite) NSArray *inventoryRecordList;

// 分类列表
@property (retain, nonatomic, readwrite) NSMutableArray *productCategoryList;

// 所有仓库列表
@property (retain, nonatomic, readwrite) NSArray *allWarehouseList;

// 已启用仓库列表
@property (retain, nonatomic, readwrite) NSArray *enableWarehouseList;

// 选择的仓库ID
@property (retain, nonatomic, readwrite) NSString *selectedWarehouseId;

// 保存搜索前的数据源,当取消搜索后还原数据
@property (retain, nonatomic, readwrite) NSArray *productListBeforeSearch;

// 筛选条件
@property (retain, nonatomic, readwrite) NSArray *sortTableViewData;
@property (retain, nonatomic, readwrite) NSArray *countTableViewData;

@property (nonatomic, retain) NSMutableDictionary *pullDownButtonStausForRow;
@property (nonatomic, retain) NSIndexPath *currentEditingIndexPath;  //记录当前正在编辑的indexPath

//缓存
@property (nonatomic, retain) NSMutableDictionary *productItemRecordForUnitCache;
@property (nonatomic, retain) NSMutableDictionary *productItemRecordForSKUCache;
@property (nonatomic, retain) NSMutableDictionary *goodsSKURecord4CocoaCache;

// 顶部菜单
@property (retain, nonatomic) JCHFiltDataSectionView *topMenuSectionView;

// 当前菜品估清状态
@property (retain, nonatomic, readwrite) NSMutableDictionary *dishSoldOutFlagMap;


@end

@implementation JCHRestaurantSoldOutViewController

- (id)init
{
    self = [super init];
    if (self) {
        if (self.enumManifestType == kJCHRestaurantDishesMarkSold) {
            self.title = @"菜品估清";
        } else if (self.enumManifestType == kJCHRestaurantDishesUnmarkSold) {
            self.title = @"取消估清";
        } else {
            self.title = @"库存管理";
        }
        
        self.pullDownButtonStausForRow = [NSMutableDictionary dictionary];
        self.productItemRecordForSKUCache = [NSMutableDictionary dictionary];
        self.productItemRecordForUnitCache = [NSMutableDictionary dictionary];
        self.goodsSKURecord4CocoaCache = [NSMutableDictionary dictionary];
        
        enumInventorySortType = kInventoryNoSort;
        enumInventoryCountType = kJCHInventoryCountTypeAll;
        self.refreshUIAfterAutoSync = YES;
        isNeedShowHudWhenLoadData = YES;
        self.sortTableViewData = @[@"进货量从高到低", @"进货量从低到高", @"出货量从高到低", @"出货量从低到高", @"库存从高到低", @"库存从低到高", @"不排序"];
        self.countTableViewData = @[@"正库存", @"零库存", @"负库存", @"全部"];
        self.selectedWarehouseId = [[[ServiceFactory sharedInstance] utilityService] getDefaultWarehouseUUID];
        self.dishSoldOutFlagMap = [[[NSMutableDictionary alloc] init] autorelease];
    }
    
    return self;
}

- (void)dealloc
{
    [self.productRecordList release];
    [self.productCategoryList release];
    [self.productListBeforeSearch release];
    [self.sortTableViewData release];
    [self.countTableViewData release];
    [self.allWarehouseList release];
    [self.enableWarehouseList release];
    self.topMenuSectionView = nil;
    self.inventoryRecordList = nil;
    self.allInventoryRecordList = nil;
    self.dishSoldOutFlagMap = nil;
    self.productItemRecordList= nil;
    
    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // [self loadData];
    
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    return;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (YES == self.isNeedReloadAllData) {
        
        [self loadData];
        
        id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
        WarehouseRecord4Cocoa *warehouseRecord = [warehouseService queryWarehouseByUUID:self.selectedWarehouseId];
        [titleButton setTitle:warehouseRecord.warehouseName forState:UIControlStateNormal];
        
        //初始化
        enumInventorySortType = kInventoryNoSort;
        enumInventoryCountType = kJCHInventoryCountTypeAll;
        [self.topMenuSectionView setSearchBarText:@""];
        self.productListBeforeSearch = self.productRecordList;
        
        
        if (self.topMenuSectionView.isShow) {
            [self.topMenuSectionView hide:nil];
            [self.topMenuSectionView setSelectedButtonStatus:NO];
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
    if (YES == hasCreateUI) {
        return;
    } else {
        hasCreateUI = YES;
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
    
    contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    [self.view addSubview:contentTableView];
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    contentTableView.backgroundColor = JCHColorGlobalBackground;
    contentTableView.tableFooterView = [[[UIView alloc] init] autorelease];
    contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    CGFloat footerViewHeight = 49;
    [contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-footerViewHeight);
    }];
    
    _footerView = [[[JCHAddProductFooterView alloc] initWithFrame:CGRectZero] autorelease];
    [self.view addSubview:_footerView];
    _footerView.delegate = self;
    
    [self updateFooterViewData:NO];
    
    [_footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(footerViewHeight);
        make.bottom.equalTo(self.view);
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
    
    CGRect viewRect = CGRectMake(0, 0, kScreenWidth, kJCHTableViewSectionViewHeight);
    NSArray<NSString *> *buttonTitleArray = @[@"分类", @"规格", @"数量", @"排序"];
    NSArray<NSNumber *> *viewTypesArray = @[@(kJCHFiltDataPullDownButtonListViewType),
                                            @(kJCHFiltDataPullDownSKUViewType),
                                            @(kJCHFiltDataPullDownTableViewType),
                                            @(kJCHFiltDataPullDownTableViewType)];
    self.topMenuSectionView = [[[JCHFiltDataSectionView alloc] initWithFrame:viewRect
                                                               containerView:contentTableView
                                                                      titles:buttonTitleArray
                                                           pullDownViewClass:viewTypesArray] autorelease];
    self.topMenuSectionView.delegate = self;
    
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
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    [window addSubview:menuView];
}

#pragma mark - LoadData

-(void)loadData
{
    [MBProgressHUD showHUDWithTitle:@"加载商品中..."
                             detail:nil
                           duration:100
                               mode:MBProgressHUDModeIndeterminate
                          superView:self.view
                         completion:nil];
    
    // 1) 查询当前所有的商品信息
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    id<FinanceCalculateService> calculateService = [[ServiceFactory sharedInstance] financeCalculateService];
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    id<CategoryService> categoryService = [[ServiceFactory sharedInstance] categoryService];
    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *allProduct = [productService queryAllCuisine:YES];
        NSArray *allGoodsSKURecordArray = nil;
        [skuService queryAllGoodsSKU:&allGoodsSKURecordArray];
        
        self.allGoodsSKURecordArray = allGoodsSKURecordArray;
        
        for (ProductRecord4Cocoa *record in allProduct){
            record.productNamePinYin = [JCHPinYinUtility getFirstPinYinLetterForProductName:record.goods_name];
        }
        
        // 2) 创建用于初始化TableView的数据
        self.productCategoryList = [[[NSMutableArray alloc] init] autorelease];
        self.inventoryMap = [NSMutableDictionary dictionary];
        
        
        JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
        if (manifestStorage.currentManifestType == kJCHManifestAssembling || manifestStorage.currentManifestType == kJCHManifestDismounting) {
            // 拼装单和拆装单只显示主辅单位的商品(要设置辅单位)
            NSMutableArray *mainAuxiliaryUnitProductList = [NSMutableArray array];
            for (ProductRecord4Cocoa *productRecord in allProduct) {
                if (productRecord.is_multi_unit_enable) {
                    //主辅单位类的商品，判断是否有辅单位，将有辅单位的商品加进来
                    
                    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
                    NSArray *unitList = [productService queryUnitGoodsItem:productRecord.goods_uuid];
                    if (unitList.count > 0) {
                        [mainAuxiliaryUnitProductList addObject:productRecord];
                    }
                }
            }
            self.allProductRecordList = mainAuxiliaryUnitProductList;
        } else if (manifestStorage.currentManifestType == kJCHManifestInventory) {
            // 1.盘点单要找到已被删除并且有库存的商品
            NSArray *inventoryList = [calculateService calculateAllInventory:manifestStorage.warehouseID];
            
            NSMutableArray *allProductForInventoryManifest = [NSMutableArray arrayWithArray:allProduct];
            for (InventoryDetailRecord4Cocoa *inventoryDetailRecord in inventoryList) {
                BOOL inventoryProductInAllProduct = NO;
                for (ProductRecord4Cocoa *productRecord in allProduct) {
                    if ([inventoryDetailRecord.productNameUUID isEqualToString:productRecord.goods_uuid]) {
                        inventoryProductInAllProduct = YES;
                        break;
                    }
                }
                if (inventoryProductInAllProduct == NO && inventoryDetailRecord.currentInventoryCount != 0) {
                    ProductRecord4Cocoa *productRecord = [productService queryProductByUUID:inventoryDetailRecord.productNameUUID];
                    [allProductForInventoryManifest addObject:productRecord];
                }
            }
            
            // 2.找到更改单位（之前单位有库存）的商品
            for (InventoryDetailRecord4Cocoa *inventoryDetailRecord in inventoryList) {
                BOOL inventoryProductInAllProduct = NO;
                
                ProductRecord4Cocoa *theProductRecord = nil;
                ProductRecord4Cocoa *specialProductRecord = [[[ProductRecord4Cocoa alloc] init] autorelease];;
                for (ProductRecord4Cocoa *productRecord in allProduct) {
                    if ([inventoryDetailRecord.productNameUUID isEqualToString:productRecord.goods_uuid]) {
                        inventoryProductInAllProduct = YES;
                        theProductRecord = productRecord;
                        specialProductRecord.goods_name = productRecord.goods_name;
                        specialProductRecord.goods_uuid = productRecord.goods_uuid;
                        specialProductRecord.goods_type = productRecord.goods_type;
                        specialProductRecord.goods_category_uuid = productRecord.goods_category_uuid;
                        specialProductRecord.goods_unit = productRecord.goods_unit;
                        specialProductRecord.goods_unit_uuid = productRecord.goods_unit_uuid;
                        specialProductRecord.goods_unit_digits = productRecord.goods_unit_digits;
                        specialProductRecord.goods_hiden_flag = NO;
                        specialProductRecord.is_multi_unit_enable = productRecord.is_multi_unit_enable;
                        specialProductRecord.sku_hiden_flag = productRecord.sku_hiden_flag;
                        specialProductRecord.goods_sku_uuid = productRecord.goods_sku_uuid;
                        specialProductRecord.productNamePinYin = productRecord.productNamePinYin;
                        specialProductRecord.sort_index = productRecord.sort_index;
                        
                        break;
                    }
                }
                
                if (inventoryProductInAllProduct == YES && inventoryDetailRecord.currentInventoryCount != 0) {
                    
                    if (specialProductRecord.is_multi_unit_enable) {
                        // 如果是主副单位商品，要和所有单位比较，如果该库存单位不在主副单位里面，则将改商品添加进商品列表，商品的单位改为库存的单位
                        NSArray *productItemRecordArray = [productService queryUnitGoodsItem:specialProductRecord.goods_uuid];
                        BOOL containInventoryUnit = NO;
                        if ([specialProductRecord.goods_unit isEqualToString:inventoryDetailRecord.productUnit]) {
                            containInventoryUnit = YES;
                        } else {
                            for (ProductItemRecord4Cocoa *productItem in productItemRecordArray) {
                                if ([productItem.unitName isEqualToString:inventoryDetailRecord.productUnit]) {
                                    containInventoryUnit = YES;
                                    break;
                                }
                            }
                        }
                        
                        if (!containInventoryUnit) {
                            specialProductRecord.goods_unit = inventoryDetailRecord.productUnit;
                            specialProductRecord.goods_unit_uuid = inventoryDetailRecord.productUnitUUID;
                            specialProductRecord.goods_unit_digits = inventoryDetailRecord.unitDigits;
                            specialProductRecord.is_multi_unit_enable = NO;
                            [allProductForInventoryManifest insertObject:specialProductRecord atIndex:[allProductForInventoryManifest indexOfObject:theProductRecord] + 1];
                        }
                    } else {
                        // 如果不是主副单位商品，直接和主单位商品比较
                        if (![specialProductRecord.goods_unit isEqualToString:inventoryDetailRecord.productUnit]) {
                            specialProductRecord.goods_unit = inventoryDetailRecord.productUnit;
                            specialProductRecord.goods_unit_uuid = inventoryDetailRecord.productUnitUUID;
                            specialProductRecord.goods_unit_digits = inventoryDetailRecord.unitDigits;
                            [allProductForInventoryManifest insertObject:specialProductRecord atIndex:[allProductForInventoryManifest indexOfObject:theProductRecord] + 1];
                        }
                    }
                }
            }
            
            self.allProductRecordList = allProductForInventoryManifest;
            
            NSArray *inventoryRecordForProduct = [self subSectionInventoryArrayForProduct:inventoryList];
            for (NSArray *arr in inventoryRecordForProduct) {
                InventoryDetailRecord4Cocoa *record = [arr firstObject];
                [self.inventoryMap setObject:arr forKey:record.productNameUUID];
            }
            
        } else {
            self.allProductRecordList = allProduct;
        }
        
        self.productCategoryList = [[[NSMutableArray alloc] initWithArray:[categoryService queryAllCategory]] autorelease];
        
        NSArray *warehouseArray = [warehouseService queryAllWarehouse];
        
        NSMutableArray *enableWarehouseArray = [NSMutableArray array];
        for (WarehouseRecord4Cocoa *warehouseRecord in warehouseArray) {
            if (warehouseRecord.warehouseStatus == 0) {
                [enableWarehouseArray addObject:warehouseRecord];
            }
        }
        self.allWarehouseList = enableWarehouseArray;
        self.productRecordList = self.allProductRecordList;
        NSMutableArray *productItemArray = [[[NSMutableArray alloc] init] autorelease];
        
        // 查询所有单品
        for (ProductRecord4Cocoa *product in self.productRecordList) {
            if (product.sku_hiden_flag == NO) {
                [productItemArray addObjectsFromArray:product.productItemList];
            } else if (product.is_multi_unit_enable == YES) {
                [productItemArray addObjectsFromArray:product.productItemList];
            } else {
                // pass
            }
            
            if (YES == product.sku_hiden_flag ||
                YES == product.is_multi_unit_enable) {
                ProductItemRecord4Cocoa *itemRecord = [[[ProductItemRecord4Cocoa alloc] init] autorelease];
                itemRecord.goodsUUID = product.goods_uuid;
                itemRecord.goodsUnitUUID = product.goods_unit_uuid;
                itemRecord.goodsSkuUUID = product.goods_sku_uuid;
                itemRecord.skuUUIDVector = @[];
                itemRecord.imageName1 = product.goods_image_name;
                itemRecord.imageName2 = @"";
                itemRecord.imageName3 = @"";
                itemRecord.imageName4 = @"";
                itemRecord.imageName5 = @"";
                itemRecord.itemPrice = 0.0;
                itemRecord.itemBarCode = @"";
                itemRecord.ratio = 1.0;
                itemRecord.unitName = product.goods_unit;
                itemRecord.hasSoldOut = product.has_sold_out;
                itemRecord.unitDigits = (int)product.goods_unit_digits;
                
                [productItemArray addObject:itemRecord];
            }
        }
        
        // 基于估清/取消估清进行过滤
        if (self.enumManifestType == kJCHRestaurantDishesMarkSold) {
            NSMutableArray *unsoldItemArray = [[[NSMutableArray alloc] init] autorelease];
            for (ProductItemRecord4Cocoa *item in productItemArray) {
                if (item.hasSoldOut == NO) {
                    [unsoldItemArray addObject:item];
                }
            }
            
            self.productItemRecordList = unsoldItemArray;
        } else if (self.enumManifestType == kJCHRestaurantDishesUnmarkSold) {
            NSMutableArray *soldItemArray = [[[NSMutableArray alloc] init] autorelease];
            for (ProductItemRecord4Cocoa *item in productItemArray) {
                if (item.hasSoldOut == YES) {
                    [soldItemArray addObject:item];
                }
            }
            
            self.productItemRecordList = soldItemArray;
        }
        
        
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
            
            [self createUI];
            [self updateFooterViewData:NO];
            [MBProgressHUD hideHUDForView:self.view animated:NO];
            
            NSInteger totalSoldOutCount = 0;
            for (ProductItemRecord4Cocoa *product in self.productItemRecordList) {
                if (YES == product.hasSoldOut) {
                    totalSoldOutCount += 1;
                }
                
                [self.dishSoldOutFlagMap setObject:@(product.hasSoldOut)
                                            forKey:[NSString stringWithFormat:@"%@-%@-%@", product.goodsUUID, product.goodsSkuUUID, product.goodsUnitUUID]];
            }
            
            JCHAddProductFooterViewData *viewData = [[[JCHAddProductFooterViewData alloc] init] autorelease];
            viewData.productAmount = @"";
            viewData.transactionCount = totalSoldOutCount;
            viewData.remark = @"";
            [_footerView setViewData:viewData animation:YES];
            [_footerView enableSaveButton];
            
            // 在UI界面创建完之后在异步加载库存信息
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSArray *inventoryList = [calculateService calculateAllInventory:manifestStorage.warehouseID];
                self.inventoryRecordList = inventoryList;
                self.allInventoryRecordList = inventoryList;
                for (InventoryDetailRecord4Cocoa *record in inventoryList) {
                    NSString *key = [NSString stringWithFormat:@"%@_%@", record.productNameUUID, record.productUnitUUID];
                    [self.inventoryMap setObject:record forKey:key];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [contentTableView reloadData];
                    
                    NSArray *sectionViewDataArray = @[
                                                      self.productCategoryList,
                                                      allSKUValueToType,
                                                      self.countTableViewData,
                                                      self.sortTableViewData,
                                                      ];
                    [self.topMenuSectionView setData:sectionViewDataArray];
                });
            });
        });
    });
    
    return;
}

- (void)reloadWithSortAndFilter:(NSInteger)sectionMenuTag
{
    switch (sectionMenuTag) {
        case 0:
        {
            [self clearOtherSectionMenu:sectionMenuTag];
            [self filterCategory];
        }
            break;
            
        case 3:
        {
            [self clearOtherSectionMenu:sectionMenuTag];
            [self sortData];
        }
            break;
            
        case 1:
        {
            
        }
            break;
            
        case 2:
        {
            [self clearOtherSectionMenu:sectionMenuTag];
            [self filterInventoryCount];
        }
            break;
            
        default:
            break;
    }
}

- (void)sortData
{
    NSArray *sortedInventoryList = self.inventoryRecordList;
    switch (enumInventorySortType) {
        case kInventoryNoSort:
        {
            
        }
            break;
        case kInventorySortByPurchasesCountDescending:
        {
            sortedInventoryList = [self.inventoryRecordList sortedArrayUsingComparator:^NSComparisonResult(InventoryDetailRecord4Cocoa *obj1, InventoryDetailRecord4Cocoa *obj2) {
                return obj1.currentTotalPurchasesCount < obj2.currentTotalPurchasesCount;
            }];
        }
            break;
        case kInventorySortByPurchasesCountAscending:
        {
            sortedInventoryList = [self.inventoryRecordList sortedArrayUsingComparator:^NSComparisonResult(InventoryDetailRecord4Cocoa *obj1, InventoryDetailRecord4Cocoa *obj2) {
                return obj1.currentTotalPurchasesCount > obj2.currentTotalPurchasesCount;
            }];
        }
            break;
        case kInventorySortByShipmentCountDescending:
        {
            sortedInventoryList = [self.inventoryRecordList sortedArrayUsingComparator:^NSComparisonResult(InventoryDetailRecord4Cocoa *obj1, InventoryDetailRecord4Cocoa *obj2) {
                return obj1.currentTotalShipmentCount < obj2.currentTotalShipmentCount;
            }];
        }
            break;
        case kInventorySortByShipmentCountAscending:
        {
            sortedInventoryList = [self.inventoryRecordList sortedArrayUsingComparator:^NSComparisonResult(InventoryDetailRecord4Cocoa *obj1, InventoryDetailRecord4Cocoa *obj2) {
                return obj1.currentTotalShipmentCount > obj2.currentTotalShipmentCount;
            }];
        }
            break;
        case kInventorySortByInventoryCountDescending:
        {
            sortedInventoryList = [self.inventoryRecordList sortedArrayUsingComparator:^NSComparisonResult(InventoryDetailRecord4Cocoa *obj1, InventoryDetailRecord4Cocoa *obj2) {
                return obj1.currentInventoryCount < obj2.currentInventoryCount;
            }];
        }
            break;
        case kInventorySortByInventoryCountAscending:
        {
            sortedInventoryList = [self.inventoryRecordList sortedArrayUsingComparator:^NSComparisonResult(InventoryDetailRecord4Cocoa *obj1, InventoryDetailRecord4Cocoa *obj2) {
                return obj1.currentInventoryCount > obj2.currentInventoryCount;
            }];
        }
            break;
            
            
        default:
            break;
    }
    
    // 依据库存排序结果，对商品进行排序
    [self sortProductByInventoryOrder:sortedInventoryList];
    
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
            self.inventoryRecordList = self.allInventoryRecordList;
        }
            break;
            
        case kJCHInventoryCountTypePositive:        //正库存
        {
            NSMutableArray *tempArray = [NSMutableArray array];
            for (InventoryDetailRecord4Cocoa *record in self.allInventoryRecordList)
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
            for (InventoryDetailRecord4Cocoa *record in self.allInventoryRecordList)
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
            for (InventoryDetailRecord4Cocoa *record in self.allInventoryRecordList)
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
    NSString *selectedButtonTitle = [self.topMenuSectionView getSelectedButtonTitle:0];
    if (selectedButtonTitle) {
        if ([selectedButtonTitle isEqualToString:@"全部"]) {
            self.inventoryRecordList = self.allInventoryRecordList;
        }
        else
        {
            for (InventoryDetailRecord4Cocoa *record in self.allInventoryRecordList)
            {
                if ([record.productCategory isEqualToString:selectedButtonTitle]) {
                    [inventoryInCategory addObject:record];
                }
            }
            self.inventoryRecordList = inventoryInCategory;
        }
    }
    [self sortData];
}

// 筛选规格
- (void)filterSKU:(NSArray *)filteredSKUValueUUIDArray
{
    NSMutableArray *filteredProductArray = [NSMutableArray array];
    
    if (filteredSKUValueUUIDArray == nil || filteredSKUValueUUIDArray.count == 0) {
        [filteredProductArray addObjectsFromArray:self.productRecordList];
    } else {
        
        int queryCount = 0;
        NSMutableDictionary *cacheGoodsSKURecord = [[[NSMutableDictionary alloc] init] autorelease];
        
        id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
        id<FinanceCalculateService> calculateService = [[ServiceFactory sharedInstance] financeCalculateService];
        
        //遍历所有库存
        for (NSInteger i = 0; i < self.productRecordList.count; i++) {
            
            ProductRecord4Cocoa *productRecord = self.productRecordList[i];
            
            //查询所有有规格的商品对应的goodsSKURecord的集合
            NSArray *allGoodsSKURecordArray = nil;
            [skuService queryAllGoodsSKU:&allGoodsSKURecordArray];
            
            BOOL productHasSKU = NO;
            for (GoodsSKURecord4Cocoa *goodsSKURecord in allGoodsSKURecordArray) {
                if ([productRecord.goods_sku_uuid isEqualToString:goodsSKURecord.goodsSKUUUID]) {
                    productHasSKU = YES;
                    break;
                }
            }
            
            //如果该商品没有规格，则跳过
            if (!productHasSKU) {
                NSLog(@"%@ 没有规格", productRecord.goods_name);
                continue;
            }
            
            
            TICK;
            InventoryDetailRecord4Cocoa *inventoryDetailRecordWithSKUUUIDArray = [calculateService calculateInventoryFor:productRecord.goods_uuid
                                                                                                                unitUUID:productRecord.goods_unit_uuid warehouseUUID:@"0"];
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
                            [filteredProductArray addObject:productRecord];
                            
                            goto label;
                        }
                    }
                }
            }
            
            label : NSLog(@"goto");
            
        }
        NSLog(@"query count: %d", queryCount);
    }
    
    self.productRecordList = filteredProductArray;
    
    [self sortData];
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].windows[0] animated:YES];
}


// 基于库存排序对商品进行排序
- (void)sortProductByInventoryOrder:(NSArray *)sortedInventoryList
{
    NSMutableArray *sortedProductList = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *tempProductList = [[[NSMutableArray alloc] initWithArray:self.allProductRecordList] autorelease];
    for (InventoryDetailRecord4Cocoa *inventory in sortedInventoryList) {
        for (ProductRecord4Cocoa *product in tempProductList) {
            if ([product.goods_uuid isEqualToString:inventory.productNameUUID] &&
                [product.goods_unit_uuid isEqualToString:inventory.productUnitUUID]) {
                [sortedProductList addObject:product];
                [tempProductList removeObject:product];
                break;
            }
        }
    }
    
    // [sortedProductList addObjectsFromArray:tempProductList];
    self.productRecordList = sortedProductList;
}

- (void)showPlaceholderView
{
    if (self.productRecordList.count == 0) {
        //contentTableView.hidden = YES;
        placeholderView.hidden = NO;
    }
    else
    {
        //contentTableView.hidden = NO;
        placeholderView.hidden = YES;
    }
}

- (void)clearOtherSectionMenu:(NSInteger)sectionMenuTag
{
#if 0
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
#else
    
    if (0 == sectionMenuTag) {
        [self.topMenuSectionView clearOption:sectionMenuTag];
        [self.topMenuSectionView selectCell:2 cellIndex:self.countTableViewData.count - 1];
        enumInventoryCountType = kJCHInventoryCountTypeAll;
    } else if (1 == sectionMenuTag) {
        [self.topMenuSectionView selectButton:0 buttonIndex:0];
        [self.topMenuSectionView selectCell:2 cellIndex:self.countTableViewData.count - 1];
        enumInventoryCountType = kJCHInventoryCountTypeAll;
    } else if (2 == sectionMenuTag) {
        [self.topMenuSectionView selectButton:0 buttonIndex:0];
        [self.topMenuSectionView clearOption:sectionMenuTag];
    } else if (3 == sectionMenuTag) {
        
    } else {
        //pass
    }
    
#endif
}

- (void)switchToPhotoBrowser:(NSIndexPath *)indexPath
{
    InventoryDetailRecord4Cocoa *inventoryDetail = self.productRecordList[indexPath.row];
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    
    ProductRecord4Cocoa *productRecord = [productService queryProductByUUID:inventoryDetail.productNameUUID];
    
    [JCHImageUtility showPhotoBrowser:productRecord viewController:self];
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.productItemRecordList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductItemRecord4Cocoa *productItem = self.productItemRecordList[indexPath.row];
    
    JCHSoldOutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHSoldOutTableViewCell"];
    if (cell == nil) {
        cell = [[[JCHSoldOutTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JCHSoldOutTableViewCell"] autorelease];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.arrowImageView.hidden = YES;
    
    ProductRecord4Cocoa *theProduct = nil;
    for (ProductRecord4Cocoa *product in self.allProductRecordList) {
        if ([product.goods_uuid isEqualToString:productItem.goodsUUID]) {
            theProduct = product;
            break;
        }
    }
    
    JCHAddProductTableViewCellData *cellData = [[[JCHAddProductTableViewCellData alloc] init] autorelease];
    cellData.productLogoImage = theProduct.goods_image_name;
    cellData.productCategory = theProduct.goods_type;
    cellData.productName = theProduct.goods_name;
    cellData.productUnit = productItem.unitName;
    cellData.sku_hidden_flag = theProduct.sku_hiden_flag;
    cellData.is_multi_unit_enable = theProduct.is_multi_unit_enable;
    cellData.isArrowButtonStatusPullDown = NO;
    cellData.hasSoldOut = productItem.hasSoldOut;
    
    if (NO == cellData.sku_hidden_flag && NO == cellData.is_multi_unit_enable) {
        GoodsSKURecord4Cocoa *skuRecord = nil;
        id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
        [skuService queryGoodsSKU:productItem.goodsSkuUUID skuArray:&skuRecord];
        cellData.goodsSKURecord = skuRecord;
    }
    
    cell.handleClickEvent = ^(BOOL isSelected, NSInteger cellIndex) {
        ProductItemRecord4Cocoa *product = self.productItemRecordList[cellIndex];
        [self.dishSoldOutFlagMap setObject:@(isSelected)
                                    forKey:[NSString stringWithFormat:@"%@-%@-%@", product.goodsUUID, product.goodsSkuUUID, product.goodsUnitUUID]];
        
        NSInteger totalSelectedCount = 0;
        for (NSNumber *flag in self.dishSoldOutFlagMap.allValues) {
            totalSelectedCount += flag.boolValue;
        }
        
        JCHAddProductFooterViewData *viewData = [[[JCHAddProductFooterViewData alloc] init] autorelease];
        viewData.productAmount = @"";
        viewData.transactionCount = totalSelectedCount;
        viewData.remark = @"";
        [_footerView setViewData:viewData animation:YES];
        [_footerView enableSaveButton];
    };
    
    [cell setCellData:cellData cellIndex:indexPath.row];
        
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kJCHAddProductTableViewCellNormalHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kJCHAddProductTableViewCellNormalHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
#if 1
    return 0.0;
#else
    return 44.0;
#endif
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.topMenuSectionView;
}

#pragma mark - JCHMenuViewDelegate

- (void)menuItemDidSelected:(JCHMenuView *)menuView indexPath:(NSIndexPath *)indexPath
{
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
}

- (void)menuViewDidHide
{
    titleButton.selected = NO;
}

// 恢复之前添加的记录
- (void)restoreManifestTransactionDetailInfo:(ManifestTransactionDetail *)detail
{
    NSArray *allManifestRecord = [[JCHManifestMemoryStorage sharedInstance] getAllManifestRecord];
    for (ManifestTransactionDetail *storedTransactionDetail in allManifestRecord) {
        if ([storedTransactionDetail.goodsNameUUID isEqualToString: detail.goodsNameUUID] &&
            [JCHTransactionUtility skuUUIDs:storedTransactionDetail.skuValueUUIDs isEqualToArray:detail.skuValueUUIDs] &&
            [storedTransactionDetail.unitUUID isEqualToString:detail.unitUUID]) {
            detail.productCountFloat = storedTransactionDetail.productCountFloat;
            detail.productDiscount = storedTransactionDetail.productDiscount;
            detail.productPrice = storedTransactionDetail.productPrice;
            detail.productAddedTimestamp = storedTransactionDetail.productAddedTimestamp;
            
            detail.warehouseUUID = storedTransactionDetail.warehouseUUID;
            
            break;
        }
    }
}

- (void)loadSKUInventory:(ProductRecord4Cocoa *)productRecord manifestTransactions:(NSMutableArray *)manifestTransactionsToProduct
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorage.currentManifestType == kJCHOrderShipment ||
        manifestStorage.currentManifestType == kJCHOrderPurchases ||
        manifestStorage.currentManifestType == kJCHManifestMigrate) {
        //进货、出货、移库时异步加载单品库存
        
        //单品库存 (比较耗时，异步加载)
        id<FinanceCalculateService> calculateService = [[ServiceFactory sharedInstance] financeCalculateService];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //对于有规格的商品，需要重新查询其单品库存
            if (!productRecord.sku_hiden_flag) {
                
                InventoryDetailRecord4Cocoa *inventoryDetailRecord = [calculateService calculateInventoryFor:productRecord.goods_uuid
                                                                                                    unitUUID:productRecord.goods_unit_uuid
                                                                                               warehouseUUID:manifestStorage.warehouseID];
                NSArray *productSKUInventoryArray = inventoryDetailRecord.productSKUInventoryArray;
                
                for (ManifestTransactionDetail *detail in manifestTransactionsToProduct) {
                    
                    //如果当前商品启用多规格，遍历该商品对应的所有的SKUInventoryRecord4Cocoa，找出该单品对应的SKUInventoryRecord4Cocoa，得到库存
                    for (SKUInventoryRecord4Cocoa *skuInventoryRecord in productSKUInventoryArray) {
                        GoodsSKURecord4Cocoa *record = nil;
                        for (GoodsSKURecord4Cocoa *tempRecord in self.allGoodsSKURecordArray) {
                            if ([tempRecord.goodsSKUUUID isEqualToString:skuInventoryRecord.productSKUUUID]) {
                                record = tempRecord;
                                break;
                            }
                        }
                        
                        NSMutableArray *skuValueRecord = [NSMutableArray array];
                        for (NSDictionary *dict in record.skuArray) {
                            [skuValueRecord addObject:[dict allValues][0]];
                        }
                        NSDictionary *skuValuedDict = [JCHTransactionUtility getTransactionsWithData:skuValueRecord];
                        
                        //所有组合
                        NSArray *skuValueCombineArray = [skuValuedDict allValues][0];
                        NSArray *skuValueUUIDsArray = [skuValuedDict allKeys][0];
                        
                        if (skuValueCombineArray && [JCHTransactionUtility skuUUIDs:detail.skuValueUUIDs isEqualToArray:skuValueUUIDsArray[0]]) {
                            //CGFloat inventoryCount = skuInventoryRecord.currentTotalPurchasesCount - skuInventoryRecord.currentTotalShipmentCount;
                            CGFloat inventoryCount = skuInventoryRecord.currentInventoryCount;
                            detail.productInventoryCount = [NSString stringFromCount:inventoryCount unitDigital:productRecord.goods_unit_digits];
                            //detail.productPrice = [NSString stringWithFormat:@"%.2f", skuInventoryRecord.averageCostPrice];
                            break;
                        }
                    }
                    
                    if (!detail.productInventoryCount) {
                        detail.productInventoryCount = [NSString stringFromCount:0 unitDigital:productRecord.goods_unit_digits];
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [_skuListView reloadData];
                });
            }
        });
    } else if (manifestStorage.currentManifestType == kJCHManifestInventory) {
        //盘点单 键盘上的列表数据源个数和productSKUInventoryArray相关，不能异步加载
        
        
        id<FinanceCalculateService> calculateService = [[ServiceFactory sharedInstance] financeCalculateService];
        InventoryDetailRecord4Cocoa *inventoryDetailRecord = [calculateService calculateInventoryFor:productRecord.goods_uuid
                                                                                            unitUUID:productRecord.goods_unit_uuid
                                                                                       warehouseUUID:manifestStorage.warehouseID];
        NSArray *productSKUInventoryArray = inventoryDetailRecord.productSKUInventoryArray;
        
        
        id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
        GoodsSKURecord4Cocoa *goodsSKURecord = nil;
        [skuService queryGoodsSKU:productRecord.goods_sku_uuid skuArray:&goodsSKURecord];
        
        
        //1.当商品无规格且规格关闭，查询其库存和成本价
        
        if (goodsSKURecord.skuArray.count == 0 && productRecord.sku_hiden_flag) {
            
            ManifestTransactionDetail *detail = [manifestTransactionsToProduct firstObject];
            
            //对于盘点单，productCount表示当前库存或者盘后库存
            
            detail.productName = productRecord.goods_name;
            detail.productCount = [NSString stringFromCount:inventoryDetailRecord.currentInventoryCount unitDigital:productRecord.goods_unit_digits];
            detail.productPrice = [NSString stringWithFormat:@"%.2f", inventoryDetailRecord.averageCostPrice];
            detail.productInventoryCount = [NSString stringFromCount:inventoryDetailRecord.currentInventoryCount unitDigital:productRecord.goods_unit_digits];
            detail.averagePriceBefore = [NSString stringWithFormat:@"%.2f", inventoryDetailRecord.averageCostPrice];
            [self restoreManifestTransactionDetailInfo:detail];
        }
        
        //2.当商品有规格，并且规格关闭，要将该商品的所有有库存的单品 添加到manifestTransactionsToProduct
        
        if (goodsSKURecord.skuArray.count > 0 && productRecord.sku_hiden_flag) {
            
            //[manifestTransactionsToProduct removeAllObjects];
            
            //当前为无规格的商品的，去除之前有规格的并且数量为0的单品
            productSKUInventoryArray = [JCHTransactionUtility fliterSKUInventoryRecordList:productSKUInventoryArray
                                                                                forProduct:productRecord];
            
            
            
            //如果当前商品启用多规格，遍历该商品对应的所有的SKUInventoryRecord4Cocoa，找出该单品对应的SKUInventoryRecord4Cocoa，得到库存
            for (SKUInventoryRecord4Cocoa *skuInventoryRecord in productSKUInventoryArray) {
                GoodsSKURecord4Cocoa *record = nil;
                for (GoodsSKURecord4Cocoa *tempRecord in self.allGoodsSKURecordArray) {
                    if ([tempRecord.goodsSKUUUID isEqualToString:skuInventoryRecord.productSKUUUID]) {
                        record = tempRecord;
                        break;
                    }
                }
                
                NSMutableArray *skuValueRecord = [NSMutableArray array];
                for (NSDictionary *dict in record.skuArray) {
                    [skuValueRecord addObject:[dict allValues][0]];
                }
                NSDictionary *skuValuedDict = [JCHTransactionUtility getTransactionsWithData:skuValueRecord];
                
                //所有组合
                NSArray *skuValueCombineArray = [skuValuedDict allValues][0];
                NSArray *skuValueUUIDs = [skuValuedDict allKeys][0];
                
                ManifestTransactionDetail *detail = [[[ManifestTransactionDetail alloc] init] autorelease];
                detail.productCategory = productRecord.goods_type;
                detail.productName = productRecord.goods_name;
                detail.productUnit = productRecord.goods_unit;
                detail.productImageName = productRecord.goods_image_name;
                detail.productUnit_digits = productRecord.goods_unit_digits;
                //detail.productDiscount = @"1.0";
                //detail.productCount = @"0";
                detail.skuValueCombine = record ? [skuValueCombineArray firstObject] : nil;
                detail.skuHidenFlag = productRecord.sku_hiden_flag;
                
                //! @todo 这里需要设置为当前选择仓库的 warehouse id
                detail.warehouseUUID = manifestStorage.warehouseID;
                detail.goodsCategoryUUID = productRecord.goods_category_uuid;
                detail.goodsNameUUID = productRecord.goods_uuid;
                detail.unitUUID = productRecord.goods_unit_uuid;
                
                
                detail.skuValueUUIDs = record ? skuValueUUIDs[[skuValueCombineArray indexOfObject:detail.skuValueCombine]] : nil;
                detail.productCount = [NSString stringFromCount:skuInventoryRecord.currentInventoryCount unitDigital:productRecord.goods_unit_digits];
                detail.productInventoryCount = [NSString stringFromCount:skuInventoryRecord.currentInventoryCount unitDigital:productRecord.goods_unit_digits];
                detail.productPrice = [NSString stringWithFormat:@"%.2f", skuInventoryRecord.averageCostPrice];
                detail.averagePriceBefore = [NSString stringWithFormat:@"%.2f", skuInventoryRecord.averageCostPrice];
                
                [self restoreManifestTransactionDetailInfo:detail];
                
                BOOL detailInManifestTransactionsToProduct = NO;
                ManifestTransactionDetail *tempDetail = nil;
                for (ManifestTransactionDetail *theDetail in manifestTransactionsToProduct) {
                    if ([JCHTransactionUtility skuUUIDs:theDetail.skuValueUUIDs isEqualToArray:detail.skuValueUUIDs]) {
                        tempDetail = theDetail;
                        detailInManifestTransactionsToProduct = YES;
                    }
                }
                
                if (!detailInManifestTransactionsToProduct) {
                    [manifestTransactionsToProduct addObject:detail];
                } else {
                    [manifestTransactionsToProduct replaceObjectAtIndex:[manifestTransactionsToProduct indexOfObject:tempDetail] withObject:detail];
                }
                
            }
        }
        
        //3.当商品有规格并且规格打开，查找 所有未出现在  当前所有的规格的组合列表中的 库存单品，添加到manifestTransactionsToProduct
        if (goodsSKURecord.skuArray.count > 0 && !productRecord.sku_hiden_flag) {
            
            //当前为多规格的商品的，去除之前无规格的并且数量为0的单品
            productSKUInventoryArray = [JCHTransactionUtility fliterSKUInventoryRecordList:productSKUInventoryArray
                                                                                forProduct:productRecord];
            
            
            //找出所有库存单品对应的记录
            NSMutableArray *allTransactionInSKUInventoryArray = [NSMutableArray array];
            //如果当前商品启用多规格，遍历该商品对应的所有的SKUInventoryRecord4Cocoa，找出该单品对应的SKUInventoryRecord4Cocoa，得到库存
            for (SKUInventoryRecord4Cocoa *skuInventoryRecord in productSKUInventoryArray) {
                GoodsSKURecord4Cocoa *record = nil;
                for (GoodsSKURecord4Cocoa *tempRecord in self.allGoodsSKURecordArray) {
                    if ([tempRecord.goodsSKUUUID isEqualToString:skuInventoryRecord.productSKUUUID]) {
                        record = tempRecord;
                        break;
                    }
                }
                
                NSMutableArray *skuValueRecord = [NSMutableArray array];
                for (NSDictionary *dict in record.skuArray) {
                    [skuValueRecord addObject:[dict allValues][0]];
                }
                NSDictionary *skuValuedDict = [JCHTransactionUtility getTransactionsWithData:skuValueRecord];
                
                //所有组合
                NSArray *skuValueCombineArray = [skuValuedDict allValues][0];
                NSArray *skuValueUUIDs = [skuValuedDict allKeys][0];
                
                ManifestTransactionDetail *detail = [[[ManifestTransactionDetail alloc] init] autorelease];
                detail.productCategory = productRecord.goods_type;
                detail.productName = productRecord.goods_name;
                detail.productUnit = productRecord.goods_unit;
                detail.productImageName = productRecord.goods_image_name;
                detail.productUnit_digits = productRecord.goods_unit_digits;
                detail.productDiscount = @"1.0";
                //detail.productCount = @"0";
                detail.skuValueCombine = record ? [skuValueCombineArray firstObject] : nil;
                detail.skuHidenFlag = productRecord.sku_hiden_flag;
                
                //! @todo 这里需要设置为当前选择仓库的 warehouse id
                detail.warehouseUUID = manifestStorage.warehouseID;
                detail.goodsCategoryUUID = productRecord.goods_category_uuid;
                detail.goodsNameUUID = productRecord.goods_uuid;
                detail.unitUUID = productRecord.goods_unit_uuid;
                
                
                detail.skuValueUUIDs = record ? skuValueUUIDs[[skuValueCombineArray indexOfObject:detail.skuValueCombine]] : nil;
                detail.productCount = [NSString stringFromCount:skuInventoryRecord.currentInventoryCount unitDigital:productRecord.goods_unit_digits];
                detail.productPrice = [NSString stringWithFormat:@"%.2f", skuInventoryRecord.averageCostPrice];
                
                detail.productInventoryCount = [NSString stringFromCount:skuInventoryRecord.currentInventoryCount unitDigital:productRecord.goods_unit_digits];
                detail.averagePriceBefore = [NSString stringWithFormat:@"%.2f", skuInventoryRecord.averageCostPrice];
                [allTransactionInSKUInventoryArray addObject:detail];
            }
            
            //找到未出现在 当前所有的规格的组合列表中的 库存单品 对应的transactionDetail
            id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
            GoodsSKURecord4Cocoa *record = nil;
            
            
            [skuService queryGoodsSKU:productRecord.goods_sku_uuid skuArray:&record];
            NSMutableArray *skuValueRecord = [NSMutableArray array];
            for (NSDictionary *dict in record.skuArray) {
                [skuValueRecord addObject:[dict allValues][0]];
            }
            NSDictionary *skuValuedDict = [JCHTransactionUtility getTransactionsWithData:skuValueRecord];
            
            //当前所有的规格的组合
            NSArray *allSKUValueUUIDsArray = [skuValuedDict allKeys][0];
            
            NSMutableArray *otherDetailArray = [NSMutableArray array];
            
            for (ManifestTransactionDetail *detail in allTransactionInSKUInventoryArray) {
                
                BOOL inTheList = NO;
                for (NSArray *skuValueUUIDsArray in allSKUValueUUIDsArray) {
                    if ([JCHTransactionUtility skuUUIDs:skuValueUUIDsArray isEqualToArray:detail.skuValueUUIDs]) {
                        inTheList = YES;
                    }
                }
                
                
                if (!inTheList) {
                    
                    [self restoreManifestTransactionDetailInfo:detail];
                    [otherDetailArray addObject:detail];
                }
            }
            
            for (ManifestTransactionDetail *detail in manifestTransactionsToProduct) {
                for (ManifestTransactionDetail *inventoryTransactionDetail in allTransactionInSKUInventoryArray) {
                    if ([JCHTransactionUtility skuUUIDs:detail.skuValueUUIDs isEqualToArray:inventoryTransactionDetail.skuValueUUIDs]) {
                        detail.productCount = inventoryTransactionDetail.productCount;
                        detail.productPrice = inventoryTransactionDetail.productPrice;
                        
                        detail.productInventoryCount = inventoryTransactionDetail.productInventoryCount;
                        detail.averagePriceBefore = inventoryTransactionDetail.averagePriceBefore;
                        [self restoreManifestTransactionDetailInfo:detail];
                    }
                }
            }
            
            [manifestTransactionsToProduct addObjectsFromArray:otherDetailArray];
        }
    }
}

#pragma mark -
#pragma mark JCHDataFiltSectionViewDelegate
- (void)skuSelect:(NSInteger)menuIndex UUIDArray:(NSArray *)filteredSKUValueUUIDArray
{
    [self.topMenuSectionView hide:nil];
    
    [self clearOtherSectionMenu:1];
    
    [MBProgressHUD showHUDWithTitle:@"筛选中..."
                             detail:@""
                           duration:1000
                               mode:MBProgressHUDModeIndeterminate
                         completion:nil];
    
    [self performSelector:@selector(filterSKU:) withObject:filteredSKUValueUUIDArray afterDelay:0.01];
}

- (void)buttonClick:(NSInteger)menuIndex buttonSelected:(NSInteger)selectedButtonIndex
{
    [self.topMenuSectionView hide:nil];
    [self reloadWithSortAndFilter:menuIndex];
}

- (void)tableViewSelectRow:(NSInteger)menuIndex tableRow:(NSInteger)row
{
    if (menuIndex == 3) {
        enumInventorySortType = (enum JCHInventorySortType)row;
    } else if (menuIndex == 2){
        enumInventoryCountType = (enum JCHInventoryCountType)row;
    } else {
        //pass
    }
    
    [self.topMenuSectionView hide:nil];
    [self reloadWithSortAndFilter:menuIndex];
}

- (void)clickSearchButton
{
    //保存搜索之前的数据源,当搜索完后还原
    self.productListBeforeSearch = self.productRecordList;
    //点击搜索后数据源为全部库存
    self.productRecordList = self.allProductRecordList;
    [contentTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(JCHSearchBar *)searchBar
{
    searchBar.textField.text = @"";
    [self.topMenuSectionView showSearchBar:NO];
    contentTableView.scrollEnabled = YES;
    
    self.productRecordList = self.productListBeforeSearch;
    [contentTableView reloadData];
}

- (void)searchBarTextChanged:(JCHSearchBar *)searchBar
{
    
}

- (void)searchBarDidBeginEditing:(JCHSearchBar *)searchBar
{
    
}

- (NSMutableArray *)subSectionInventoryArrayForProduct:(NSArray *)manifestArray
{
    // 根据ManifestTransactionDetail中的goodsNameUUID字段进行分组
    NSMutableSet *set = [NSMutableSet set];
    
    [manifestArray enumerateObjectsUsingBlock:^(InventoryDetailRecord4Cocoa *detail, NSUInteger idx, BOOL * _Nonnull stop) {
        [set addObject:detail.productNameUUID];
    }];
    
    /*此时，set里面已经存储了可以分为组数*/
    
    //接下来需要用到NSPredicate语法进行筛选
    __block NSMutableArray *groupArr = [NSMutableArray array];
    [set enumerateObjectsUsingBlock:^(NSString * _Nonnull goodsNameUUID, BOOL * _Nonnull stop) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productNameUUID = %@", goodsNameUUID];
        NSArray *tempArr = [NSArray arrayWithArray:[manifestArray filteredArrayUsingPredicate:predicate]];
        [groupArr addObject:tempArr];
    }];
    
    return groupArr;
}

- (void)updateFooterViewData:(BOOL)animation
{
    //! @todo 收集当前用户添加的商品列表
    CGFloat totalAmount = 0.0f;
    
    JCHManifestMemoryStorage *storage = [JCHManifestMemoryStorage sharedInstance];
    NSArray *transactionList = [storage getAllManifestRecord];
    
    for (ManifestTransactionDetail * detail in transactionList) {
        CGFloat price = [detail.productPrice doubleValue];
        CGFloat count = detail.productCountFloat;
        CGFloat amount = price * count;
        totalAmount += amount;
    }
    
    NSUInteger totalCount = transactionList.count;
    JCHAddProductFooterViewData *viewData = [[[JCHAddProductFooterViewData alloc] init] autorelease];
    viewData.productAmount = [NSString stringWithFormat:@"%.2f", totalAmount];
    viewData.transactionCount = totalCount;
    viewData.remark = storage.currentManifestRemark;
    [_footerView setViewData:viewData animation:animation];
    [_footerView enableSaveButton];
    
    return;
}

#pragma mark -
#pragma mark JCHAddProductFooterViewDelegate
- (void)handleClickSaveOrderList
{
    NSMutableArray<ProductItemRecord4Cocoa *> *soldOutArray = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray<ProductItemRecord4Cocoa *> *notSoldOutArray = [[[NSMutableArray alloc] init] autorelease];
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    
    for (ProductItemRecord4Cocoa *product in self.productItemRecordList) {
        ProductRecord4Cocoa *theProduct = nil;
        for (ProductRecord4Cocoa *item in self.allProductRecordList) {
            if ([item.goods_uuid isEqualToString:product.goodsUUID]) {
                theProduct = item;
            }
        }
        
        NSString *key = [NSString stringWithFormat:@"%@-%@-%@", product.goodsUUID, product.goodsSkuUUID, product.goodsUnitUUID];
        
        if (YES == theProduct.sku_hiden_flag && NO == theProduct.is_multi_unit_enable) {
            product.goodsSkuUUID = @"";
            product.goodsUnitUUID = @"";
            product.goodsUUID = theProduct.goods_uuid;
        }
        
        BOOL isSoldOut = [[self.dishSoldOutFlagMap objectForKey:key] boolValue];
        if (YES == isSoldOut) {
            product.hasSoldOut = YES;
            [soldOutArray addObject:product];
        } else {
            product.hasSoldOut = NO;
            [notSoldOutArray addObject:product];
        }
    }
    
    [productService setProductItemSoldOutFlag:soldOutArray soldOut:YES];
    [productService setProductItemSoldOutFlag:notSoldOutArray soldOut:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleEditRemark
{
    
}

- (void)handleShowTransactionList
{
    
}

@end
