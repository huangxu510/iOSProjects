//
//  JCHManifestDetailViewController.m
//  jinchuhuo
//
//  Created by apple on 15/8/19.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHManifestDetailViewController.h"
#import "JCHManifestViewController.h"
#import "JCHAddProductMainViewController.h"
#import "JCHManifestDetailHeaderView.h"
#import "JCHManifestDetailFooterView.h"
#import "ManifestTableFooterView.h"
#import "JCHManifestDetailTableViewCell.h"
#import "JCHManifestDetailSectionVIew.h"
#import "JCHCreateManifestTableViewCell.h"
#import "JCHCreateManifestTableSectionView.h"
#import "JCHUISizeSettings.h"
#import "ServiceFactory.h"
#import "JCHUIDebugger.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHImageUtility.h"
#import "JCHTransactionUtility.h"
#import "NSString+JCHString.h"
#import "CommonHeader.h"
#import "JCHBluetoothManager.h"
#import "JCHTransactionUtility.h"
#import "JCHManifestMemoryStorage.h"
#import "Masonry.h"

@interface JCHManifestDetailViewController ()
{
    JCHManifestDetailHeaderView *detailHeaderView;
    JCHManifestDetailFooterView *detailFooterView;

    UITableView *contentTableView;
}


@property (retain, nonatomic, readwrite) ManifestRecord4Cocoa *manifestRecord;
@property (retain, nonatomic, readwrite) NSMutableDictionary *heightForRow;

//普通货单详情
@property (retain, nonatomic, readwrite) ManifestRecord4Cocoa *currentManifestDetail;

// 拼装单分组的数据源
@property (retain, nonatomic, readwrite) NSArray *assemblingManifestTransactionSectionList;

@end

@implementation JCHManifestDetailViewController

- (id)initWithManifestRecord:(ManifestRecord4Cocoa *)manifestRecord;
{
    self = [super init];
    if (self) {
        //self.title = @"货单内容";
        self.manifestRecord = manifestRecord;
        self.heightForRow = [NSMutableDictionary dictionary];
        
        
        if (manifestRecord.manifestType == kJCHOrderPurchases) {
            self.title = @"进货单详情";
        } else if (manifestRecord.manifestType == kJCHOrderShipment) {
            self.title = @"出货单详情";
        } else if (manifestRecord.manifestType == kJCHManifestInventory) {
            self.title = @"盘点单详情";
        } else if (manifestRecord.manifestType == kJCHManifestMigrate) {
            self.title = @"移库单详情";
        } else if (manifestRecord.manifestType == kJCHManifestAssembling) {
            self.title = @"拼装单详情";
        } else if (manifestRecord.manifestType == kJCHManifestDismounting) {
            self.title = @"拆装单详情";
        }
    }
    
    return self;
}

- (void)dealloc
{
    [self.currentManifestDetail release];
    [self.manifestRecord release];
    [self.heightForRow release];
    self.assemblingManifestTransactionSectionList = nil;
    
    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadManifestDetail];
    
    
    return;
}


- (void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.manifestRecord.manifestType == kJCHOrderPurchases || self.manifestRecord.manifestType == kJCHOrderShipment) {
#if !TARGET_OS_SIMULATOR
        if ([JCHBluetoothManager shareInstance].canPrintInManifestDetail) {
            UIButton *printButton = [JCHUIFactory createButton:CGRectMake(0, 0, 40, 44)
                                                        target:self
                                                        action:@selector(print)
                                                         title:@""
                                                    titleColor:nil
                                               backgroundColor:nil];
            [printButton setImage:[UIImage imageNamed:@"goodslist_ic"] forState:UIControlStateNormal];
            
            UIBarButtonItem *editButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:printButton] autorelease];
            
            UIBarButtonItem *fixedSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
            fixedSpace.width = -5;
            self.navigationItem.rightBarButtonItems = @[fixedSpace, editButtonItem];
        }
#endif
    } 

    
    contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:contentTableView];
    
    [contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    detailHeaderView = [[[JCHManifestDetailHeaderView alloc] initWithType:self.manifestRecord.manifestType] autorelease];
    detailHeaderView.frame = CGRectMake(0, 0, kScreenWidth, detailHeaderView.viewHeight);
    contentTableView.tableHeaderView = detailHeaderView;
    
    detailFooterView = [[[JCHManifestDetailFooterView alloc] initWithType:self.manifestRecord.manifestType] autorelease];
    detailFooterView.frame = CGRectMake(0, 0, kScreenWidth, detailFooterView.viewHeight);
    contentTableView.tableFooterView = detailFooterView;
    
    return;
}



