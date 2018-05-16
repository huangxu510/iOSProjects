//
//  JCHAddProcductMainViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/8.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHAddProductMainViewController.h"
#import "JCHAddProductRecordViewController.h"
#import "JCHMenuView.h"
#import "JCHTitleArrowButton.h"
#import "JCHAddProductSearchViewController.h"
#import "JCHAddProductCategorySelectView.h"
#import "JCHAddProductByScanCodeViewController.h"
#import "JCHInputView.h"
#import "JCHSearchBar.h"
#import "JCHSettleAccountsViewController.h"
#import "JCHCreateManifestViewController.h"
#import "JCHAddProductChildViewController.h"
#import "JCHAddProductFooterView.h"
#import "JCHAddProductTitleLabel.h"
#import "JCHRestaurantManifestUtility.h"
#import "JCHAddProductShoppingCartListView.h"
#import "ServiceFactory.h"
#import "JCHManifestMemoryStorage.h"
#import "UIView+JCHView.h"
#import "CommonHeader.h"
#import "JCHPinYinUtility.h"
#import <Masonry.h>


@implementation ManifestTransactionDetail

- (id)init
{
    self = [super init];
    if (self) {
        // pass
        self.productPrice = @"0.00";
        self.productCount = @"0";
        self.productDiscount = @"1";
        self.productInventoryCount = @"0";
        self.averagePriceBefore = @"0.00";
    }
    
    return self;
}

- (void)dealloc
{
    [self.productCategory release];
    [self.productImageName release];
    [self.productName release];
    [self.productUnit release];
    [self.productPrice release];
    [self.productCount release];
    [self.productTotalAmount release];
    [self.productDiscount release];
    [self.productInventoryCount release];
    [self.warehouseUUID release];
    [self.transactionUUID release];
    [self.unitUUID release];
    [self.goodsNameUUID release];
    [self.goodsCategoryUUID release];
    [self.skuValueUUIDs release];
    [self.skuValueCombine release];
    [self.averagePriceBefore release];
    [self.dishProperty release];
    
    [super dealloc];
    return;
}

- (void)setProductCount:(NSString *)productCount
{
    if (_productCount != productCount) {
        [_productCount release];
        _productCount = [productCount retain];
        
        _productCountFloat = _productCount.doubleValue;
    }
}

- (void)setProductCountFloat:(CGFloat)productCountFloat
{
    //商品数量保留4位小数
    _productCountFloat = [JCHFinanceCalculateUtility roundDownFloatNumber:productCountFloat scale:4];
    _productCount = [[NSString stringFromCount:_productCountFloat unitDigital:self.productUnit_digits] retain];
}

@end


@interface JCHAddProductMainViewController () <JCHAddProductFooterViewDelegate,
                                                UIScrollViewDelegate,
                                                JCHSearchBarDelegate,
                                                JCHInputViewDelegate,
                                                JCHMenuViewDelegate>
{
    JCHTitleArrowButton *_titleButton;
    JCHAddProductCategorySelectView *_categorySelectView;
    UIScrollView *_bigScrollView;
    UIButton *_searchButton;
    UIButton *_switchStyleButton;
    
    JCHAddProductFooterView *_footerView;
    

    JCHPlaceholderView *_placeholderView;
    UIButton *_goToAddProductButton;
    
    JCHInputView *_inputView;
}

//! @brief 左边分类列表的分类名称数组
// NSArray<分类名称>
@property (retain, nonatomic, readwrite) NSMutableArray *productCategoryList;

//! @brief 左边的分类名称数组以及对应的右边的属于左边分类的商品列表
// NSDictionary<分类名称，NSArray<ProductRecord4Cococa> >
@property (retain, nonatomic, readwrite) NSMutableDictionary *productCategoryToProductListMap;

//! @brief @{productNameUUID_productUnitUUID : InventoryDetailRecord4Cocoa, @{productNameUUID : @[InvenyoryDetailRecord4Cocoa, ...]}}
@property (retain, nonatomic, readwrite) NSMutableDictionary *inventoryMap;


@property (retain, nonatomic, readwrite) NSArray *allProduct;

