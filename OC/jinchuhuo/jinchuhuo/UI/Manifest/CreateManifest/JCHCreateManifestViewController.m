//
//  JCHCreateManifestViewController.m
//  jinchuhuo
//
//  Created by apple on 15/8/13.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHCreateManifestViewController.h"
#import "JCHCreateManifestProductDiscountEditingView.h"
#import "JCHAddProductFooterView.h"
#import "JCHAddProductChildViewController.h"
#import "JCHCreateManifestWarehouseSelectView.h"
#import "JCHAddProductByScanCodeViewController.h"
#import "JCHSettleAccountsKeyboardView.h"
#import "JCHManifestViewController.h"
#import "JCHSettleAccountsViewController.h"
#import "JCHAddProductSKUListView.h"
#import "JCHManifestTotalDiscountKeyboardView.h"
#import "JCHManifestShipmentKeyboardView.h"
#import "JCHManifestPurchasesKeyboardView.h"
#import "JCHRestaurantDishDetailFooterView.h"
#import "JCHInputView.h"
#import "JCHCreateManifestTotalDiscountEditingView.h"
#import "JCHCreateManifestTableSectionView.h"
#import "JCHRestaurantManifestUtility.h"
#import "JCHCreateManifestTableViewCell.h"
#import "JCHManifestUtility.h"
#import "JCHManifestMemoryStorage.h"
#import "JCHUISizeSettings.h"
#import "ServiceFactory.h"
#import "Masonry.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import "JCHImageUtility.h"
#import "JCHTransactionUtility.h"
#import "UIView+JCHView.h"
#import "MBProgressHUD+JCHHud.h"
#import "CommonHeader.h"

//#import "JCHBluetoothHelper.h"

enum {
    kCreateManifestTableviewHeaderViewHeight = 61,
    kCreateManifestTableViewFooterViewHeight = 49,
};

@interface JCHCreateManifestViewController () < JCHInputViewDelegate,
                                                JCHAddProductSKUListViewDelegate,
                                                JCHSettleAccountsKeyboardViewDelegate,
                                                JCHPickerViewDelegate,
                                                UIPickerViewDataSource,
                                                UIPickerViewDelegate,
                                                JCHAddProductFooterViewDelegate,
                                                JCHRestaurantDishDetailFooterViewDelegate>
{
    enum JCHOrderType enumCreateManifestType;
    UITableView *contentTableView;
    JCHCreateManifestWarehouseSelectView *warehouseSelectView;
    JCHCreateManifestHeaderView *dateSelectView;
#if !MMR_RESTAURANT_VERSION
    JCHCreateManifestFooterView *defaultFooterView;
#else
    JCHRestaurantDishDetailFooterView *defaultFooterView;
#endif
    JCHAddProductFooterView *scanCodefooterView;
    JCHDatePickerView *datePickerView;
    
    NSInteger currentProductCount;
    
    JCHCreateManifestTotalDiscountEditingView *totalDiscountView;
    JCHInputView *inputView;
    CGFloat keyBoardHeight;
    
    JCHAddProductSKUListView *skuListView;
    JCHCreateManifestProductDiscountEditingView *_discountEditingView;
    JCHSettleAccountsKeyboardView *keyboardView;
    JCHPickerView *_pickerView;
}

@property (retain, nonatomic, readwrite) NSMutableArray *currentProductInManifestList;
@property (retain, nonatomic, readwrite) NSMutableDictionary *heightForRow;
@property (retain, nonatomic, readwrite) NSString *currentRemark;
@property (retain, nonatomic, readwrite) NSString *currentOrderListID;
@property (retain, nonatomic, readwrite) NSString *currentOrderDate;

//! @brief 目标仓库(移库单用)
@property (retain, nonatomic, readwrite) WarehouseRecord4Cocoa *destinationWarehouseRecord;

@property (retain, nonatomic, readwrite) NSArray *warehouseList;

//当前编辑折扣的detail
@property (retain, nonatomic, readwrite) ManifestTransactionDetail *currentDiscountEditingDetail;

//! @brief 餐饮版改单前的订单流水
@property (retain, nonatomic, readwrite) NSArray *restaurantOldTransactionList;

@end

@implementation JCHCreateManifestViewController

- (id)init
{
    self = [super init];
    if (self) {
        JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
        enumCreateManifestType = manifestStorage.currentManifestType;
        
        self.currentOrderListID = [manifestStorage.currentManifestID retain];
        self.currentOrderDate = [manifestStorage.currentManifestDate retain];
        self.currentRemark = manifestStorage.currentManifestRemark;
        self.heightForRow = [NSMutableDictionary dictionary];
        
        NSString *prefixString = @"新建";
        if (manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeEdit) {
            prefixString = @"编辑";
        }
        NSString *titleName = [NSString stringWithFormat:@"%@%@", prefixString, [JCHManifestUtility getOrderNameByType:enumCreateManifestType]];
        self.title = titleName;
        
#if MMR_RESTAURANT_VERSION
        NSString *manifestType = @"";
        switch (manifestStorage.enumRestaurantManifestType) {
            case kJCHRestaurantMaterialInventory:    // 原料盘点
            {
                manifestType = @"原料盘点";
            }
                break;
                
            case kJCHRestaurantMaterialWastage:      // 原料损耗
            {
                manifestType = @"原料损耗";
            }
                break;
                
            case kJCHRestaurantDishesStorage:        // 菜品入库
            {
                manifestType = @"菜品入库";
            }
                break;
                
            case kJCHRestaurantDishesWastage:        // 菜品损耗
            {
                manifestType = @"菜品损耗";
            }
                break;
                
            case kJCHRestaurantDishesMarkSold:       // 菜品估清
            {
                manifestType = @"菜品估清";
            }
                break;
                
            case kJCHRestaurantDishesUnmarkSold:     // 取消估清
            {
                manifestType = @"取消估清";
            }
                break;
                
            default:
            {
                if (manifestStorage.currentManifestType == kJCHOrderPurchases) {
                    manifestType = @"采购";
                } else {
                    manifestType = @"未知货单类型";
                }
                
            }
                break;
        }
        
        if (manifestStorage.enumRestaurantManifestType == kJCHRestaurantOpenTable ||
            manifestStorage.currentManifestType == kJCHOrderShipment) {
            titleName = manifestStorage.tableName;
        } else {
            titleName = [NSString stringWithFormat:@"%@%@单", prefixString, manifestType];
        }
        
        self.title = titleName;
#endif
        
    }
    
    return self;
}

- (void)dealloc
{
    [self.currentRemark release];
    self.currentOrderListID = nil;
    self.currentOrderDate = nil;
    
    [self.heightForRow release];
    [self.currentProductInManifestList release];
    [self.lastEditedProductUUID release];
    [self.warehouseList release];
    [self.destinationWarehouseRecord release];
    [self.currentDiscountEditingDetail release];
    self.inventoryMap = nil;
    self.restaurantOldTransactionList = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = JCHColorGlobalBackground;
    [self createUI];
    [self loadData];
    
    return;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    NSArray *manifestList = [[JCHManifestMemoryStorage sharedInstance] getAllManifestRecord];
    self.currentProductInManifestList = [NSMutableArray arrayWithArray:manifestList];
    [self loadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    [JCHNotificationCenter removeObserver:self];
}

- (void)createUI
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];

#if !MMR_RESTAURANT_VERSION
    UIButton *addProductButton = [JCHUIFactory createButton:CGRectMake(0, 0, 30, 44)
                                                         target:self
                                                         action:@selector(handleAddProduct)
                                                          title:nil
                                                     titleColor:nil
                                                backgroundColor:nil];
    [addProductButton setImage:[UIImage imageNamed:@"icon_account_add"] forState:UIControlStateNormal];
    UIBarButtonItem *addItem = [[[UIBarButtonItem alloc] initWithCustomView:addProductButton] autorelease];
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    UIViewController *lastViewController = viewControllers[viewControllers.count - 2];
    if ([lastViewController isKindOfClass:[JCHManifestViewController class]]) {
        self.navigationItem.rightBarButtonItem = addItem;
    }
#else
    if (manifestStorage.currentManifestType == kJCHOrderPurchases) {
        UIButton *addProductButton = [JCHUIFactory createButton:CGRectMake(0, 0, 30, 44)
                                                         target:self
                                                         action:@selector(handleAddProduct)
                                                          title:nil
                                                     titleColor:nil
                                                backgroundColor:nil];
        [addProductButton setImage:[UIImage imageNamed:@"icon_account_add"] forState:UIControlStateNormal];
        UIBarButtonItem *addItem = [[[UIBarButtonItem alloc] initWithCustomView:addProductButton] autorelease];
        
        NSArray *viewControllers = self.navigationController.viewControllers;
        UIViewController *lastViewController = viewControllers[viewControllers.count - 2];
        if ([lastViewController isKindOfClass:[JCHManifestViewController class]]) {
            self.navigationItem.rightBarButtonItem = addItem;
        }
    }
#endif
    
#if MMR_RESTAURANT_VERSION
    CGFloat headerViewHeight = 0;
    if (manifestStorage.currentManifestType == kJCHOrderShipment ||
        manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable) {
        headerViewHeight = 0;
    } else {
        headerViewHeight = kCreateManifestTableviewHeaderViewHeight;
    }
#else
    CGFloat headerViewHeight = kCreateManifestTableviewHeaderViewHeight;
