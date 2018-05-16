//
//  JCHProductDetailViewController.m
//  jinchuhuo
//
//  Created by apple on 15/8/19.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHProductDetailViewController.h"
#import "JCHProductDetailView.h"
#import "JCHProductDetailTableSectionView.h"
#import "JCHProductDetailTableViewCell.h"
#import "JCHProductDetailFooterView.h"
#import "ServiceFactory.h"
#import "JCHUIDebugger.h"
#import "JCHInputAccessoryView.h"
#import "JCHProductTitleComponentView.h"
#import "JCHImageUtility.h"
#import "UIImage+JCHImage.h"
#import "CommonHeader.h"
#import "UIView+JCHView.h"
#import "NSString+JCHString.h"
#import "JCHTransactionUtility.h"
#import "Masonry.h"
#import <SDCycleScrollView.h>


@interface JCHProductDetailViewController () <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    UIScrollView *_containerScrollView;

    UILabel *_productNameLabel;
    JCHProductDetailView *_detailView;
    UITableView *_skuContentTableView;
    JCHProductDetailFooterView *_footerView;
    SDCycleScrollView *_cycleScrollView;
}

@property (retain, nonatomic, readwrite) NSString *currentUnitUUID;
@property (retain, nonatomic, readwrite) NSString *currentProductUUID;
@property (retain, nonatomic, readwrite) NSString *warehouseID;
@property (retain, nonatomic, readwrite) InventoryDetailRecord4Cocoa *inventoryDetailRecord;
@property (retain, nonatomic, readwrite) NSArray *productTransactionList;
@property (retain, nonatomic, readwrite) NSArray *allGoodsSKURecordArray;

@property (retain, nonatomic, readwrite) MBProgressHUD *hud;

@end

@implementation JCHProductDetailViewController

- (id)initWithName:(NSString *)productUUID
          unitUUID:(NSString *)unitUUID
       warehouseID:(NSString *)warehouseID
{
    self = [super init];
    if (self) {
        self.title = @"商品详情";
        self.currentProductUUID = productUUID;
        self.currentUnitUUID = unitUUID;
        self.warehouseID = warehouseID;
    }
    
    return self;
}

- (void)dealloc
{
    [self.inventoryDetailRecord release];
    [self.currentProductUUID release];
    [self.productTransactionList release];
    [self.allGoodsSKURecordArray release];
    [self.currentUnitUUID release];
    [self.hud release];
    [self.warehouseID release];
    
    [super dealloc];
    
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData];
    //[self createUI];
    
    
    
    return;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    

    CGSize contenSize = _containerScrollView.contentSize;
    if (contenSize.height <= kScreenHeight - 64) {
        _containerScrollView.contentSize = CGSizeMake(0, kScreenHeight - 64 + 1);
    }
}


- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    CGFloat productLogoImageViewHeight = 250.0f;
    CGFloat productNameLabelHeight = 44.0f;
    CGFloat productDetailViewHeight = 70.0f;
    CGFloat viewTopOffset = 20.0f;
    CGFloat tableViewHeight = 0.0f;
    CGFloat footerViewHeight = 114.0f;
    
    if (self.productTransactionList == nil || self.productTransactionList.count == 0) {
        tableViewHeight = 0;
    }
    else {
        tableViewHeight = 30 * (self.productTransactionList.count + 1);
    }

    _containerScrollView = [[[UIScrollView alloc] init] autorelease];
    _containerScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_containerScrollView];

    [_containerScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];

    
    _cycleScrollView = [[[SDCycleScrollView alloc] init] autorelease];
    _cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
    [_cycleScrollView addSeparateLineWithMasonryTop:NO bottom:YES];
    [_containerScrollView addSubview:_cycleScrollView];
    
    [_cycleScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_containerScrollView.mas_top);
        make.height.mas_equalTo(productLogoImageViewHeight);
        make.width.mas_equalTo(kScreenWidth);
        make.centerX.equalTo(_containerScrollView.mas_centerX);
    }];
    
    UIView *nameLabelContainerView = [[[UIView alloc] init] autorelease];
    nameLabelContainerView.backgroundColor = [UIColor whiteColor];
    [_containerScrollView addSubview:nameLabelContainerView];
    
    [nameLabelContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_containerScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(_cycleScrollView.mas_bottom);
        make.height.mas_equalTo(productNameLabelHeight);
    }];
    
    _productNameLabel = [JCHUIFactory createLabel:CGRectZero
                                            title:@""
                                             font:[UIFont systemFontOfSize:14.0f]
                                        textColor:JCHColorMainBody
                                           aligin:NSTextAlignmentLeft];
    _productNameLabel.backgroundColor = [UIColor whiteColor];
    _productNameLabel.numberOfLines = 2;
    [nameLabelContainerView addSubview:_productNameLabel];
    
    [_productNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nameLabelContainerView).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(kScreenWidth - 2 * kStandardLeftMargin);
        make.top.equalTo(nameLabelContainerView);
        make.height.mas_equalTo(nameLabelContainerView);
    }];
    
    _detailView = [[[JCHProductDetailView alloc] initWithFrame:CGRectZero] autorelease];
    _detailView.layer.borderWidth = kSeparateLineWidth;
    _detailView.layer.borderColor = JCHColorSeparateLine.CGColor;
 
    [_containerScrollView addSubview:_detailView];
    [_detailView addSeparateLineWithMasonryTop:YES bottom:YES];
    
    [_detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_productNameLabel.mas_bottom);
        make.height.mas_equalTo(productDetailViewHeight);
        make.left.equalTo(_containerScrollView);
        make.width.mas_equalTo(kScreenWidth);
    }];
    
    _skuContentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    _skuContentTableView.backgroundColor = [UIColor whiteColor];
    _skuContentTableView.dataSource = self;
    _skuContentTableView.delegate = self;
    _skuContentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _skuContentTableView.layer.borderWidth = kSeparateLineWidth;
    _skuContentTableView.layer.borderColor = JCHColorSeparateLine.CGColor;
    [_containerScrollView addSubview:_skuContentTableView];
    
    [_skuContentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_detailView);
        make.right.equalTo(_detailView);
        make.top.equalTo(_detailView.mas_bottom).with.offset(viewTopOffset);
        make.height.mas_equalTo(tableViewHeight);
    }];
    
    _footerView = [[[JCHProductDetailFooterView alloc] initWithFrame:CGRectZero] autorelease];
    _footerView.backgroundColor = [UIColor whiteColor];
    _footerView.layer.borderWidth = kSeparateLineWidth;
    _footerView.layer.borderColor = JCHColorSeparateLine.CGColor;
    [_containerScrollView addSubview:_footerView];
    
    [_footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_detailView);
        make.right.equalTo(_detailView);
        make.top.equalTo(_skuContentTableView.mas_bottom).with.offset(viewTopOffset);
        make.height.mas_equalTo(footerViewHeight);
    }];
    
    [_containerScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_footerView.mas_bottom);
    }];
    
    return;
}

- (void)setProductData:(InventoryDetailRecord4Cocoa *)inventoryRecord
{
    {
        id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
        ProductRecord4Cocoa *productRecord = [productService queryProductByUUID:inventoryRecord.productNameUUID];
        
        NSMutableArray *imageNames = [NSMutableArray array];
        if (![productRecord.goods_image_name isEmptyString]) {
            NSString *imageName = [JCHImageUtility getImagePath:productRecord.goods_image_name];
            if ([UIImage imageNamed:imageName]) {
                [imageNames addObject:imageName];
            }
        }
        if (![productRecord.goods_image_name2 isEmptyString]) {
            NSString *imageName = [JCHImageUtility getImagePath:productRecord.goods_image_name2];
            if ([UIImage imageNamed:imageName]) {
                [imageNames addObject:imageName];
            }
        }
        if (![productRecord.goods_image_name3 isEmptyString]) {
            NSString *imageName = [JCHImageUtility getImagePath:productRecord.goods_image_name3];
            if ([UIImage imageNamed:imageName]) {
                [imageNames addObject:imageName];
            }
        }
        if (![productRecord.goods_image_name4 isEmptyString]) {
            NSString *imageName = [JCHImageUtility getImagePath:productRecord.goods_image_name4];
            if ([UIImage imageNamed:imageName]) {
                [imageNames addObject:imageName];
            }
        }
        if (![productRecord.goods_image_name5 isEmptyString]) {
            NSString *imageName = [JCHImageUtility getImagePath:productRecord.goods_image_name5];
            if ([UIImage imageNamed:imageName]) {
                [imageNames addObject:imageName];
            }
        }
        
        if (imageNames.count == 0) {
            [imageNames addObject:@"icon_default_bg"];
        }
        
        _cycleScrollView.localizationImageNamesGroup = imageNames;
        _productNameLabel.text = inventoryRecord.productName;
    }
    
    {
        JCHProductDetailViewData *detailViewData = [[[JCHProductDetailViewData alloc] init] autorelease];
        detailViewData.productCategory = inventoryRecord.productCategory;
        detailViewData.productUnit = inventoryRecord.productUnit;
        //CGFloat inventoryCount = inventoryRecord.currentTotalPurchasesCount - inventoryRecord.currentTotalShipmentCount;
        CGFloat inventoryCount = inventoryRecord.currentInventoryCount;
        detailViewData.productCount = [NSString stringFromCount:inventoryCount unitDigital:inventoryRecord.unitDigits];
        const CGFloat totalValue = inventoryRecord.averageCostPrice * inventoryCount;
        
        detailViewData.productAmount = [NSString stringWithFormat:@"¥%.2f", totalValue];
        [_detailView setViewData:detailViewData];
    }
    
    {
        JCHProductDetailFooterViewData *footerViewData = [[[JCHProductDetailFooterViewData alloc] init] autorelease];
        footerViewData.traderCode = inventoryRecord.productMerchantCode;
        footerViewData.barCode = inventoryRecord.productBarCode;
        footerViewData.remark = inventoryRecord.productRemark;
        [_footerView setViewData:footerViewData];
        CGFloat footerViewHeight = _footerView.viewHeight;
        if (footerViewHeight != 38 * 3)
        {
            [_footerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(footerViewHeight);
            }];
            
            CGFloat offset = footerViewHeight - 38 * 3;
            
            CGSize contentSize = _containerScrollView.contentSize;
            contentSize.height += offset;
            _containerScrollView.contentSize = contentSize;
        }
    }
}