//! @brief 保存所有的goodsSKURecord
@property (retain, nonatomic, readwrite) NSArray *allGoodsSKURecordArray;

@property (retain, nonatomic, readwrite) JCHAddProductChildViewController *currentChildViewController;


//! @brief 仓库列表
@property (retain, nonatomic, readwrite) NSArray *warehouseList;

@property (retain, nonatomic, readwrite) NSArray *defaultRightBarButtonItems;

@end

@implementation JCHAddProductMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createNavigationBarItem];
}

- (id)init
{
    self = [super init];
    if (self) {

    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self updateFooterViewData:NO];
    
    if (self.isNeedReloadAllData) {
        [self loadData];
        self.isNeedReloadAllData = NO;
    }
    
    //盘点单、移库单、拆拼装单，当从下个页面返回要刷新当前的controller
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorage.currentManifestType == kJCHManifestInventory ||
        manifestStorage.currentManifestType == kJCHManifestMigrate ||
        manifestStorage.currentManifestType == kJCHManifestAssembling ||
        manifestStorage.currentManifestType == kJCHManifestDismounting) {
        [self.currentChildViewController reloadData:NO];
    }
    return;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)dealloc
{
    [self.productCategoryList release];
    [self.productCategoryToProductListMap release];
    [self.inventoryMap release];
    [self.allProduct release];
    [self.allGoodsSKURecordArray release];
    [self.currentChildViewController release];
    self.warehouseList = nil;
    self.defaultRightBarButtonItems = nil;
    
    [JCHNotificationCenter removeObserver:self];
    
    [super dealloc];
}

- (void)createNavigationBarItem
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    self.navigationController.navigationItem.rightBarButtonItem = nil;
    
#if !MMR_RESTAURANT_VERSION
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
    WarehouseRecord4Cocoa *warehouseRecord = [warehouseService queryWarehouseByUUID:manifestStorage.warehouseID];
    _titleButton = [JCHTitleArrowButton buttonWithType:UIButtonTypeCustom];
    _titleButton.frame = CGRectMake(0, 0, 40, 50);
    _titleButton.autoReverseArrow = YES;
    _titleButton.autoAdjustButtonWidth = YES;
    _titleButton.maxWidth = 100;
    [_titleButton setImage:[UIImage imageNamed:@"homepage_storename_open"] forState:UIControlStateNormal];
    _titleButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [_titleButton setTitle:warehouseRecord.warehouseName forState:UIControlStateNormal];
    [_titleButton addTarget:self action:@selector(handleShowWarehouseSelectMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = _titleButton;
    
#else
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorage.currentManifestType == kJCHOrderShipment) {
        self.navigationItem.title = @"点菜";
    } else {
        self.navigationItem.title = @"采购";
    }
#endif
    

#if !MMR_RESTAURANT_VERSION
    UIButton *scanButton = [JCHUIFactory createButton:CGRectMake(0, 0, 30, 44)
                                               target:self
                                               action:@selector(handleScanCode)
                                                title:nil
                                           titleColor:nil
                                      backgroundColor:nil];
    [scanButton setImage:[UIImage imageNamed:@"nav_ic_homepage_scan"] forState:UIControlStateNormal];
    scanButton.adjustsImageWhenHighlighted = NO;
    UIBarButtonItem *scanBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:scanButton] autorelease];
#endif
    
    UIButton *searchButton = [JCHUIFactory createButton:CGRectMake(0, 0, 30, 44)
                                                 target:self
                                                 action:@selector(searchProduct:)
                                                  title:@""
                                             titleColor:nil
                                        backgroundColor:nil];
    [searchButton setImage:[UIImage imageNamed:@"nav_ic_homepage_search"] forState:UIControlStateNormal];
    searchButton.adjustsImageWhenHighlighted = NO;
    UIBarButtonItem *searchBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:searchButton] autorelease];
    
    
    _switchStyleButton = [JCHUIFactory createButton:CGRectMake(0, 0, 30, 44)
                                             target:self
                                             action:@selector(switchStyle:)
                                              title:@""
                                         titleColor:nil
                                    backgroundColor:nil];
    [_switchStyleButton setImage:[UIImage imageNamed:@"nav_ic_switch_topmenu"] forState:UIControlStateNormal];
    [_switchStyleButton setImage:[UIImage imageNamed:@"nav_ic_switch_leftmenu"] forState:UIControlStateSelected];
    _switchStyleButton.adjustsImageWhenHighlighted = NO;
    UIBarButtonItem *switchStyleBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:_switchStyleButton] autorelease];
    
    UIBarButtonItem *flexSpacer = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:self
                                                                                action:nil] autorelease];
    flexSpacer.width = -10;
    