#pragma mark -
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.manifestRecord.manifestType == kJCHManifestAssembling) {
        return self.assemblingManifestTransactionSectionList.count;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.manifestRecord.manifestType == kJCHOrderShipment ||
        self.manifestRecord.manifestType == kJCHOrderPurchases ||
        self.manifestRecord.manifestType == kJCHManifestMigrate ||
        self.manifestRecord.manifestType == kJCHManifestDismounting)
    {
        return self.currentManifestDetail.manifestTransactionArray.count;
    } else if (self.manifestRecord.manifestType == kJCHManifestInventory) {
        return self.currentManifestDetail.countingTransactionArray.count;
    } else if (self.manifestRecord.manifestType == kJCHManifestAssembling) {
        return 1;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *height = [self.heightForRow objectForKey:@(indexPath.row)];
    return [height doubleValue];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.manifestRecord.manifestType == kJCHManifestAssembling) {
        if (section == 0) {
            return 30;
        } else {
            return 1;
        }
    } else {
       return 30.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.manifestRecord.manifestType == kJCHManifestAssembling) {
        if (section == 0) {
            CGRect viewFrame = CGRectMake(0, 0, kScreenWidth, 30);
            JCHManifestDetailSectionView *sectionView = [[[JCHManifestDetailSectionView alloc] initWithFrame:viewFrame manifestType:self.manifestRecord.manifestType] autorelease];
            return sectionView;
        } else {
            return nil;
        }
    } else {
        CGRect viewFrame = CGRectMake(0, 0, kScreenWidth, 30);
        JCHManifestDetailSectionView *sectionView = [[[JCHManifestDetailSectionView alloc] initWithFrame:viewFrame manifestType:self.manifestRecord.manifestType] autorelease];
        return sectionView;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kManifestDetailTableViewCellTag = @"kManifestDetailTableViewCellTag";
    JCHCreateManifestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kManifestDetailTableViewCellTag];
    if (nil == cell) {
        
        NSInteger manifestType = self.currentManifestDetail ? self.manifestRecord.manifestType : kJCHManifestInventory;
        cell = [[[JCHCreateManifestTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                      reuseIdentifier:kManifestDetailTableViewCellTag
                                                         manifestType:(enum JCHOrderType)manifestType
                                                     isManifestDetail:YES] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    
    
    
    JCHCreateManifestTableViewCellData *cellData = [[[JCHCreateManifestTableViewCellData alloc] init] autorelease];
    
    if (self.manifestRecord.manifestType == kJCHOrderPurchases ||
        self.manifestRecord.manifestType == kJCHOrderShipment ||
        self.manifestRecord.manifestType == kJCHManifestMigrate ||
        self.manifestRecord.manifestType == kJCHManifestDismounting) {
        ManifestTransactionRecord4Cocoa *transactionRecord = self.currentManifestDetail.manifestTransactionArray[indexPath.row];
        cellData.productName = transactionRecord.productName;
        cellData.productCount = [NSString stringFromCount:transactionRecord.productCount unitDigital:transactionRecord.unitDigits];
        
        //cellData.productCount = [NSString stringWithFormat:@"%.2f", transactionRecord.productCount];
        cellData.productPrice = [NSString stringWithFormat:@"%.2f", transactionRecord.productPrice];
        cellData.productDiscount = [NSString stringWithFormat:@"%.2f", transactionRecord.productDiscount];
        
        
        id <SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
        GoodsSKURecord4Cocoa *skuRecord = nil;
        
        [skuService queryGoodsSKU:transactionRecord.goodsSKUUUID skuArray:&skuRecord];
        
        
        NSMutableArray *skuValueRecordArray = [NSMutableArray array];
        for (NSDictionary *dict in skuRecord.skuArray) {
            [skuValueRecordArray addObject:[dict allValues][0]];
        }
        NSDictionary *skuDict = [JCHTransactionUtility getTransactionsWithData:skuValueRecordArray];
        cellData.productSKUValueCombine = skuDict ? [skuDict allValues][0][0] : @"";
        cellData.productImageName = transactionRecord.productImageName;
        cellData.productUnit = transactionRecord.productUnit;
        cellData.productProperty = transactionRecord.dishProperty;
    
    } else if (self.manifestRecord.manifestType == kJCHManifestAssembling) {
        
        ManifestTransactionRecord4Cocoa *transactionRecord = [self.assemblingManifestTransactionSectionList[indexPath.section] firstObject];
        cellData.productName = transactionRecord.productName;
        cellData.productCount = [NSString stringFromCount:transactionRecord.productCount unitDigital:transactionRecord.unitDigits];
        
        //cellData.productCount = [NSString stringWithFormat:@"%.2f", transactionRecord.productCount];
        cellData.productPrice = [NSString stringWithFormat:@"%.2f", transactionRecord.productPrice];
        cellData.productDiscount = [NSString stringWithFormat:@"%.2f", transactionRecord.productDiscount];
        cellData.productSKUValueCombine = @"";
        cellData.productImageName = transactionRecord.productImageName;
        cellData.productUnit = transactionRecord.productUnit;
        
        
        NSArray *auxiliaryUnitDetailList = self.assemblingManifestTransactionSectionList[indexPath.section];
        NSMutableString *mainAuxiliaryUnitCountInfo = [NSMutableString string];
        for (NSInteger i = 0; i < auxiliaryUnitDetailList.count; i++) {
            ManifestTransactionRecord4Cocoa *auxiliaryRecord = auxiliaryUnitDetailList[i];
            NSString *productCount = [NSString stringFromCount:auxiliaryRecord.productCount unitDigital:auxiliaryRecord.unitDigits];
            if (i == 0) {
                [mainAuxiliaryUnitCountInfo appendString:[NSString stringWithFormat:@"%@%@", productCount, auxiliaryRecord.productUnit]];
            } else {
                [mainAuxiliaryUnitCountInfo appendString:[NSString stringWithFormat:@"%@%@%@",  @";", productCount, auxiliaryRecord.productUnit]];
            }
        }
        cellData.mainAuxiliaryUnitCountInfo = mainAuxiliaryUnitCountInfo;
    } else if (self.manifestRecord.manifestType == kJCHManifestInventory) {
        CountingTransactionRecord4Cocoa *transactionRecord = self.currentManifestDetail.countingTransactionArray[indexPath.row];
        cellData.productName = transactionRecord.productName;
        cellData.productCount = [NSString stringFromCount:transactionRecord.productCountAfter unitDigital:transactionRecord.unitDigits];
        cellData.productPrice = [NSString stringWithFormat:@"%.2f", transactionRecord.averagePriceAfter];
        
        CGFloat productIncreaseCount = transactionRecord.productCountAfter - transactionRecord.productCountBefore;
        cellData.productIncreaseCount = [NSString stringFromCount:productIncreaseCount unitDigital:transactionRecord.unitDigits];
        id <SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
        GoodsSKURecord4Cocoa *skuRecord = nil;
        
        [skuService queryGoodsSKU:transactionRecord.productSKUUUID skuArray:&skuRecord];
        
        NSMutableArray *skuValueRecordArray = [NSMutableArray array];
        for (NSDictionary *dict in skuRecord.skuArray) {
            [skuValueRecordArray addObject:[dict allValues][0]];
        }
        NSDictionary *skuDict = [JCHTransactionUtility getTransactionsWithData:skuValueRecordArray];
        cellData.productSKUValueCombine = skuDict ? [skuDict allValues][0][0] : @"";
        cellData.productImageName = transactionRecord.productImageName;
        cellData.productUnit = transactionRecord.productUnit;
    }
    
    [cell setData:cellData];
    [self.heightForRow setObject:@(cell.cellHeight) forKey:@(indexPath.row)];

    return cell;
}

#pragma mark - LoadData

- (void)loadManifestDetail
{
    [MBProgressHUD showHUDWithTitle:@"加载中..."
                             detail:nil
                           duration:100
                               mode:MBProgressHUDModeIndeterminate
                          superView:self.view
                         completion:nil];
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    id<BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        JCHManifestDetailHeaderViewData *viewData = [[[JCHManifestDetailHeaderViewData alloc] init] autorelease];
        JCHManifestDetailFooterViewData *footerViewData = [[[JCHManifestDetailFooterViewData alloc] init] autorelease];
        NSString *manifestOperator = @"";
        
        self.currentManifestDetail = [manifestService queryManifestDetail:self.manifestRecord.manifestID];
        
        if (self.manifestRecord.manifestType == kJCHOrderShipment ||
            self.manifestRecord.manifestType == kJCHOrderPurchases ||
            self.manifestRecord.manifestType == kJCHManifestMigrate ||
            self.manifestRecord.manifestType == kJCHManifestAssembling ||
            self.manifestRecord.manifestType == kJCHManifestDismounting)
        {
            //进货单、出货单、移库单
            BookMemberRecord4Cocoa *bookMemberRecord = [bookMemberService queryBookMemberWithUserID:[NSString stringWithFormat:@"%ld", self.currentManifestDetail.operatorID]];
            manifestOperator = [JCHDisplayNameUtility getDisplayNickName:bookMemberRecord];
            
            viewData.manifestID = self.currentManifestDetail.manifestID;
            viewData.manifestDate = [NSString stringFromSeconds:self.currentManifestDetail.manifestTimestamp dateStringType:kJCHDateStringType5];
            viewData.manifestType = self.currentManifestDetail.manifestType;
            viewData.manifestBuyer = self.currentManifestDetail.buyerName;
            viewData.manifestSeller = self.currentManifestDetail.sellerName;
            viewData.manifestOperator = manifestOperator;
            viewData.productCount = self.currentManifestDetail.manifestTransactionArray.count;
            
            CGFloat totalCount = 0;
            for (ManifestTransactionRecord4Cocoa *record in self.currentManifestDetail.manifestTransactionArray) {
                totalCount += record.productCount;
            }
            viewData.totalCount = totalCount;
            WarehouseRecord4Cocoa *sourceWarehouseRecord = [warehouseService queryWarehouseByUUID:self.currentManifestDetail.sourceWarehouseID];
            WarehouseRecord4Cocoa *targetWarehouseRecord = [warehouseService queryWarehouseByUUID:self.currentManifestDetail.targetWarehouseID];
            
            if (self.manifestRecord.manifestType == kJCHManifestMigrate) {
                viewData.manifestWarehouseInfo = [NSString stringWithFormat:@"源仓库：%@   目标仓库：%@", sourceWarehouseRecord.warehouseName, targetWarehouseRecord.warehouseName];
            } else {
                viewData.manifestWarehouseInfo = sourceWarehouseRecord.warehouseName;
            }
            
            
            footerViewData.manifestAmount = self.currentManifestDetail.manifestAmount;
            footerViewData.manifestDiscount = self.currentManifestDetail.manifestDiscount;
            
            
#if MMR_TAKEOUT_VERSION
            NSString *boxFeeAccountUUID = [manifestService getBoxFeeAccountUUID];
            NSString *shippingFeeAccountUUID = [manifestService getShippingFeeAccountUUID];
            NSArray *feeList = self.currentManifestDetail.feeList;
            for (FeeRecord4Cocoa *feeRecord in feeList) {
                if ([feeRecord.feeAccountUUID isEqualToString:boxFeeAccountUUID]) {
                    footerViewData.boxAmount = feeRecord.fee;
                } else if ([feeRecord.feeAccountUUID isEqualToString:shippingFeeAccountUUID]) {
                    footerViewData.deliveryAmount = feeRecord.fee;
                }
            }
            footerViewData.manifestRealPay = [JCHFinanceCalculateUtility roundDownFloatNumber:self.currentManifestDetail.finalAmount];
#else
            footerViewData.manifestRealPay = [JCHFinanceCalculateUtility roundDownFloatNumber:self.currentManifestDetail.manifestAmount * self.currentManifestDetail.manifestDiscount - self.currentManifestDetail.eraseAmount - self.currentManifestDetail.lessAmount];
#endif
            
            footerViewData.manifestRemark = self.currentManifestDetail.manifestRemark;
            footerViewData.manifestEraseAmount = self.currentManifestDetail.eraseAmount;
            footerViewData.manifestType = self.currentManifestDetail.manifestType;
            
            footerViewData.hasPayed = self.currentManifestDetail.hasPayed;
            footerViewData.payway = self.currentManifestDetail.paymentMethod;
            
            if (self.manifestRecord.manifestType == kJCHManifestAssembling) {
                self.assemblingManifestTransactionSectionList = [self subSectionManifestArrayForAssembling:self.currentManifestDetail.manifestTransactionArray];
            }
            
        } else if (self.manifestRecord.manifestType == kJCHManifestInventory) {
            //盘点单
            NSInteger increaseSKUCount = 0;
            NSInteger decreaseSKUCount = 0;
            CGFloat increaseCount = 0;
            CGFloat decreaseCount = 0;
            for (CountingTransactionRecord4Cocoa *transactionRecord in self.currentManifestDetail.countingTransactionArray) {
                
                CGFloat productCountDiff = transactionRecord.productCountAfter - transactionRecord.productCountBefore;
                //盘盈
                if (productCountDiff > 0) {
                    increaseSKUCount++;
                    increaseCount += productCountDiff;
                } else if (productCountDiff < 0) {
                    //盘亏
                    decreaseSKUCount++;
                    decreaseCount += fabs(productCountDiff);
                }
            }
            
            BookMemberRecord4Cocoa *bookMemberRecord = [bookMemberService queryBookMemberWithUserID:[NSString stringWithFormat:@"%ld", self.currentManifestDetail.operatorID]];
            manifestOperator = [JCHDisplayNameUtility getDisplayNickName:bookMemberRecord];
            
            viewData.manifestID = self.currentManifestDetail.manifestID;
            viewData.manifestDate = [NSString stringFromSeconds:self.currentManifestDetail.manifestTimestamp dateStringType:kJCHDateStringType5];
            viewData.manifestType = kJCHManifestInventory;
            viewData.manifestOperator = manifestOperator;
            viewData.productCount = self.currentManifestDetail.countingTransactionArray.count;
            viewData.increaseSKUCount = increaseSKUCount;
            viewData.increaseCount = increaseCount;
            viewData.decreaseSKUCount = decreaseSKUCount;
            viewData.decreaseCount = decreaseCount;
            WarehouseRecord4Cocoa *warehouseRecord = [warehouseService queryWarehouseByUUID:self.currentManifestDetail.sourceWarehouseID];
            viewData.manifestWarehouseInfo = warehouseRecord.warehouseName;
            
            
            footerViewData.manifestRemark = self.currentManifestDetail.manifestRemark;
            footerViewData.manifestType = kJCHManifestInventory;
        }
       
        

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self createUI];
            [detailHeaderView setViewData:viewData];
            [detailFooterView setViewData:footerViewData];
            [contentTableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:NO];
        });
    });
    
    return;
}