#endif
    
    CGFloat warehouseSelectViewHeight = 0;
    CGFloat warehouseSelectViewTopOffset = 0;
    if (manifestStorage.currentManifestType == kJCHManifestInventory || manifestStorage.currentManifestType == kJCHManifestDismounting || manifestStorage.currentManifestType == kJCHManifestAssembling) {
        headerViewHeight = kStandardItemHeight;
    } else if (manifestStorage.currentManifestType == kJCHManifestMigrate) {
        warehouseSelectViewHeight = 60;
        warehouseSelectViewTopOffset = 30;
        headerViewHeight = kStandardItemHeight;
    }
    
    UIView *headerContainerView = [[[UIView alloc] init] autorelease];
    [self.view addSubview:headerContainerView];
    
    [headerContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top);
        make.height.mas_equalTo(headerViewHeight + warehouseSelectViewHeight + warehouseSelectViewTopOffset);
    }];
    
    CGRect headerRect = CGRectMake(0, 0, self.view.frame.size.width, headerViewHeight);
    
    BOOL isCommonManifest = NO;
    if (manifestStorage.currentManifestType == kJCHOrderPurchases || manifestStorage.currentManifestType == kJCHOrderShipment) {
        isCommonManifest = YES;
    }
    dateSelectView = [[[JCHCreateManifestHeaderView alloc] initWithFrame:headerRect isCommonManifest:isCommonManifest] autorelease];
    dateSelectView.delegate = self;
    [headerContainerView addSubview:dateSelectView];
    [dateSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(headerContainerView);
        make.height.mas_equalTo(headerRect.size.height);
    }];
    
    [dateSelectView addSeparateLineWithMasonryTop:NO bottom:YES];
    
    if (manifestStorage.currentManifestType == kJCHManifestMigrate) {
        warehouseSelectView = [[[JCHCreateManifestWarehouseSelectView alloc] initWithFrame:CGRectZero] autorelease];
        id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
        WarehouseRecord4Cocoa *warehouseRecord = [warehouseService queryWarehouseByUUID:manifestStorage.warehouseID];
        warehouseSelectView.sourceWarehouse = warehouseRecord.warehouseName;
        WeakSelf;
        [warehouseSelectView setSelectWarehouse:^{
            [weakSelf showPickerView];
        }];
        [headerContainerView addSubview:warehouseSelectView];
        
        [warehouseSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(dateSelectView.mas_bottom).offset(warehouseSelectViewTopOffset);
            make.left.right.bottom.equalTo(headerContainerView);
        }];
    }
    
    CGRect footerRect = CGRectZero;
#if MMR_RESTAURANT_VERSION
    if (manifestStorage.currentManifestType == kJCHOrderShipment ||
        manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable) {
        footerRect = CGRectMake(0,0, self.view.frame.size.width, 72);
        defaultFooterView = [[[JCHRestaurantDishDetailFooterView alloc] initWithFrame:footerRect] autorelease];
        [self.view addSubview:defaultFooterView];
        defaultFooterView.delegate = self;
    } else {
        footerRect = CGRectMake(0,0, self.view.frame.size.width, kCreateManifestTableViewFooterViewHeight);
        defaultFooterView = (JCHRestaurantDishDetailFooterView *)[[[JCHCreateManifestFooterView alloc] initWithFrame:footerRect] autorelease];
        [self.view addSubview:defaultFooterView];
        ((JCHCreateManifestFooterView *)defaultFooterView).eventDelegate = self;
    }
#else
    footerRect = CGRectMake(0,0, self.view.frame.size.width, kCreateManifestTableViewFooterViewHeight);
    defaultFooterView = [[[JCHCreateManifestFooterView alloc] initWithFrame:footerRect] autorelease];
    [self.view addSubview:defaultFooterView];
    defaultFooterView.eventDelegate = self;
#endif
    
    [defaultFooterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(footerRect.size.height);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    contentTableView.backgroundColor = JCHColorGlobalBackground;
    contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    contentTableView.tableFooterView = [[[UIView alloc] init] autorelease];
    [self.view addSubview:contentTableView];
    
#if MMR_RESTAURANT_VERSION
    CGFloat tableViewTopOffset = 0.0;
    if (manifestStorage.currentManifestType == kJCHOrderShipment ||
        manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable) {
        tableViewTopOffset = 0.0;
    } else {
        tableViewTopOffset = 2.1 * kStandardHeightOffsetNoTabBar;
    }
#else
    const CGFloat tableViewTopOffset = 2.1 * kStandardHeightOffsetNoTabBar;
#endif
    
    [contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(headerContainerView.mas_bottom).with.offset(tableViewTopOffset);
        make.bottom.equalTo(defaultFooterView.mas_top);
    }];
    
    
    const CGRect pickerRect = CGRectMake(0, kScreenHeight, self.view.frame.size.width, kJCHPickerViewHeight);
    
    _pickerView = [[[JCHPickerView alloc] initWithFrame:pickerRect title:@"类别" showInView:self.view] autorelease];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    
    return;
}

- (void)changeUIForScanCodeViewController
{
    [dateSelectView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    
    dateSelectView.hidden = YES;
    
    [contentTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(defaultFooterView.mas_top);
    }];
    
    scanCodefooterView = [[[JCHAddProductFooterView alloc] initWithFrame:CGRectZero] autorelease];
    [self.view addSubview:scanCodefooterView];
    scanCodefooterView.delegate = self;
    [self updateScanCodefooterViewData];
    
    [scanCodefooterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(defaultFooterView);
    }];
    defaultFooterView.hidden = YES;
}

- (void)updateScanCodefooterViewData
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
    [scanCodefooterView setViewData:viewData animation:NO];
    
    return;
}


- (void)showPickerView
{
    [_pickerView show];
}

- (void)handleAddProduct
{
    JCHAddProductMainViewController *addProductViewController = [[[JCHAddProductMainViewController alloc] init] autorelease];
    [self.navigationController pushViewController:addProductViewController animated:YES];
}

#pragma mark - 弹出折扣键盘
- (void)showDiscountKeyboard:(NSInteger)rowIndex
{
    ManifestTransactionDetail *currentDetail = self.currentProductInManifestList[rowIndex];
    self.currentDiscountEditingDetail = currentDetail;
    
    _discountEditingView = [[[JCHCreateManifestProductDiscountEditingView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)] autorelease];
    
    _discountEditingView.discountLabel.text = [JCHTransactionUtility getOrderDiscountFromFloat:currentDetail.productDiscount.doubleValue];
    CGFloat keyboardHeight = [JCHSizeUtility calculateWidthWithSourceWidth:196.0f];
    keyboardView = [[[JCHSettleAccountsKeyboardView alloc] initWithFrame:CGRectZero
                                                          keyboardHeight:keyboardHeight
                                                                 topView:_discountEditingView
                                                  topContainerViewHeight:50] autorelease];
    keyboardView.delegate = self;
    [keyboardView setEditText:_discountEditingView.discountLabel.text editMode:kJCHSettleAccountsKeyboardViewEditModeDiscount];
    [keyboardView show];
    
    WeakSelf;
    [_discountEditingView setHideViewBlock:^{
        [weakSelf -> keyboardView hide];
    }];
}