#if !MMR_RESTAURANT_VERSION
    self.navigationItem.rightBarButtonItems = @[flexSpacer, scanBarButtonItem, searchBarButtonItem, switchStyleBarButtonItem];
#else
    self.navigationItem.rightBarButtonItems = @[flexSpacer, searchBarButtonItem, switchStyleBarButtonItem];
#endif
    self.defaultRightBarButtonItems = self.navigationItem.rightBarButtonItems;
    
#if MMR_TAKEOUT_VERSION
    _titleButton.arrowHidden = YES;
    [_titleButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
#endif
}

- (void)createUI
{
    if (self.allProduct.count == 0) {
        self.navigationItem.rightBarButtonItems = nil;
    } else {
        self.navigationItem.rightBarButtonItems = self.defaultRightBarButtonItems;
    }
    NSInteger addProductListStyle = [JCHUserDefaults integerForKey:kAddProductListUIStyleKey];
    if (addProductListStyle == 0) {
        _switchStyleButton.selected = YES;
        [self switchStyle:_switchStyleButton];
    } else {
        _switchStyleButton.selected = NO;
        [self switchStyle:_switchStyleButton];
    }
}


- (void)createDefaultUI
{
    CGFloat smallScrollViewHeight = 40.0f;
    
    _categorySelectView = [[[JCHAddProductCategorySelectView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, smallScrollViewHeight) dataSource:self.productCategoryList] autorelease];
    [self.view addSubview:_categorySelectView];
    WeakSelf;
    [_categorySelectView setTitleLabelClickAction:^(NSInteger labelTag) {
        [weakSelf titleLabelClickAction:labelTag];
    }];
    
    CGFloat contentX = self.productCategoryList.count * kScreenWidth;
    _bigScrollView = [[[UIScrollView alloc] initWithFrame:CGRectZero] autorelease];
    _bigScrollView.contentSize = CGSizeMake(contentX, 0);
    _bigScrollView.pagingEnabled = YES;
    _bigScrollView.showsHorizontalScrollIndicator = NO;
    _bigScrollView.delegate = self;
    _bigScrollView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_bigScrollView];
    
    [_bigScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(smallScrollViewHeight);
        make.bottom.equalTo(self.view).with.offset(-kTabBarHeight);
    }];
    
    
    [self addController];
    
    
    
    if (self.childViewControllers.count > 0) {
        JCHAddProductChildViewController *childVC = self.childViewControllers[0];
        [_bigScrollView addSubview:childVC.view];
    }
    
    CGFloat footerViewHeight = 49;
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
    
    
    _placeholderView = [[[JCHPlaceholderView alloc] initWithFrame:CGRectZero] autorelease];
    _placeholderView.hidden = YES;
    _placeholderView.imageView.image = [UIImage imageNamed:@"default_goods_placeholder"];
    _placeholderView.label.text = @"打理生意从添加分类和商品开始...";
    [self.view addSubview:_placeholderView];
    
    [_placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(158);
        make.width.mas_equalTo(kScreenWidth);
        make.centerY.equalTo(self.view).with.offset(-40);
    }];
    
    CGFloat goToAddProductButtonHeight = 44;
    CGFloat goToAddProductButtonWidth = 105;
    
    _goToAddProductButton = [JCHUIFactory createButton:CGRectZero
                                                target:self
                                                action:@selector(handleGoToAddProduct)
                                                 title:@"+立即添加"
                                            titleColor:JCHColorHeaderBackground
                                       backgroundColor:[UIColor whiteColor]];
    _goToAddProductButton.layer.borderWidth = kSeparateLineWidth;
    _goToAddProductButton.layer.borderColor = JCHColorSeparateLine.CGColor;
    _goToAddProductButton.layer.cornerRadius = 2.0f;
    [self.view addSubview:_goToAddProductButton];
    
    [_goToAddProductButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_placeholderView.mas_bottom).with.offset(10);
        make.height.mas_equalTo(goToAddProductButtonHeight);
        make.width.mas_equalTo(goToAddProductButtonWidth);
        make.centerX.equalTo(self.view);
    }];
    
    if (self.allProduct.count == 0) {
        for (UIView *subView in self.view.subviews) {
            subView.hidden = YES;
        }
        _placeholderView.hidden = NO;
        _goToAddProductButton.hidden = NO;
    } else  {
        _placeholderView.hidden = YES;
        _goToAddProductButton.hidden = YES;
    }
    
    if ([[JCHSyncStatusManager shareInstance] isShopManager] == NO) {
        _goToAddProductButton.hidden = YES;
    }

}

