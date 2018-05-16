//
//  JCHTemporaryManifestViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/4/5.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTempManifestViewController.h"
#import "JCHCreateManifestViewController.h"
#import "JCHSettleAccountsViewController.h"
#import "JCHManifestListTableViewCell.h"
#import "ServiceFactory.h"
#import "CommonHeader.h"
#import "JCHPerimissionUtility.h"
#import "JCHManifestMemoryStorage.h"

@interface JCHTempManifestViewController () <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate>
{
    UITableView *_contentTableView;
}

@property (nonatomic, retain) NSMutableArray *allTempManifestList;
@property (nonatomic, retain) JCHManifestListTableViewCell *lastEditingCell;

@end

@implementation JCHTempManifestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"挂单清单";
    [self createUI];
    [self lodaData];
}

- (void)dealloc
{
    [self.allTempManifestList release];
    [self.lastEditingCell release];
    
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_contentTableView deselectRowAtIndexPath:[_contentTableView indexPathForSelectedRow] animated:YES];

    return;
}


- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    _contentTableView.dataSource = self;
    _contentTableView.delegate = self;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_contentTableView];
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - LoadData
- (void)lodaData
{
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    
    NSArray *allTempManifestList = nil;
    [manifestService queryStashManifestList:0
                                   pageSize:-1
                                  condition:nil
                        manifestRecordArray:&allTempManifestList];
    self.allTempManifestList = [NSMutableArray arrayWithArray:allTempManifestList];
    
    [self.allTempManifestList sortUsingComparator:^NSComparisonResult(ManifestRecord4Cocoa *obj1, ManifestRecord4Cocoa *obj2) {
        return obj1.manifestTimestamp < obj2.manifestTimestamp;
    }];
    [_contentTableView reloadData];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allTempManifestList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *kCellReuseTag = @"kCellReuseTag";
    JCHManifestListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseTag];
    if (nil == cell) {
        cell = [[[JCHManifestListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellReuseTag] autorelease];
    }
    
    [cell setButtonStateSelected:NO];
    

    ManifestInfo *manifestInfo = [[[ManifestInfo alloc] init] autorelease];
    ManifestRecord4Cocoa *manifestRecord = self.allTempManifestList[indexPath.row];
    manifestInfo.hasPayed = manifestRecord.hasPayed;
    manifestInfo.isManifestReturned = manifestRecord.isManifestReturned;
    manifestInfo.manifestType = manifestRecord.manifestType;
    manifestInfo.manifestOrderID = manifestRecord.manifestID;
    manifestInfo.manifestDate = [NSString stringFromSeconds:manifestRecord.manifestTimestamp dateStringType:kJCHDateStringType2];
    manifestInfo.manifestAmount = [NSString stringWithFormat:@"%.2f", [JCHFinanceCalculateUtility roundDownFloatNumber:manifestRecord.manifestAmount * manifestRecord.manifestDiscount - manifestRecord.eraseAmount - manifestRecord.lessAmount]];
    manifestInfo.operatorID = manifestRecord.operatorID;
    manifestInfo.manifestProductCount = manifestRecord.productCount;
    
    if (manifestRecord.manifestRemark == nil || [manifestRecord.manifestRemark isEqualToString:@""]){
        NSMutableArray *productNames = [NSMutableArray array];
        for (ManifestTransactionRecord4Cocoa *transactionRecord in manifestRecord.manifestTransactionArray) {
            if (![productNames containsObject:transactionRecord.productName]) {
                [productNames addObject:transactionRecord.productName];
            }
        }
        NSMutableString *remarkStr = [NSMutableString stringWithString:@""];
        
        if (productNames.count > 0) {
            for (NSString *productName in productNames) {
                [remarkStr appendString:[NSString stringWithFormat:@"%@、", productName]];
            }
            [remarkStr deleteCharactersInRange:NSMakeRange(remarkStr.length - 1, 1)];
        }
        
        manifestInfo.manifestRemark = remarkStr;
    } else {
        manifestInfo.manifestRemark = manifestRecord.manifestRemark;
    }

    
    NSArray *rightButtons = [self rightButtons];
    [cell setRightUtilityButtons:rightButtons WithButtonWidth:[JCHSizeUtility calculateWidthWithSourceWidth:65.0f]];
    
    cell.delegate = self;
    

    [cell setCellData:manifestInfo];
    return cell;
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightButons = [NSMutableArray array];
    
    [rightButons sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f) icon:[UIImage imageNamed:@"manifest_more_open_add"]];
    [rightButons sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f) icon:[UIImage imageNamed:@"manifest_more_open_checkout"]];
    
    [rightButons sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f) icon:[UIImage imageNamed:@"manifest_more_open_delete2"]];
    
    
    return rightButons;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ManifestRecord4Cocoa *manifestRecord = self.allTempManifestList[indexPath.row];
    [self createManifest:manifestRecord];
    
    
    JCHCreateManifestViewController *manifestViewController = [[[JCHCreateManifestViewController alloc] init] autorelease];
    manifestViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:manifestViewController animated:YES];

    return;
}


