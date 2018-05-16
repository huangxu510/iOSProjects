//
//  JCHChargeAccountDetailViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHChargeAccountDetailViewController.h"
#import "JCHChargeAccountViewController.h"
#import "JCHAccountBookViewController.h"
#import "JCHManifestDetailViewController.h"
#import "JCHCheckoutOnAccountViewController.h"
#import "JCHChargeAccountTableSecionView.h"
#import "JCHChargeAccountFooterView.h"
#import "JCHManifestListTableViewCell.h"
#import "CommonHeader.h"
#import "ServiceFactory.h"
#import "JCHPinYinUtility.h"
#import "JCHManifestType.h"
#import "JCHManifestMemoryStorage.h"
#import <Masonry.h>

@interface JCHChargeAccountDetailViewController () <UITableViewDataSource,
                                                    UITableViewDelegate,
                                                    SWTableViewCellDelegate,
                                                    JCHChargeAccountFooterViewDelegate>
{
    UITableView *_contentTableView;
    JCHChargeAccountFooterView *_footerView;
    JCHChargeAccountType _currentChargeAccountType;
}

@property (nonatomic, retain) NSString *contactsUUID;
@property (nonatomic, retain) JCHManifestListTableViewCell *lastEditingCell;

@end

@implementation JCHChargeAccountDetailViewController

- (instancetype)initWithContactsUUID:(NSString *)contactsUUID
                   chargeAccountType:(JCHChargeAccountType)chargeAccountType
{
    self = [super init];
    if (self) {
        self.contactsUUID = contactsUUID;
        _currentChargeAccountType = chargeAccountType;
    }
    return self;
}

- (void)dealloc
{
    [self.allManifest release];
    [self.contactsUUID release];
    [self.lastEditingCell release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    if (self.isNeedReloadAllData) {
        [self loadData];
        self.isNeedReloadAllData = NO;
    }
}


- (void)createUI
{
    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    _contentTableView.dataSource = self;
    _contentTableView.delegate = self;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _contentTableView.tableFooterView = [[[UIView alloc] init] autorelease];
    _contentTableView.backgroundColor = JCHColorGlobalBackground;
    [self.view addSubview:_contentTableView];
    
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(self.view);
        make.bottom.equalTo(self.view);//.with.offset(-49);
    }];
    
    [_contentTableView registerClass:[JCHManifestListTableViewCell class] forCellReuseIdentifier:@"cell"];
    
#if 0
    _footerView = [[[JCHChargeAccountFooterView alloc] initWithFrame:CGRectZero] autorelease];
    _footerView.delegate = self;
    [self.view addSubview:_footerView];
    
    [_footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.equalTo(self.view);
        make.top.equalTo(_contentTableView.mas_bottom);
    }];
#endif
}