- (void)addController
{
    for (NSInteger i = 0; i < self.productCategoryList.count; i++) {
        JCHAddProductChildViewController *childVC = [[[JCHAddProductChildViewController alloc] initWithType:kJCHAddProductChildViewControllerTypeDefault] autorelease];
        NSString *selectedCategory = self.productCategoryList[i];
        
        childVC.selectCategory = selectedCategory;
        childVC.categoryList = self.productCategoryList;
        childVC.productCategoryToProductListMap = self.productCategoryToProductListMap;
        childVC.inventoryMap = self.inventoryMap;
        childVC.allGoodsSKURecordArray = self.allGoodsSKURecordArray;
        
        [self addChildViewController:childVC];
    }
    self.currentChildViewController = [self.childViewControllers firstObject];
}

- (void)handleShowWarehouseSelectMenu:(UIButton *)sender
{
    sender.selected = !sender.selected;
    CGFloat menuViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:120];
    CGFloat maxHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:200];
    
    NSMutableArray *titles = [NSMutableArray array];
    for (WarehouseRecord4Cocoa *warehouseRecord in self.warehouseList) {
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

- (void)handlePopAction
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeNew) {
        
        if ([[manifestStorage getAllManifestRecord] count] > 0) {
            
            NSString *message = nil;
            if (manifestStorage.currentManifestType == kJCHOrderShipment) {
                message = @"有未保存的出货商品，是否确定退出？";
            } else if (manifestStorage.currentManifestType == kJCHOrderPurchases) {
                message = @"有未保存的进货商品，是否确定退出？";
            } else if (manifestStorage.currentManifestType == kJCHManifestInventory) {
                message = @"有未保存的盘点商品，是否确定退出？";
            } else if (manifestStorage.currentManifestType == kJCHManifestMigrate){
                message = @"有未保存的移库商品，是否确定退出？";
            } else if (manifestStorage.currentManifestType == kJCHManifestDismounting) {
                message = @"有未保存的拆装商品，是否确定退出？";
            } else if (manifestStorage.currentManifestType == kJCHManifestAssembling) {
                message = @"有未保存的拼装商品，是否确定退出？";
            } else {
                message = @"有未保存商品，是否确定退出？";
            }
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }];
            UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertController addAction:alertAction];
            [alertController addAction:cancleAction];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 切换列表样式
- (void)switchStyle:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    
    if (sender.selected) {
        [self createLeftListUI];
    } else {
        [self createDefaultUI];
    }
    
    [JCHUserDefaults setInteger:sender.selected forKey:kAddProductListUIStyleKey];
    [JCHUserDefaults synchronize];
}