#pragma mark - 弹出普通键盘
- (void)showKeyboard:(NSInteger)rowIndex
{
    NSMutableArray *manifestTransactionsToProduct = [NSMutableArray array];
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    // 组装单要商品界面只显示主单位，点击后键盘上面列表里要显示所有辅单位
    if (manifestStorage.currentManifestType == kJCHManifestAssembling) {
        
        ManifestTransactionDetail *detail = [self.currentProductInManifestList[rowIndex] firstObject];

        id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
        ProductRecord4Cocoa *productRecord = [productService queryProductByUUID:detail.goodsNameUUID];

        
        // 主单位
        ManifestTransactionDetail *mainUnitDetail = [JCHAddProductChildViewController createManifestTransactionDetail:productRecord];
        mainUnitDetail.productUnit = productRecord.goods_unit;
        mainUnitDetail.unitUUID = productRecord.goods_unit_uuid;
        mainUnitDetail.productUnit_digits = productRecord.goods_unit_digits;
        
        NSString *key = [NSString stringWithFormat:@"%@_%@", productRecord.goods_uuid, productRecord.goods_unit_uuid];
        InventoryDetailRecord4Cocoa *inventoryRecord = [self.inventoryMap objectForKey:key];
        CGFloat currentTotalInventoryCount = inventoryRecord.currentInventoryCount;
        NSString *inventoryCount = [NSString stringFromCount:currentTotalInventoryCount unitDigital:productRecord.goods_unit_digits];
        mainUnitDetail.productInventoryCount = inventoryCount;
        mainUnitDetail.ratio = 1;
        mainUnitDetail.isMainUnit = YES;
        
        [manifestTransactionsToProduct addObject:mainUnitDetail];
        
        // 辅单位
        NSArray *unitList = [productService queryUnitGoodsItem:productRecord.goods_uuid];
        
        for (ProductItemRecord4Cocoa *productItemRecord in unitList) {
            
            BOOL detailInManifestStorage = NO;
            for (ManifestTransactionDetail *detail in self.currentProductInManifestList[rowIndex]) {
                if ([productItemRecord.goodsUnitUUID isEqualToString:detail.unitUUID]) {
                    ManifestTransactionDetail *transactionDetail = [JCHAddProductChildViewController createManifestTransactionDetail:productRecord];
                    transactionDetail.productUnit = detail.productUnit;
                    transactionDetail.unitUUID = detail.unitUUID;
                    transactionDetail.productUnit_digits = detail.productUnit_digits;
                    
                    // 辅单位库存存为主单位库存，由于界面上用不到辅单位库存，编辑辅单位的时候要和主单位的库存进行比较，所以存为主单位库存
                    transactionDetail.productInventoryCount = inventoryCount;
                    transactionDetail.productCount = detail.productCount;
                    transactionDetail.ratio = productItemRecord.ratio;
                    transactionDetail.isMainUnit = NO;
                    
                    [manifestTransactionsToProduct addObject:transactionDetail];
                    
                    detailInManifestStorage = YES;
                    break;
                }
            }
            
            if (detailInManifestStorage == NO) {
                ManifestTransactionDetail *detail = [JCHAddProductChildViewController createManifestTransactionDetail:productRecord];
                detail.productUnit = productItemRecord.unitName;
                detail.unitUUID = productItemRecord.goodsUnitUUID;
                detail.productUnit_digits = productItemRecord.unitDigits;

                // 辅单位库存存为主单位库存，由于界面上用不到辅单位库存，编辑辅单位的时候要和主单位的库存进行比较，所以存为主单位库存
                detail.productInventoryCount = inventoryCount;
                detail.ratio = productItemRecord.ratio;
                detail.isMainUnit = NO;
                
                [manifestTransactionsToProduct addObject:detail];
            }
        }
    } else if (manifestStorage.currentManifestType == kJCHManifestDismounting) {
        
        ManifestTransactionDetail *currentDetail = self.currentProductInManifestList[rowIndex];
        id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
        ProductRecord4Cocoa *productRecord = [productService queryProductByUUID:currentDetail.goodsNameUUID];
        
        // 主单位
        ManifestTransactionDetail *mainUnitDetail = [JCHAddProductChildViewController createManifestTransactionDetail:productRecord];
        mainUnitDetail.productUnit = productRecord.goods_unit;
        mainUnitDetail.unitUUID = productRecord.goods_unit_uuid;
        mainUnitDetail.productUnit_digits = productRecord.goods_unit_digits;
        
        NSString *key = [NSString stringWithFormat:@"%@_%@", productRecord.goods_uuid, productRecord.goods_unit_uuid];
        InventoryDetailRecord4Cocoa *inventoryRecord = [self.inventoryMap objectForKey:key];
        CGFloat currentTotalInventoryCount = inventoryRecord.currentInventoryCount;
        NSString *inventoryCount = [NSString stringFromCount:currentTotalInventoryCount unitDigital:productRecord.goods_unit_digits];
        mainUnitDetail.productInventoryCount = inventoryCount;
        mainUnitDetail.ratio = 1;
        mainUnitDetail.isMainUnit = YES;
        [manifestTransactionsToProduct addObject:mainUnitDetail];
        
        
        // 辅单位
        ManifestTransactionDetail *transactionDetail = [JCHAddProductChildViewController createManifestTransactionDetail:productRecord];
        transactionDetail.productUnit = currentDetail.productUnit;
        transactionDetail.unitUUID = currentDetail.unitUUID;
        transactionDetail.productUnit_digits = currentDetail.productUnit_digits;
        
        // 辅单位库存存为主单位库存，由于界面上用不到辅单位库存，编辑辅单位的时候要和主单位的库存进行比较，所以存为主单位库存
        transactionDetail.productInventoryCount = inventoryCount;
        transactionDetail.productCount = currentDetail.productCount;
        transactionDetail.ratio = currentDetail.ratio;
        transactionDetail.isMainUnit = NO;
        
        [manifestTransactionsToProduct addObject:transactionDetail];
    } else {
        ManifestTransactionDetail *currentDetail = self.currentProductInManifestList[rowIndex];
        
        //键盘操作的detail
        ManifestTransactionDetail *editDetial = [[[ManifestTransactionDetail alloc] init] autorelease];
        editDetial.productCategory = currentDetail.productCategory;
        editDetial.productName = currentDetail.productName;
        editDetial.productImageName = currentDetail.productImageName;
        editDetial.productUnit = currentDetail.productUnit;
        editDetial.productCount = currentDetail.productCount;
        editDetial.productCountFloat = currentDetail.productCountFloat;
        editDetial.productInventoryCount = currentDetail.productInventoryCount;
        editDetial.productPrice = currentDetail.productPrice;
        editDetial.productDiscount = currentDetail.productDiscount;
        editDetial.productAddedTimestamp = currentDetail.productAddedTimestamp;
        editDetial.productUnit_digits = currentDetail.productUnit_digits;
        editDetial.warehouseUUID = currentDetail.warehouseUUID;
        editDetial.transactionUUID = currentDetail.transactionUUID;
        editDetial.unitUUID = currentDetail.unitUUID;
        editDetial.goodsNameUUID = currentDetail.goodsNameUUID;
        editDetial.goodsCategoryUUID = currentDetail.goodsCategoryUUID;
        editDetial.skuValueUUIDs = currentDetail.skuValueUUIDs;
        editDetial.skuValueCombine = currentDetail.skuValueCombine;
        editDetial.skuHidenFlag = currentDetail.skuHidenFlag;
        editDetial.averagePriceBefore = currentDetail.averagePriceBefore;
        
        
        //在货单编辑或复制中 库存信息为nil，默认先给0，后面异步重新查找库存信息
        
        if (manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeEdit || manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeCopy) {
            
            editDetial.productInventoryCount = @"0";
            [self calculateInventoryCountForTransactionDetail:editDetial];
        }
        [manifestTransactionsToProduct addObject:editDetial];
    }
    
    
    ManifestTransactionDetail *detail = manifestTransactionsToProduct.firstObject;
    skuListView = [[[JCHAddProductSKUListView alloc] initWithFrame:CGRectZero
                                                       productName:detail.productName
                                                      manifestType:enumCreateManifestType
                                                        dataSource:manifestTransactionsToProduct] autorelease];
    skuListView.delegate = self;
    
    CGFloat skuListViewHeight = kSKUListRowHeight * skuListView.dataSource.count + kSKUListSectionHeight;
    if (manifestStorage.currentManifestType == kJCHManifestAssembling || manifestStorage.currentManifestType == kJCHManifestDismounting) {
        // 拼装单listView高度比较特殊
        skuListViewHeight = kSKUListRowHeight * (skuListView.dataSource.count - 1) + kSKUListSectionHeight;
    }
    CGFloat keyboardHeight = [JCHSizeUtility calculateWidthWithSourceWidth:196.0f];
    keyboardView = [[[JCHSettleAccountsKeyboardView alloc] initWithFrame:CGRectZero
                                                          keyboardHeight:keyboardHeight
                                                                 topView:skuListView
                                                  topContainerViewHeight:skuListViewHeight] autorelease];
    keyboardView.delegate = self;
    keyboardView.unit_digits = detail.productUnit_digits;
    [keyboardView setEditText:detail.productCount editMode:kJCHSettleAccountsKeyboardViewEditModeCount];
    [keyboardView show];

    return;
}

// 扫码拼装单扫到主单位商品调用
- (void)showAssemblingKeyboard:(ProductRecord4Cocoa *)productRecord
{
    NSMutableArray *manifestTransactionsToProduct = [NSMutableArray array];
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    // 组装单要商品界面只显示主单位，点击后键盘上面列表里要显示所有辅单位
    
    
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    
    // 主单位
    ManifestTransactionDetail *mainUnitDetail = [JCHAddProductChildViewController createManifestTransactionDetail:productRecord];
    mainUnitDetail.productUnit = productRecord.goods_unit;
    mainUnitDetail.unitUUID = productRecord.goods_unit_uuid;
    mainUnitDetail.productUnit_digits = productRecord.goods_unit_digits;
    
    NSString *key = [NSString stringWithFormat:@"%@_%@", productRecord.goods_uuid, productRecord.goods_unit_uuid];
    InventoryDetailRecord4Cocoa *inventoryRecord = [self.inventoryMap objectForKey:key];
    CGFloat currentTotalInventoryCount = inventoryRecord.currentInventoryCount;
    NSString *inventoryCount = [NSString stringFromCount:currentTotalInventoryCount unitDigital:productRecord.goods_unit_digits];
    mainUnitDetail.productInventoryCount = inventoryCount;
    mainUnitDetail.productPrice = [NSString stringWithFormat:@"%.2f", inventoryRecord.averageCostPrice];
    mainUnitDetail.averagePriceBefore = mainUnitDetail.productPrice;
    mainUnitDetail.ratio = 1;
    mainUnitDetail.isMainUnit = YES;
    
    [manifestTransactionsToProduct addObject:mainUnitDetail];
    
    // 辅单位
    NSArray *unitList = [productService queryUnitGoodsItem:productRecord.goods_uuid];
    
    for (ProductItemRecord4Cocoa *productItemRecord in unitList) {
        
        BOOL detailInManifestStorage = NO;
        for (ManifestTransactionDetail *detail in [manifestStorage getAllManifestRecord]) {
            if ([productItemRecord.goodsUnitUUID isEqualToString:detail.unitUUID]) {
                [manifestTransactionsToProduct addObject:detail];
                detailInManifestStorage = YES;
                break;
            }
        }
        
        if (detailInManifestStorage == NO) {
            ManifestTransactionDetail *detail = [JCHAddProductChildViewController createManifestTransactionDetail:productRecord];
            detail.productUnit = productItemRecord.unitName;
            detail.unitUUID = productItemRecord.goodsUnitUUID;
            detail.productUnit_digits = productItemRecord.unitDigits;
            
            // 辅单位库存存为主单位库存，由于界面上用不到辅单位库存，编辑辅单位的时候要和主单位的库存进行比较，所以存为主单位库存
            detail.productInventoryCount = inventoryCount;
            detail.ratio = productItemRecord.ratio;
            detail.isMainUnit = NO;
            
            [manifestTransactionsToProduct addObject:detail];
        }
    }
    
    
    ManifestTransactionDetail *detail = manifestTransactionsToProduct.firstObject;
    skuListView = [[[JCHAddProductSKUListView alloc] initWithFrame:CGRectZero
                                                       productName:detail.productName
                                                      manifestType:enumCreateManifestType
                                                        dataSource:manifestTransactionsToProduct] autorelease];
    skuListView.delegate = self;
    
    CGFloat skuListViewHeight = kSKUListRowHeight * skuListView.dataSource.count + kSKUListSectionHeight;
    if (manifestStorage.currentManifestType == kJCHManifestAssembling) {
        // 拼装单listView高度比较特殊
        skuListViewHeight = kSKUListRowHeight * (skuListView.dataSource.count - 1) + kSKUListSectionHeight;
    }
    CGFloat keyboardHeight = [JCHSizeUtility calculateWidthWithSourceWidth:196.0f];
    keyboardView = [[[JCHSettleAccountsKeyboardView alloc] initWithFrame:CGRectZero
                                                          keyboardHeight:keyboardHeight
                                                                 topView:skuListView
                                                  topContainerViewHeight:skuListViewHeight] autorelease];
    keyboardView.delegate = self;
    keyboardView.unit_digits = detail.productUnit_digits;
    [keyboardView setEditText:detail.productCount editMode:kJCHSettleAccountsKeyboardViewEditModeCount];
    [keyboardView show];
}