#pragma mark - SWTableViewCellDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [_contentTableView indexPathForCell:cell];
    ManifestRecord4Cocoa *manifestRecord = self.allTempManifestList[indexPath.row];
    if (index == 0 || index == 1) {

        [self createManifest:manifestRecord];
    }
    
    switch (index) {
        case 0: //继续添加
        {
            self.hidesBottomBarWhenPushed = YES;
            JCHAddProductMainViewController *addProductViewController = [[[JCHAddProductMainViewController alloc] init] autorelease];
            [self.navigationController pushViewController:addProductViewController animated:YES];
        }
            break;
            
        case 1: //结账
        {
            self.hidesBottomBarWhenPushed = YES;
            JCHSettleAccountsViewController *settleAccountsVC = [[[JCHSettleAccountsViewController alloc] init] autorelease];
            [self.navigationController pushViewController:settleAccountsVC animated:YES];
        }
            break;
            
        case 2: //删除
        {

            id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
            int status = [manifestService deleteStashManifest:manifestRecord.manifestID];
            if (status == 0) {
                [self.allTempManifestList removeObject:manifestRecord];
                [_contentTableView beginUpdates];
                [_contentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [_contentTableView endUpdates];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    JCHManifestListTableViewCell *myCell = (JCHManifestListTableViewCell *)cell;
    if (state == kCellStateCenter) {
        [myCell setButtonStateSelected:NO];
        
    } else if (state == kCellStateRight)
    {
        if (self.lastEditingCell != cell) {
            [self.lastEditingCell hideUtilityButtonsAnimated:YES];
        }
        
        self.lastEditingCell = (JCHManifestListTableViewCell *)cell;
        [myCell setButtonStateSelected:YES];
    }
}

- (void)swipeableTableViewCellDidEndScrolling:(SWTableViewCell *)cell
{
    
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

- (void)createManifest:(ManifestRecord4Cocoa *)manifestRecord
{
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    id<ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    [manifestStorage clearData];
    
    manifestStorage.manifestMemoryType = kJCHManifestMemoryTypeNew;
    manifestStorage.currentManifestID = manifestRecord.manifestID;
    manifestStorage.currentManifestDate = [NSString stringFromSeconds:manifestRecord.manifestTimestamp dateStringType:kJCHDateStringType5];
    manifestStorage.currentManifestType = (enum JCHOrderType)manifestRecord.manifestType;
    manifestStorage.currentManifestRemark = manifestRecord.manifestRemark;
    manifestStorage.currentManifestDiscount = manifestRecord.manifestDiscount;
    manifestStorage.currentManifestEraseAmount = manifestRecord.eraseAmount;
    manifestStorage.isRejected = ![JCHFinanceCalculateUtility floatValueIsZero:manifestRecord.eraseAmount];
    manifestStorage.hasPayed = manifestRecord.hasPayed;
    
    
    //联系人UUID
    NSString *defaultBuyerUUID = [manifestService getDefaultCustomUUID];
    NSString *defaultSellerUUID = [manifestService getDefaultSupplierUUID];
    NSString *contactUUID = nil;
    if (manifestRecord.manifestType == kJCHOrderPurchases && ![manifestRecord.sellerUUID isEqualToString:defaultSellerUUID]) {
        contactUUID = manifestRecord.sellerUUID;
    } else if (manifestRecord.manifestType == kJCHOrderShipment && ![manifestRecord.buyerUUID isEqualToString:defaultBuyerUUID  ]) {
        contactUUID = manifestRecord.buyerUUID;
    } else {
        //pass
    }
    
    if (contactUUID) {
        ContactsRecord4Cocoa *contactRecord = [contactsService queryContacts:contactUUID];
        manifestStorage.currentContactsRecord = contactRecord;
    } else {
        manifestStorage.currentContactsRecord = nil;
    }
    
    
    for (ManifestTransactionRecord4Cocoa *transactionRecord in manifestRecord.manifestTransactionArray) {
        ManifestTransactionDetail *transactionDetail = [[[ManifestTransactionDetail alloc] init] autorelease];
        transactionDetail.productCategory    = transactionRecord.productCategory;
        transactionDetail.productName        = transactionRecord.productName;
        transactionDetail.productImageName   = transactionRecord.productImageName;
        transactionDetail.productUnit        = transactionRecord.productUnit;
        transactionDetail.productCount       = [NSString stringFromCount:transactionRecord.productCount unitDigital:transactionRecord.unitDigits];;
        transactionDetail.productPrice       = [NSString stringWithFormat:@"%.2f", transactionRecord.productPrice];
        transactionDetail.productDiscount    = [NSString stringWithFormat:@"%.2f", transactionRecord.productDiscount];
        transactionDetail.productUnit_digits = transactionRecord.unitDigits;
        transactionDetail.warehouseUUID      = transactionRecord.warehouseUUID;
        transactionDetail.transactionUUID    = transactionRecord.transactionUUID;
        transactionDetail.unitUUID           = transactionRecord.unitUUID;
        transactionDetail.goodsNameUUID      = transactionRecord.goodsNameUUID;
        transactionDetail.goodsCategoryUUID  = transactionRecord.goodsCategoryUUID;
        
        //transactionDetail.productInventoryCount
        
        
        GoodsSKURecord4Cocoa *skuRecord = nil;
        [skuService queryGoodsSKU:transactionRecord.goodsSKUUUID skuArray:&skuRecord];
        
        NSMutableArray *skuValueRecordArray = [NSMutableArray array];
        for (NSDictionary *dict in skuRecord.skuArray) {
            [skuValueRecordArray addObject:[dict allValues][0]];
        }
        NSDictionary *skuDict = [JCHTransactionUtility getTransactionsWithData:skuValueRecordArray];
        transactionDetail.skuValueUUIDs = [skuDict allKeys][0][0];
        
        if (skuRecord.skuArray.count == 0) {
            transactionDetail.skuValueCombine = @"";
        } else {
            transactionDetail.skuValueCombine = [skuDict allValues][0][0];
        }
        
        id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
        ProductRecord4Cocoa *productRecord = [productService queryProductByUUID:transactionRecord.goodsNameUUID];
        transactionDetail.skuHidenFlag = productRecord.sku_hiden_flag;
        
        manifestStorage.warehouseID = transactionRecord.warehouseUUID;
        [manifestStorage addManifestRecord:transactionDetail];
    }
}


@end