#pragma mark - LoadData
- (void)loadData
{
    __block BOOL isFinishedLoadData = NO;
    if ([MBProgressHUD getHudShowingStatus]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (!isFinishedLoadData) {
                [MBProgressHUD showHUDWithTitle:@"加载中..."
                                         detail:nil
                                       duration:100
                                           mode:MBProgressHUDModeIndeterminate
                                      superView:self.view
                                     completion:nil];
            }
        });
    } else {
        [MBProgressHUD showHUDWithTitle:@"加载中..."
                                 detail:nil
                               duration:100
                                   mode:MBProgressHUDModeIndeterminate
                              superView:self.view
                             completion:nil];
    }
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *allManifestList = nil;
        
        if (_currentChargeAccountType == kJCHChargeAccountReceipt) {
            //! @brief 查询指定用户应收账款对应的货单列表
            [manifestService queryManifestOfAccountReceivable:self.contactsUUID manifestRecordArray:&allManifestList];
        } else if (_currentChargeAccountType == kJCHChargeAccountPayment) {
            //! @brief 查询指定用户应付账款对应的货单列表
            [manifestService queryManifestOfAccountPayable:self.contactsUUID manifestRecordArray:&allManifestList];
        } else {
            return;
        }
        
        
        NSMutableArray *manifestList_sorted = [NSMutableArray arrayWithArray:[allManifestList sortedArrayUsingComparator:^NSComparisonResult(ManifestRecord4Cocoa *obj1, ManifestRecord4Cocoa *obj2) {
            return obj1.manifestTimestamp < obj2.manifestTimestamp;
        }]];
        
        //去除退货单
        for (ManifestRecord4Cocoa *record in allManifestList) {
            if ((record.manifestType == kJCHOrderPurchasesReject) || (record.manifestType == kJCHOrderShipmentReject)) {
                [manifestList_sorted removeObject:record];
            }
        }
        
        self.allManifest = manifestList_sorted;
        
        CGFloat totalAmount = 0.0f;
        for (ManifestRecord4Cocoa *manifestRecord in self.allManifest) {
            totalAmount += manifestRecord.manifestAmount * manifestRecord.manifestDiscount;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_footerView setViewData:totalAmount];
            [_contentTableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:NO];
            isFinishedLoadData = YES;
        });
    });
    
    return;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allManifest.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHManifestListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setButtonStateSelected:NO];
    ManifestRecord4Cocoa *manifestRecord = self.allManifest[indexPath.row];
    
    ManifestInfo *manifestInfo = [[[ManifestInfo alloc] init] autorelease];
    
    manifestInfo.isManifestReturned = manifestRecord.isManifestReturned;
    manifestInfo.manifestType = manifestRecord.manifestType;
    manifestInfo.manifestOrderID = manifestRecord.manifestID;
    manifestInfo.manifestDate = [NSString stringFromSeconds:manifestRecord.manifestTimestamp dateStringType:kJCHDateStringType2];
    manifestInfo.manifestAmount = [NSString stringWithFormat:@"%.2f", [JCHFinanceCalculateUtility roundDownFloatNumber:manifestRecord.manifestAmount * manifestRecord.manifestDiscount - manifestRecord.eraseAmount]];
    
    if (manifestRecord.manifestRemark == nil || [manifestRecord.manifestRemark isEqualToString:@""]){
        NSMutableArray *productNames = [NSMutableArray array];
        for (ManifestTransactionRecord4Cocoa *transactionRecord in manifestRecord.manifestTransactionArray) {
            if (![productNames containsObject:transactionRecord.productName]) {
                [productNames addObject:transactionRecord.productName];
            }
        }
        NSMutableString *remarkStr = [NSMutableString stringWithString:@"此单商品包括:"];
        for (NSString *productName in productNames) {
            [remarkStr appendString:[NSString stringWithFormat:@"%@、", productName]];
        }
        [remarkStr deleteCharactersInRange:NSMakeRange(remarkStr.length - 1, 1)];
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

    [rightButons sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f) icon:[UIImage imageNamed:@"manifest_more_open_checkout"]];

    return rightButons;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 62.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    JCHChargeAccountTableSecionView *sectionView = [[[JCHChargeAccountTableSecionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 62.0f)] autorelease];
    
    JCHChargeAccountTableSecionViewData *data = [[[JCHChargeAccountTableSecionViewData alloc] init] autorelease];
    
    data.headImageName = nil;;
    
    id<ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
    ContactsRecord4Cocoa *contactsRecord = [contactsService queryContacts:self.contactsUUID];
    data.memberName = contactsRecord.name;
    data.phoneNumber = contactsRecord.phone;
    NSString *manifestCountInfo = nil;
    if (_currentChargeAccountType == kJCHChargeAccountReceipt) {
        manifestCountInfo = [NSString stringWithFormat:@"%ld个未收款", self.allManifest.count];
    } else if (_currentChargeAccountType == kJCHChargeAccountPayment) {
        manifestCountInfo = [NSString stringWithFormat:@"%ld个应付款", self.allManifest.count];
    }
    data.manifestCountInfo = manifestCountInfo;
    
    [sectionView setViewData:data];
    return  sectionView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ManifestRecord4Cocoa *manifestRecord = self.allManifest[indexPath.row];
    JCHManifestDetailViewController *viewController = [[[JCHManifestDetailViewController alloc] initWithManifestRecord:manifestRecord] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - SWTableViewCellDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [_contentTableView indexPathForCell:cell];
    ManifestRecord4Cocoa *manifestRecord = self.allManifest[indexPath.row];
    
    switch (index) {
        case 0: //结账
        {
            id<ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
            id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
            ContactsRecord4Cocoa *contactsRecord = [contactsService queryContacts:self.contactsUUID];
            JCHCheckoutOnAccountViewController *checkoutOnAccountVC = [[[JCHCheckoutOnAccountViewController alloc] init] autorelease];
            NSString *arapOrderID = @"";
            if (kJCHOrderShipment == manifestRecord.manifestType) {
                arapOrderID = [manifestService createReceiptManifestID];
            } else if (kJCHOrderPurchases == manifestRecord.manifestType) {
                arapOrderID = [manifestService createPaymentManifestID];
            } else {
                // pass
            }
            
            ManifestARAPRecord4Cocoa *manifestARAPRecord = [[[ManifestARAPRecord4Cocoa alloc] init] autorelease];
            manifestARAPRecord.manifestID = manifestRecord.manifestID;
            manifestARAPRecord.manifestType = manifestRecord.manifestType;
            manifestARAPRecord.manifestARAPAmount = manifestRecord.manifestAmount * manifestRecord.manifestDiscount - manifestRecord.eraseAmount;
            manifestARAPRecord.manifestRealPayAmount = manifestARAPRecord.manifestARAPAmount;
            manifestARAPRecord.arapRemark = @"";
            manifestARAPRecord.arapOrderID = arapOrderID;
            
            JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
            [manifestStorage clearData];
            manifestStorage.currentContactsRecord = contactsRecord;
            manifestStorage.manifestARAPList = @[manifestARAPRecord];
            
            if (_currentChargeAccountType == kJCHChargeAccountPayment) {
                manifestStorage.currentManifestType = kJCHOrderPayment;
            } else {
                manifestStorage.currentManifestType = kJCHOrderReceipt;
            }
            
            [self.navigationController pushViewController:checkoutOnAccountVC animated:YES completion:^{
                [cell hideUtilityButtonsAnimated:NO];
            }];
        }
            break;
            
        case 1://移除订单
        {
            //[self.allManifest removeObjectAtIndex:indexPath.row];
            //[_contentTableView beginUpdates];
            //[_contentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //[_contentTableView endUpdates];
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
    }
    if (state == kCellStateRight)
    {
        if (self.lastEditingCell != cell) {
            [self.lastEditingCell hideUtilityButtonsAnimated:YES];
        }
        self.lastEditingCell = (JCHManifestListTableViewCell *)cell;
        [myCell setButtonStateSelected:YES];
    }
}


- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}