- (void)createLeftListUI
{
    JCHAddProductChildViewController *childVC = [[[JCHAddProductChildViewController alloc] initWithType:kJCHAddProductChildViewControllerTypeLeftMenu] autorelease];
    childVC.categoryList = self.productCategoryList;
    childVC.productCategoryToProductListMap = self.productCategoryToProductListMap;
    childVC.inventoryMap = self.inventoryMap;
    childVC.allGoodsSKURecordArray = self.allGoodsSKURecordArray;
    [self addChildViewController:childVC];
    [self.view addSubview:childVC.view];
    self.currentChildViewController = childVC;
    
    CGFloat footerViewHeight = 49;
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
    
    _placeholderView = [[[JCHPlaceholderView alloc] initWithFrame:CGRectZero] autorelease];
    _placeholderView.hidden = YES;
    _placeholderView.imageView.image = [UIImage imageNamed:@"default_goods_placeholder"];
    _placeholderView.label.text = @"打理生意从添加分类和商品开始...";
    [self.view addSubview:_placeholderView];
    
    [_placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(158);
        make.width.mas_equalTo(kScreenWidth);
        make.centerY.equalTo(self.view).with.offset(-40);
    }];
    
    CGFloat goToAddProductButtonHeight = 44;
    CGFloat goToAddProductButtonWidth = 105;
    
    _goToAddProductButton = [JCHUIFactory createButton:CGRectZero
                                                target:self
                                                action:@selector(handleGoToAddProduct)
                                                 title:@"+立即添加"
                                            titleColor:JCHColorHeaderBackground
                                       backgroundColor:[UIColor whiteColor]];
    _goToAddProductButton.layer.borderWidth = kSeparateLineWidth;
    _goToAddProductButton.layer.borderColor = JCHColorSeparateLine.CGColor;
    _goToAddProductButton.layer.cornerRadius = 2.0f;
    [self.view addSubview:_goToAddProductButton];
    
    [_goToAddProductButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_placeholderView.mas_bottom).with.offset(10);
        make.height.mas_equalTo(goToAddProductButtonHeight);
        make.width.mas_equalTo(goToAddProductButtonWidth);
        make.centerX.equalTo(self.view);
    }];
    
    if (self.allProduct.count == 0) {
        for (UIView *subView in self.view.subviews) {
            subView.hidden = YES;
        }
        _placeholderView.hidden = NO;
        _goToAddProductButton.hidden = NO;
        childVC.view.hidden = YES;
    } else  {
        _placeholderView.hidden = YES;
        _goToAddProductButton.hidden = YES;
        childVC.view.hidden = NO;
    }
    
    if ([[JCHSyncStatusManager shareInstance] isShopManager] == NO) {
        _goToAddProductButton.hidden = YES;
    }
}


- (void)searchProduct:(UIButton *)sender
{
    JCHAddProductSearchViewController *searchVC = [[[JCHAddProductSearchViewController alloc] initWithAllProduct:self.allProduct inventoryMap:self.inventoryMap] autorelease];
    WeakSelf;
    [searchVC setCallBackBlock:^(ProductRecord4Cocoa *productRecord, NSString *unitUUID) {
        [weakSelf switchToProduct:productRecord unitUUID:unitUUID];
    }];
    [self.navigationController pushViewController:searchVC animated:YES];
}

- (void)titleLabelClickAction:(NSInteger)labelTag
{
    CGFloat offsetX = labelTag * kScreenWidth;
    [_bigScrollView setContentOffset:CGPointMake(offsetX, 0) animated:NO];
    
    JCHAddProductChildViewController *childVC = self.childViewControllers[labelTag];
    self.currentChildViewController = childVC;
    childVC.view.frame = _bigScrollView.bounds;
    [childVC reloadData:NO];
    if (![_bigScrollView.subviews containsObject:childVC.view]) {
        [_bigScrollView addSubview:childVC.view];
    }
}

- (void)updateFooterViewData:(BOOL)animation
{
    //! @todo 收集当前用户添加的商品列表
    CGFloat totalAmount = 0.0f;

    JCHManifestMemoryStorage *storage = [JCHManifestMemoryStorage sharedInstance];
    NSArray *transactionList = [storage getAllManifestRecord];
    
    NSUInteger totalCount = 0;
    for (ManifestTransactionDetail * detail in transactionList) {
        CGFloat price = [detail.productPrice doubleValue];
        CGFloat count = detail.productCountFloat;
        CGFloat amount = price * count;
        totalAmount += amount;
        totalCount += detail.productCountFloat;
    }
    
    
    JCHAddProductFooterViewData *viewData = [[[JCHAddProductFooterViewData alloc] init] autorelease];
    viewData.productAmount = [NSString stringWithFormat:@"%.2f", totalAmount];
#if MMR_TAKEOUT_VERSION
    viewData.transactionCount = totalCount;
#else
    viewData.transactionCount = transactionList.count;
#endif
    
    viewData.remark = storage.currentManifestRemark;
    [_footerView setViewData:viewData animation:animation];
    
    return;
}