- (void)calculateInventoryCountForTransactionDetail:(ManifestTransactionDetail *)detail
{
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    id<FinanceCalculateService> calculateService = [[ServiceFactory sharedInstance] financeCalculateService];
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSArray *allGoodsSKURecordArray = nil;
        [skuService queryAllGoodsSKU:&allGoodsSKURecordArray];
        
        ProductRecord4Cocoa *productRecord = [productService queryProductByUUID:detail.goodsNameUUID];
        JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
        InventoryDetailRecord4Cocoa *inventoryDetailRecord = [calculateService calculateInventoryFor:productRecord.goods_uuid
                                                                                            unitUUID:productRecord.goods_unit_uuid
                                                                                       warehouseUUID:manifestStorage.warehouseID];
        NSArray *productSKUInventoryArray = inventoryDetailRecord.productSKUInventoryArray;
        
        //遍历该商品对应的所有的SKUInventoryRecord4Cocoa，找出该单品对应的SKUInventoryRecord4Cocoa，得到库存
        if (productRecord.sku_hiden_flag) {
            
            //CGFloat inventoryCount = inventoryDetailRecord.currentTotalPurchasesCount - inventoryDetailRecord.currentTotalShipmentCount;
            CGFloat inventoryCount = inventoryDetailRecord.currentInventoryCount;
            detail.productInventoryCount = [NSString stringFromCount:inventoryCount unitDigital:productRecord.goods_unit_digits];
        } else {
            
            for (SKUInventoryRecord4Cocoa *skuInventoryRecord in productSKUInventoryArray) {
                GoodsSKURecord4Cocoa *record = nil;
                for (GoodsSKURecord4Cocoa *tempRecord in allGoodsSKURecordArray) {
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
                    break;
                }
            }
            
            if (!detail.productInventoryCount) {
                detail.productInventoryCount = [NSString stringFromCount:0 unitDigital:productRecord.goods_unit_digits];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [skuListView reloadData];
        });
    });
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorage.currentManifestType == kJCHManifestAssembling) {
        return self.currentProductInManifestList.count;
    } else {
        return  1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorage.currentManifestType == kJCHManifestAssembling) {
        return 1;
    } else {
        return [self.currentProductInManifestList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCreateManifestTableViewCellTag = @"kCreateManifestTableViewCellTag";
    JCHCreateManifestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCreateManifestTableViewCellTag];
    if (nil == cell) {
        cell = [[[JCHCreateManifestTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                      reuseIdentifier:kCreateManifestTableViewCellTag
                                                         manifestType:enumCreateManifestType
                                                     isManifestDetail:NO] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    ManifestTransactionDetail *productDetail = nil;
    JCHCreateManifestTableViewCellData *cellData = [[[JCHCreateManifestTableViewCellData alloc] init] autorelease];
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorage.currentManifestType == kJCHManifestAssembling) {
        NSArray *auxiliaryUnitDetailList = self.currentProductInManifestList[indexPath.section];
        productDetail = [auxiliaryUnitDetailList firstObject];
//        NSMutableString *mainAuxiliaryUnitCountInfo = [NSMutableString string];
        id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
        ProductRecord4Cocoa *productRecord = [productService queryProductByUUID:productDetail.goodsNameUUID];
        
        CGFloat mainUnitProductCount = 0;
        for (NSInteger i = 0; i < auxiliaryUnitDetailList.count; i++) {
            ManifestTransactionDetail *auxiliaryDetail = auxiliaryUnitDetailList[i];
            mainUnitProductCount += auxiliaryDetail.productCount.doubleValue * auxiliaryDetail.ratio;
        }
        cellData.productCount = [NSString stringFromCount:mainUnitProductCount unitDigital:productRecord.goods_unit_digits];
        cellData.productUnit = productRecord.goods_unit;
    } else {
        productDetail = [self.currentProductInManifestList objectAtIndex:indexPath.row];
        cellData.productCount = [NSString stringFromCount:productDetail.productCount.doubleValue unitDigital:productDetail.productUnit_digits];
        cellData.productUnit = productDetail.productUnit;
    }
    
    cellData.productName = productDetail.productName;
    cellData.productPrice = [NSString stringWithFormat:@"%.2f", productDetail.productPrice.doubleValue];
    cellData.productDiscount = productDetail.productDiscount;
    cellData.productSKUValueCombine = productDetail.skuValueCombine;
    cellData.productProperty = productDetail.dishProperty;
    
    CGFloat productIncreaseCount = productDetail.productCount.doubleValue - productDetail.productInventoryCount.doubleValue;
    cellData.productIncreaseCount = [NSString stringFromCount:productIncreaseCount unitDigital:productDetail.productUnit_digits];
    
    if (self.lastEditedProductUUID && [self.lastEditedProductUUID isEqualToString:productDetail.goodsNameUUID]) {
        cellData.lastEditedItem = YES;
        self.lastEditedProductUUID = nil;
    }
    
    cellData.productImageName = productDetail.productImageName;
    
    [cell setData:cellData];
    [self.heightForRow setObject:@(cell.cellHeight) forKey:@(indexPath.row)];
    cell.delegate = self;
    
#if !MMR_RESTAURANT_VERSION
    NSArray *rightButtons = [self rightButtons];
#else
    NSArray *rightButtons = nil;
    if(manifestStorage.currentManifestType == kJCHOrderPurchases) {
        rightButtons = [self rightButtons];
    } else {
        if (manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeEdit) {
            rightButtons = [self rightButtonsForRestuarant];
        } else if (manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeCopy ||
                   manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeNew) {
            rightButtons = [self rightButtons];
        }
    }
#endif
    [cell setRightUtilityButtons:rightButtons WithButtonWidth:[JCHSizeUtility calculateWidthWithSourceWidth:65.0f]];
 
    return cell;
}

- (NSArray *)rightButtonsForRestuarant
{
    NSMutableArray *rightButtons = [NSMutableArray array];
    
    [rightButtons sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f) icon:[UIImage imageNamed:@"more_open_complete"]];
    UIButton *completeButton = [rightButtons lastObject];
    completeButton.tag = 2000;
    
    [rightButtons sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f) icon:[UIImage imageNamed:@"more_open_hurry"]];
    UIButton *hurryButton = [rightButtons lastObject];
    hurryButton.tag = 2001;
    
    [rightButtons sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f) icon:[UIImage imageNamed:@"more_open_reture"]];
    UIButton *returnButton = [rightButtons lastObject];
    returnButton.tag = 2002;
    
    return rightButtons;
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightButtons = [NSMutableArray array];

    [rightButtons sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f) icon:[UIImage imageNamed:@"manifest_more_open_edit"]];
    UIButton *editButton = [rightButtons lastObject];
    editButton.tag = 1000;
    
    [rightButtons sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f) icon:[UIImage imageNamed:@"manifest_more_open_delete"]];
    UIButton *deleteButton = [rightButtons lastObject];
    deleteButton.tag = 1001;
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorage.currentManifestType == kJCHOrderShipment) {
        [rightButtons sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f) icon:[UIImage imageNamed:@"more_open_discount"]];
        UIButton *discountButton = [rightButtons lastObject];
        discountButton.tag = 1002;
    }
    
    if (manifestStorage.currentManifestType == kJCHOrderPurchases || manifestStorage.currentManifestType == kJCHOrderShipment) {
        [rightButtons sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f) icon:[UIImage imageNamed:@"more_open_free"]];
        UIButton *freeButton = [rightButtons lastObject];
        freeButton.tag = 1003;
    }
    
    return rightButtons;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    JCHCreateManifestTableSectionView *sectionView = [[[JCHCreateManifestTableSectionView alloc] initWithTopLine:YES BottomLine:YES] autorelease];
    sectionView.frame = CGRectMake(0, 0, self.view.frame.size.width, kJCHInventoryListTableViewCellHeight);
    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorage.currentManifestType == kJCHManifestAssembling) {
        if (section == 0) {
            return 30.0f;
        } else {
            return 0;
        }
    } else {
        return 30.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *height = [self.heightForRow objectForKey:@(indexPath.row)];

    return [height doubleValue];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[[UIView alloc] init] autorelease];
}