#pragma mark - JCHChargeAccountFooterViewDelegate
- (void)handleSettleAccount
{
    [MBProgressHUD showHUDWithTitle:@"温馨提示"
                             detail:@"暂时不支持批量结算"
                           duration:kJCHDefaultShowHudTime
                               mode:MBProgressHUDModeText
                         completion:nil];
    return;
    
#if 0
    id<ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
    ContactsRecord4Cocoa *contactsRecord = [contactsService queryContacts:self.contactsUUID];
    JCHCheckoutOnAccountViewController *checkoutOnAccountVC = [[[JCHCheckoutOnAccountViewController alloc] init] autorelease];
    
    NSMutableArray *manifestARAPList = [NSMutableArray array];
    for (ManifestRecord4Cocoa *manifestRecord in self.allManifest) {
        ManifestARAPRecord4Cocoa *manifestARAPRecord = [[[ManifestARAPRecord4Cocoa alloc] init] autorelease];
        manifestARAPRecord.manifestID = manifestRecord.manifestID;
        manifestARAPRecord.manifestType = manifestRecord.manifestType;
        manifestARAPRecord.manifestARAPAmount = [JCHFinanceCalculateUtility roundDownFloatNumber:manifestRecord.manifestAmount * manifestRecord.manifestDiscount - manifestRecord.eraseAmount];
        manifestARAPRecord.manifestRealPayAmount = manifestARAPRecord.manifestARAPAmount;
        [manifestARAPList addObject:manifestARAPRecord];
    }
    
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    [manifestStorage clearData];
    manifestStorage.currentContactsRecord = contactsRecord;
    manifestStorage.manifestARAPList = manifestARAPList;
    
    if (_currentChargeAccountType == kJCHChargeAccountPayment) {
        manifestStorage.currentManifestType = kJCHOrderPayment;
    } else {
        manifestStorage.currentManifestType = kJCHOrderReceipt;
    }
    
    [self.navigationController pushViewController:checkoutOnAccountVC animated:YES];
#endif
}

@end