- (void)handleGoToAddProduct
{
//    self.navigationController.tabBarController.selectedIndex = 4;
//    [self.navigationController popViewControllerAnimated:NO];
    JCHAddProductRecordViewController *addProductRecordVC = [[[JCHAddProductRecordViewController alloc] initWithProductRecord:nil] autorelease];
    self.isNeedReloadAllData = YES;
    [self.navigationController pushViewController:addProductRecordVC animated:YES];
}

#pragma mark - 扫码开单
- (void)handleScanCode
{
    JCHAddProductByScanCodeViewController *scanCodeViewController = [[[JCHAddProductByScanCodeViewController alloc] initWithAllProducts:self.allProduct] autorelease];
    scanCodeViewController.inventoryMap = self.inventoryMap;
    WeakSelf;
    [scanCodeViewController setCallBackBlock:^(ProductRecord4Cocoa *productRecord) {
        [weakSelf switchToProduct:productRecord unitUUID:nil];
    }];
    [self.navigationController pushViewController:scanCodeViewController animated:YES];
}

//当扫码扫到的商品是多规格商品时，跳转到该商品
- (void)switchToProduct:(ProductRecord4Cocoa *)productRecord unitUUID:(NSString *)unitUUID
{
    //NSArray *productInCategory = self.productCategoryToProductListMap[productRecord.goods_type];
    NSArray *childViewControllers = self.childViewControllers;
    
    NSInteger addProductListStyle = [JCHUserDefaults integerForKey:kAddProductListUIStyleKey];
    if (addProductListStyle == kJCHAddProductChildViewControllerTypeDefault) {
        for (JCHAddProductChildViewController *childViewController in childViewControllers) {
            if ([childViewController isKindOfClass:[JCHAddProductChildViewController class]]) {
                if ([childViewController.selectCategory isEqualToString:productRecord.goods_type]) {
                    NSInteger index = [self.childViewControllers indexOfObject:childViewController];
                    [_categorySelectView handleTitleLabelClick:index];
                    [childViewController expandProduct:productRecord unitUUID:unitUUID];
                }
            }
        }
    } else {
        JCHAddProductChildViewController *childViewController = [childViewControllers firstObject];
        [childViewController expandProduct:productRecord unitUUID:unitUUID];
    }
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
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
#if MMR_RESTAURANT_VERSION || MMR_TAKEOUT_VERSION
        // 餐饮版
        NSArray *allProduct = nil;
        if (manifestStorage.currentManifestType == kJCHOrderShipment) {
            allProduct = [productService queryAllCuisine:NO];
        } else {
            allProduct = [productService queryAllProduct];
        }
#else
        // 通用版
        NSArray *allProduct = [productService queryAllProduct];
#endif
        NSArray *allGoodsSKURecordArray = nil;
        [skuService queryAllGoodsSKU:&allGoodsSKURecordArray];
        
        self.allGoodsSKURecordArray = allGoodsSKURecordArray;
        
        for (ProductRecord4Cocoa *record in allProduct){
            record.productNamePinYin = [JCHPinYinUtility getFirstPinYinLetterForProductName:record.goods_name];
        }
        
        // 2) 创建用于初始化TableView的数据
        self.productCategoryList = [[[NSMutableArray alloc] init] autorelease];
        self.productCategoryToProductListMap = [[[NSMutableDictionary alloc] init] autorelease];
        self.inventoryMap = [NSMutableDictionary dictionary];
        
        
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
            self.allProduct = mainAuxiliaryUnitProductList;
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
            
            self.allProduct = allProductForInventoryManifest;
            
            NSArray *inventoryRecordForProduct = [self subSectionInventoryArrayForProduct:inventoryList];
            for (NSArray *arr in inventoryRecordForProduct) {
                InventoryDetailRecord4Cocoa *record = [arr firstObject];
                [self.inventoryMap setObject:arr forKey:record.productNameUUID];
            }
            
        } else {
            self.allProduct = allProduct;
        }
        
    
        NSArray *allCategory = [categoryService queryAllCategory];
        
        for (CategoryRecord4Cocoa *categoryRecord in allCategory) {
            [self.productCategoryList addObject:categoryRecord.categoryName];
            NSMutableArray *productInCategory = [self.productCategoryToProductListMap objectForKey:categoryRecord.categoryName];
            if (nil == productInCategory) {
                productInCategory = [[[NSMutableArray alloc] init] autorelease];
                [self.productCategoryToProductListMap setObject:productInCategory forKey:categoryRecord.categoryName];
            }
            
            for (ProductRecord4Cocoa *productReceord in self.allProduct) {
                if ([productReceord.goods_type isEqualToString:categoryRecord.categoryName] && productReceord.goods_hiden_flag == NO) {
                    [productInCategory addObject:productReceord];
                }
            }
            
            if (productInCategory.count == 0) {
                [self.productCategoryToProductListMap removeObjectForKey:categoryRecord.categoryName];
                [self.productCategoryList removeObject:categoryRecord.categoryName];
            }
        }
        NSArray *warehouseArray = [warehouseService queryAllWarehouse];
        
        NSMutableArray *enableWarehouseArray = [NSMutableArray array];
        for (WarehouseRecord4Cocoa *warehouseRecord in warehouseArray) {
            if (warehouseRecord.warehouseStatus == 0) {
                [enableWarehouseArray addObject:warehouseRecord];
            }
        }
        self.warehouseList = enableWarehouseArray;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self createUI];
            [self updateFooterViewData:NO];
            [MBProgressHUD hideHUDForView:self.view animated:NO];
            
            // 在UI界面创建完之后在异步加载库存信息
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSArray *inventoryList = [calculateService calculateAllInventory:manifestStorage.warehouseID];
                for (InventoryDetailRecord4Cocoa *record in inventoryList) {
                    NSString *key = [NSString stringWithFormat:@"%@_%@", record.productNameUUID, record.productUnitUUID];
                    [self.inventoryMap setObject:record forKey:key];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSArray *childViewControllers = self.childViewControllers;
                    for (JCHAddProductChildViewController *childViewController in childViewControllers) {
                        if ([childViewController isKindOfClass:[JCHAddProductChildViewController class]]) {
                            childViewController.inventoryMap = self.inventoryMap;
                            [childViewController reloadData:NO];
                        }
                    }
                });
            });
        });
    });

    return;
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