- (void)loadData
{
    self.hud = [MBProgressHUD showHUDWithTitle:@"加载中..."
                                        detail:nil
                                      duration:100
                                          mode:MBProgressHUDModeIndeterminate
                                     superView:self.view
                                    completion:nil];
    
    id<FinanceCalculateService> calculateService = [[ServiceFactory sharedInstance] financeCalculateService];
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *allGoodsSKURecordArray = nil;
        [skuService queryAllGoodsSKU:&allGoodsSKURecordArray];
        self.allGoodsSKURecordArray = allGoodsSKURecordArray;
        self.inventoryDetailRecord = [calculateService calculateInventoryFor:self.currentProductUUID
                                                                    unitUUID:self.currentUnitUUID
                                                               warehouseUUID:self.warehouseID];
        
        id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
        ProductRecord4Cocoa *productRecord = [productService queryProductByUUID:self.currentProductUUID];
        

         self.productTransactionList = [JCHTransactionUtility fliterSKUInventoryRecordList:self.inventoryDetailRecord.productSKUInventoryArray
                                                                                forProduct:productRecord];
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createUI];
            [self.view bringSubviewToFront:self.hud];
            [self setProductData:self.inventoryDetailRecord];
            [MBProgressHUD hideHUDForView:self.view animated:NO];
        });
    });
    
    return;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.productTransactionList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cellIdentifier";
    JCHProductDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[JCHProductDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    SKUInventoryRecord4Cocoa *skuInventoryRecord = self.productTransactionList[indexPath.row];
    JCHProductDetailTableViewCellData *cellData = [[[JCHProductDetailTableViewCellData alloc] init] autorelease];
    CGFloat inventoryCount = skuInventoryRecord.currentInventoryCount;
    cellData.count = [NSString stringFromCount:inventoryCount unitDigital:self.inventoryDetailRecord.unitDigits];
    cellData.purchasePrice = [NSString stringWithFormat:@"¥%.2f", skuInventoryRecord.averageCostPrice];
    cellData.shipmentPrice = [NSString stringWithFormat:@"¥%.2f", skuInventoryRecord.shipmentPrice];
    
    GoodsSKURecord4Cocoa *record = nil;
    for (GoodsSKURecord4Cocoa *tempRecord in self.allGoodsSKURecordArray) {
        if ([tempRecord.goodsSKUUUID isEqualToString:skuInventoryRecord.productSKUUUID] && ![skuInventoryRecord.productSKUUUID isEmptyString]) {
            record = tempRecord;
            break;
        }
    }
    
    NSMutableArray *skuValurRecord = [NSMutableArray array];
    for (NSDictionary *dict in record.skuArray) {
        [skuValurRecord addObject:[dict allValues][0]];
    }
    NSDictionary *skuValuedDict = [JCHTransactionUtility getTransactionsWithData:skuValurRecord];
    
    //所有组合
    NSArray *skuValueCombineArray = [skuValuedDict allValues][0];

    cellData.skuCombine = skuValueCombineArray[0] ? skuValueCombineArray[0] : @"无规格";

    [cell setCellData:cellData];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    JCHProductDetailTableSectionView *sectionView = [[[JCHProductDetailTableSectionView alloc] initWithTopLine:NO BottomLine:YES] autorelease];
    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

@end