#pragma mark - SWTableViewCellDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [contentTableView indexPathForCell:cell];
    UIButton *rightButton = cell.rightUtilityButtons[index];
    JCHManifestMemoryStorage *memoryStorage = [JCHManifestMemoryStorage sharedInstance];
    
    switch (rightButton.tag) {
        case 1000:  //编辑
        {
            if (memoryStorage.currentManifestType == kJCHManifestAssembling) {
                [self showKeyboard:indexPath.section];
            } else {
                [self showKeyboard:indexPath.row];
            }
        }
            break;
            
        case 1001:  //删除
        {
            if (memoryStorage.currentManifestType == kJCHManifestAssembling) {
                for (ManifestTransactionDetail *detail in self.currentProductInManifestList[indexPath.section]) {
                    [memoryStorage removeManifestRecord:detail];
                }
                [self.currentProductInManifestList removeObjectAtIndex:indexPath.section];
            } else {
                [memoryStorage removeManifestRecord:[self.currentProductInManifestList objectAtIndex:indexPath.row]];
                [self.currentProductInManifestList removeObjectAtIndex:indexPath.row];
            }
            
            [self loadData];
        }
            break;
            
        case 1002:  //打折
        {
            [self showDiscountKeyboard:indexPath.row];
        }
            break;
            
        case 1003:  //赠品
        {
            [cell hideUtilityButtonsAnimated:YES];
            ManifestTransactionDetail *productDetail = [self.currentProductInManifestList objectAtIndex:indexPath.row];
            productDetail.productPrice = @"0.0";
            [self loadData];
        }
            break;
            
        case 2000:  //划菜
        {
            
        }
            break;
            
        case 2001:  //催菜
        {
            
        }
            break;
            
        case 2002:  //退菜
        {
            [memoryStorage removeManifestRecord:[self.currentProductInManifestList objectAtIndex:indexPath.row]];
            [self.currentProductInManifestList removeObjectAtIndex:indexPath.row];
            [self loadData];
        }
            break;
            
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    JCHCreateManifestTableViewCell *swipCell = (JCHCreateManifestTableViewCell *)cell;
    if (state == kCellStateCenter) {
        
        swipCell.showMenuButton.selected = NO;
    } else if (state == kCellStateRight) {

        swipCell.showMenuButton.selected = YES;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}



#pragma mark - JCHCreateManifestFooterViewDelegate
- (void)handleClickSaveOrderList
{
#if MMR_RESTAURANT_VERSION
    // 餐饮版/外卖版
    [self handleClickSaveOrderListForRestaurant];
#else
    // 通用版
    [self handleClickSaveOrderListForJCH];
#endif
}

- (void)handleClickSaveOrderListForJCH
{
    if (enumCreateManifestType == kJCHOrderShipment || enumCreateManifestType == kJCHOrderPurchases) {
        JCHSettleAccountsViewController *settleAccountsVC = [[[JCHSettleAccountsViewController alloc] init] autorelease];
        [self.navigationController pushViewController:settleAccountsVC animated:YES];
    } else if (enumCreateManifestType == kJCHManifestInventory) {
        
        if ([self.parentViewController isKindOfClass:[JCHAddProductByScanCodeViewController class]]) {
            JCHCreateManifestViewController *createManifestVC = [[[JCHCreateManifestViewController alloc] init] autorelease];
            [self.navigationController pushViewController:createManifestVC animated:YES];
        } else {
            [self saveInventoryCheckManifest];
        }
        
    } else if (enumCreateManifestType == kJCHManifestMigrate) {
        if ([self.parentViewController isKindOfClass:[JCHAddProductByScanCodeViewController class]]) {
            JCHCreateManifestViewController *createManifestVC = [[[JCHCreateManifestViewController alloc] init] autorelease];
            [self.navigationController pushViewController:createManifestVC animated:YES];
        } else {
            [self saveMigrateManifest];
        }
    } else if (enumCreateManifestType == kJCHManifestAssembling) {
        if ([self.parentViewController isKindOfClass:[JCHAddProductByScanCodeViewController class]]) {
            JCHCreateManifestViewController *createManifestVC = [[[JCHCreateManifestViewController alloc] init] autorelease];
            [self.navigationController pushViewController:createManifestVC animated:YES];
        } else {
            [self saveAssemblingManifest];
        }
    } else if (enumCreateManifestType == kJCHManifestDismounting) {
        if ([self.parentViewController isKindOfClass:[JCHAddProductByScanCodeViewController class]]) {
            JCHCreateManifestViewController *createManifestVC = [[[JCHCreateManifestViewController alloc] init] autorelease];
            [self.navigationController pushViewController:createManifestVC animated:YES];
        } else {
            [self saveDismountingManifest];
        }
    }
}

- (void)handleSaveOrderListForOpenTable
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    manifestStorage.currentManifestDiscount = 1;
    
    NSArray *currentProductInManifestList = [manifestStorage getAllManifestRecord];
    NSMutableArray *transactionList = [[[NSMutableArray alloc] init] autorelease];
    
    for (ManifestTransactionDetail *productDetail in currentProductInManifestList) {
        
        NSString *transactionUUID = [[[ServiceFactory sharedInstance] utilityService] generateUUID];
        ManifestTransactionRecord4Cocoa *record = [[[ManifestTransactionRecord4Cocoa alloc] init] autorelease];
        record.productCategory = productDetail.productCategory;
        //record.productCount = [productDetail.productCount doubleValue];
        record.productCount = productDetail.productCountFloat;
        record.productDiscount = [productDetail.productDiscount doubleValue];
        record.productName = productDetail.productName;
        record.productPrice = [productDetail.productPrice doubleValue];
        record.productUnit = productDetail.productUnit;
        
        record.goodsNameUUID = productDetail.goodsNameUUID;
        record.goodsCategoryUUID = productDetail.goodsCategoryUUID;
        record.unitUUID = productDetail.unitUUID;
        record.warehouseUUID = productDetail.warehouseUUID;
        record.transactionUUID = transactionUUID;
        record.goodsSKUUUIDArray = productDetail.skuValueUUIDs;
        record.dishProperty = productDetail.dishProperty;
        
        [transactionList addObject:record];
    }
    
    // 出货单
    if (manifestStorage.currentManifestType == kJCHOrderShipment ||
        manifestStorage.currentManifestType == kJCHOrderPurchases ||
        manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable){
        //新增货单 / 复制货单
        if (manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeNew ||
            manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeCopy) {
            id<DiningTableService> diningTableService = [[ServiceFactory sharedInstance] diningTableService];
            DiningTableRecord4Cocoa *tableRecord = [diningTableService qeryDiningTable:manifestStorage.tableID];
            ManifestRecord4Cocoa *manifestRecord = [[[ManifestRecord4Cocoa alloc] init] autorelease];
            manifestRecord.manifestDiscount = 1.0;
            manifestRecord.eraseAmount = 0.0;
            manifestRecord.manifestID = manifestStorage.currentManifestID;
            manifestRecord.manifestTimestamp = [[NSDate date] timeIntervalSince1970];
            manifestRecord.manifestType = kJCHOrderShipment;
            manifestRecord.manifestRemark = @"手机开台测试";
            manifestRecord.manifestTransactionArray = transactionList;
            [JCHRestaurantManifestUtility restaurantOpenTable:(ManifestRecord4Cocoa *)manifestRecord
                                                      tableID:manifestStorage.tableID
                                                    tableName:tableRecord.tableName
                                           oldTransactionList:manifestStorage.restaurantPreInsertManifestArray
                                         navigationController:self.navigationController];
            
        } else if (manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeEdit) {
            id<DiningTableService> diningTableService = [[ServiceFactory sharedInstance] diningTableService];
            DiningTableRecord4Cocoa *tableRecord = [diningTableService qeryDiningTable:manifestStorage.tableID];
            ManifestRecord4Cocoa *manifestRecord = [[[ManifestRecord4Cocoa alloc] init] autorelease];
            manifestRecord.manifestDiscount = 1.0;
            manifestRecord.eraseAmount = 0.0;
            manifestRecord.manifestID = manifestStorage.currentManifestID;
            manifestRecord.manifestTimestamp = [[NSDate date] timeIntervalSince1970];
            manifestRecord.manifestType = kJCHOrderShipment;
            manifestRecord.manifestRemark = @"手机开台测试";
            manifestRecord.manifestTransactionArray = transactionList;
            [JCHRestaurantManifestUtility restaurantOpenTable:(ManifestRecord4Cocoa *)manifestRecord
                                                      tableID:manifestStorage.tableID
                                                    tableName:tableRecord.tableName
                                           oldTransactionList:manifestStorage.restaurantPreInsertManifestArray
                                         navigationController:self.navigationController];
        } else {
            //pass
        }
        
        manifestStorage.hasPayed = YES;
    }
}



#if MMR_RESTAURANT_VERSION || MMR_TAKEOUT_VERSION

- (void)handleClickSaveOrderListForRestaurant
{
    JCHManifestMemoryStorage *memoryStorage = [JCHManifestMemoryStorage sharedInstance];
    switch (memoryStorage.enumRestaurantManifestType) {
        case kJCHRestaurantMaterialInventory:    // 原料盘点
        {
            [self handleSaveRestaurantMaterialInventory];
        }
            break;
            
        case kJCHRestaurantMaterialWastage:      // 原料损耗
        {
            [self handleSaveRestaurantMaterialWastage];
        }
            break;
            
        case kJCHRestaurantDishesStorage:        // 菜品入库
        {
            [self handleSaveRestaurantDishesStorage];
        }
            break;
            
        case kJCHRestaurantDishesWastage:        // 菜品损耗
        {
            [self handleSaveRestaurantDishesWastage];
        }
            break;
            
        case kJCHRestaurantDishesMarkSold:       // 菜品估清
        {
            [self handleSaveRestaurantDishesMarkSold];
        }
            break;
            
        case kJCHRestaurantDishesUnmarkSold:     // 取消估清
        {
            [self handleSaveRestaurantDishesUnmarkSold];
        }
            break;
            
        case kJCHRestaurantOpenTable:            // 开台
        {
            JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
            if (manifestStorage.currentManifestType == kJCHOrderPurchases) {
                [self handleClickSaveOrderListForJCH];
            } else if (manifestStorage.currentManifestType == kJCHOrderShipment) {
                [self handleSaveOrderListForOpenTable];
            } else {
                // pass
            }
            
        }
            break;
            
        default:
        {
            
        }
            break;
    }
}

- (void)handleSaveRestaurantMaterialInventory    // 原料盘点
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    NSArray *currentProductInManifestList = [manifestStorage getAllManifestRecord];
    NSMutableArray<CountingTransactionRecord4Cocoa *> *transactionList = [[[NSMutableArray alloc] init] autorelease];
    
    for (ManifestTransactionDetail *productDetail in currentProductInManifestList) {
        CountingTransactionRecord4Cocoa *record = [[[CountingTransactionRecord4Cocoa alloc] init] autorelease];
        record.productUUID = productDetail.goodsNameUUID;
        record.productName = productDetail.productName;
        record.productSKUUUIDVector = productDetail.skuValueUUIDs;
        record.productCountBefore = [productDetail.productInventoryCount doubleValue];
        record.averagePriceBefore = [productDetail.averagePriceBefore doubleValue];
        record.productCountAfter = [productDetail.productCount doubleValue];
        record.averagePriceAfter = [productDetail.productPrice doubleValue];
        record.productCategory = productDetail.productCategory;
        record.productCategoryUUID = productDetail.goodsCategoryUUID;
        record.unitUUID = productDetail.unitUUID;
        record.productUnit = productDetail.productUnit;
        record.productImageName = productDetail.productImageName;
        record.warehouseID = manifestStorage.warehouseID;
        record.unitDigits = (int)productDetail.productUnit_digits;
        
        [transactionList addObject:record];
    }
    
    NSString *orderDate = manifestStorage.currentManifestDate;
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *selectedDate = [dateFormater dateFromString:orderDate];
    time_t manifestTime = [selectedDate timeIntervalSince1970];
    int operatorID = [[[JCHSyncStatusManager shareInstance] userID] intValue];
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    int status = [manifestService countingManifest:manifestStorage.currentManifestID
                                      manifestTime:manifestTime
                                       warehouseID:manifestStorage.warehouseID
                                    manifestRemark:manifestStorage.currentManifestRemark
                                        operatorID:operatorID
                                   transactionList:transactionList];
    
    NSString *message = @"";
    if (status == 0) {
        message = @"盘点成功";
    } else {
        message = @"盘点失败";
    }
    [MBProgressHUD showHUDWithTitle:message
                             detail:nil
                           duration:kJCHDefaultShowHudTime
                               mode:MBProgressHUDModeText
                         completion:nil];
    
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    [self.navigationController popToViewController:appDelegate.switchToTargetController animated:YES];
}

- (void)handleSaveRestaurantMaterialWastage      // 原料损耗
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    NSArray *currentProductInManifestList = [manifestStorage getAllManifestRecord];
    NSMutableArray<CountingTransactionRecord4Cocoa *> *transactionList = [[[NSMutableArray alloc] init] autorelease];
    
    for (ManifestTransactionDetail *productDetail in currentProductInManifestList) {
        CountingTransactionRecord4Cocoa *record = [[[CountingTransactionRecord4Cocoa alloc] init] autorelease];
        record.productUUID = productDetail.goodsNameUUID;
        record.productName = productDetail.productName;
        record.productSKUUUIDVector = productDetail.skuValueUUIDs;
        record.productCountBefore = [productDetail.productInventoryCount doubleValue];
        record.averagePriceBefore = [productDetail.averagePriceBefore doubleValue];
        record.productCountAfter = [productDetail.productCount doubleValue];
        record.averagePriceAfter = [productDetail.productPrice doubleValue];
        record.productCategory = productDetail.productCategory;
        record.productCategoryUUID = productDetail.goodsCategoryUUID;
        record.unitUUID = productDetail.unitUUID;
        record.productUnit = productDetail.productUnit;
        record.productImageName = productDetail.productImageName;
        record.warehouseID = manifestStorage.warehouseID;
        record.unitDigits = (int)productDetail.productUnit_digits;
        
        [transactionList addObject:record];
    }
    
    NSString *orderDate = manifestStorage.currentManifestDate;
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *selectedDate = [dateFormater dateFromString:orderDate];
    time_t manifestTime = [selectedDate timeIntervalSince1970];
    int operatorID = [[[JCHSyncStatusManager shareInstance] userID] intValue];
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    int status = [manifestService countingProductWaste:manifestStorage.currentManifestID
                                          manifestTime:manifestTime
                                           warehouseID:manifestStorage.warehouseID
                                        manifestRemark:manifestStorage.currentManifestRemark
                                            operatorID:operatorID
                                       transactionList:transactionList];
    
    NSString *message = @"";
    if (status == 0) {
        message = @"盘点成功";
    } else {
        message = @"盘点失败";
    }
    [MBProgressHUD showHUDWithTitle:message
                             detail:nil
                           duration:kJCHDefaultShowHudTime
                               mode:MBProgressHUDModeText
                         completion:nil];
    
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    [self.navigationController popToViewController:appDelegate.switchToTargetController animated:YES];
}