#pragma mark - UIScrollViewDelegate

//滚动结束（手势导致)
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = (NSInteger)(scrollView.contentOffset.x / kScreenWidth);
    JCHAddProductChildViewController *childVC = self.childViewControllers[index];
    self.currentChildViewController = childVC;
    
    childVC.view.frame = scrollView.bounds;
    [childVC reloadData:NO];
    if (![_bigScrollView.subviews containsObject:childVC.view]) {
        [_bigScrollView addSubview:childVC.view];
    }
}

//正在滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

    // 取出绝对值 避免最左边往右拉时形变超过1
    CGFloat value = ABS(scrollView.contentOffset.x / scrollView.frame.size.width);

    //当setContentOffset animation:NO 时 自己做渐变效果
    if (scrollView.decelerating || scrollView.dragging) {

        //leftLabel.scale = scaleLeft;
        [_categorySelectView setTitleLabelScale:value];
    }
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
    
#if 0
    // 4) 将用户所添加的商品依据添加的时间来进行排序
    NSArray *sortedArray = [transactionList sortedArrayUsingComparator:^NSComparisonResult(ManifestTransactionDetail *first,
                                                                                       ManifestTransactionDetail *second) {
        return first.productAddedTimestamp < second.productAddedTimestamp;
    }];
#endif

    if (storage.manifestMemoryType == kJCHManifestMemoryTypeNew) {
        JCHCreateManifestViewController *manifestViewController = [[[JCHCreateManifestViewController alloc] init] autorelease];
        [self.navigationController pushViewController:manifestViewController animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    return;
}

- (void)handleClickSaveOrderList
{
#if !MMR_RESTAURANT_VERSION
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorage.currentManifestType == kJCHOrderPurchases || manifestStorage.currentManifestType == kJCHOrderShipment || manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable) {
        JCHSettleAccountsViewController *settleAccountsVC = [[[JCHSettleAccountsViewController alloc] init] autorelease];
        [self.navigationController pushViewController:settleAccountsVC animated:YES];
    } else if (manifestStorage.currentManifestType == kJCHManifestInventory || manifestStorage.currentManifestType == kJCHManifestMigrate || manifestStorage.currentManifestType == kJCHManifestAssembling || manifestStorage.currentManifestType == kJCHManifestDismounting) {
        JCHCreateManifestViewController *manifestViewController = [[[JCHCreateManifestViewController alloc] init] autorelease];
        manifestViewController.inventoryMap = self.inventoryMap;
        [self.navigationController pushViewController:manifestViewController animated:YES];
    }
#else
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorage.currentManifestType == kJCHOrderPurchases) {
        JCHSettleAccountsViewController *settleAccountsVC = [[[JCHSettleAccountsViewController alloc] init] autorelease];
        [self.navigationController pushViewController:settleAccountsVC animated:YES];
    } else if (manifestStorage.currentManifestType == kJCHOrderShipment ||
               manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable) {
        [self saveOrderList];
    }
