//
//  JCHRestaurantManifestDetailViewController.m
//  jinchuhuo
//
//  Created by apple on 2016/12/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHRestaurantManifestDetailViewController.h"
#import "JCHManifestViewController.h"
#import "JCHAddProductMainViewController.h"
#import "JCHRestaurantManifestDetailHeaderView.h"
#import "JCHRestaurantManifestDetailFooterView.h"
#import "ManifestTableFooterView.h"
#import "JCHManifestDetailTableViewCell.h"
#import "JCHManifestDetailSectionVIew.h"
#import "JCHRestaurantManifestDetailTableViewCell.h"
#import "JCHRestaurantManifestDetailSectionView.h"
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

@interface JCHRestaurantManifestDetailViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    JCHRestaurantManifestDetailHeaderView *detailHeaderView;
    JCHRestaurantManifestDetailFooterView *detailFooterView;
    
    UITableView *contentTableView;
}


@property (retain, nonatomic, readwrite) ManifestRecord4Cocoa *manifestRecord;
@property (retain, nonatomic, readwrite) NSMutableDictionary *heightForRow;

//普通货单详情
@property (retain, nonatomic, readwrite) ManifestRecord4Cocoa *currentManifestDetail;

// 拼装单分组的数据源
@property (retain, nonatomic, readwrite) NSArray *assemblingManifestTransactionSectionList;

@end

@implementation JCHRestaurantManifestDetailViewController

- (id)initWithManifestRecord:(ManifestRecord4Cocoa *)manifestRecord;
{
    self = [super init];
    if (self) {
        //self.title = @"货单内容";
        self.manifestRecord = manifestRecord;
        self.heightForRow = [NSMutableDictionary dictionary];
        self.title = @"订单详情";
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
    
    detailHeaderView = [[[JCHRestaurantManifestDetailHeaderView alloc] initWithType:self.manifestRecord.manifestType] autorelease];
    detailHeaderView.frame = CGRectMake(0, 0, kScreenWidth, detailHeaderView.viewHeight);
    contentTableView.tableHeaderView = detailHeaderView;
    
    detailFooterView = [[[JCHRestaurantManifestDetailFooterView alloc] initWithType:self.manifestRecord.manifestType] autorelease];
    detailFooterView.frame = CGRectMake(0, 0, kScreenWidth, detailFooterView.viewHeight);
    contentTableView.tableFooterView = detailFooterView;
    
    return;
}



#pragma mark -
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.currentManifestDetail.manifestTransactionArray.count;
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
    return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect viewFrame = CGRectMake(0, 0, kScreenWidth, 30);
    JCHRestaurantManifestDetailSectionView *sectionView = [[[JCHRestaurantManifestDetailSectionView alloc] initWithFrame:viewFrame] autorelease];
    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kManifestDetailTableViewCellTag = @"kManifestDetailTableViewCellTag";
    JCHRestaurantManifestDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kManifestDetailTableViewCellTag];
    if (nil == cell) {
        
        NSInteger manifestType = self.currentManifestDetail ? self.manifestRecord.manifestType : kJCHManifestInventory;
        cell = [[[JCHRestaurantManifestDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                      reuseIdentifier:kManifestDetailTableViewCellTag
                                                         manifestType:(enum JCHOrderType)manifestType
                                                     isManifestDetail:YES] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    JCHRestaurantManifestDetailTableViewCellData *cellData = [[[JCHRestaurantManifestDetailTableViewCellData alloc] init] autorelease];
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
    cellData.totalAmount = [NSString stringWithFormat:@"%.2f元",
                            transactionRecord.productCount * transactionRecord.productPrice * transactionRecord.productDiscount];
    
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
    id<DiningTableService> diningTableService = [[ServiceFactory sharedInstance] diningTableService];
    id<TableUsageService> tableUsageService = [[ServiceFactory sharedInstance] tableUsageService];
    id<BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        JCHRestaurantManifestDetailHeaderViewData *headerViewData = [[[JCHRestaurantManifestDetailHeaderViewData alloc] init] autorelease];
        JCHRestaurantManifestDetailFooterViewData *footerViewData = [[[JCHRestaurantManifestDetailFooterViewData alloc] init] autorelease];
        NSString *manifestOperator = @"";
        
        TableUsageRecord4Cocoa *tableUsage = [[tableUsageService queryTableUsage:@[self.manifestRecord.manifestID]] firstObject];
        DiningTableRecord4Cocoa *tableRecord = [diningTableService qeryDiningTable:tableUsage.tableID];
        
        self.currentManifestDetail = [manifestService queryPreInsertManifest:self.manifestRecord.manifestID];
        BookMemberRecord4Cocoa *bookMemberRecord = [bookMemberService queryBookMemberWithUserID:[NSString stringWithFormat:@"%ld", self.currentManifestDetail.operatorID]];
        manifestOperator = [JCHDisplayNameUtility getDisplayNickName:bookMemberRecord];
        
        headerViewData.deskNumber = tableRecord.tableName;
        headerViewData.manifestDate = [NSString stringFromSeconds:self.currentManifestDetail.manifestTimestamp dateStringType:kJCHDateStringType5];
        headerViewData.usedTime = [JCHManifestUtility restaurantTimeUsed:self.currentManifestDetail.manifestTimestamp];
        headerViewData.hasFinished = NO;
        headerViewData.manifestOperator = manifestOperator;
        headerViewData.dishesCount = self.currentManifestDetail.manifestTransactionArray.count;
        headerViewData.personCount = tableUsage.numOfCustomer;
        headerViewData.remark = self.currentManifestDetail.manifestRemark;
        
        footerViewData.manifestAmount = self.currentManifestDetail.manifestAmount;
        footerViewData.manifestDiscount = self.currentManifestDetail.manifestDiscount;
        footerViewData.manifestRealPay = [JCHFinanceCalculateUtility roundDownFloatNumber:self.currentManifestDetail.manifestAmount * self.currentManifestDetail.manifestDiscount - self.currentManifestDetail.eraseAmount - self.currentManifestDetail.lessAmount];
        footerViewData.manifestRemark = self.currentManifestDetail.manifestRemark;
        footerViewData.manifestEraseAmount = self.currentManifestDetail.eraseAmount;
        footerViewData.manifestType = self.currentManifestDetail.manifestType;
        footerViewData.hasPayed = self.currentManifestDetail.hasPayed;
        footerViewData.payway = self.currentManifestDetail.paymentMethod;

        dispatch_async(dispatch_get_main_queue(), ^{
            [self createUI];
            [detailHeaderView setViewData:headerViewData];
            [detailFooterView setViewData:footerViewData];
            [contentTableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:NO];
        });
    });
    
    return;
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