- (void)handleSaveRestaurantDishesStorage        // 菜品入库
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    NSArray *currentProductInManifestList = [manifestStorage getAllManifestRecord];
    NSMutableArray<CountingTransactionRecord4Cocoa *> *transactionList = [[[NSMutableArray alloc] init] autorelease];
    
    for (ManifestTransactionDetail *productDetail in currentProductInManifestList) {
        CountingTransactionRecord4Cocoa *record = [[[CountingTransactionRecord4Cocoa alloc] init] autorelease];
        record.productUUID = productDetail.goodsNameUUID;
        record.productName = productDetail.productName;
        record.productSKUUUIDVector = productDetail.skuValueUUIDs;
        record.productCountBefore = [productDetail.productInventoryCount doubleValue];
        record.averagePriceBefore = [productDetail.averagePriceBefore doubleValue];
        record.productCountAfter = [productDetail.productCount doubleValue];
        record.averagePriceAfter = [productDetail.productPrice doubleValue];
        record.productCategory = productDetail.productCategory;
        record.productCategoryUUID = productDetail.goodsCategoryUUID;
        record.unitUUID = productDetail.unitUUID;
        record.productUnit = productDetail.productUnit;
        record.productImageName = productDetail.productImageName;
        record.warehouseID = manifestStorage.warehouseID;
        record.unitDigits = (int)productDetail.productUnit_digits;
        
        [transactionList addObject:record];
    }
    
    NSString *orderDate = manifestStorage.currentManifestDate;
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *selectedDate = [dateFormater dateFromString:orderDate];
    time_t manifestTime = [selectedDate timeIntervalSince1970];
    int operatorID = [[[JCHSyncStatusManager shareInstance] userID] intValue];
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    int status = [manifestService countingCuisineStore:manifestStorage.currentManifestID
                                          manifestTime:manifestTime
                                           warehouseID:manifestStorage.warehouseID
                                        manifestRemark:manifestStorage.currentManifestRemark
                                            operatorID:operatorID
                                       transactionList:transactionList];
    
    NSString *message = @"";
    if (status == 0) {
        message = @"盘点成功";
    } else {
        message = @"盘点失败";
    }
    [MBProgressHUD showHUDWithTitle:message
                             detail:nil
                           duration:kJCHDefaultShowHudTime
                               mode:MBProgressHUDModeText
                         completion:nil];
    
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    [self.navigationController popToViewController:appDelegate.switchToTargetController animated:YES];
}

- (void)handleSaveRestaurantDishesWastage        // 菜品损耗
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    NSArray *currentProductInManifestList = [manifestStorage getAllManifestRecord];
    NSMutableArray<CountingTransactionRecord4Cocoa *> *transactionList = [[[NSMutableArray alloc] init] autorelease];
    
    for (ManifestTransactionDetail *productDetail in currentProductInManifestList) {
        CountingTransactionRecord4Cocoa *record = [[[CountingTransactionRecord4Cocoa alloc] init] autorelease];
        record.productUUID = productDetail.goodsNameUUID;
        record.productName = productDetail.productName;
        record.productSKUUUIDVector = productDetail.skuValueUUIDs;
        record.productCountBefore = [productDetail.productInventoryCount doubleValue];
        record.averagePriceBefore = [productDetail.averagePriceBefore doubleValue];
        record.productCountAfter = [productDetail.productCount doubleValue];
        record.averagePriceAfter = [productDetail.productPrice doubleValue];
        record.productCategory = productDetail.productCategory;
        record.productCategoryUUID = productDetail.goodsCategoryUUID;
        record.unitUUID = productDetail.unitUUID;
        record.productUnit = productDetail.productUnit;
        record.productImageName = productDetail.productImageName;
        record.warehouseID = manifestStorage.warehouseID;
        record.unitDigits = (int)productDetail.productUnit_digits;
        
        [transactionList addObject:record];
    }
    
    NSString *orderDate = manifestStorage.currentManifestDate;
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *selectedDate = [dateFormater dateFromString:orderDate];
    time_t manifestTime = [selectedDate timeIntervalSince1970];
    int operatorID = [[[JCHSyncStatusManager shareInstance] userID] intValue];
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    int status = [manifestService countingCuisineWaste:manifestStorage.currentManifestID
                                          manifestTime:manifestTime
                                           warehouseID:manifestStorage.warehouseID
                                        manifestRemark:manifestStorage.currentManifestRemark
                                            operatorID:operatorID
                                       transactionList:transactionList];
    
    NSString *message = @"";
    if (status == 0) {
        message = @"盘点成功";
    } else {
        message = @"盘点失败";
    }
    [MBProgressHUD showHUDWithTitle:message
                             detail:nil
                           duration:kJCHDefaultShowHudTime
                               mode:MBProgressHUDModeText
                         completion:nil];
    
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    [self.navigationController popToViewController:appDelegate.switchToTargetController animated:YES];
}

- (void)handleSaveRestaurantDishesMarkSold       // 菜品估清
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    NSArray *currentProductInManifestList = [manifestStorage getAllManifestRecord];
    
    NSMutableArray<ProductItemRecord4Cocoa *> *itemList = [[[NSMutableArray alloc] init] autorelease];
    for (ManifestTransactionDetail *productDetail in currentProductInManifestList) {
        ProductItemRecord4Cocoa *record = [[[ProductItemRecord4Cocoa alloc] init] autorelease];
        record.goodsUUID = productDetail.goodsNameUUID;
        record.goodsUnitUUID = productDetail.unitUUID;
        record.goodsSkuUUID = @"";
        record.skuUUIDVector = productDetail.skuValueUUIDs;
        record.imageName1 = @"";
        record.imageName2 = @"";
        record.imageName3 = @"";
        record.imageName4 = @"";
        record.imageName5 = @"";
        record.itemPrice = 0.0;
        record.itemBarCode = @"";
        record.ratio = 1.0;
        record.unitName = productDetail.productUnit;
        record.unitDigits = (int)productDetail.productUnit_digits;
        
        [itemList addObject:record];
    }
    
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    int status = [productService setProductItemSoldOutFlag:itemList soldOut:YES];
    
    NSString *message = @"";
    if (status == 0) {
        message = @"估清成功";
    } else {
        message = @"估清失败";
    }
    [MBProgressHUD showHUDWithTitle:message
                             detail:nil
                           duration:kJCHDefaultShowHudTime
                               mode:MBProgressHUDModeText
                         completion:nil];
    
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    [self.navigationController popToViewController:appDelegate.switchToTargetController animated:YES];
}

- (void)handleSaveRestaurantDishesUnmarkSold     // 取消估清
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    NSArray *currentProductInManifestList = [manifestStorage getAllManifestRecord];
    
    NSMutableArray<ProductItemRecord4Cocoa *> *itemList = [[[NSMutableArray alloc] init] autorelease];
    for (ManifestTransactionDetail *productDetail in currentProductInManifestList) {
        ProductItemRecord4Cocoa *record = [[[ProductItemRecord4Cocoa alloc] init] autorelease];
        record.goodsUUID = productDetail.goodsNameUUID;
        record.goodsUnitUUID = productDetail.unitUUID;
        record.goodsSkuUUID = @"";
        record.skuUUIDVector = productDetail.skuValueUUIDs;
        record.imageName1 = @"";
        record.imageName2 = @"";
        record.imageName3 = @"";
        record.imageName4 = @"";
        record.imageName5 = @"";
        record.itemPrice = 0.0;
        record.itemBarCode = @"";
        record.ratio = 1.0;
        record.unitName = productDetail.productUnit;
        record.unitDigits = (int)productDetail.productUnit_digits;
        
        [itemList addObject:record];
    }
    
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    int status = [productService setProductItemSoldOutFlag:itemList soldOut:NO];
    
    NSString *message = @"";
    if (status == 0) {
        message = @"估清成功";
    } else {
        message = @"估清失败";
    }
    [MBProgressHUD showHUDWithTitle:message
                             detail:nil
                           duration:kJCHDefaultShowHudTime
                               mode:MBProgressHUDModeText
                         completion:nil];
    
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    [self.navigationController popToViewController:appDelegate.switchToTargetController animated:YES];
}

#endif

- (void)handleEditRemark
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    inputView = [[[JCHInputView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 44)] autorelease];
    
    inputView.delegate = self;
    [inputView show];
    
    inputView.textView.returnKeyType = UIReturnKeyDone;
}

#pragma mark - JCHAddProductFooterViewDelegate