#endif
}

#pragma mark -
#pragma mark 编辑备注
- (void)handleEditRemark
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    

    _inputView = [[[JCHInputView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 44)] autorelease];
    
    _inputView.delegate = self;
    [_inputView show];
}


- (void)keyboardShow:(NSNotification *)note
{
    CGRect keyBoardRect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat deltaY = keyBoardRect.size.height;
    //keyBoardHeight = deltaY;
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        _inputView.transform = CGAffineTransformMakeTranslation(0, -deltaY - 44);
    }];
    JCHManifestMemoryStorage *storage = [JCHManifestMemoryStorage sharedInstance];
    _inputView.textView.text = storage.currentManifestRemark;
}

- (void)keyboardHide:(NSNotification *)note
{
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        _inputView.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [JCHNotificationCenter removeObserver:self];
    }];
}

#pragma mark - JCHInputViewDelegate

- (void)inputViewWillHide:(JCHInputView *)inputView textView:(UITextView *)contentTextView
{
    //保存备注;
    //currentRemark = [contentTextView.text retain];
    JCHManifestMemoryStorage *storage = [JCHManifestMemoryStorage sharedInstance];
    storage.currentManifestRemark = contentTextView.text;
    
    [self updateFooterViewData:NO];
}

#pragma mark - JCHMenuViewDelegate

- (void)menuItemDidSelected:(JCHMenuView *)menuView indexPath:(NSIndexPath*)indexPath
{
    WarehouseRecord4Cocoa *warehouseRecord = self.warehouseList[indexPath.row];
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    if ([manifestStorage.warehouseID isEqualToString:warehouseRecord.warehouseID]) {
        return;
    } else {
        
        NSArray *manifestTransactionArray = [manifestStorage getAllManifestRecord];
        
        if (manifestTransactionArray.count > 0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"切换仓库将清空已添加的商品，\n是否切换？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [manifestStorage removeAllManifestRecords];
                manifestStorage.warehouseID = [NSString stringWithFormat:@"%@", warehouseRecord.warehouseID];
                [_titleButton setTitle:warehouseRecord.warehouseName forState:UIControlStateNormal];
                [self loadData];
            }];
            UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertController addAction:alertAction];
            [alertController addAction:cancleAction];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            manifestStorage.warehouseID = [NSString stringWithFormat:@"%@", warehouseRecord.warehouseID];
            [_titleButton setTitle:warehouseRecord.warehouseName forState:UIControlStateNormal];
            [self loadData];
        }
    }
}

- (void)menuViewDidHide
{
    _titleButton.selected = NO;
}


- (void)saveOrderList
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


@end

