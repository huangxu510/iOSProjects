//
//  JCHAddProductComponentViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/8.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHAddProductChildViewController.h"
#import "JCHAddProductForRestaurantTableViewCell.h"
#import "JCHCategoryListTableViewCell.h"
#import "JCHAddProductMainViewController.h"
#import "ProductRecord4Cocoa.h"
#import "JCHImageUtility.h"
#import "JCHSizeUtility.h"
#import "SKUService.h"
#import "JCHUISettings.h"
#import "ServiceFactory.h"
#import "JCHManifestMemoryStorage.h"
#import "JCHTransactionUtility.h"
#import "NSString+JCHString.h"
#import "JCHRestaurantSKUItemView.h"
#import <Masonry.h>
#import <KLCPopup.h>
#import "CommonHeader.h"

@interface JCHAddProductChildViewController () <UITableViewDataSource, UITableViewDelegate, JCHAddProductTableViewCellDelegate, JCHAddProductSKUListViewDelegate, JCHSettleAccountsKeyboardViewDelegate, JCHRestaurantSKUItemViewDelegate, JCHAddProductForRestaurantTableViewCellDelegate>
{
    UITableView *_leftTableView;
    UITableView *_contentTableView;
    JCHAddProductSKUListView *_skuListView;
    
    JCHSettleAccountsKeyboardView *_keyboardView;
    
    JCHAddProductChildViewControllerType _currentType;
}

@property (nonatomic, retain) NSMutableDictionary *heightForRow;
@property (nonatomic, retain) NSMutableDictionary *pullDownButtonStausForRow;
@property (nonatomic, retain) NSIndexPath *currentEditingIndexPath;  //记录当前正在编辑的indexPath

@property (nonatomic, retain) NSArray *productRecordInCategory;

//缓存
@property (nonatomic, retain) NSMutableDictionary *productItemRecordForUnitCache;
@property (nonatomic, retain) NSMutableDictionary *productItemRecordForSKUCache;
@property (nonatomic, retain) NSMutableDictionary *goodsSKURecord4CocoaCache;

@end

@implementation JCHAddProductChildViewController

- (instancetype)initWithType:(JCHAddProductChildViewControllerType)type
{
    self = [super init];
    if (self) {
        _currentType = type;
        self.heightForRow = [NSMutableDictionary dictionary];
        self.pullDownButtonStausForRow = [NSMutableDictionary dictionary];
        self.productItemRecordForSKUCache = [NSMutableDictionary dictionary];
        self.productItemRecordForUnitCache = [NSMutableDictionary dictionary];
        self.goodsSKURecord4CocoaCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    [self.productRecordInCategory release];
    [self.heightForRow release];
    [self.pullDownButtonStausForRow release];
    [self.inventoryMap release];
    [self.currentEditingIndexPath release];
    [self.allGoodsSKURecordArray release];
    [self.categoryList release];
    [self.productCategoryToProductListMap release];
    [self.selectCategory release];
    [self.productItemRecordForUnitCache release];
    [self.productItemRecordForSKUCache release];
    [self.goodsSKURecord4CocoaCache release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_currentType == kJCHAddProductChildViewControllerTypeDefault) {
        _contentTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kTabBarHeight - 40 - 64) style:UITableViewStylePlain] autorelease];
        _contentTableView.delegate = self;
        _contentTableView.dataSource = self;
        _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_contentTableView];
    } else if (_currentType == kJCHAddProductChildViewControllerTypeLeftMenu) {
        
        CGFloat leftTableViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:73.0f];
        _leftTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
        _leftTableView.dataSource = self;
        _leftTableView.delegate = self;
        _leftTableView.backgroundColor = JCHColorGlobalBackground;
        _leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _leftTableView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_leftTableView];
        
        [_leftTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.view);
            make.height.mas_equalTo(kScreenHeight - kTabBarHeight - 64);
            make.width.mas_equalTo(leftTableViewWidth);
        }];
        
        _contentTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kTabBarHeight - 40 - 64) style:UITableViewStylePlain] autorelease];
        _contentTableView.delegate = self;
        _contentTableView.dataSource = self;
        _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_contentTableView];
        
        [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_leftTableView.mas_right);
            make.top.right.equalTo(self.view);
            make.height.equalTo(_leftTableView);
        }];
    }
    
    if (self.categoryList.count > 0) {
        
        if (_currentType == kJCHAddProductChildViewControllerTypeLeftMenu) {
            [_leftTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            self.selectCategory = [self.categoryList firstObject];
            
            self.productRecordInCategory = self.productCategoryToProductListMap[self.selectCategory];
        } else {
            self.productRecordInCategory = self.productCategoryToProductListMap[self.selectCategory];
        }
    }
}


- (void)reloadData:(BOOL)layoutIfNeeded
{
    [_contentTableView reloadData];
    if (layoutIfNeeded) {
        [_contentTableView layoutIfNeeded];
    }
}