- (NSArray *)subSectionManifestArrayForAssembling:(NSArray *)manifestArray
{
    // 根据ManifestTransactionDetail中的goodsNameUUID字段进行分组
    NSMutableSet *set = [NSMutableSet set];
    
    [manifestArray enumerateObjectsUsingBlock:^(ManifestTransactionRecord4Cocoa *detail, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (void)print
{
    id <SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    
    NSMutableArray *transactionList = [NSMutableArray array];
    for (ManifestTransactionRecord4Cocoa *transactionRecord in self.currentManifestDetail.manifestTransactionArray) {
        ManifestTransactionDetail *detail = [[[ManifestTransactionDetail alloc] init] autorelease];
        detail.productName = transactionRecord.productName;
        detail.productCount =  [NSString stringFromCount:transactionRecord.productCount unitDigital:transactionRecord.unitDigits];
        detail.productPrice = [NSString stringWithFormat:@"%.2f", transactionRecord.productPrice];
        detail.productDiscount = [NSString stringWithFormat:@"%.2f", transactionRecord.productDiscount];
        //detail.skuValueCombine =
        
        GoodsSKURecord4Cocoa *skuRecord = nil;
        
        [skuService queryGoodsSKU:transactionRecord.goodsSKUUUID skuArray:&skuRecord];
        
        
        NSMutableArray *skuValueRecordArray = [NSMutableArray array];
        for (NSDictionary *dict in skuRecord.skuArray) {
            [skuValueRecordArray addObject:[dict allValues][0]];
        }
        NSDictionary *skuDict = [JCHTransactionUtility getTransactionsWithData:skuValueRecordArray];
        detail.skuValueCombine = [skuDict allValues][0][0];
        
        [transactionList addObject:detail];
    }
    
    NSString *contactName = nil;
    if (self.currentManifestDetail.manifestType == kJCHOrderPurchases || self.currentManifestDetail.manifestType == kJCHOrderPurchasesReject) {
        contactName = self.currentManifestDetail.sellerName;
    } else if (self.currentManifestDetail.manifestType == kJCHOrderShipment || self.currentManifestDetail.manifestType == kJCHOrderShipmentReject) {
        contactName = self.currentManifestDetail.buyerName;
    }

    JCHPrintInfoModel *printInfo = [[[JCHPrintInfoModel alloc] init] autorelease];
    printInfo.manifestType = self.currentManifestDetail.manifestType;
    printInfo.manifestID = self.currentManifestDetail.manifestID;
    printInfo.manifestDate = self.currentManifestDetail.manifestDate;
    printInfo.manifestDiscount = self.currentManifestDetail.manifestDiscount;
    printInfo.eraseAmount = self.currentManifestDetail.eraseAmount;
    printInfo.manifestRemark = self.currentManifestDetail.manifestRemark;
    printInfo.contactName = contactName;
    printInfo.hasPayed = self.currentManifestDetail.hasPayed;
    printInfo.transactionList = transactionList;
    printInfo.otherFeeList = self.currentManifestDetail.feeList;
    
#if !TARGET_OS_SIMULATOR
    [[JCHBluetoothManager shareInstance] printManifest:printInfo showHud:YES];
#endif
}

@end