//购物车
- (void)handleShowTransactionList
{
    JCHManifestMemoryStorage *storage = [JCHManifestMemoryStorage sharedInstance];
    
    //去掉数量为0的transaction
    NSArray *transactionList = [storage getAllManifestRecord];
    for (ManifestTransactionDetail *detail in transactionList) {
        
        if ([detail.productCount doubleValue] == 0) {
            [storage removeManifestRecord:detail];
        }
    }
    
    if (storage.manifestMemoryType == kJCHManifestMemoryTypeNew) {
        JCHCreateManifestViewController *manifestViewController = [[[JCHCreateManifestViewController alloc] init] autorelease];
        [self.navigationController pushViewController:manifestViewController animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    return;
}


#pragma mark - 保持盘点单信息
- (void)saveInventoryCheckManifest
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    
    NSArray *currentProductInManifestList = [manifestStorage getAllManifestRecord];
    NSMutableArray<CountingTransactionRecord4Cocoa *> *transactionList = [[[NSMutableArray alloc] init] autorelease];
    
    for (ManifestTransactionDetail *productDetail in currentProductInManifestList) {
        
        CountingTransactionRecord4Cocoa *record = [[[CountingTransactionRecord4Cocoa alloc] init] autorelease];
        record.productUUID = productDetail.goodsNameUUID;
        record.productName = productDetail.productName;
        record.productSKUUUIDVector = productDetail.skuValueUUIDs;
        record.productCountBefore = [productDetail.productInventoryCount doubleValue];
        record.averagePriceBefore = [productDetail.averagePriceBefore doubleValue];
        record.productCountAfter = [productDetail.productCount doubleValue];
        record.averagePriceAfter = [productDetail.productPrice doubleValue];
        record.productCategory = productDetail.productCategory;
        record.productCategoryUUID = productDetail.goodsCategoryUUID;
        record.unitUUID = productDetail.unitUUID;
        record.productUnit = productDetail.productUnit;
        record.productImageName = productDetail.productImageName;
        record.warehouseID = manifestStorage.warehouseID;
        record.unitDigits = (int)productDetail.productUnit_digits;
        
        [transactionList addObject:record];
    }
    
    NSString *orderDate = manifestStorage.currentManifestDate;
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *selectedDate = [dateFormater dateFromString:orderDate];
    time_t manifestTime = [selectedDate timeIntervalSince1970];
    
    int operatorID = [[[JCHSyncStatusManager shareInstance] userID] intValue];
    
    
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    
    int status = [manifestService countingManifest:manifestStorage.currentManifestID
                                      manifestTime:manifestTime
                                       warehouseID:manifestStorage.warehouseID
                                    manifestRemark:manifestStorage.currentManifestRemark
                                        operatorID:operatorID
                                   transactionList:transactionList];
    
    NSString *message = @"";
    if (status == 0) {
        message = @"盘点成功";
    } else {
        message = @"盘点失败";
    }
    [MBProgressHUD showHUDWithTitle:message
                             detail:nil
                           duration:kJCHDefaultShowHudTime
                               mode:MBProgressHUDModeText
                         completion:nil];
    
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    
    [self.navigationController popToViewController:appDelegate.switchToTargetController animated:YES];
}

#pragma mark - 保存移库单信息

- (void)saveMigrateManifest
{
    if (self.destinationWarehouseRecord == nil) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"请选择目标仓库"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    if ([self.destinationWarehouseRecord.warehouseID isEqualToString:manifestStorage.warehouseID]) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"目标仓库和源仓库不能相同"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    
    NSArray *currentProductInManifestList = [manifestStorage getAllManifestRecord];
    NSMutableArray<ManifestTransactionRecord4Cocoa *> *transactionList = [[[NSMutableArray alloc] init] autorelease];
    
    NSString *transactionUUID = [[[ServiceFactory sharedInstance] utilityService] generateUUID];
    for (ManifestTransactionDetail *productDetail in currentProductInManifestList) {
        
        ManifestTransactionRecord4Cocoa *record = [[[ManifestTransactionRecord4Cocoa alloc] init] autorelease];
        record.productCategory = productDetail.productCategory;
        record.productName = productDetail.productName;
        record.productImageName = productDetail.productImageName;
        record.productCount = [productDetail.productCount doubleValue];
        record.productDiscount = [productDetail.productDiscount doubleValue];
        record.productPrice = [productDetail.productPrice doubleValue];
        record.productUnit = productDetail.productUnit;
        record.unitDigits = productDetail.productUnit_digits;
        record.warehouseUUID = productDetail.warehouseUUID;
        record.transactionUUID = transactionUUID;
        record.unitUUID = productDetail.unitUUID;
        record.goodsNameUUID = productDetail.goodsNameUUID;
        record.goodsCategoryUUID = productDetail.goodsCategoryUUID;
        record.goodsSKUUUIDArray = productDetail.skuValueUUIDs;
        record.dishProperty = productDetail.dishProperty;
        [transactionList addObject:record];
    }
    
    NSString *orderDate = manifestStorage.currentManifestDate;
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *selectedDate = [dateFormater dateFromString:orderDate];
    time_t manifestTime = [selectedDate timeIntervalSince1970];
    
    int operatorID = [[[JCHSyncStatusManager shareInstance] userID] intValue];
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];

    int status = [manifestService transferManifest:transactionList
                                      manifestTime:manifestTime
                                        operatorID:operatorID
                                        manifestID:manifestStorage.currentManifestID
                                            remark:manifestStorage.currentManifestRemark
                                   sourceWarehouse:manifestStorage.warehouseID
                                   targetWarehouse:(NSString *)self.destinationWarehouseRecord.warehouseID];
    
    NSString *message = @"";
    if (status == 0) {
        message = @"移库成功";
    } else {
        message = @"移库失败";
    }
    [MBProgressHUD showHUDWithTitle:message
                             detail:nil
                           duration:kJCHDefaultShowHudTime
                               mode:MBProgressHUDModeText
                         completion:nil];
    
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    
    [self.navigationController popToViewController:appDelegate.switchToTargetController animated:YES];
}

#pragma mark - 保存拼装单信息
- (void)saveAssemblingManifest
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    
    NSArray *currentProductInManifestList = [manifestStorage getAllManifestRecord];
    NSMutableArray<ManifestTransactionRecord4Cocoa *> *transactionList = [[[NSMutableArray alloc] init] autorelease];
    
    for (ManifestTransactionDetail *productDetail in currentProductInManifestList) {

        NSString *transactionUUID = [[[ServiceFactory sharedInstance] utilityService] generateUUID];
        ManifestTransactionRecord4Cocoa *transactionRecord = [[[ManifestTransactionRecord4Cocoa alloc] init] autorelease];
        transactionRecord.productCategory = productDetail.productCategory;
        transactionRecord.productCount = productDetail.productCountFloat;
        transactionRecord.productDiscount = [productDetail.productDiscount doubleValue];
        transactionRecord.productName = productDetail.productName;
        transactionRecord.productPrice = [productDetail.productPrice doubleValue];
        transactionRecord.productUnit = productDetail.productUnit;
        transactionRecord.goodsNameUUID = productDetail.goodsNameUUID;
        transactionRecord.goodsCategoryUUID = productDetail.goodsCategoryUUID;
        transactionRecord.unitUUID = productDetail.unitUUID;
        transactionRecord.warehouseUUID = productDetail.warehouseUUID;
        transactionRecord.transactionUUID = transactionUUID;
        transactionRecord.goodsSKUUUIDArray = productDetail.skuValueUUIDs;
        
        [transactionList addObject:transactionRecord];
    }
    
    NSString *orderDate = manifestStorage.currentManifestDate;
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *selectedDate = [dateFormater dateFromString:orderDate];
    time_t manifestTime = [selectedDate timeIntervalSince1970];
    
    int operatorID = [[[JCHSyncStatusManager shareInstance] userID] intValue];
    
    
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    
    
    int status = [manifestService assemblingManifest:manifestStorage.currentManifestID
                                        manifestTime:manifestTime
                                         warehouseID:manifestStorage.warehouseID
                                          operatorID:operatorID
                                         operateTime:manifestTime
                                              remark:manifestStorage.currentManifestRemark
                                   targetTransaction:transactionList];

    
    NSString *message = @"";
    if (status == 0) {
        message = @"拼装成功";
    } else {
        message = @"拼装失败";
    }

    
    [MBProgressHUD showHUDWithTitle:message
                             detail:nil
                           duration:kJCHDefaultShowHudTime
                               mode:MBProgressHUDModeText
                         completion:nil];
    
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    
    [self.navigationController popToViewController:appDelegate.switchToTargetController animated:YES];
}

#pragma mark - 保存拆装单信息
- (void)saveDismountingManifest
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    
    NSArray *currentProductInManifestList = [manifestStorage getAllManifestRecord];
    NSMutableArray<ManifestTransactionRecord4Cocoa *> *transactionList = [[[NSMutableArray alloc] init] autorelease];
    
    for (ManifestTransactionDetail *productDetail in currentProductInManifestList) {
        
        NSString *transactionUUID = [[[ServiceFactory sharedInstance] utilityService] generateUUID];
        ManifestTransactionRecord4Cocoa *transactionRecord = [[[ManifestTransactionRecord4Cocoa alloc] init] autorelease];
        transactionRecord.productCategory = productDetail.productCategory;
        transactionRecord.productCount = productDetail.productCountFloat;
        transactionRecord.productDiscount = [productDetail.productDiscount doubleValue];
        transactionRecord.productName = productDetail.productName;
        transactionRecord.productPrice = [productDetail.productPrice doubleValue];
        transactionRecord.productUnit = productDetail.productUnit;
        transactionRecord.goodsNameUUID = productDetail.goodsNameUUID;
        transactionRecord.goodsCategoryUUID = productDetail.goodsCategoryUUID;
        transactionRecord.unitUUID = productDetail.unitUUID;
        transactionRecord.warehouseUUID = productDetail.warehouseUUID;
        transactionRecord.transactionUUID = transactionUUID;
        transactionRecord.goodsSKUUUIDArray = productDetail.skuValueUUIDs;

        
        [transactionList addObject:transactionRecord];
    }
    
    NSString *orderDate = manifestStorage.currentManifestDate;
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *selectedDate = [dateFormater dateFromString:orderDate];
    time_t manifestTime = [selectedDate timeIntervalSince1970];
    
    int operatorID = [[[JCHSyncStatusManager shareInstance] userID] intValue];
    
    
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    
    
    int status = [manifestService dismountingManifest:manifestStorage.currentManifestID
                                         manifestTime:manifestTime
                                          warehouseID:manifestStorage.warehouseID
                                           operatorID:operatorID
                                          operateTime:manifestTime
                                               remark:manifestStorage.currentManifestRemark
                                    targetTransaction:transactionList];
    
    NSString *message = @"";
    if (status == 0) {
        message = @"拆装成功";
    } else {
        message = @"拆装失败";
    }
    
    [MBProgressHUD showHUDWithTitle:message
                             detail:nil
                           duration:kJCHDefaultShowHudTime
                               mode:MBProgressHUDModeText
                         completion:nil];
    
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    
    [self.navigationController popToViewController:appDelegate.switchToTargetController animated:YES];
}