- (void)expandProduct:(ProductRecord4Cocoa *)productRecord unitUUID:(NSString *)unitUUID
{
    NSInteger addProductListStyle = [JCHUserDefaults integerForKey:kAddProductListUIStyleKey];
    
    if (addProductListStyle == kJCHAddProductChildViewControllerTypeLeftMenu) {
        
        self.selectCategory = productRecord.goods_type;
        NSInteger row = [self.categoryList indexOfObject:self.selectCategory];
        NSIndexPath *leftIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
        NSIndexPath *currentSelectIndexPath = [_leftTableView indexPathForSelectedRow];
        [self tableView:_leftTableView didDeselectRowAtIndexPath:currentSelectIndexPath];
        [_leftTableView selectRowAtIndexPath:leftIndexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
        [self tableView:_leftTableView didSelectRowAtIndexPath:leftIndexPath];
        self.productRecordInCategory = self.productCategoryToProductListMap[self.selectCategory];
    }
    
    NSArray *allKeys = self.pullDownButtonStausForRow.allKeys;
    for (NSNumber *key in allKeys) {
        [self.pullDownButtonStausForRow setObject:@(NO) forKey:key];
    }
    
    NSMutableArray *productInCategory = [NSMutableArray arrayWithArray:self.productRecordInCategory];
    [productInCategory removeObject:productRecord];
    [productInCategory insertObject:productRecord atIndex:0];
    self.productRecordInCategory = productInCategory;
    [self reloadData:YES];
    [_contentTableView setContentOffset:CGPointZero];
    
    if (unitUUID) {
        //主辅单位商品
        JCHAddProductTableViewCell *cell = [_contentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [self handleShowKeyboard:cell unitUUID:unitUUID];
    } else {
        //无规格或者多规格商品
        [self tableView:_contentTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
}

- (void)switchToPhotoBrowser:(NSIndexPath *)indexPath
{
    ProductRecord4Cocoa *productRecord = self.productRecordInCategory[indexPath.row];
    [JCHImageUtility showPhotoBrowser:productRecord viewController:self];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_currentType == kJCHAddProductChildViewControllerTypeDefault) {
        return self.productRecordInCategory.count;
    } else {
        if (tableView == _leftTableView) {
            return self.categoryList.count;
        } else {
            
            NSArray *productInCategory = self.productCategoryToProductListMap[self.selectCategory];
            return productInCategory.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _contentTableView) {
        
        ProductRecord4Cocoa *productRecord = self.productRecordInCategory[indexPath.row];
      
        UITableViewCell *theCell = [self getTableViewCell:indexPath];
        
        if ([theCell isKindOfClass:[JCHAddProductTableViewCell class]]) {
            JCHAddProductTableViewCell *cell = (JCHAddProductTableViewCell *)theCell;
            
            JCHAddProductTableViewCellData *cellData = [self configureCellData:indexPath];
            
            [cell setCellData:cellData];
            
            if (productRecord.is_multi_unit_enable) {
                [self.heightForRow setObject:@(cell.pullDownCellHeight) forKey:@(indexPath.row)];
            } else {
                if ([[self.pullDownButtonStausForRow objectForKey:@(indexPath.row)] boolValue]) {
                    [self.heightForRow setObject:@(cell.pullDownCellHeight) forKey:@(indexPath.row)];
                } else {
                    [self.heightForRow setObject:@(cell.normalCellHeight) forKey:@(indexPath.row)];
                }
            }
            
        } else if ([theCell isKindOfClass:[JCHAddProductForRestaurantTableViewCell class]]) {
            JCHAddProductForRestaurantTableViewCell *cell = (JCHAddProductForRestaurantTableViewCell *)theCell;
            
            JCHAddProductTableViewCellData *cellData = [self configureCellData:indexPath];
            
            [cell setCellData:cellData];
            
            if (productRecord.is_multi_unit_enable) {
                
                [self.heightForRow setObject:@(cell.pullDownCellHeight) forKey:@(indexPath.row)];
            } else {
                if ([[self.pullDownButtonStausForRow objectForKey:@(indexPath.row)] boolValue]) {
                    [self.heightForRow setObject:@(cell.pullDownCellHeight) forKey:@(indexPath.row)];
                } else {
                    [self.heightForRow setObject:@(cell.normalCellHeight) forKey:@(indexPath.row)];
                }
            }
        }
        
        
        return theCell;
    } else {
        JCHCategoryListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHCategoryListTableViewCell"];
        if (cell == nil) {
            cell = [[JCHCategoryListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JCHCategoryListTableViewCell"];
        }
        cell.titleLabel.text = self.categoryList[indexPath.row];
        cell.titleLabel.numberOfLines = 2;
        return cell;
    }
}

- (UITableViewCell *)getTableViewCell:(NSIndexPath *)indexPath
{
    UITableViewCell *theCell = nil;
#if MMR_RESTAURANT_VERSION || MMR_TAKEOUT_VERSION
    
    JCHManifestMemoryStorage *memoryStorage = [JCHManifestMemoryStorage sharedInstance];
    if (memoryStorage.currentManifestType == kJCHOrderShipment) {
        JCHAddProductForRestaurantTableViewCell *cell = [_contentTableView dequeueReusableCellWithIdentifier:@"JCHAddProductForRestaurantTableViewCell"];
        if (cell == nil) {
            cell = [[[JCHAddProductForRestaurantTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JCHAddProductForRestaurantTableViewCell"] autorelease];
        }
        cell.delegate = self;
        cell.addProductListStyle = [JCHUserDefaults integerForKey:kAddProductListUIStyleKey];
        WeakSelf;
        [cell setTapBlock:^(JCHAddProductForRestaurantTableViewCell *currentCell) {
            [weakSelf switchToPhotoBrowser:indexPath];
        }];
        theCell = cell;
    } else {
        JCHAddProductTableViewCell *cell = [_contentTableView dequeueReusableCellWithIdentifier:@"JCHAddProductTableViewCell"];
        if (cell == nil) {
            cell = [[[JCHAddProductTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JCHAddProductTableViewCell"] autorelease];
        }
        
        cell.delegate = self;
        cell.addProductListStyle = [JCHUserDefaults integerForKey:kAddProductListUIStyleKey];
        WeakSelf;
        [cell setTapBlock:^(JCHAddProductTableViewCell *currentCell) {
            [weakSelf switchToPhotoBrowser:indexPath];
        }];
        theCell = cell;
    }
    
#else
    JCHAddProductTableViewCell *cell = [_contentTableView dequeueReusableCellWithIdentifier:@"JCHAddProductTableViewCell"];
    if (cell == nil) {
        cell = [[[JCHAddProductTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JCHAddProductTableViewCell"] autorelease];
    }
    
    cell.delegate = self;
    cell.addProductListStyle = [JCHUserDefaults integerForKey:kAddProductListUIStyleKey];
    WeakSelf;
    [cell setTapBlock:^(JCHAddProductTableViewCell *currentCell) {
        [weakSelf switchToPhotoBrowser:indexPath];
    }];
    theCell = cell;
#endif
    
    return theCell;
}

- (JCHAddProductTableViewCellData *)configureCellData:(NSIndexPath *)indexPath
{
    ProductRecord4Cocoa *productRecord = self.productRecordInCategory[indexPath.row];
    
    JCHAddProductTableViewCellData *cellData = [[[JCHAddProductTableViewCellData alloc] init] autorelease];
    cellData.productLogoImage = productRecord.goods_image_name;
    cellData.productCategory = productRecord.goods_type;
    cellData.productName = productRecord.goods_name;
    cellData.productUnit = productRecord.goods_unit;
    cellData.sku_hidden_flag = productRecord.sku_hiden_flag;
    cellData.is_multi_unit_enable = productRecord.is_multi_unit_enable;
    cellData.isArrowButtonStatusPullDown = [[self.pullDownButtonStausForRow objectForKey:@(indexPath.row)] boolValue];
    cellData.productLogoImage = productRecord.goods_image_name;
    cellData.productProperty = productRecord.cuisineProperty;
    
    
    if (productRecord.is_multi_unit_enable) {
        // 主辅单位数据 (库存，价格)
        id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
        NSArray<ProductItemRecord4Cocoa *> *unitList = nil;
        
        if (productRecord.is_multi_unit_enable) {
            unitList = self.productItemRecordForUnitCache[productRecord.goods_uuid];
            if (unitList == nil) {
                unitList = [productService queryUnitGoodsItem:productRecord.goods_uuid];
                [self.productItemRecordForUnitCache setObject:unitList forKey:productRecord.goods_uuid];
            }
        }
        
        // 得到主辅单位的viewData
        cellData.auxiliaryUnitList = [self getMainAuxiliaryViewData:productRecord unitList:unitList];
    } else {
        // 多规格
        if (!productRecord.sku_hiden_flag) {
            GoodsSKURecord4Cocoa *record = self.goodsSKURecord4CocoaCache[productRecord.goods_uuid];
            if (record == nil) {
                id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
                [skuService queryGoodsSKU:productRecord.goods_sku_uuid skuArray:&record];
                [self.goodsSKURecord4CocoaCache setObject:record forKey:productRecord.goods_uuid];
            }
            cellData.goodsSKURecord = record;
        } else {
            //无规格
        }
        
        // 设置多规格和无规格商品cellData的价格、库存、数量
        [self setCellDataPriceAndInventoryCount:cellData productRecord:productRecord];
    }
    
    if (NO == productRecord.sku_hiden_flag) {
        // 多规格

#if MMR_BASE_VERSION || MMR_RESTAURANT_VERSION
        cellData.productCount = @"0";
#else
        NSString *productCountString = @"";
        CGFloat productCount = [self getDisherCountForSKU:productRecord unitUUID:productRecord.goods_unit_uuid];
        if ([JCHFinanceCalculateUtility floatValueIsZero:(productCount - (NSInteger)productCount)]) {
            productCountString = [NSString stringWithFormat:@"%ld", (NSInteger)productCount];
        } else {
            productCountString = [NSString stringWithFormat:@"%.2f", productCount];
        }
        cellData.productCount = productCountString;
#endif
        
        
    } else {
        // 无规格/主辅单位
        cellData.productCount = [NSString stringWithFormat:@"%d",
                                 (int)[self getDishesCountForNoneSKU:productRecord unitUUID:productRecord.goods_unit_uuid]];
    }
    return cellData;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _leftTableView) {
        return 40;
    } else {
        NSNumber *number = [self.heightForRow objectForKey:@(indexPath.row)];
        return [number doubleValue];
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == _leftTableView) {
        return 40;
    } else {
        NSNumber *number = [self.heightForRow objectForKey:@(indexPath.row)];
        
        if (number) {
            return [number doubleValue];
        } else {
            if ([JCHUserDefaults integerForKey:kAddProductListUIStyleKey]) {
                return kJCHAddproductTableViewCellLeftMenuCellHeight;
            } else {
                return kJCHAddProductTableViewCellNormalHeight;
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _leftTableView) {
        JCHCategoryListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.selected = YES;
        
        self.selectCategory = self.categoryList[indexPath.row];
        self.productRecordInCategory = self.productCategoryToProductListMap[self.selectCategory];
        [_contentTableView reloadData];
    } else {
#if MMR_RESTAURANT_VERSION || MMR_TAKEOUT_VERSION
        // 餐饮版和外卖版不需要显示键盘
#else
        JCHAddProductTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        ProductRecord4Cocoa *productRecord = (ProductRecord4Cocoa *)(self.productRecordInCategory[indexPath.row]);
        
        if (productRecord.is_multi_unit_enable) {
            return;
        }
        id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
        GoodsSKURecord4Cocoa *record = nil;
        [skuService queryGoodsSKU:productRecord.goods_sku_uuid skuArray:&record];
        
        if (productRecord.sku_hiden_flag || (!productRecord.sku_hiden_flag && record.skuArray.count == 0)) {
            [self handleShowKeyboard:cell unitUUID:nil];
        }
        else
        {
            [self handlePullDownSKUDetailView:cell button:cell.pullDownButton];
        }
#endif
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (tableView == _leftTableView) {
        JCHCategoryListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.selected = NO;
    }
}

#pragma mark - JCHAddProductTableViewCellDelegate

- (void)handlePullDownSKUDetailView:(JCHAddProductTableViewCell *)cell button:(UIButton *)button
{
    button.selected = !button.selected;
    NSIndexPath *indexPath = [_contentTableView indexPathForCell:cell];
    
    //货单编辑恢复 已经选择的规格
    if (button.selected) {
        [self handleRestoreSelectedSKUForManifestEdit:indexPath];
    }
    
    
    if (button.selected) {
        self.currentEditingIndexPath = indexPath;
    }
    
    
    if (button.selected) {
        [self.heightForRow setObject:@(cell.pullDownCellHeight) forKey:@(indexPath.row)];
        
        [self.pullDownButtonStausForRow setObject:@(YES) forKey:@(indexPath.row)];
        
        [_contentTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    else
    {
        [self.heightForRow setObject:@(cell.normalCellHeight) forKey:@(indexPath.row)];
        
        [self.pullDownButtonStausForRow setObject:@(NO) forKey:@(indexPath.row)];
        
        [_contentTableView deselectRowAtIndexPath:indexPath animated:YES];
        
        [cell deselectAllButtons];
    }

    [_contentTableView beginUpdates];
    [_contentTableView endUpdates];
    [_contentTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


- (void)handleSelectInventorySKU:(JCHAddProductTableViewCell *)cell
{
    NSIndexPath *indexPath = [_contentTableView indexPathForCell:cell];
    ProductRecord4Cocoa *productRecord = self.productRecordInCategory[indexPath.row];
    id<FinanceCalculateService> calculateService = [[ServiceFactory sharedInstance] financeCalculateService];
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    InventoryDetailRecord4Cocoa *inventoryDetailRecord = [calculateService calculateInventoryFor:productRecord.goods_uuid
                                                                                        unitUUID:productRecord.goods_unit_uuid
                                                                                   warehouseUUID:manifestStorage.warehouseID];
    NSArray *productSKUInventoryArray = inventoryDetailRecord.productSKUInventoryArray;
    
    
    //保存所有有库存的sku
    NSMutableArray *allSKUUUIDsForInventory = [NSMutableArray array];
    for (SKUInventoryRecord4Cocoa *skuInventoryRecord in productSKUInventoryArray) {
        GoodsSKURecord4Cocoa *record = nil;
        for (GoodsSKURecord4Cocoa *tempRecord in self.allGoodsSKURecordArray) {
            if ([tempRecord.goodsSKUUUID isEqualToString:skuInventoryRecord.productSKUUUID]) {
                record = tempRecord;
                break;
            }
        }
        
        for (NSDictionary *dict in record.skuArray) {
            SKUValueRecord4Cocoa *skuValueRecord = [dict allValues][0][0];
            
            if ((skuInventoryRecord.currentInventoryCount > 0) &&
                ![allSKUUUIDsForInventory containsObject:skuValueRecord.skuValueUUID]) {
                [allSKUUUIDsForInventory addObject:skuValueRecord.skuValueUUID];
            }
        }
    }
    [cell selectButtons:allSKUUUIDsForInventory];
}

+ (ManifestTransactionDetail *)createManifestTransactionDetail:(ProductRecord4Cocoa *)productRecord
{
    return [self createManifestTransactionDetail:productRecord property:@""];
}

+ (ManifestTransactionDetail *)createManifestTransactionDetail:(ProductRecord4Cocoa *)productRecord property:(NSString *)property
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    ManifestTransactionDetail *detail = [[[ManifestTransactionDetail alloc] init] autorelease];
    detail.productCategory = productRecord.goods_type;
    detail.productName = productRecord.goods_name;
    detail.productUnit = productRecord.goods_unit;
    detail.productImageName = productRecord.goods_image_name;
    detail.productUnit_digits = productRecord.goods_unit_digits;
    detail.productDiscount = @"1.0";
    detail.productCount = @"0";
    
    //出货时 主辅单位商品的数量默认为1
    if (manifestStorage.currentManifestType == kJCHOrderShipment || manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable) {
        detail.productCount = @"1";
    }
    detail.skuValueCombine = @"";
    detail.skuHidenFlag = productRecord.sku_hiden_flag;
    detail.warehouseUUID = manifestStorage.warehouseID;
    detail.goodsCategoryUUID = productRecord.goods_category_uuid;
    detail.goodsNameUUID = productRecord.goods_uuid;
    detail.unitUUID = productRecord.goods_unit_uuid;
    detail.productInventoryCount = [NSString stringFromCount:0 unitDigital:productRecord.goods_unit_digits];
    detail.dishProperty = property;
    
    return detail;
}

// unitUUID不为nil，表示的是主辅单位类型的商品
- (void)handleShowKeyboard:(JCHAddProductTableViewCell *)cell unitUUID:(NSString *)unitUUID
{
    _contentTableView.userInteractionEnabled = NO;
    
    NSIndexPath *indexPath = [_contentTableView indexPathForCell:cell];
    self.currentEditingIndexPath = indexPath;
    [_contentTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    ProductRecord4Cocoa *productRecord = (ProductRecord4Cocoa *)(self.productRecordInCategory[indexPath.row]);
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    //保存当前弹出列表里面的transations
    NSMutableArray *manifestTransactionsToProduct = [NSMutableArray array];
    
    if (productRecord.is_multi_unit_enable) {
        // 主辅单位
        ProductUnitRecord4Cocoa *productUnitRecord = nil;
        if (unitUUID) {
            id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
            productUnitRecord = [productService queryGoodsUnit:productRecord.goods_uuid unitUUID:unitUUID];
            
            //主单位查出来productUnitRecord数据都为空
            if ([productUnitRecord.unitUUID isEmptyString]) {
                productUnitRecord.unitUUID = productRecord.goods_unit_uuid;
                productUnitRecord.unitName = productRecord.goods_unit;
                productUnitRecord.unitDigits = (int)productRecord.goods_unit_digits;
            }
        }
        
        // 组装单要商品界面只显示主单位，点击后键盘上面列表里要显示所有辅单位
        if (manifestStorage.currentManifestType == kJCHManifestAssembling) {
            // 主单位
            ManifestTransactionDetail *mainUnitDetail = [JCHAddProductChildViewController createManifestTransactionDetail:productRecord];
            mainUnitDetail.productUnit = productUnitRecord.unitName;
            mainUnitDetail.unitUUID = productUnitRecord.unitUUID;
            mainUnitDetail.productUnit_digits = productUnitRecord.unitDigits;
            mainUnitDetail.ratio = 1;
            mainUnitDetail.isMainUnit = YES;
            
            NSString *key = [NSString stringWithFormat:@"%@_%@", productRecord.goods_uuid, productUnitRecord.unitUUID];
            InventoryDetailRecord4Cocoa *inventoryRecord = [self.inventoryMap objectForKey:key];
            CGFloat currentTotalInventoryCount = inventoryRecord.currentInventoryCount;
            NSString *inventoryCount = [NSString stringFromCount:currentTotalInventoryCount unitDigital:productUnitRecord.unitDigits];
            mainUnitDetail.productInventoryCount = inventoryCount;
            mainUnitDetail.productPrice = [NSString stringWithFormat:@"%.2f", inventoryRecord.averageCostPrice];
            [self setTransactionDetailPrice:mainUnitDetail productRecord:productRecord];
            
            //恢复之前添加的记录
            [self restoreManifestTransactionDetailInfo:mainUnitDetail];
            
            [manifestTransactionsToProduct addObject:mainUnitDetail];
            
            // 辅单位
            NSArray *unitList = self.productItemRecordForUnitCache[productRecord.goods_uuid];
            
            for (ProductItemRecord4Cocoa *productItemRecord in unitList) {
                ManifestTransactionDetail *detail = [JCHAddProductChildViewController createManifestTransactionDetail:productRecord];
                detail.productUnit = productItemRecord.unitName;
                detail.unitUUID = productItemRecord.goodsUnitUUID;
                detail.productUnit_digits = productItemRecord.unitDigits;
                
                // 辅单位库存存为主单位库存，由于界面上用不到辅单位库存，编辑辅单位的时候要和主单位的库存进行比较，所以存为主单位库存
                detail.productInventoryCount = inventoryCount;
                detail.ratio = productItemRecord.ratio;
                detail.isMainUnit = NO;
                
                NSString *key = [NSString stringWithFormat:@"%@_%@", productRecord.goods_uuid, productItemRecord.goodsUnitUUID];
                InventoryDetailRecord4Cocoa *inventoryRecord = [self.inventoryMap objectForKey:key];
                detail.productPrice = [NSString stringWithFormat:@"%.2f", inventoryRecord.averageCostPrice];
                [self setTransactionDetailPrice:detail productRecord:productRecord];
                
                //恢复之前添加的记录
                [self restoreManifestTransactionDetailInfo:detail];
                
                [manifestTransactionsToProduct addObject:detail];
            }
        } else if (manifestStorage.currentManifestType == kJCHManifestDismounting) {
            // 拆装单点击的肯定是辅单位, 但是还要把主单位detail添加进来
            if (![productUnitRecord.unitUUID isEmptyString]) {
                
                // 主单位
                ManifestTransactionDetail *mainUnitDetail = [JCHAddProductChildViewController createManifestTransactionDetail:productRecord];
                mainUnitDetail.productUnit = productRecord.goods_unit;
                mainUnitDetail.unitUUID = productRecord.goods_unit_uuid;
                mainUnitDetail.productUnit_digits = productRecord.goods_unit_digits;
                mainUnitDetail.ratio = 1;
                mainUnitDetail.isMainUnit = YES;
                
                NSString *mainUnitKey = [NSString stringWithFormat:@"%@_%@", productRecord.goods_uuid, mainUnitDetail.unitUUID];
                InventoryDetailRecord4Cocoa *mainUnitInventoryRecord = [self.inventoryMap objectForKey:mainUnitKey];
                CGFloat mainUnitTotalInventoryCount = mainUnitInventoryRecord.currentInventoryCount;
                NSString *mainUnitInventoryCount = [NSString stringFromCount:mainUnitTotalInventoryCount unitDigital:productUnitRecord.unitDigits];
                mainUnitDetail.productInventoryCount = mainUnitInventoryCount;
                mainUnitDetail.productPrice = [NSString stringWithFormat:@"%.2f", mainUnitInventoryRecord.averageCostPrice];
                //恢复之前添加的记录
                [self restoreManifestTransactionDetailInfo:mainUnitDetail];
                [manifestTransactionsToProduct addObject:mainUnitDetail];
                
                // 辅单位
                ManifestTransactionDetail *detail = [JCHAddProductChildViewController createManifestTransactionDetail:productRecord];
                detail.productUnit = productUnitRecord.unitName;
                detail.unitUUID = productUnitRecord.unitUUID;
                detail.productUnit_digits = productUnitRecord.unitDigits;
                detail.ratio = productUnitRecord.ratio;
                detail.isMainUnit = NO;
                
                // 从inventoryMap中取库存信息
                NSString *auxiliaryUnitKey = [NSString stringWithFormat:@"%@_%@", productRecord.goods_uuid, productUnitRecord.unitUUID];
                InventoryDetailRecord4Cocoa *auxiliaryUnitInventoryRecord = [self.inventoryMap objectForKey:auxiliaryUnitKey];
                CGFloat auxiliaryUnitTotalInventoryCount = auxiliaryUnitInventoryRecord.currentInventoryCount;
                NSString *auxiliaryUnitInventoryCount = [NSString stringFromCount:auxiliaryUnitTotalInventoryCount unitDigital:productUnitRecord.unitDigits];
                detail.productInventoryCount = auxiliaryUnitInventoryCount;
                detail.productPrice = [NSString stringWithFormat:@"%.2f", auxiliaryUnitInventoryRecord.averageCostPrice];
                //恢复之前添加的记录
                [self restoreManifestTransactionDetailInfo:detail];
                [manifestTransactionsToProduct addObject:detail];
            }
        } else {
            ManifestTransactionDetail *detail = [JCHAddProductChildViewController createManifestTransactionDetail:productRecord];
            
            NSString *key = [NSString stringWithFormat:@"%@_%@", productRecord.goods_uuid, productUnitRecord.unitUUID];
            InventoryDetailRecord4Cocoa *inventoryRecord = [self.inventoryMap objectForKey:key];
            CGFloat currentTotalInventoryCount = inventoryRecord.currentInventoryCount;
            NSString *inventoryCount = [NSString stringFromCount:currentTotalInventoryCount unitDigital:productUnitRecord.unitDigits];
            
            detail.productUnit = productUnitRecord.unitName;
            detail.unitUUID = productUnitRecord.unitUUID;
            detail.productUnit_digits = productUnitRecord.unitDigits;
            detail.productInventoryCount = inventoryCount;
            detail.productPrice = [NSString stringWithFormat:@"%.2f", inventoryRecord.averageCostPrice];
            detail.averagePriceBefore = detail.productPrice;
            if (manifestStorage.currentManifestType == kJCHManifestInventory) {
                detail.productCount = inventoryCount;
            }
            
            [self setTransactionDetailPrice:detail productRecord:productRecord];
            
            //恢复之前添加的记录
            [self restoreManifestTransactionDetailInfo:detail];
            
            [manifestTransactionsToProduct addObject:detail];
        }
    } else {
        if (!productRecord.sku_hiden_flag) {
            // 多规格
            NSArray *selectedData = [cell getSKUData];
            
            id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
            GoodsSKURecord4Cocoa *record = nil;
            
            [skuService queryGoodsSKU:productRecord.goods_sku_uuid skuArray:&record];
            
            if ((selectedData.count == 0) && !productRecord.sku_hiden_flag && record.skuArray.count != 0) {
                UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"选择规格后才能添加商品" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil] autorelease];
                [av show];
                _contentTableView.userInteractionEnabled = YES;
                return;
            }
            
            
            if (selectedData.count < record.skuArray.count && !productRecord.sku_hiden_flag) {
                UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"每个规格必须至少选择一个属性" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil] autorelease];
                [av show];
                _contentTableView.userInteractionEnabled = YES;
                return;
            }
            
            NSDictionary *skuValuedDict = [JCHTransactionUtility getTransactionsWithData:selectedData];
            
            // 已选中规格的所有组合
            NSArray *skuValueCombineArray = [skuValuedDict allValues][0];
            
            // 保存所有组合对应的skuValueUUIDs (Nsarray)
            NSArray *skuValueUUIDsArray = [skuValuedDict allKeys][0];
            
            if (record.skuArray.count == 0) {
                skuValueCombineArray = @[@""];
            }

            for (NSString *skuValueCombine in skuValueCombineArray) {
                
                ManifestTransactionDetail *detail = [JCHAddProductChildViewController createManifestTransactionDetail:productRecord];
                // 多规格单品数量默认为0
                detail.productCount = @"0";
                detail.skuValueCombine = skuValueCombine;
                detail.skuValueUUIDs = skuValueUUIDsArray[[skuValueCombineArray indexOfObject:skuValueCombine]];
                
                
                [self setTransactionDetailPrice:detail productRecord:productRecord];
                
                //恢复之前添加的记录
                [self restoreManifestTransactionDetailInfo:detail];
                
                [manifestTransactionsToProduct addObject:detail];
            }
        } else {
            // 无规格
     
            ManifestTransactionDetail *detail = [JCHAddProductChildViewController createManifestTransactionDetail:productRecord];
            detail.skuValueUUIDs = nil;
            
            //数量显示库存
            NSString *key = [NSString stringWithFormat:@"%@_%@", productRecord.goods_uuid, productRecord.goods_unit_uuid];
            InventoryDetailRecord4Cocoa *inventoryRecord = [self.inventoryMap objectForKey:key];
            //const CGFloat currentTotalInventoryCount = inventoryRecord.currentTotalPurchasesCount - inventoryRecord.currentTotalShipmentCount;
            const CGFloat currentTotalInventoryCount = inventoryRecord.currentInventoryCount;
            
            if (productRecord.sku_hiden_flag) {
                detail.productInventoryCount = [NSString stringFromCount:currentTotalInventoryCount unitDigital:productRecord.goods_unit_digits];
            }
            
            [self setTransactionDetailPrice:detail productRecord:productRecord];
            
            //恢复之前添加的记录
            [self restoreManifestTransactionDetailInfo:detail];
            
            [manifestTransactionsToProduct addObject:detail];
        }
        
        // 非主辅单位加载库存信息、盘前成本价等
        [self loadSKUInventory:productRecord manifestTransactions:manifestTransactionsToProduct];
    }
    
    
    _skuListView = [[[JCHAddProductSKUListView alloc] initWithFrame:CGRectZero
                                                        productName:productRecord.goods_name
                                                       manifestType:manifestStorage.currentManifestType
                                                         dataSource:manifestTransactionsToProduct] autorelease];
    _skuListView.delegate = self;
    _skuListView.backgroundColor = [UIColor whiteColor];
    
    CGFloat skuListViewHeight = kSKUListRowHeight * _skuListView.dataSource.count + kSKUListSectionHeight;
    if (manifestStorage.currentManifestType == kJCHManifestAssembling || manifestStorage.currentManifestType == kJCHManifestDismounting) {
        // 拼装单listView高度比较特殊
        skuListViewHeight = kSKUListRowHeight * (_skuListView.dataSource.count - 1) + kSKUListSectionHeight;
    }
    CGFloat keyboardHeight = [JCHSizeUtility calculateWidthWithSourceWidth:196.0f];
    _keyboardView = [[[JCHSettleAccountsKeyboardView alloc] initWithFrame:CGRectZero
                                                           keyboardHeight:keyboardHeight
                                                                  topView:_skuListView
                                                   topContainerViewHeight:skuListViewHeight] autorelease];
    _keyboardView.delegate = self;
    ManifestTransactionDetail *detail = [manifestTransactionsToProduct firstObject];
    _keyboardView.unit_digits = detail.productUnit_digits;
    [_keyboardView setEditText:detail.productCount editMode:kJCHSettleAccountsKeyboardViewEditModeCount];
    [_keyboardView show];
}

#pragma mark - JCHAddProductForRestaurantTableViewCellDelegate

- (void)handleRestaurantIncreaseDishCount:(JCHAddProductForRestaurantTableViewCell *)cell unitUUID:(NSString *)unitUUID
{
    NSIndexPath *indexPath = [_contentTableView indexPathForCell:cell];
    ProductRecord4Cocoa *productRecord = self.productRecordInCategory[indexPath.row];
    
    
    [self addTransactionForOrderDishes:productRecord
                              unitUUID:(nil == unitUUID) ? productRecord.goods_unit_uuid : unitUUID
                                  plus:YES];
    [_contentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    JCHAddProductMainViewController *mainVC = (JCHAddProductMainViewController *)self.parentViewController;
    [mainVC updateFooterViewData:YES];
}

- (void)handleRestaurantDecreaseDishCount:(JCHAddProductForRestaurantTableViewCell *)cell unitUUID:(NSString *)unitUUID
{
    NSIndexPath *indexPath = [_contentTableView indexPathForCell:cell];
    ProductRecord4Cocoa *productRecord = self.productRecordInCategory[indexPath.row];
    [self addTransactionForOrderDishes:productRecord
                              unitUUID:(nil == unitUUID) ? productRecord.goods_unit_uuid : unitUUID
                                  plus:NO];
    [_contentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    JCHAddProductMainViewController *mainVC = (JCHAddProductMainViewController *)self.parentViewController;
    [mainVC updateFooterViewData:YES];
}

- (void)handleRestaurantMainUnitDecreaseDishCount:(JCHAddProductForRestaurantTableViewCell *)cell unitUUID:(NSString *)unitUUID
{
    NSIndexPath *indexPath = [_contentTableView indexPathForCell:cell];
    ProductRecord4Cocoa *productRecord = self.productRecordInCategory[indexPath.row];
    [self addTransactionForOrderDishes:productRecord
                              unitUUID:(nil == unitUUID) ? productRecord.goods_unit_uuid : unitUUID
                                  plus:NO];
    [_contentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    JCHAddProductMainViewController *mainVC = (JCHAddProductMainViewController *)self.parentViewController;
    [mainVC updateFooterViewData:YES];
}

- (void)handleRestaurantMainUnitIncreaseDishCount:(JCHAddProductForRestaurantTableViewCell *)cell unitUUID:(NSString *)unitUUID
{
    NSIndexPath *indexPath = [_contentTableView indexPathForCell:cell];
    ProductRecord4Cocoa *productRecord = self.productRecordInCategory[indexPath.row];
    
    
    [self addTransactionForOrderDishes:productRecord
                              unitUUID:(nil == unitUUID) ? productRecord.goods_unit_uuid : unitUUID
                                  plus:YES];
    [_contentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    JCHAddProductMainViewController *mainVC = (JCHAddProductMainViewController *)self.parentViewController;
    [mainVC updateFooterViewData:YES];
}

- (void)handleRestaurantAddSKUDish:(JCHAddProductForRestaurantTableViewCell *)cell
{
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    GoodsSKURecord4Cocoa *record = nil;
    NSIndexPath *indexPath = [_contentTableView indexPathForCell:cell];
    ProductRecord4Cocoa *productRecord = (ProductRecord4Cocoa *)(self.productRecordInCategory[indexPath.row]);
    [skuService queryGoodsSKU:productRecord.goods_sku_uuid skuArray:&record];
    
    CGRect popFrame = CGRectMake(0, 0, kScreenWidth - 60, 0);
    JCHRestaurantSKUItemView *itemView = [[[JCHRestaurantSKUItemView alloc] initWithFrame:popFrame
                                                                              goodsRecord:productRecord
                                                                           goodsSKURecord:record] autorelease];
    itemView.backgroundColor = [UIColor whiteColor];
    itemView.delegate = self;
    itemView.layer.cornerRadius = 6.0;
    KLCPopup *popView = [KLCPopup popupWithContentView:itemView
                                              showType:KLCPopupShowTypeSlideInFromTop
                                           dismissType:KLCPopupDismissTypeSlideOutToBottom
                                              maskType:KLCPopupMaskTypeDimmed
                              dismissOnBackgroundTouch:YES
                                 dismissOnContentTouch:NO];
    
    popView.didFinishDismissingCompletion = ^{
        [_contentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    };
    [popView show];
}

// 恢复之前添加的记录
- (void)restoreManifestTransactionDetailInfo:(ManifestTransactionDetail *)detail
{
    NSArray *allManifestRecord = [[JCHManifestMemoryStorage sharedInstance] getAllManifestRecord];
    for (ManifestTransactionDetail *storedTransactionDetail in allManifestRecord) {
        if ([storedTransactionDetail.goodsNameUUID isEqualToString: detail.goodsNameUUID] &&
            [JCHTransactionUtility skuUUIDs:storedTransactionDetail.skuValueUUIDs isEqualToArray:detail.skuValueUUIDs] &&
            [storedTransactionDetail.unitUUID isEqualToString:detail.unitUUID] &&
            [storedTransactionDetail.dishProperty isEqualToString:detail.dishProperty]) {
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
        manifestStorage.currentManifestType == kJCHManifestMigrate ||
        manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable) {
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

#pragma mark - JCHSettleAccountsKeyboardViewDelegate

- (NSString *)keyboardViewEditingChanged:(NSString *)editText
{
    return [JCHAddProductChildViewController keyboardViewEditingChanged:editText
                                                            skuListView:_skuListView
                                                           keyboardView:_keyboardView];
}

- (void)keyboardViewOKButtonClick
{
    [JCHAddProductChildViewController keyboardViewOKButtonClick:_skuListView];
    
    JCHAddProductTableViewCell *cell = [_contentTableView cellForRowAtIndexPath:self.currentEditingIndexPath];
    if (cell.pullDownButton.selected) {
        [self.heightForRow setObject:@(cell.normalCellHeight) forKey:@(self.currentEditingIndexPath.row)];
        
        [self.pullDownButtonStausForRow setObject:@(NO) forKey:@(self.currentEditingIndexPath.row)];
    }
    
    [_contentTableView reloadRowsAtIndexPaths:@[self.currentEditingIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [_keyboardView hide];
    
    JCHAddProductMainViewController *mainVC = (JCHAddProductMainViewController *)self.parentViewController;
    [mainVC updateFooterViewData:YES];
}

- (void)keyboardViewDidHide:(JCHSettleAccountsKeyboardView *)keyboard
{
    NSIndexPath *indexPath = [_contentTableView indexPathForSelectedRow];
    [_contentTableView deselectRowAtIndexPath:indexPath animated:YES];
    _contentTableView.userInteractionEnabled = YES;
}



//! @note 此处作为类方法， 方便JCHCreateManifestViewController里面的JCHSettleAccountsKeyboardViewDelegate调用
+ (NSString *)keyboardViewEditingChanged:(NSString *)editText
                       skuListView:(JCHAddProductSKUListView *)skuListView
                      keyboardView:(JCHSettleAccountsKeyboardView *)keyboardView
{
    NSArray *selectedData = nil;
    if (skuListView.singleEditing) {
        selectedData = @[skuListView.singleEditingData];
    } else {
        selectedData = skuListView.selectedData;
    }
    for (ManifestTransactionDetail *detail in skuListView.dataSource) {
        for (ManifestTransactionDetail *selectedDetail in selectedData) {
            if ([JCHTransactionUtility skuUUIDs:detail.skuValueUUIDs isEqualToArray:selectedDetail.skuValueUUIDs] && [detail.unitUUID isEqualToString:selectedDetail.unitUUID]) {
                if (keyboardView.editMode == kJCHSettleAccountsKeyboardViewEditModePrice) {
                    detail.productPrice = [editText stringByReplacingOccurrencesOfString:@"¥" withString:@""];
                } else if (keyboardView.editMode == kJCHSettleAccountsKeyboardViewEditModeCount) {
                    detail.productCount = editText;
                    
                    //盘点单，如果输入的数量小于盘前数量，则将成本价还原成盘前成本价
                    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
                    if (manifestStorage.currentManifestType == kJCHManifestInventory) {
                        if ([detail.productCount doubleValue] <= [detail.productInventoryCount doubleValue]) {
                            detail.productPrice = detail.averagePriceBefore;
                        }
                    } else if (manifestStorage.currentManifestType == kJCHManifestMigrate) {
                        if ([detail.productCount doubleValue] > [detail.productInventoryCount doubleValue]) {
                            
                            if (detail.productInventoryCount.doubleValue > 0) {
                                detail.productCount = detail.productInventoryCount;
                            } else {
                                detail.productCount = @"0";
                            }
                            
                        }
                    } else if (manifestStorage.currentManifestType == kJCHManifestAssembling) {
                        
                        CGFloat otherAuxiliaryCount = 0;
                        for (ManifestTransactionDetail *otherAuxiliaryDetail in skuListView.dataSource) {
                            if (!otherAuxiliaryDetail.isMainUnit && ![otherAuxiliaryDetail.unitUUID isEqualToString:detail.unitUUID]) {
                                otherAuxiliaryCount += otherAuxiliaryDetail.productCountFloat * otherAuxiliaryDetail.ratio;
                            }
                        }
                        if ([detail.productCount doubleValue] * detail.ratio + otherAuxiliaryCount > [detail.productInventoryCount doubleValue]) {
                            if (detail.productInventoryCount.doubleValue > 0) {
                                detail.productCount = [NSString stringFromCount:floor((detail.productInventoryCount.doubleValue - otherAuxiliaryCount) / detail.ratio) unitDigital:detail.productUnit_digits];
                            } else {
                                detail.productCount = @"0";
                            }
                        }
                    } else if (manifestStorage.currentManifestType == kJCHManifestDismounting) {
                        if ([detail.productCount doubleValue] > [detail.productInventoryCount doubleValue]) {
                            
                            if (detail.productInventoryCount.doubleValue > 0) {
                                detail.productCount = detail.productInventoryCount;
                            } else {
                                detail.productCount = @"0";
                            }
                        }
                    }
                    editText = detail.productCount;
                } else if (keyboardView.editMode == kJCHSettleAccountsKeyboardViewEditModeTotalAmount) {
                    NSString *totalAmount = [editText stringByReplacingOccurrencesOfString:@"¥" withString:@""];
                    detail.productCountFloat = totalAmount.doubleValue / detail.productPrice.doubleValue;
                    detail.productTotalAmount = totalAmount;
                }
            }
        }
    }
    
    [skuListView reloadData];
    return editText;
}

+ (void)keyboardViewOKButtonClick:(JCHAddProductSKUListView *)skuListView
{
    JCHManifestMemoryStorage *storage = [JCHManifestMemoryStorage sharedInstance];
    
    //更新或添加storage中的transaction
    
    for (ManifestTransactionDetail *detail in skuListView.dataSource) {
        BOOL isTransactionInStorage = NO;
        for (ManifestTransactionDetail *storedTransactionDetail in [storage getAllManifestRecord]) {
            if (([storedTransactionDetail.goodsNameUUID isEqualToString: detail.goodsNameUUID] &&
                 [storedTransactionDetail.goodsCategoryUUID isEqualToString:detail.goodsCategoryUUID]) &&
                [JCHTransactionUtility skuUUIDs:storedTransactionDetail.skuValueUUIDs isEqualToArray:detail.skuValueUUIDs] &&
                [storedTransactionDetail.unitUUID isEqualToString:detail.unitUUID]) { //有规格 根据名称类型的uuid还有sku判断是否为同一规格
                
                //当数量、价格、折扣改变时重新取当前时间
                if ((detail.productCount != storedTransactionDetail.productCount) || (detail.productPrice != storedTransactionDetail.productPrice) || (detail.productDiscount != storedTransactionDetail.productDiscount)) {
                    storedTransactionDetail.productAddedTimestamp = time(NULL);
                }
                
                storedTransactionDetail.productCountFloat = detail.productCountFloat;
                storedTransactionDetail.productDiscount = detail.productDiscount;
                storedTransactionDetail.productPrice = [NSString stringWithFormat:@"%.2f", [detail.productPrice doubleValue]];
                
                
                isTransactionInStorage = YES;
                
                
                
                if (storage.currentManifestType == kJCHOrderShipment || storage.currentManifestType == kJCHOrderPurchases || storage.currentManifestType == kJCHManifestMigrate || storage.currentManifestType == kJCHManifestAssembling || storage.currentManifestType == kJCHManifestDismounting ||
                    kJCHRestaurntManifestOpenTable == storage.currentManifestType) {
                    //数量为0，从storage中删除
                    if (storedTransactionDetail.productCountFloat == 0) {
                        [storage removeManifestRecord:storedTransactionDetail];
                        isTransactionInStorage = NO;
                    }
                } else if (storage.currentManifestType == kJCHManifestInventory) {
                    if ([detail.productCount doubleValue] == [detail.productInventoryCount doubleValue] && [detail.productPrice doubleValue] == [detail.averagePriceBefore doubleValue]) {
                        [storage removeManifestRecord:storedTransactionDetail];
                    }
                } else if (storage.currentManifestType == kJCHManifestMaterialWastage) {
                    if ([detail.productCount doubleValue] == [detail.productInventoryCount doubleValue] && [detail.productPrice doubleValue] == [detail.averagePriceBefore doubleValue]) {
                        [storage removeManifestRecord:storedTransactionDetail];
                    }
                }
            
                break;
            }
        }
        
        detail.productAddedTimestamp = time(NULL);
        
        
        if (storage.currentManifestType == kJCHOrderShipment || storage.currentManifestType == kJCHOrderPurchases || storage.currentManifestType == kJCHManifestMigrate ||  storage.currentManifestType == kJCHManifestDismounting || kJCHRestaurntManifestOpenTable == storage.currentManifestType) {
            //如果没有在storage中发现，则增加一个detail
            if (!isTransactionInStorage && (detail.productCountFloat != 0)) {
                detail.productPrice = [NSString stringWithFormat:@"%.2f", [detail.productPrice doubleValue]];
                [storage addManifestRecord:detail];
            }
        } else if (storage.currentManifestType == kJCHManifestInventory) {
            if (!isTransactionInStorage) {
                detail.productPrice = [NSString stringWithFormat:@"%.2f", [detail.productPrice doubleValue]];
                [storage addManifestRecord:detail];
            }
        } else if (storage.currentManifestType == kJCHManifestMaterialWastage) {
                if (!isTransactionInStorage) {
                    detail.productPrice = [NSString stringWithFormat:@"%.2f", [detail.productPrice doubleValue]];
                    [storage addManifestRecord:detail];
                }
        } else if (storage.currentManifestType == kJCHManifestAssembling) {
            
            if (!isTransactionInStorage && (detail.productCountFloat != 0)) {
                // 拼装单的成本价要自己计算（主单位成本价 * 数量 / 辅单位数量）
                ManifestTransactionDetail *mainUnitDetail = nil;
                for (ManifestTransactionDetail *theDetail in skuListView.dataSource) {
                    if ([theDetail.goodsNameUUID isEqualToString:detail.goodsNameUUID] && theDetail.isMainUnit) {
                        mainUnitDetail = theDetail;
                        break;
                    }
                }
                if (mainUnitDetail) {
                    CGFloat price = mainUnitDetail.productPrice.doubleValue * detail.productCount.doubleValue * detail.ratio / detail.productCount.doubleValue;
                    detail.productPrice = [NSString stringWithFormat:@"%.2f", price];
                }
                [storage addManifestRecord:detail];
            }
        }
    }
}


//货单编辑恢复已选的规格
- (void)handleRestoreSelectedSKUForManifestEdit:(NSIndexPath *)indexPath
{
    ProductRecord4Cocoa *productRecord = (ProductRecord4Cocoa *)(self.productRecordInCategory[indexPath.row]);
    if (productRecord.sku_hiden_flag) {
        return;
    }
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    if (manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeNew) {
        return;
    }
    
    NSArray *allManifestRecord = [manifestStorage getAllManifestRecord];
    
    NSMutableArray *allSKUUUIDsForSelectedSKU = [NSMutableArray array];
    for (ManifestTransactionDetail *detail in allManifestRecord) {
        if ([productRecord.goods_uuid isEqualToString:detail.goodsNameUUID]) {
            NSArray *skuUUIDs = detail.skuValueUUIDs;
            for (NSString *skuUUID in skuUUIDs) {
                if (![allSKUUUIDsForSelectedSKU containsObject:skuUUID]) {
                    [allSKUUUIDsForSelectedSKU addObject:skuUUID];
                }
            }
        }
    }
    JCHAddProductTableViewCell *cell = [_contentTableView cellForRowAtIndexPath:indexPath];
    [cell selectButtons:allSKUUUIDsForSelectedSKU];
}


#pragma mark - JCHAddProductSKUListViewDelegate

- (void)skuListView:(JCHAddProductSKUListView *)view labelTaped:(UILabel *)editLabel
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    //if (manifestStorage.currentManifestType == kJCHOrderShipment) {
    ManifestTransactionDetail *transactionDetail = [_skuListView.dataSource firstObject];
    NSInteger unit_digits = transactionDetail.productUnit_digits;
    
    if (editLabel.tag == kJCHAddProductSKUListTableViewCellCountLableTag) {
        _keyboardView.unit_digits = unit_digits;
        NSString *countString = [editLabel.text stringByReplacingOccurrencesOfString:transactionDetail.productUnit withString:@""];
        _keyboardView.isFirstEdit = YES;
        
        if (manifestStorage.currentManifestType == kJCHOrderShipment || manifestStorage.currentManifestType == kJCHOrderPurchases || manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable) {
            [_keyboardView setEditText:countString editMode:kJCHSettleAccountsKeyboardViewEditModeCount];
        } 
    } else if (editLabel.tag == kJCHAddProductSKUListTableViewCellPriceLableTag) {
        
        _keyboardView.isFirstEdit = YES;
        if (manifestStorage.currentManifestType == kJCHOrderShipment || manifestStorage.currentManifestType == kJCHOrderPurchases || manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable) {
            [_keyboardView setEditText:editLabel.text editMode:kJCHSettleAccountsKeyboardViewEditModePrice];
        } else if (manifestStorage.currentManifestType == kJCHManifestInventory) {
            //盘点单 kJCHAddProductSKUListTableViewCellPriceLableTag 表示的盘后数量
            NSString *countString = [editLabel.text stringByReplacingOccurrencesOfString:transactionDetail.productUnit withString:@""];
            [_keyboardView setEditText:countString editMode:kJCHSettleAccountsKeyboardViewEditModeCount];
        }
    } else if (editLabel.tag == kJCHAddProductSKUListTableViewCellTotalAmountLableTag) {
        
        _keyboardView.isFirstEdit = YES;
        if (manifestStorage.currentManifestType == kJCHOrderShipment || manifestStorage.currentManifestType == kJCHOrderPurchases || manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable) {
            [_keyboardView setEditText:editLabel.text editMode:kJCHSettleAccountsKeyboardViewEditModeTotalAmount];
        } else if (manifestStorage.currentManifestType == kJCHManifestInventory) {
            [_keyboardView setEditText:editLabel.text editMode:kJCHSettleAccountsKeyboardViewEditModePrice];
        }
        
    }
}

- (void)handleHideView:(JCHAddProductSKUListView *)view
{
    [_keyboardView hide];
}




//设置ProductItemRecord的Price  cellForRow里面用
- (void)setProductItemRecordPrice:(ProductRecord4Cocoa *)productRecord
                         viewData:(JCHAddProductMainAuxiliaryUnitSelectViewData *)viewData
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    //进货 (上次进货价)
    if (manifestStorage.currentManifestType == kJCHOrderPurchases) {
        
        if ([viewData.unitUUID isEqualToString:productRecord.goods_unit_uuid]) {
            viewData.productPrice = [NSString stringWithFormat:@"%.2f", productRecord.goods_last_purchase_price];
        } else {
            
            viewData.productPrice = [NSString stringWithFormat:@"%.2f", [productRecord.last_purchase_price_map[viewData.unitUUID] doubleValue]];
        }
    }
    //出货 (出货价)
    else if (manifestStorage.currentManifestType == kJCHOrderShipment || manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable) {
        
        if ([viewData.unitUUID isEqualToString:productRecord.goods_unit_uuid]) {
            viewData.productPrice = [NSString stringWithFormat:@"%.2f", productRecord.goods_sell_price];
        } else {
            NSArray *productItemRecordList = self.productItemRecordForUnitCache[productRecord.goods_uuid];
            for (ProductItemRecord4Cocoa *productItemRecord in productItemRecordList) {
                if ([productItemRecord.goodsUnitUUID isEqualToString:viewData.unitUUID]) {
                    viewData.productPrice = [NSString stringWithFormat:@"%.2f", productItemRecord.itemPrice];
                }
            }
        }
    }
    //盘点 (成本价)
    else if (manifestStorage.currentManifestType == kJCHManifestInventory) {
        //计算总数量、价格区间、单品数
        CGFloat productTotalInventoryCountDiff = 0;
        NSMutableArray *priceArray = [NSMutableArray array];
        NSMutableArray *detailsInProduct = [NSMutableArray array];
        
        for (ManifestTransactionDetail *detail in [manifestStorage getAllManifestRecord]) {
            if ([detail.goodsNameUUID isEqualToString:productRecord.goods_uuid] &&
                [detail.unitUUID isEqualToString:viewData.unitUUID]) {
                
                [detailsInProduct addObject:detail];
                
                CGFloat transactionCount = [detail.productCount doubleValue];
                CGFloat transactionCountBefore = [detail.productInventoryCount doubleValue];
                productTotalInventoryCountDiff += transactionCount - transactionCountBefore;
                
                if ([detail.productCount doubleValue] != 0){
                    [priceArray addObject:detail.productPrice];
                }
            }
        }
        
        
        if (detailsInProduct.count > 0) {
            viewData.afterManifestInventoryChecked = YES;
        } else {
            viewData.afterManifestInventoryChecked = NO;
        }
        
        viewData.productPrice = [JCHTransactionUtility getPriceStringFrowPriceArray:priceArray];;
    }
    //移库 (移库不显示价格)
    else if (manifestStorage.currentManifestType == kJCHManifestMigrate) {
        //pass
    } else {
        
    }
}

// 设置多规格和无规格商品cellData的价格、库存、数量
- (void)setCellDataPriceAndInventoryCount:(JCHAddProductTableViewCellData *)cellData productRecord:(ProductRecord4Cocoa *)productRecord
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    //数量显示库存
    NSString *key = [NSString stringWithFormat:@"%@_%@", productRecord.goods_uuid, productRecord.goods_unit_uuid];
    InventoryDetailRecord4Cocoa *inventoryRecord = [self.inventoryMap objectForKey:key];
    CGFloat currentTotalInventoryCount = inventoryRecord.currentInventoryCount;
    
    NSString *inventoryCount = [NSString stringFromCount:currentTotalInventoryCount unitDigital:productRecord.goods_unit_digits];
    
    
    //出货时，价格显示的是出售价  数量显示库存
    if (manifestStorage.currentManifestType == kJCHOrderShipment || manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable) {
        
        //多规格显示价格区间
        if (!productRecord.sku_hiden_flag) {
            NSArray *productSKUItemRecordArray = self.productItemRecordForSKUCache[productRecord.goods_uuid];
            if (!productSKUItemRecordArray) {
                TICK;
                id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
                productSKUItemRecordArray = [productService querySkuGoodsItem:productRecord.goods_uuid];
                [self.productItemRecordForSKUCache setObject:productSKUItemRecordArray forKey:productRecord.goods_uuid];
                TOCK(@"querySkuGoodsItem");
            }
            NSMutableArray *priceArray = [NSMutableArray array];
            
            BOOL productItemHasSet = NO;
            for (ProductItemRecord4Cocoa *productItemRecord in productSKUItemRecordArray) {
                [priceArray addObject:@(productItemRecord.itemPrice)];
                if (productItemRecord.itemPrice != 0) {
                    productItemHasSet = YES;
                }
            }
            
            if (!productItemHasSet) {
                [priceArray removeAllObjects];
                [priceArray addObject:@(productRecord.goods_sell_price)];
            }
            
            cellData.productPrice = [JCHTransactionUtility getPriceStringFrowPriceArray:priceArray];
        } else {
            cellData.productPrice = [NSString stringWithFormat:@"%.2f", productRecord.goods_sell_price];
        }
        
        
        cellData.productInventoryCount = inventoryCount;
    } else if (manifestStorage.currentManifestType == kJCHOrderPurchases)
    {
        //进货时价格显示参考价，数量显示库存
        cellData.productPrice = [NSString stringWithFormat:@"%.2f", productRecord.goods_last_purchase_price];
        cellData.productInventoryCount = inventoryCount;
    } else if (manifestStorage.currentManifestType == kJCHManifestInventory) {  // 盘点单
        //盘点单要显示盘后数量、成本价
        
        //计算总数量、价格区间、单品数
        CGFloat productTotalInventoryCountDiff = 0;
        NSMutableArray *priceArray = [NSMutableArray array];
        NSMutableArray *detailsInProduct = [NSMutableArray array];
        
        for (ManifestTransactionDetail *detail in [manifestStorage getAllManifestRecord]) {
            if ([detail.goodsNameUUID isEqualToString:productRecord.goods_uuid]) {
                
                [detailsInProduct addObject:detail];
                
                CGFloat transactionCount = [detail.productCount doubleValue];
                CGFloat transactionCountBefore = [detail.productInventoryCount doubleValue];
                productTotalInventoryCountDiff += transactionCount - transactionCountBefore;
                
                if ([detail.productCount doubleValue] != 0){
                    [priceArray addObject:detail.productPrice];
                }
            }
        }
        
        id<FinanceCalculateService> calculateService = [[ServiceFactory sharedInstance] financeCalculateService];
        InventoryDetailRecord4Cocoa *inventoryDetailRecord = [calculateService calculateInventoryFor:productRecord.goods_uuid
                                                                                            unitUUID:productRecord.goods_unit_uuid
                                                                                       warehouseUUID:manifestStorage.warehouseID];
        NSArray *productSKUInventoryArray = [JCHTransactionUtility fliterSKUInventoryRecordList:inventoryDetailRecord.productSKUInventoryArray forProduct:productRecord];
        for (SKUInventoryRecord4Cocoa *skuInventoryRecord in productSKUInventoryArray) {
            
            BOOL skuInventoryRecordInAllManifestRecord = NO;
            for (ManifestTransactionDetail *detail in [manifestStorage getAllManifestRecord]) {
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
                //NSArray *skuValueCombineArray = [skuValuedDict allValues][0];
                NSArray *skuValueUUIDs = [skuValuedDict allKeys][0];
                if ([JCHTransactionUtility skuUUIDs:skuValueUUIDs[0] isEqualToArray:detail.skuValueUUIDs]) {
                    skuInventoryRecordInAllManifestRecord = YES;
                }
            }
            
            if (!skuInventoryRecordInAllManifestRecord) {
                [priceArray addObject:@(skuInventoryRecord.averageCostPrice)];
            }
        }
        
        NSString *price = [JCHTransactionUtility getPriceStringFrowPriceArray:priceArray];
        
        if (detailsInProduct.count > 0) {
            cellData.afterManifestInventoryChecked = YES;
            cellData.productInventoryCount = [NSString stringFromCount:currentTotalInventoryCount + productTotalInventoryCountDiff unitDigital:productRecord.goods_unit_digits];
            cellData.productPrice = price;
        } else {
            cellData.afterManifestInventoryChecked = NO;
            cellData.productInventoryCount = inventoryCount;
        }
    } else if (manifestStorage.currentManifestType == kJCHManifestMigrate) {
        
        CGFloat productCount = 0.0;
        for (ManifestTransactionDetail *detail in [manifestStorage getAllManifestRecord]) {
            if ([detail.goodsNameUUID isEqualToString:productRecord.goods_uuid]) {
                
                productCount += [detail.productCount doubleValue];
            }
        }
        cellData.productInventoryCount = inventoryCount;
        cellData.productCount = [NSString stringFromCount:productCount unitDigital:productRecord.goods_unit_digits];
    }
}

//设置transaction的price
- (void)setTransactionDetailPrice:(ManifestTransactionDetail *)detail productRecord:(ProductRecord4Cocoa *)productRecord
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    //进货 (上次进货价)
    if (manifestStorage.currentManifestType == kJCHOrderPurchases) {
        
        //主辅单位
        if (productRecord.is_multi_unit_enable) {
            if ([detail.unitUUID isEqualToString:productRecord.goods_unit_uuid]) {
                detail.productPrice = [NSString stringWithFormat:@"%.2f", productRecord.goods_last_purchase_price];
            } else {
                
                detail.productPrice = [NSString stringWithFormat:@"%.2f", [productRecord.last_purchase_price_map[detail.unitUUID] doubleValue]];
            }
        } else {
            //多规格
            if (!productRecord.sku_hiden_flag) {
                detail.productPrice = @"0.00";
            } else {
                detail.productPrice = [NSString stringWithFormat:@"%.2f", productRecord.goods_last_purchase_price];
            }
        }
    }
    //出货 (出货价)
    else if (manifestStorage.currentManifestType == kJCHOrderShipment || manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable) {
        
        //主辅单位
        if (productRecord.is_multi_unit_enable) {
            if ([detail.unitUUID isEqualToString:productRecord.goods_unit_uuid]) {
                detail.productPrice = [NSString stringWithFormat:@"%.2f", productRecord.goods_sell_price];
            } else {
                
                NSArray *productItemRecordList = self.productItemRecordForUnitCache[productRecord.goods_uuid];
                for (ProductItemRecord4Cocoa *productItemRecord in productItemRecordList) {
                    if ([productItemRecord.goodsUnitUUID isEqualToString:detail.unitUUID]) {
                        detail.productPrice = [NSString stringWithFormat:@"%.2f", productItemRecord.itemPrice];
                    }
                }
            }
        } else {
            //多规格
            if (!productRecord.sku_hiden_flag) {
                NSArray *productSKUItemRecordArray = self.productItemRecordForSKUCache[productRecord.goods_uuid];
                
                if (!productSKUItemRecordArray) {
                    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
                    productSKUItemRecordArray = [productService querySkuGoodsItem:productRecord.goods_uuid];
                    [self.productItemRecordForSKUCache setObject:productSKUItemRecordArray forKey:productRecord.goods_uuid];
                }
                
                //旧数据升级上来的查询的SKUItem数量为0，则用统一出售价
                if (productSKUItemRecordArray.count == 0) {
                    detail.productPrice = [NSString stringWithFormat:@"%.2f", productRecord.goods_sell_price];
                } else {
                    for (ProductItemRecord4Cocoa *productItemRecord in productSKUItemRecordArray) {
                        if ([JCHTransactionUtility skuUUIDs:productItemRecord.skuUUIDVector isEqualToArray:detail.skuValueUUIDs]) {
                            
                            if (productItemRecord.itemPrice == 0) {
                                //如果单品价格为0，则取主价格
                                detail.productPrice = [NSString stringWithFormat:@"%.2f", productRecord.goods_sell_price];
                            } else {
                                detail.productPrice = [NSString stringWithFormat:@"%.2f", productItemRecord.itemPrice];
                            }
                        }
                    }
                }
            } else {
                detail.productPrice = [NSString stringWithFormat:@"%.2f", productRecord.goods_sell_price];
            }
        }
        
    }
    //盘点 (成本价)
    else if (manifestStorage.currentManifestType == kJCHManifestInventory) {
        
        //NSString *key = [NSString stringWithFormat:@"%@_%@", productRecord.goods_uuid, productRecord.goods_unit_uuid];
        //InventoryDetailRecord4Cocoa *inventoryRecord = [self.inventoryMap objectForKey:key];
        
        //detail.productPrice = [NSString stringWithFormat:@"%.2f", inventoryRecord.averageCostPrice];
    }
    //移库 (移库不显示价格)
    else if (manifestStorage.currentManifestType == kJCHManifestMigrate) {
        //pass
    } else {
        
    }
}

//得到主辅单位的viewData
- (NSArray *)getMainAuxiliaryViewData:(ProductRecord4Cocoa *)productRecord unitList:(NSArray *)unitList
{
    NSMutableArray *mainAuxuliaryUnitList = [NSMutableArray array];
    for (NSInteger i = 0; i <= unitList.count; i++) {
        
        JCHAddProductMainAuxiliaryUnitSelectViewData *viewData = [[[JCHAddProductMainAuxiliaryUnitSelectViewData alloc] init] autorelease];
        
        if (i == 0) {
            
            // 主单位
            // 拆装单不显示主单位
            
            JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
            if (manifestStorage.currentManifestType != kJCHManifestDismounting) {
                
                NSString *key = [NSString stringWithFormat:@"%@_%@", productRecord.goods_uuid, productRecord.goods_unit_uuid];
                InventoryDetailRecord4Cocoa *inventoryRecord = [self.inventoryMap objectForKey:key];
                CGFloat currentTotalInventoryCount = inventoryRecord.currentInventoryCount;
                NSString *inventoryCount = [NSString stringFromCount:currentTotalInventoryCount unitDigital:productRecord.goods_unit_digits];
                
                viewData.isMainUint = YES;
                viewData.productMainUnit = productRecord.goods_unit;
                viewData.productInventoryCount = inventoryCount;
                viewData.unitUUID = productRecord.goods_unit_uuid;
                [self setProductItemRecordPrice:productRecord viewData:viewData];
                
                
                // 拼装单数量统计所有要拼成辅单位的数量，并且库存数量显示拼装后库存的数量
                if (manifestStorage.currentManifestType == kJCHManifestAssembling) {
                    CGFloat productCount = 0.0;
                    for (ManifestTransactionDetail *detail in [manifestStorage getAllManifestRecord]) {
                        if ([detail.goodsNameUUID isEqualToString:productRecord.goods_uuid]) {
                            productCount += detail.productCount.doubleValue * detail.ratio;
                        }
                    }
                    CGFloat inventoryCountAfterAssembling = inventoryCount.doubleValue - productCount;
                    viewData.productInventoryCount = [NSString stringFromCount:inventoryCountAfterAssembling unitDigital:productRecord.goods_unit_digits];
                    viewData.productCount = [NSString stringFromCount:productCount unitDigital:productRecord.goods_unit_digits];
                } else {
                    for (ManifestTransactionDetail *storedTransactionDetail in [[JCHManifestMemoryStorage sharedInstance] getAllManifestRecord]) {
                        if ([storedTransactionDetail.goodsNameUUID isEqualToString: productRecord.goods_uuid] && [storedTransactionDetail.unitUUID isEqualToString:viewData.unitUUID]) {
                            viewData.productCount = storedTransactionDetail.productCount;
                        }
                    }
                }
                
                [mainAuxuliaryUnitList addObject:viewData];
            }
        } else {
            // 辅单位
            // 拼装单不显示辅单位
            JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
            if (manifestStorage.currentManifestType != kJCHManifestAssembling) {
                ProductItemRecord4Cocoa *productItemRecord = unitList[i - 1];
                NSString *key = [NSString stringWithFormat:@"%@_%@", productRecord.goods_uuid, productItemRecord.goodsUnitUUID];
                InventoryDetailRecord4Cocoa *inventoryRecord = [self.inventoryMap objectForKey:key];
                CGFloat currentTotalInventoryCount = inventoryRecord.currentInventoryCount;
                NSString *inventoryCount = [NSString stringFromCount:currentTotalInventoryCount unitDigital:productItemRecord.unitDigits];
                
                
                viewData.isMainUint = NO;
                viewData.productMainUnit = productRecord.goods_unit;
                viewData.productAuxiliaryUnit = productItemRecord.unitName;
                viewData.scale = productItemRecord.ratio;
                viewData.productInventoryCount = inventoryCount;
                viewData.unitUUID = productItemRecord.goodsUnitUUID;
                [self setProductItemRecordPrice:productRecord viewData:viewData];
                

                for (ManifestTransactionDetail *storedTransactionDetail in [[JCHManifestMemoryStorage sharedInstance] getAllManifestRecord]) {
                    if ([storedTransactionDetail.goodsNameUUID isEqualToString: productRecord.goods_uuid] && [storedTransactionDetail.unitUUID isEqualToString:viewData.unitUUID]) {
                        viewData.productCount = storedTransactionDetail.productCount;
                        
                        // 如果是拆装单，库存显示拆后库存
                        if (manifestStorage.currentManifestType == kJCHManifestDismounting) {
                            CGFloat inventoryCountAfterAssembling = inventoryCount.doubleValue - storedTransactionDetail.productCount.doubleValue;
                            viewData.productInventoryCount = [NSString stringFromCount:inventoryCountAfterAssembling unitDigital:productRecord.goods_unit_digits];
                        }
                    }
                }
                
                [mainAuxuliaryUnitList addObject:viewData];
            }
        }
    }
    return mainAuxuliaryUnitList;
}

// 无规格添加一个菜品
- (void)addTransactionForOrderDishes:(ProductRecord4Cocoa *)productRecord unitUUID:(NSString *)unitUUID plus:(BOOL)plus
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];

    //更新或添加storage中的transaction
    BOOL isTransactionInStorage = NO;
    for (ManifestTransactionDetail *storedTransactionDetail in [manifestStorage getAllManifestRecord]) {
        if (([storedTransactionDetail.goodsNameUUID isEqualToString: productRecord.goods_uuid] &&
             [storedTransactionDetail.goodsCategoryUUID isEqualToString:productRecord.goods_category_uuid]) &&
            [storedTransactionDetail.unitUUID isEqualToString:unitUUID]) {
            
            //当数量、价格、折扣改变时重新取当前时间
  
            storedTransactionDetail.productAddedTimestamp = time(NULL);
            
            if (plus) {
                storedTransactionDetail.productCountFloat++;
            } else {
                storedTransactionDetail.productCountFloat--;
            }
            
            
            isTransactionInStorage = YES;
            
            //数量为0，从storage中删除
            if (storedTransactionDetail.productCountFloat == 0) {
                [manifestStorage removeManifestRecord:storedTransactionDetail];
                isTransactionInStorage = NO;
            }
            
            break;
        }
    }
    
    //如果没有在storage中发现，则增加一个detail
    if (!isTransactionInStorage && plus) {
        
        ManifestTransactionDetail *detail = nil;
        
        if (productRecord.is_multi_unit_enable) {
            // 主辅单位
            ProductUnitRecord4Cocoa *productUnitRecord = nil;
            
            id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
            productUnitRecord = [productService queryGoodsUnit:productRecord.goods_uuid unitUUID:unitUUID];
            
            //主单位查出来productUnitRecord数据都为空
            if ([productUnitRecord.unitUUID isEmptyString]) {
                productUnitRecord.unitUUID = productRecord.goods_unit_uuid;
                productUnitRecord.unitName = productRecord.goods_unit;
                productUnitRecord.unitDigits = (int)productRecord.goods_unit_digits;
            }
            
            
            {
                detail = [JCHAddProductChildViewController createManifestTransactionDetail:productRecord];
                
                NSString *key = [NSString stringWithFormat:@"%@_%@", productRecord.goods_uuid, productUnitRecord.unitUUID];
                InventoryDetailRecord4Cocoa *inventoryRecord = [self.inventoryMap objectForKey:key];
                CGFloat currentTotalInventoryCount = inventoryRecord.currentInventoryCount;
                NSString *inventoryCount = [NSString stringFromCount:currentTotalInventoryCount unitDigital:productUnitRecord.unitDigits];
                
                detail.productCount = @"1";
                detail.productUnit = productUnitRecord.unitName;
                detail.unitUUID = productUnitRecord.unitUUID;
                detail.productUnit_digits = productUnitRecord.unitDigits;
                detail.productInventoryCount = inventoryCount;
                detail.productPrice = [NSString stringWithFormat:@"%.2f", inventoryRecord.averageCostPrice];
                detail.averagePriceBefore = detail.productPrice;
                if (manifestStorage.currentManifestType == kJCHManifestInventory) {
                    detail.productCount = inventoryCount;
                }
                
                [self setTransactionDetailPrice:detail productRecord:productRecord];
                
                //恢复之前添加的记录
                [self restoreManifestTransactionDetailInfo:detail];
                
            }
        }  else {
            // 无规格
            
            detail = [JCHAddProductChildViewController createManifestTransactionDetail:productRecord];
            detail.skuValueUUIDs = nil;
            detail.productCount = @"1";
            //数量显示库存
            NSString *key = [NSString stringWithFormat:@"%@_%@", productRecord.goods_uuid, productRecord.goods_unit_uuid];
            InventoryDetailRecord4Cocoa *inventoryRecord = [self.inventoryMap objectForKey:key];
            //const CGFloat currentTotalInventoryCount = inventoryRecord.currentTotalPurchasesCount - inventoryRecord.currentTotalShipmentCount;
            const CGFloat currentTotalInventoryCount = inventoryRecord.currentInventoryCount;
            
            if (productRecord.sku_hiden_flag) {
                detail.productInventoryCount = [NSString stringFromCount:currentTotalInventoryCount unitDigital:productRecord.goods_unit_digits];
            }
            
            [self setTransactionDetailPrice:detail productRecord:productRecord];
            
            //恢复之前添加的记录
            [self restoreManifestTransactionDetailInfo:detail];
        }
        
        
        detail.productPrice = [NSString stringWithFormat:@"%.2f", [detail.productPrice doubleValue]];
        [manifestStorage addManifestRecord:detail];
    }
}

// 多规格添加或减少一个菜品
- (void)addTransactionForSKUOrderDishes:(ProductRecord4Cocoa *)productRecord skuValues:(NSArray *)skuValues plus:(BOOL)plus property:(NSString *)property
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    GoodsSKURecord4Cocoa *record = nil;
    
    [skuService queryGoodsSKU:productRecord.goods_sku_uuid skuArray:&record];


    NSDictionary *skuValuedDict = [JCHTransactionUtility getTransactionsWithData:skuValues];
    
    // 已选中规格的所有组合
    NSArray *skuValueCombineArray = [skuValuedDict allValues][0];
    
    // 保存所有组合对应的skuValueUUIDs (Nsarray)
    NSArray *skuValueUUIDsArray = [skuValuedDict allKeys][0];
    
    if (record.skuArray.count == 0) {
        skuValueCombineArray = @[@""];
    }
    
    
    //更新或添加storage中的transaction
    BOOL isTransactionInStorage = NO;
    for (ManifestTransactionDetail *storedTransactionDetail in [manifestStorage getAllManifestRecord]) {
        if (([storedTransactionDetail.goodsNameUUID isEqualToString: productRecord.goods_uuid] &&
             [storedTransactionDetail.goodsCategoryUUID isEqualToString:productRecord.goods_category_uuid]) &&
            [storedTransactionDetail.unitUUID isEqualToString:productRecord.goods_unit_uuid] &&
            [JCHTransactionUtility skuUUIDs:storedTransactionDetail.skuValueUUIDs isEqualToArray:skuValueUUIDsArray.firstObject] &&
            [storedTransactionDetail.dishProperty isEqualToString:property]) {
            
            //当数量、价格、折扣改变时重新取当前时间
            
            storedTransactionDetail.productAddedTimestamp = time(NULL);
            
            if (plus) {
                storedTransactionDetail.productCountFloat++;
            } else {
                storedTransactionDetail.productCountFloat--;
            }
            
            
            isTransactionInStorage = YES;
            
            //数量为0，从storage中删除
            if (storedTransactionDetail.productCountFloat == 0) {
                [manifestStorage removeManifestRecord:storedTransactionDetail];
                isTransactionInStorage = NO;
            }
            
            break;
        }
    }
    
    
        
    
    if (!isTransactionInStorage && plus) {
            
        ManifestTransactionDetail *detail = [JCHAddProductChildViewController createManifestTransactionDetail:productRecord property:(NSString *)property];
            // 多规格单品数量默认为0
            detail.productCount = @"1";
            detail.skuValueCombine = [skuValueCombineArray firstObject];
            detail.skuValueUUIDs = [skuValueUUIDsArray firstObject];
        
            [self setTransactionDetailPrice:detail productRecord:productRecord];
            
            //恢复之前添加的记录
            [self restoreManifestTransactionDetailInfo:detail];
        
            detail.productPrice = [NSString stringWithFormat:@"%.2f", [detail.productPrice doubleValue]];
            [manifestStorage addManifestRecord:detail];
    }
}

// 无规格菜品数量
- (NSInteger)getDishesCountForNoneSKU:(ProductRecord4Cocoa *)productRecord unitUUID:(NSString *)unitUUID
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    NSInteger dishCount = 0;
    for (ManifestTransactionDetail *storedTransactionDetail in [manifestStorage getAllManifestRecord]) {
        if (([storedTransactionDetail.goodsNameUUID isEqualToString: productRecord.goods_uuid] &&
             [storedTransactionDetail.goodsCategoryUUID isEqualToString:productRecord.goods_category_uuid]) &&
            [storedTransactionDetail.unitUUID isEqualToString:unitUUID]) {
            dishCount = [storedTransactionDetail.productCount integerValue];
            break;
        }
    }
    
    return dishCount;
}

- (CGFloat)getDisherCountForSKU:(ProductRecord4Cocoa *)productRecord unitUUID:(NSString *)unitUUID
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    CGFloat dishCount = 0;
    for (ManifestTransactionDetail *storedTransactionDetail in [manifestStorage getAllManifestRecord]) {
        if (([storedTransactionDetail.goodsNameUUID isEqualToString: productRecord.goods_uuid] &&
             [storedTransactionDetail.goodsCategoryUUID isEqualToString:productRecord.goods_category_uuid]) &&
            [storedTransactionDetail.unitUUID isEqualToString:unitUUID]) {
            CGFloat currentDishCount = storedTransactionDetail.productCount.floatValue;
            dishCount += currentDishCount;
        }
    }
    
    return dishCount;
}

#pragma mark -
#pragma mark JCHRestaurantSKUItemViewDelegate
- (void)handleRestaurantIncreaseSKUDishCount:(NSArray *)skuArray goodsRecord:(ProductRecord4Cocoa *)goodsRecord property:(NSString *)property
{
    [self addTransactionForSKUOrderDishes:goodsRecord skuValues:skuArray plus:YES property:property];
    JCHAddProductMainViewController *mainVC = (JCHAddProductMainViewController *)self.parentViewController;
    [mainVC updateFooterViewData:YES];
}

- (void)handleRestaurantDecreaseSKUDishCount:(NSArray *)skuArray goodsRecord:(ProductRecord4Cocoa *)goodsRecord property:(NSString *)property
{
    [self addTransactionForSKUOrderDishes:goodsRecord skuValues:skuArray plus:NO property:property];
    JCHAddProductMainViewController *mainVC = (JCHAddProductMainViewController *)self.parentViewController;
    [mainVC updateFooterViewData:YES];
}

- (void)handleCloseView
{
    [KLCPopup dismissAllPopups];
}

- (NSInteger)getRestaurantSKUDishCount:(NSArray *)skuArray goodsRecord:(ProductRecord4Cocoa *)productRecord property:(NSString *)property
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    GoodsSKURecord4Cocoa *record = nil;
    
    [skuService queryGoodsSKU:productRecord.goods_sku_uuid skuArray:&record];
    
    NSDictionary *skuValuedDict = [JCHTransactionUtility getTransactionsWithData:skuArray];
    
    // 已选中规格的所有组合
    NSArray *skuValueCombineArray = [skuValuedDict allValues][0];
    
    // 保存所有组合对应的skuValueUUIDs (Nsarray)
    NSArray *skuValueUUIDsArray = [skuValuedDict allKeys][0];
    
    if (record.skuArray.count == 0) {
        skuValueCombineArray = @[@""];
    }
    
    NSInteger totalDishCount = 0;
    
    for (ManifestTransactionDetail *storedTransactionDetail in [manifestStorage getAllManifestRecord]) {
        if (([storedTransactionDetail.goodsNameUUID isEqualToString: productRecord.goods_uuid] &&
             [storedTransactionDetail.goodsCategoryUUID isEqualToString:productRecord.goods_category_uuid]) &&
            [storedTransactionDetail.unitUUID isEqualToString:productRecord.goods_unit_uuid] &&
            [JCHTransactionUtility skuUUIDs:storedTransactionDetail.skuValueUUIDs isEqualToArray:skuValueUUIDsArray.firstObject] &&
            [storedTransactionDetail.dishProperty isEqualToString:property]) {
            
            //当数量、价格、折扣改变时重新取当前时间
            storedTransactionDetail.productAddedTimestamp = time(NULL);
            totalDishCount = storedTransactionDetail.productCountFloat;
            
            break;
        }
    }
    
    return totalDishCount;
}

- (CGFloat)getRestaurantSKUDishPrice:(NSArray *)skuArray goodsRecord:(ProductRecord4Cocoa *)productRecord property:(NSString *)property
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    GoodsSKURecord4Cocoa *record = nil;
    
    [skuService queryGoodsSKU:productRecord.goods_sku_uuid skuArray:&record];
    
    NSDictionary *skuValuedDict = [JCHTransactionUtility getTransactionsWithData:skuArray];
    
    // 已选中规格的所有组合
    NSArray *skuValueCombineArray = [skuValuedDict allValues][0];
    
    // 保存所有组合对应的skuValueUUIDs (Nsarray)
    NSArray *skuValueUUIDsArray = [skuValuedDict allKeys][0];
    
    if (record.skuArray.count == 0) {
        skuValueCombineArray = @[@""];
    }
    
    CGFloat dishPrice = 0;
    for (ManifestTransactionDetail *storedTransactionDetail in [manifestStorage getAllManifestRecord]) {
        if (([storedTransactionDetail.goodsNameUUID isEqualToString: productRecord.goods_uuid] &&
             [storedTransactionDetail.goodsCategoryUUID isEqualToString:productRecord.goods_category_uuid]) &&
            [storedTransactionDetail.unitUUID isEqualToString:productRecord.goods_unit_uuid] &&
            [JCHTransactionUtility skuUUIDs:storedTransactionDetail.skuValueUUIDs isEqualToArray:skuValueUUIDsArray.firstObject] &&
            [storedTransactionDetail.dishProperty isEqualToString:property]) {
            
            //当数量、价格、折扣改变时重新取当前时间
            storedTransactionDetail.productAddedTimestamp = time(NULL);
            dishPrice = storedTransactionDetail.productPrice.doubleValue;
            
            break;
        }
    }
    
    return dishPrice;
}

@end