- (CGFloat)calculateTotalOrderCost
{
    CGFloat totalCost = 0.0;
    for (ManifestTransactionDetail *product in self.currentProductInManifestList) {
        double productCount = product.productCountFloat;
        double productPrice = [product.productPrice doubleValue];
        double productDiscount = [product.productDiscount doubleValue];
        
        totalCost += productCount * productPrice * productDiscount;
    }
    
    return totalCost;
}

- (void)keyboardShow:(NSNotification *)note
{
    CGRect keyBoardRect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat deltaY = keyBoardRect.size.height;
    keyBoardHeight = deltaY;
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        inputView.transform = CGAffineTransformMakeTranslation(0, -deltaY - 44);
    }];
    JCHManifestMemoryStorage *storage = [JCHManifestMemoryStorage sharedInstance];
    inputView.textView.text = storage.currentManifestRemark;
}

- (void)keyboardHide:(NSNotification *)note
{
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        inputView.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {

    }];
}


#pragma mark - LoadData
- (void)loadData
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorage.currentManifestType == kJCHManifestMigrate) {
        id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
        NSArray *warehouseArray = [warehouseService queryAllWarehouse];
        NSMutableArray *enableWarehouseArray = [NSMutableArray array];
        for (WarehouseRecord4Cocoa *warehouseRecord in warehouseArray) {
            if (warehouseRecord.warehouseStatus == 0) {
                [enableWarehouseArray addObject:warehouseRecord];
            }
        }
        self.warehouseList = enableWarehouseArray;
    }
    
    // 将当前存储在MemoryStorage中的已添加到货单的中的商品数据更新到当前controller的数据源currentProductInManifestList中    
    NSArray *manifestArray = [[JCHManifestMemoryStorage sharedInstance] getAllManifestRecord];
    CGFloat totalManifestAmount = 0;
    if (manifestStorage.currentManifestType == kJCHManifestAssembling) {
        self.currentProductInManifestList = [self subSectionManifestArrayForAssembling:manifestArray];
    } else {
        self.currentProductInManifestList = [NSMutableArray arrayWithArray:manifestArray];
        totalManifestAmount = [self calculateTotalOrderCost];
    }
    
    
    // 更新header view
    JCHCreateManifestHeaderViewData *headerData = [[[JCHCreateManifestHeaderViewData alloc] init] autorelease];
    headerData.orderID = self.currentOrderListID;
    headerData.orderDate = self.currentOrderDate;

    [dateSelectView setData:headerData];
    
    // 更新footer view
#if !MMR_RESTAURANT_VERSION
    JCHCreateManifestFooterViewData *footerData = [[[JCHCreateManifestFooterViewData alloc] init] autorelease];
    footerData.totalPrice = [NSString stringWithFormat:@"%.2f", totalManifestAmount];
    footerData.remark = self.currentRemark;
    footerData.productCount = manifestArray.count;
    [defaultFooterView setData:footerData];
#else
    if (manifestStorage.currentManifestType == kJCHOrderShipment ||
        manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable) {
        [defaultFooterView setPeopleCount:manifestStorage.restaurantPeopleCount
                              totalAmount:totalManifestAmount];
    } else {
        JCHCreateManifestFooterViewData *footerData = [[[JCHCreateManifestFooterViewData alloc] init] autorelease];
        footerData.totalPrice = [NSString stringWithFormat:@"%.2f", totalManifestAmount];
        footerData.remark = self.currentRemark;
        footerData.productCount = manifestArray.count;
        [(JCHCreateManifestFooterView *)defaultFooterView setData:footerData];
    }
#endif
    
    // 更新table view
    [contentTableView reloadData];
    [self updateScanCodefooterViewData];
}

- (NSMutableArray *)subSectionManifestArrayForAssembling:(NSArray *)manifestArray
{
    // 根据ManifestTransactionDetail中的goodsNameUUID字段进行分组
    NSMutableSet *set = [NSMutableSet set];
    
    [manifestArray enumerateObjectsUsingBlock:^(ManifestTransactionDetail *detail, NSUInteger idx, BOOL * _Nonnull stop) {
        [set addObject:detail.goodsNameUUID];
    }];
 
    /*此时，set里面已经存储了可以分为组数*/
    
    //接下来需要用到NSPredicate语法进行筛选
    __block NSMutableArray *groupArr = [NSMutableArray array];
    [set enumerateObjectsUsingBlock:^(NSString * _Nonnull goodsNameUUID, BOOL * _Nonnull stop) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"goodsNameUUID = %@", goodsNameUUID];
        NSArray *tempArr = [NSArray arrayWithArray:[manifestArray filteredArrayUsingPredicate:predicate]];
        [groupArr addObject:tempArr];
    }];
    
    return groupArr;
}

#pragma mark - JCHInputViewDelegate

- (void)inputViewWillHide:(JCHInputView *)theInputView textView:(UITextView *)contentTextView
{
    //保存备注;
    self.currentRemark = contentTextView.text;
    JCHManifestMemoryStorage *storage = [JCHManifestMemoryStorage sharedInstance];
    storage.currentManifestRemark = self.currentRemark;
    
    [self loadData];
}

#pragma mark -
#pragma mark CreateOrderHeaderViewDelegate

- (void)handleChooseDate
{
    const CGFloat kUIDatePickerViewHeight = 240;
    CGRect pickerViewFrame = CGRectMake(0, 0, self.view.frame.size.width, kUIDatePickerViewHeight);
    datePickerView = [[[JCHDatePickerView alloc] initWithFrame:pickerViewFrame
                                                         title:@"请选择货单日期"] autorelease];
    datePickerView.delegate = self;
    datePickerView.datePickerMode = UIDatePickerModeDateAndTime;

    [datePickerView show];
}


#pragma mark - JCHAddProductSKUListViewDelegate

- (void)skuListView:(JCHAddProductSKUListView *)view labelTaped:(UILabel *)editLabel
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    ManifestTransactionDetail *transactionDetail = [skuListView.dataSource firstObject];
    NSInteger unit_digits = transactionDetail.productUnit_digits;
    
    if (editLabel.tag == kJCHAddProductSKUListTableViewCellCountLableTag) {
        keyboardView.unit_digits = unit_digits;
        NSString *countString = [editLabel.text stringByReplacingOccurrencesOfString:transactionDetail.productUnit withString:@""];
        keyboardView.isFirstEdit = YES;
        if (manifestStorage.currentManifestType == kJCHOrderShipment || manifestStorage.currentManifestType == kJCHOrderPurchases) {
            [keyboardView setEditText:countString editMode:kJCHSettleAccountsKeyboardViewEditModeCount];
        } else if (manifestStorage.currentManifestType == kJCHManifestInventory) {
            
        }
    } else if (editLabel.tag == kJCHAddProductSKUListTableViewCellPriceLableTag) {
        keyboardView.isFirstEdit = YES;
        if (manifestStorage.currentManifestType == kJCHOrderShipment || manifestStorage.currentManifestType == kJCHOrderPurchases) {
            [keyboardView setEditText:editLabel.text editMode:kJCHSettleAccountsKeyboardViewEditModePrice];
        } else if (manifestStorage.currentManifestType == kJCHManifestInventory) {
            //盘点单 kJCHAddProductSKUListTableViewCellPriceLableTag 表示的盘后数量
            NSString *countString = [editLabel.text stringByReplacingOccurrencesOfString:transactionDetail.productUnit withString:@""];
            [keyboardView setEditText:countString editMode:kJCHSettleAccountsKeyboardViewEditModeCount];
        }
    } else if (editLabel.tag == kJCHAddProductSKUListTableViewCellTotalAmountLableTag) {
        keyboardView.isFirstEdit = YES;
        if (manifestStorage.currentManifestType == kJCHOrderShipment || manifestStorage.currentManifestType == kJCHOrderPurchases) {
            [keyboardView setEditText:editLabel.text editMode:kJCHSettleAccountsKeyboardViewEditModeTotalAmount];
        } else if (manifestStorage.currentManifestType == kJCHManifestInventory) {
            [keyboardView setEditText:editLabel.text editMode:kJCHSettleAccountsKeyboardViewEditModePrice];
        }
    }
}

- (void)handleHideView:(JCHAddProductSKUListView *)view
{
    [keyboardView hide];
}

#pragma mark - JCHSettleAccountsKeyboardViewDelegate
- (NSString *)keyboardViewEditingChanged:(NSString *)editText
{
    if (keyboardView.editMode == kJCHSettleAccountsKeyboardViewEditModeDiscount) {
        //编辑折扣
        _discountEditingView.discountLabel.text = [editText stringByAppendingString:@"折"];
    } else {
        //编辑其它
        editText = [JCHAddProductChildViewController keyboardViewEditingChanged:editText
                                                                    skuListView:skuListView
                                                                   keyboardView:keyboardView];
    }
    return editText;
}

- (void)keyboardViewOKButtonClick
{
    if (keyboardView.editMode == kJCHSettleAccountsKeyboardViewEditModeDiscount) {
        //编辑折扣
        CGFloat discount =  [JCHTransactionUtility getOrderDiscountFromString:_discountEditingView.discountLabel.text];
        self.currentDiscountEditingDetail.productDiscount = [NSString stringWithFormat:@"%.2f", discount];
    } else {
        //编辑其它
        [JCHAddProductChildViewController keyboardViewOKButtonClick:skuListView];
    }
    
    [self loadData];
    [keyboardView hide];
}


#pragma mark - JCHDatePickerViewDelegate
- (void)handleDatePickerViewDidHide:(JCHDatePickerView *)datePicker selectedDate:(NSDate *)selectedDate;
{
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *selectedDateString = [dateFormater stringFromDate:selectedDate];
    [dateSelectView setOrderDate:selectedDateString];
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    manifestStorage.currentManifestDate = selectedDateString;
    
    self.currentOrderDate = selectedDateString;
    
    return;
}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return kJCHPickerViewRowHeight;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    WarehouseRecord4Cocoa *warehouseRecord = self.warehouseList[row];
    return warehouseRecord.warehouseName;
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.warehouseList.count;
}

- (void)pickerViewWillHide:(JCHPickerView *)pickerView
{
    NSInteger selecetedRow = [pickerView.pickerView selectedRowInComponent:0];
    self.destinationWarehouseRecord = self.warehouseList[selecetedRow];
    warehouseSelectView.destinationWarehouse = self.destinationWarehouseRecord.warehouseName;
}

#pragma mark -
#pragma mark JCHRestaurantDishDetailFooterViewDelegate

- (void)handleRestaurantAddDish
{
    [self handleAddProduct];
}

- (void)handleRestaurantFinish
{
    [self handleClickSaveOrderList];
}

@end
