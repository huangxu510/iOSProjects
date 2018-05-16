                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //
//  JCHManifestViewController.m
//  jinchuhuo
//
//  Created by apple on 15/8/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHManifestViewController.h"
#import "JCHManifestFilterConditionSelectView.h"
#import "JCHCreateManifestViewController.h"
#import "JCHAddProductMainViewController.h"
#import "JCHBarCodeScannerViewController.h"
#import "JCHManifestFilterViewController.h"
#import "JCHManifestTableViewSectionView.h"
#import "JCHManifestListTableViewCell.h"
#import "JCHManifestDetailViewController.h"
#import "ManifestHeaderView.h"
#import "JCHSettlementManager.h"
#import "JCHInputAccessoryView.h"
#import "JCHUISizeSettings.h"
#import "ServiceFactory.h"
#import "JCHUISettings.h"
#import "JCHManifestType.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHSyncStatusManager.h"
#import "JCHPerimissionUtility.h"
#import "UIImage+JCHImage.h"
#import "UIView+JCHView.h"
#import "JCHPinYinUtility.h"
#import "Masonry.h"
#import "JCHFinanceCalculateUtility.h"
#import "CommonHeader.h"
#import "NSString+JCHString.h"
#import "JCHManifestFilterMenuView.h"
#import "JCHRestaurantManifestDetailViewController.h"
#import "JCHRestaurantManifestListTableViewCell.h"
#import <MJRefresh.h>


typedef NS_ENUM(NSInteger, JCHManifestRightButtonTag)
{
    kJCHManifestRightButtonTagDelete,
    kJCHManifestRightButtonTagReturn,
    kJCHManifestRightButtonTagEdit,
    kJCHManifestRightButtonTagCopy,
};


@interface JCHManifestViewController () <SWTableViewCellDelegate,
                                        UIAlertViewDelegate,
                                        UISearchBarDelegate,
                                        UITabBarControllerDelegate>
{
    UITableView *contentTableView;
    JCHPlaceholderView *placeholderView;
    
    
    NSIndexPath *currentIndexPath;          //当前编辑的行
    NSString *loadMessage;                  //菊花提示语
    
    BOOL isNeedShowHudWhenLoadData;         //刷新数据的时候是否需要显示菊花
}

//二维数组,根据日期分组
@property (retain, nonatomic, readwrite) NSArray *allManifestSectionList;
@property (nonatomic, retain) NSMutableArray *allManifest;

@property (nonatomic, retain) JCHManifestListTableViewCell *lastEditingCell;

@property (nonatomic, retain) ManifestRecord4Cocoa *returnedManifsetRecordForWeiXinPay;
@property (nonatomic, retain) NSString *returnManifestID;

@property (nonatomic, retain) ManifestCondition4Cocoa *manifestCondition;
@property (nonatomic, retain) JCHManifestFilterMenuView *menuView;

@end

@implementation JCHManifestViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"货单管理";
        
        currentIndexPath = nil;
        [self registerResponseNotificationHandler];
        self.refreshUIAfterAutoSync = YES;
        isNeedShowHudWhenLoadData = YES;
        loadMessage = @"加载中...";

        self.allManifest = [NSMutableArray array];
    }
    
    return self;
}

- (void)dealloc
{
    [self unregisterResponseNotificationHandler];
    [self.allManifestSectionList release];
    [self.allManifest release];
    [self.lastEditingCell release];
    [self.returnedManifsetRecordForWeiXinPay release];
    [self.returnManifestID release];
    [self.manifestCondition release];
    [self.menuView release];
    
    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = JCHColorGlobalBackground;
    self.tabBarController.delegate = self;
    [self createUI];

    return;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //货单编辑完只加载部分货单
    if (self.isNeedReloadPartData) {
        [self reloadData:YES offset:currentIndexPath.row];
        self.isNeedReloadPartData = NO;
        self.isNeedReloadAllData = NO;
    } else {
        if (self.isNeedReloadAllData) {
            
            [self.allManifest removeAllObjects];
            [self loadData];
            self.isNeedReloadAllData = NO;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [contentTableView deselectRowAtIndexPath:[contentTableView indexPathForSelectedRow] animated:NO];
    return;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)createUI
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (statusManager.isShopManager) {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    WeakSelf;
    contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    contentTableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    contentTableView.showsVerticalScrollIndicator = NO;
    contentTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    contentTableView.backgroundColor = JCHColorGlobalBackground;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf.allManifest removeAllObjects];
        [weakSelf loadData];
    }];
    
    header.lastUpdatedTimeLabel.hidden = YES;
    contentTableView.mj_header = header;
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        [weakSelf loadData];
    }];
    [footer setTitle:@"" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    [footer setTitle:@"" forState:MJRefreshStateNoMoreData];
    contentTableView.mj_footer = footer;
    footer.refreshingTitleHidden = YES;

    [self.view addSubview:contentTableView];
    [contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    self.menuView = [[[JCHManifestFilterMenuView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kStandardItemHeight) superView:self.view] autorelease];
    [self.menuView addSeparateLineWithMasonryTop:NO bottom:YES];
    
    [self.menuView setCommitBlock:^{
        [weakSelf.allManifest removeAllObjects];
        [weakSelf loadData];
    }];
    
    if (statusManager.isShopManager) {
        self.navigationItem.titleView = self.menuView;
        self.menuView.backgroundColor = JCHColorHeaderBackground;
    } else {
        contentTableView.tableHeaderView = self.menuView;
        self.menuView.backgroundColor = [UIColor whiteColor];
    }
    
    
    
    placeholderView = [[[JCHPlaceholderView alloc] initWithFrame:CGRectZero] autorelease];
    placeholderView.hidden = YES;
    placeholderView.imageView.image = [UIImage imageNamed:@"default_bill_placeholder"];
    placeholderView.label.text = @"暂无货单";
    [self.view addSubview:placeholderView];
    
    [placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(158);
        make.width.mas_equalTo(kScreenWidth);
        make.centerY.equalTo(self.view);
    }];
    
    
#if MMR_TAKEOUT_VERSION
    self.navigationItem.titleView = nil;
#endif

    return;
}

- (NSInteger)secondsFromTimeString:(NSString *)timeString endTime:(BOOL)endTime
{
    if ([timeString isEqualToString:@""]) {
        return 0;
    }
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *date = [dateFormatter dateFromString:timeString];
    NSTimeInterval time = [date timeIntervalSince1970];
    
    if (endTime) {
        return time + 59;
    } else {
        return time;
    }
}

#pragma mark -
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.allManifestSectionList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)self.allManifestSectionList[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 28;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    JCHManifestTableViewSectionView *sectionView = sectionView = [[[JCHManifestTableViewSectionView alloc] initWithTopLine:NO BottomLine:YES] autorelease];
    
    ManifestRecord4Cocoa *record = [self.allManifestSectionList[section] firstObject];
    sectionView.titleLabel.text = [NSString stringFromSeconds:record.manifestTimestamp dateStringType:kJCHDateStringType3];
    
    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ManifestRecord4Cocoa *manifestRecord = [self.allManifestSectionList[indexPath.section] objectAtIndex:indexPath.row];
    
#if MMR_RESTAURANT_VERSION
    // 餐饮版
    JCHRestaurantManifestListTableViewCell *cell = nil;
    if (manifestRecord.manifestType == kJCHOrderShipment) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"JCHRestaurantManifestListTableViewCell"];
        if (cell == nil) {
            cell = [[[JCHRestaurantManifestListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JCHRestaurantManifestListTableViewCell"] autorelease];
        }
    } else {
        NSString *kCellReuseTag = @"kCellReuseTag";
        cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseTag];
        if (nil == cell) {
            cell = (JCHRestaurantManifestListTableViewCell *)[[[JCHManifestListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellReuseTag] autorelease];
        }
    }
#else
    // 通用版/外卖版
    NSString *kCellReuseTag = @"kCellReuseTag";
    JCHManifestListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseTag];
    if (nil == cell) {
        cell = [[[JCHManifestListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellReuseTag] autorelease];
    }
#endif
    
    [cell setButtonStateSelected:NO];
    
    ManifestInfo *manifestInfo = [[[ManifestInfo alloc] init] autorelease];
    manifestInfo.hasPayed = manifestRecord.hasPayed;
    manifestInfo.isManifestReturned = manifestRecord.isManifestReturned;
    manifestInfo.manifestType = manifestRecord.manifestType;
    manifestInfo.manifestOrderID = manifestRecord.manifestID;
    manifestInfo.manifestDate = [NSString stringFromSeconds:manifestRecord.manifestTimestamp dateStringType:kJCHDateStringType2];
    
    
#if MMR_TAKEOUT_VERSION
    manifestInfo.manifestAmount = [NSString stringWithFormat:@"%.2f", [JCHFinanceCalculateUtility roundDownFloatNumber:manifestRecord.finalAmount]];
#else
    manifestInfo.manifestAmount = [NSString stringWithFormat:@"%.2f", [JCHFinanceCalculateUtility roundDownFloatNumber:manifestRecord.manifestAmount * manifestRecord.manifestDiscount - manifestRecord.eraseAmount - manifestRecord.lessAmount]];
#endif
    
#if MMR_RESTAURANT_VERSION
    manifestInfo.hasFinished = NO;
    manifestInfo.usedTime = [JCHManifestUtility restaurantTimeUsed:manifestRecord.manifestTimestamp];
#endif
    
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
    
    NSArray *rightButtons = [self rightButtons:manifestRecord];
    
    cell.delegate = self;
    cell.manifestType = manifestRecord.manifestType;
    
    if (manifestRecord.manifestType == kJCHOrderShipment || manifestRecord.manifestType == kJCHOrderPurchases) {
        [cell hideShowMenuButton:(rightButtons.count == 0)];
        
        if (!manifestRecord.isManifestReturned){
#if MMR_RESTAURANT_VERSION
            if (manifestRecord.manifestType == kJCHOrderShipment) {
                [cell setRightUtilityButtons:nil WithButtonWidth:[JCHSizeUtility calculateWidthWithSourceWidth:65.0f]];
                [cell hideShowMenuButton:YES];
            } else {
                [cell setRightUtilityButtons:rightButtons WithButtonWidth:[JCHSizeUtility calculateWidthWithSourceWidth:65.0f]];
            }
#else
            [cell setRightUtilityButtons:rightButtons WithButtonWidth:[JCHSizeUtility calculateWidthWithSourceWidth:65.0f]];
#endif
            //[cell hideShowMenuButton:NO];
        } else {
            //退货单不能删也不能退
            [cell setRightUtilityButtons:nil WithButtonWidth:[JCHSizeUtility calculateWidthWithSourceWidth:65.0f]];
            [cell hideShowMenuButton:YES];
        }
    } else {
        [cell setRightUtilityButtons:nil];
    }
    

    
    [cell setCellData:manifestInfo];
    return cell;
}


- (NSArray *)rightButtons:(ManifestRecord4Cocoa *)manifestRecord
{
    //id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    NSMutableArray *rightButtons = [NSMutableArray array];
    
    //删单
    if ([JCHPerimissionUtility canDeleteManifest]) {
        [rightButtons sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f) icon:[UIImage imageNamed:@"manifest_more_open_delete"]];
        UIButton *deleteButton = [rightButtons lastObject];
        deleteButton.tag = kJCHManifestRightButtonTagDelete;
    }
    //退单
    if ([JCHPerimissionUtility canReturnManifest]) {
        [rightButtons sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f) icon:[UIImage imageNamed:@"manifest_more_open_back"]];
        UIButton *returnButton = [rightButtons lastObject];
        returnButton.tag = kJCHManifestRightButtonTagReturn;
    }
    
    //编辑
#if 1
    if ([JCHPerimissionUtility canEditManifest]) {
        
        [rightButtons sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f) icon:[UIImage imageNamed:@"manifest_more_open_edit"]];
        UIButton *editButton = [rightButtons lastObject];
        editButton.tag = kJCHManifestRightButtonTagEdit;
    }
#endif
    //货单复制
    if ([JCHPerimissionUtility canCopyManifest]) {
        [rightButtons sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f) icon:[UIImage imageNamed:@"manifest_more_open_copy"]];
        UIButton *copyButton = [rightButtons lastObject];
        copyButton.tag = kJCHManifestRightButtonTagCopy;
    }
    
    return rightButtons;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#if MMR_RESTAURANT_VERSION
    ManifestRecord4Cocoa *manifestRecord = [self.allManifestSectionList[indexPath.section] objectAtIndex:indexPath.row];
    if (manifestRecord.manifestType == kJCHOrderShipment) {
        ManifestRecord4Cocoa *manifestRecord = [self.allManifestSectionList[indexPath.section] objectAtIndex:indexPath.row];
        JCHRestaurantManifestDetailViewController *viewController = [[[JCHRestaurantManifestDetailViewController alloc] initWithManifestRecord:manifestRecord] autorelease];
        viewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        ManifestRecord4Cocoa *manifestRecord = [self.allManifestSectionList[indexPath.section] objectAtIndex:indexPath.row];
        JCHManifestDetailViewController *viewController = [[[JCHManifestDetailViewController alloc] initWithManifestRecord:manifestRecord] autorelease];
        viewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:viewController animated:YES];
    }
#else
    ManifestRecord4Cocoa *manifestRecord = [self.allManifestSectionList[indexPath.section] objectAtIndex:indexPath.row];
    JCHManifestDetailViewController *viewController = [[[JCHManifestDetailViewController alloc] initWithManifestRecord:manifestRecord] autorelease];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
#endif
    return;
}


#pragma mark - SWTableViewCellDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [contentTableView indexPathForCell:cell];
    UIButton *rightButton = cell.rightUtilityButtons[index];
    //return;
    currentIndexPath = indexPath;
    //NSArray *rightButtons = cell.rightUtilityButtons;
    switch (rightButton.tag) {
        case kJCHManifestRightButtonTagDelete: //删除订单
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                         message:@"确定删除该订单吗?"
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                               otherButtonTitles:@"确定", nil];
            av.tag = 1000;
            [av show];
        }
            break;
            
        case kJCHManifestRightButtonTagReturn: //退单
        {
            currentIndexPath = indexPath;
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                         message:@"是否要退单?"
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                               otherButtonTitles:@"确定", nil];
            av.tag = 1001;
            [av show];
        }
            break;
            
        case kJCHManifestRightButtonTagEdit: //编辑
        {
            [self handleEditManifest:indexPath];
        }
            break;
            
        case kJCHManifestRightButtonTagCopy:
        {
            [self handleCopyManifest:indexPath];
        }
            
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


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (!statusManager.isShopManager) {
        self.menuView.offsetY = scrollView.contentOffset.y;
    }
}


#pragma mark - 退单
- (void)handleRejectOrder
{
    ManifestRecord4Cocoa *manifestRecord = self.allManifestSectionList[currentIndexPath.section][currentIndexPath.row];
    
    if (kJCHOrderPurchases != manifestRecord.manifestType &&
        kJCHOrderShipment != manifestRecord.manifestType) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"已结账，不能退单"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        [contentTableView reloadRowsAtIndexPaths:@[currentIndexPath]
                                withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    
    if (manifestRecord.isManifestReturned) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"当前货单已进行退单操作"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        [contentTableView reloadRowsAtIndexPaths:@[currentIndexPath]
                                withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    if (manifestRecord.manifestType != 0 && manifestRecord.manifestType != 1) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                     message:@"只有进货单与出货单支持退单操作"
                                                    delegate:nil
                                           cancelButtonTitle:@"我知道了"
                                           otherButtonTitles: nil];
        [av show];
        [contentTableView reloadRowsAtIndexPaths:@[currentIndexPath]
                                withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    
    
    
    BOOL isManifestPayByOnline = [manifestService isManifestPayByOnline:manifestRecord.manifestID
                                                           manifestType:manifestRecord.manifestType];
    NSString *returnManifestID = [manifestService createReturnManifestID];
    self.returnManifestID = returnManifestID;
    
    if (!isManifestPayByOnline) {
        
        id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
        [manifestService returnManifest:manifestRecord.manifestType
                             manifestID:manifestRecord.manifestID
                       returnManifestID:returnManifestID];
        loadMessage = @"退单中...";
        [self reloadData:YES offset:currentIndexPath.row];
    } else {        
        [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                 detail:@"退单中，请稍候..."
                               duration:1000
                                   mode:MBProgressHUDModeIndeterminate
                             completion:nil];
        
        id<OnlineSettlement> settlementService = [[ServiceFactory sharedInstance] onlineSettlementService];
        CMBCRefundRequest *request = [[[CMBCRefundRequest alloc] init] autorelease];
        request.orderAmount = (NSInteger)([JCHFinanceCalculateUtility roundDownFloatNumber:manifestRecord.manifestAmount * manifestRecord.manifestDiscount - manifestRecord.eraseAmount - manifestRecord.lessAmount] * 100);;
        request.orderNote = [NSString stringWithFormat:@"退款: %@", manifestRecord.manifestID];
        request.orderId = [NSString stringWithFormat:@"%@-%@",
                           [[JCHSyncStatusManager shareInstance] accountBookID],
                           manifestRecord.manifestID];
        request.bindId = [[JCHSettlementManager sharedInstance] getBindID];
        request.token = [[JCHSyncStatusManager shareInstance] syncToken];
        request.serviceURL = [NSString stringWithFormat:@"%@/cmbc/refund", kCMBCPayServiceURL];

        
        [settlementService cmbcRefund:request callback:^(id response) {
            [MBProgressHUD hideAllHudsForWindow];
            
            NSDictionary *userData = response;
            if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
                NSDictionary *responseData = userData[@"data"];
                NSInteger responseCode = [responseData[@"code"] integerValue];
                NSString *responseDescription = responseData[@"desc"];
                NSString *responseStatus = responseData[@"status"];
                
                NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
                
                if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                    // fail
                    [[JCHSettlementManager sharedInstance] handleRefundError:responseCode];
                } else {
                    //success
                    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
                    [manifestService returnManifest:manifestRecord.manifestType
                                         manifestID:manifestRecord.manifestID
                                   returnManifestID:self.returnManifestID];
                    loadMessage = @"退单中";
                    [self reloadData:YES offset:currentIndexPath.row];
                    [MBProgressHUD showHUDWithTitle:@"退款成功"
                                             detail:nil
                                           duration:2
                                               mode:MBProgressHUDModeCustomView
                                         completion:nil];
                }
            } else {
                // network error
                [MBProgressHUD showNetWorkFailedHud:@"网络连接失败"];
            }
        }];
    }
    
    return;
}

#pragma mark - 删单
- (void)handleDeleteManifest
{
    ManifestRecord4Cocoa *manifestRecord = self.allManifestSectionList[currentIndexPath.section][currentIndexPath.row];
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    
    TICK;
    BOOL isManifestAlreadyARAP = [manifestService isManifestAlreadyARAP:manifestRecord.manifestID
                                                           manifestType:manifestRecord.manifestType];
    TOCK(@"isManifestAlreadyARAP");
    startTime = [NSDate date];
    BOOL isManifestPayByOnline = [manifestService isManifestPayByOnline:manifestRecord.manifestID
                                                           manifestType:manifestRecord.manifestType];
    TOCK(@"isManifestPayByOnline");
    
    if (isManifestAlreadyARAP) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"已结账，不能删除"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    if (isManifestPayByOnline) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"在线支付暂时不能删除"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    [manifestService deleteManifest:manifestRecord.manifestType
                         manifestID:manifestRecord.manifestID];
    
    loadMessage = @"删单中";
    [self reloadData:YES offset:currentIndexPath.row];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //删单
    if (alertView.tag == 1000) {
        if (buttonIndex == 0) {
            [contentTableView reloadRowsAtIndexPaths:@[currentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else
        {
            [self handleDeleteManifest];
        }

    } else if (alertView.tag == 1001) { //退单
        
        if (buttonIndex == 0) {
            [contentTableView reloadRowsAtIndexPaths:@[currentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else
        {
            [self handleRejectOrder];
        }
    }
}

#pragma mark - 货单编辑
- (void)handleEditManifest:(NSIndexPath *)indexPath
{
    ManifestRecord4Cocoa *manifestRecord = [self.allManifestSectionList[indexPath.section] objectAtIndex:indexPath.row];
    
    if (![manifestRecord.paymentMethod isEqualToString:@"现金"]) {
        
        if ([manifestRecord.paymentMethod containsString:@"赊销"] || [manifestRecord.paymentMethod containsString:@"赊购"]) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                 message:@"做过赊销赊购的货单暂不支持编辑"
                                                                delegate:nil
                                                       cancelButtonTitle:@"我知道了"
                                                       otherButtonTitles:nil] autorelease];
            [alertView show];
        } else {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                 message:@"只有现金方式支付的货单可以编辑"
                                                                delegate:nil
                                                       cancelButtonTitle:@"我知道了"
                                                       otherButtonTitles:nil] autorelease];
            [alertView show];
        }
        return;
    }
    
    if ((manifestRecord.manifestType != kJCHOrderShipment && manifestRecord.manifestType != kJCHOrderPurchases)) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"只有进货单和出货单可以编辑"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
#if 0
    //如果是赊销赊购的要求未付款
    BOOL isManifestAlreadyARAP = [manifestService isManifestAlreadyARAP:manifestRecord.manifestID
                                                           manifestType:manifestRecord.manifestType];
  
    if (isManifestAlreadyARAP) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"赊销赊购的货单不能编辑"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
#endif
    
    //如果原单的仓库被禁用或者删除，提示用户是否切到默认仓库
    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
    NSArray *warehouseList = [warehouseService queryAllWarehouse];
    
    BOOL isWarehouseExist = NO;
    BOOL isWarehouseEnable = NO;
    
    for (WarehouseRecord4Cocoa *warehouseRecord in warehouseList) {
        if ([warehouseRecord.warehouseID isEqualToString:manifestRecord.sourceWarehouseID]) {
            isWarehouseExist = YES;
            
            if (warehouseRecord.warehouseStatus == 0) {
                isWarehouseEnable = YES;
            }
        }
        break;
    }
    if (isWarehouseEnable == NO || isWarehouseExist == NO) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"该货单的原仓库已被删除或者禁用，将为您切换到默认仓库" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            currentIndexPath = indexPath;
            [self makeSureEditManifest:manifestRecord warehouseID:@"0"];
        }];
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:alertAction];
        [alertController addAction:cancleAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        currentIndexPath = indexPath;
        [self makeSureEditManifest:manifestRecord warehouseID:manifestRecord.sourceWarehouseID];
    }
}

- (void)makeSureEditManifest:(ManifestRecord4Cocoa *)manifestRecord warehouseID:(NSString *)warehouseID
{
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    appDelegate.switchToTargetController = self;
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    id<ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    [manifestStorage clearData];
    manifestStorage.manifestMemoryType = kJCHManifestMemoryTypeEdit;
    manifestStorage.currentManifestID = manifestRecord.manifestID;
    manifestStorage.currentManifestDate = [NSString stringFromSeconds:manifestRecord.manifestTimestamp dateStringType:kJCHDateStringType5];
    manifestStorage.currentManifestType = (enum JCHOrderType)manifestRecord.manifestType;
    manifestStorage.currentManifestRemark = manifestRecord.manifestRemark;
    manifestStorage.currentManifestDiscount = manifestRecord.manifestDiscount;
    manifestStorage.currentManifestEraseAmount = manifestRecord.eraseAmount;
    manifestStorage.isRejected = ![JCHFinanceCalculateUtility floatValueIsZero:manifestRecord.eraseAmount];
    manifestStorage.hasPayed = manifestRecord.hasPayed;
    manifestStorage.warehouseID = warehouseID;
    
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
        
        [manifestStorage addManifestRecord:transactionDetail];
    }
    
    JCHCreateManifestViewController *manifestViewController = [[[JCHCreateManifestViewController alloc] init] autorelease];
    manifestViewController.hidesBottomBarWhenPushed = YES;
    
    JCHManifestListTableViewCell *cell = [contentTableView cellForRowAtIndexPath:currentIndexPath];
    [self.navigationController pushViewController:manifestViewController animated:YES completion:^{
        [cell hideUtilityButtonsAnimated:NO];
    }];
}

#pragma mark - 货单复制
- (void)handleCopyManifest:(NSIndexPath *)indexPath
{
    ManifestRecord4Cocoa *manifestRecord = [self.allManifestSectionList[indexPath.section] objectAtIndex:indexPath.row];
    
    
    //如果原单的仓库被禁用或者删除，提示用户是否切到默认仓库
    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
    NSArray *warehouseList = [warehouseService queryAllWarehouse];
    
    BOOL isWarehouseExist = NO;
    BOOL isWarehouseEnable = NO;
    
    for (WarehouseRecord4Cocoa *warehouseRecord in warehouseList) {
        if ([warehouseRecord.warehouseID isEqualToString:manifestRecord.sourceWarehouseID]) {
            isWarehouseExist = YES;
            
            if (warehouseRecord.warehouseStatus == 0) {
                isWarehouseEnable = YES;
            }
        }
        break;
    }
    if (isWarehouseEnable == NO || isWarehouseExist == NO) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"该货单的原仓库已被删除或者禁用，将为您切换到默认仓库" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            currentIndexPath = indexPath;
            [self makeSureCopyManifest:manifestRecord warehouseID:@"0"];
        }];
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:alertAction];
        [alertController addAction:cancleAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        currentIndexPath = indexPath;
        [self makeSureCopyManifest:manifestRecord warehouseID:manifestRecord.sourceWarehouseID];
    }
}

- (void)makeSureCopyManifest:(ManifestRecord4Cocoa *)manifestRecord warehouseID:(NSString *)warehouseID
{
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    appDelegate.switchToTargetController = self;
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    id<ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    [manifestStorage clearData];
    manifestStorage.manifestMemoryType = kJCHManifestMemoryTypeCopy;
    manifestStorage.currentManifestID = [manifestService createManifestID:kJCHOrderShipment];
    manifestStorage.currentManifestDate = [JCHManifestUtility getOrderDate];
    manifestStorage.currentManifestType = (enum JCHOrderType)manifestRecord.manifestType;
    manifestStorage.currentManifestRemark = manifestRecord.manifestRemark;
    manifestStorage.currentManifestDiscount = manifestRecord.manifestDiscount;
    manifestStorage.currentManifestEraseAmount = manifestRecord.eraseAmount;
    manifestStorage.isRejected = ![JCHFinanceCalculateUtility floatValueIsZero:manifestRecord.eraseAmount];
    manifestStorage.warehouseID = warehouseID;
    
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
        
        [manifestStorage addManifestRecord:transactionDetail];
    }
    
    JCHCreateManifestViewController *manifestViewController = [[[JCHCreateManifestViewController alloc] init] autorelease];
    manifestViewController.hidesBottomBarWhenPushed = YES;
    
    JCHManifestListTableViewCell *cell = [contentTableView cellForRowAtIndexPath:currentIndexPath];
    [self.navigationController pushViewController:manifestViewController animated:YES completion:^{
        [cell hideUtilityButtonsAnimated:NO];
    }];
}

#pragma mark - 微信退款
- (void)handleFinishScanBarCode:(NSString *)barCode
{
    [MBProgressHUD showHUDWithTitle:@"退款中"
                             detail:nil
                           duration:1000
                               mode:MBProgressHUDModeIndeterminate
                         completion:nil];
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id <OnlineSettlement> settltmentService = [[ServiceFactory sharedInstance] onlineSettlementService];
    id <ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    
    NSString *weiXinPayUUID = [manifestService getWeiXinPayAccountUUID];

    WeiXinRefundRequest *request = [[[WeiXinRefundRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.deviceUUID = statusManager.deviceUUID;
    request.serviceURL = [NSString stringWithFormat:@"%@/weixin/sl/micropay/refund", kPaySystemServerIP];
    request.bindID = [NSString stringWithFormat:@"%@_%@", statusManager.accountBookID, weiXinPayUUID];
    request.manifestID = barCode;
    request.payTransId = self.returnedManifsetRecordForWeiXinPay.manifestID;
    NSInteger refundFee = (NSInteger)([JCHFinanceCalculateUtility roundDownFloatNumber:self.returnedManifsetRecordForWeiXinPay.manifestAmount * self.returnedManifsetRecordForWeiXinPay.manifestDiscount - self.returnedManifsetRecordForWeiXinPay.eraseAmount - self.returnedManifsetRecordForWeiXinPay.lessAmount] * 100);
    request.refundFee = refundFee;
    request.refundTransId = self.returnManifestID;
    
    [settltmentService weixinRefund:request response:kJCHWeiXinRefundNotification];
}

#pragma mark - QueryWeiXinRefundNotificationAndMethod

- (void)registerResponseNotificationHandler
{
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleWeiXinRefund:)
                                  name:kJCHWeiXinRefundNotification
                                object:[UIApplication sharedApplication]];
}

- (void)unregisterResponseNotificationHandler
{
    [JCHNotificationCenter removeObserver:self
                                     name:kJCHWeiXinRefundNotification
                                   object:[UIApplication sharedApplication]];
}

//! @note 货单编辑接收通知改变刷新部分标记为yes
- (void)handleNeedReloadPartData
{
    self.isNeedReloadPartData = YES;
}

- (void)handleWeiXinRefund:(NSNotification *)notify
{
    NSLog(@"%@", notify);
    
    NSDictionary *userData = notify.userInfo;
    
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        NSString *responseDescription = responseData[@"desc"];
        NSString *responseStatus = responseData[@"status"];
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
        
        if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
            //fail
            [MBProgressHUD showHudWithStatusCode:responseCode
                                       sceneType:kJCHMBProgressHUDSceneTypeWeiXinRefund];
            
            
            return;
        } else {
            // success
            NSString *refundStatus = responseData[@"data"][@"refundStatus"];
            //NSInteger refundFee = [responseData[@"data"][@"refundFee"] integerValue];
            
            if ([refundStatus isEqualToString:@"success"]) {
                //success
                id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
                [manifestService returnManifest:self.returnedManifsetRecordForWeiXinPay.manifestType
                                     manifestID:self.returnedManifsetRecordForWeiXinPay.manifestID
                               returnManifestID:self.returnManifestID];
                loadMessage = @"退单中";
                [self reloadData:YES offset:currentIndexPath.row];
                [MBProgressHUD showHUDWithTitle:@"退款成功"
                                         detail:nil
                                       duration:2
                                           mode:MBProgressHUDModeCustomView
                                     completion:nil];
            } else if ([refundStatus isEqualToString:@"error"] || [responseStatus isEqualToString:@"fail"]){
                //error退款失败（系统级）  fail退款失败
                [MBProgressHUD showResultCustomViewHUDWithTitle:@"退款失败"
                                                         detail:nil
                                                       duration:2
                                                         result:NO
                                                     completion:nil];
            }
        }
    } else {
        // network error
        [MBProgressHUD showNetWorkFailedHud:@"退款失败"];
    }
}

#pragma mark - clearData

- (void)clearData
{
    NSLog(@"ClearManifestData");
    [self.allManifest removeAllObjects];
    [self.menuView resetManifestFilterCondition:YES];
    self.allManifestSectionList = @[];
    self.isNeedReloadAllData = YES;
    isNeedShowHudWhenLoadData = YES;
    [contentTableView reloadData];
}

#pragma mark -
#pragma mark 加载数据
- (void)loadData
{
    [self reloadData:NO offset:0];
}


/**
 *  刷新数据，当退单、删单操作后，要重新加载当前单及后面的数据，refresh为YES
 *
 *  @param refresh       refresh为YES 刷新传入的currentOffset以及之后的数据， refresh为NO 普通加载和上拉加载
 *  @param currentOffset 偏移量
 */
- (void)reloadData:(BOOL)refreshCurrentOffsetAndBehind offset:(NSInteger)currentOffset
{
    NSLog(@"LoadManifestData");
#if PERFORMANCETEST
    TICK;
#endif
    //货单编辑完后会有货单编辑成功的提示，所以 "加载中..." 的提示要延迟调用一会(但必须在tableview reloadData之前)
    __block BOOL isFinishedLoadData = NO;
    if ([MBProgressHUD getHudShowingStatus]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kJCHDefaultShowHudTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
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
        //如果当前有筛选条件或者 refreh为yes 或者第一次加载 或者标记需要现实hud的时候 要加上hud
        if (self.menuView.manifestFilterCondition || refreshCurrentOffsetAndBehind || isNeedShowHudWhenLoadData) {
            [MBProgressHUD showHUDWithTitle:loadMessage
                                     detail:nil
                                   duration:100
                                       mode:MBProgressHUDModeIndeterminate
                                  superView:self.view
                                 completion:nil];
            loadMessage = @"加载中...";
            isNeedShowHudWhenLoadData = NO;
        }
    }
    
    JCHSyncStatusManager *syncStatusManager = [JCHSyncStatusManager shareInstance];
    
    //默认全部货单类型
    NSArray *allGeneralManifestTypeVector = @[@(0), @(1), @(2), @(3)];
    //默认全部仓单类型
    NSArray *allWarehouseManifestTypeVector = @[@(6), @(7), @(8), @(9)];
    
    //店员只显示出货单、出货退单
    if (!syncStatusManager.isShopManager) {
        allGeneralManifestTypeVector = @[@(1), @(3)];
    }
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    
    NSString *searchText = self.menuView.searchString;
    
    if (self.manifestCondition == nil) {
        ManifestCondition4Cocoa *manifestCondition = [[[ManifestCondition4Cocoa alloc] init] autorelease];
        manifestCondition.searchText = searchText;
        manifestCondition.beginDateTime = 0;
        manifestCondition.endDateTime = 0;
        manifestCondition.beginTimeOfDay = 0;
        manifestCondition.endTimeOfDay = 0;
        manifestCondition.minAmount = 0;
        manifestCondition.maxAmount = 0;
        manifestCondition.manifestTypeVector = allGeneralManifestTypeVector;
        manifestCondition.paymentAccountUUIDVector = @[];
        manifestCondition.settleStatusVector = @[];
        self.manifestCondition = manifestCondition;
    }
    
    NSDictionary *manifestFilterCondition = self.menuView.manifestFilterCondition;
    if (manifestFilterCondition) {
        
        NSInteger manifestType = [[manifestFilterCondition objectForKey:kManifestTypeKey] integerValue];
        NSArray *manifestTypeVector = nil;
        
        if (manifestType == -2) {
            //全部仓单
            manifestTypeVector = allWarehouseManifestTypeVector;
        } else if (manifestType == -1) {
            //全部普通货单
            manifestTypeVector = allGeneralManifestTypeVector;
        } else {
            manifestTypeVector = @[@(manifestType)];
        }
        
        NSString *dateStartString = [manifestFilterCondition objectForKey:kManifestDateStartKey];
        NSString *dateEndString = [manifestFilterCondition objectForKey:kManifestDateEndKey];
        
        NSString *startTimeString = [manifestFilterCondition objectForKey:kManifestTimeStartKey];
        NSString *endTimeString = [manifestFilterCondition objectForKey:kManifestTimeEndKey];
        
        NSString *amountStartString = [manifestFilterCondition objectForKey:kManifestAmountStartKey];
        NSString *amountEndString = [manifestFilterCondition objectForKey:kManifestAmountEndKey];
        
        NSInteger manifestPayWay = [[manifestFilterCondition objectForKey:kManifestPayWayKey] integerValue];
        NSInteger manifestPayStatus = [[manifestFilterCondition objectForKey:kManifestPayStatusKey] integerValue];
        
        NSTimeInterval dateStart = [dateStartString stringToSecondsEndTime:NO];
        NSTimeInterval dateEnd = [dateEndString stringToSecondsEndTime:YES];
        
        NSTimeInterval startTime = [self secondsFromTimeString:startTimeString endTime:NO];
        NSTimeInterval endTime = [self secondsFromTimeString:endTimeString endTime:YES];
        
        CGFloat amountStart = amountEndString.doubleValue;
        CGFloat amountEnd = amountStartString.doubleValue;
        
        
        self.manifestCondition.searchText = searchText;
        self.manifestCondition.beginDateTime = dateStart;
        self.manifestCondition.endDateTime = dateEnd;
        self.manifestCondition.beginTimeOfDay = startTime;
        self.manifestCondition.endTimeOfDay = endTime;
        self.manifestCondition.minAmount = amountEnd;
        self.manifestCondition.maxAmount = amountStart;
        self.manifestCondition.manifestTypeVector = manifestTypeVector;
        self.manifestCondition.paymentAccountUUIDVector = [self switchPayWayToPaymentAccountUUIDVector:manifestPayWay];
        self.manifestCondition.settleStatusVector = [self switchPayStatusToSettleStatusVector:manifestPayStatus];
    }
    
    
    NSInteger offset = 0;
    NSInteger pageSize = 10;
    
    if (refreshCurrentOffsetAndBehind) {
        offset = currentOffset;
        pageSize = self.allManifest.count - currentOffset;
    } else {
        offset = self.allManifest.count;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

#if !MMR_RESTAURANT_VERSION
        NSArray *manifestListInRange = nil;
        [manifestService queryAllManifestList:offset
                                     pageSize:pageSize
                                    condition:self.manifestCondition
                          manifestRecordArray:&manifestListInRange];
#else
        NSArray *normalManifestListInRange = nil;
        [manifestService queryAllManifestList:offset
                                     pageSize:pageSize
                                    condition:self.manifestCondition
                          manifestRecordArray:&normalManifestListInRange];
        
        NSArray *preInsertManifestListInRange = nil;
        [manifestService queryPreInsertManifestList:offset
                                           pageSize:pageSize
                                          condition:self.manifestCondition
                                manifestRecordArray:&preInsertManifestListInRange];
        
        NSMutableArray *manifestListInRange = [[[NSMutableArray alloc] init] autorelease];
        [manifestListInRange addObjectsFromArray:normalManifestListInRange];
        [manifestListInRange addObjectsFromArray:preInsertManifestListInRange];

#endif
        
        for (ManifestRecord4Cocoa *manifestRecord in manifestListInRange) {
            NSArray *manifestTransactionArray = manifestRecord.manifestTransactionArray;
            for (ManifestTransactionRecord4Cocoa *manifestTransactionRecord in manifestTransactionArray) {
                manifestTransactionRecord.productNamePinYin = [JCHPinYinUtility getFirstPinYinLetterForProductName:manifestTransactionRecord.productName];
            }
        }

        
        if (refreshCurrentOffsetAndBehind) {
            [self.allManifest replaceObjectsInRange:NSMakeRange(currentOffset, pageSize)
                               withObjectsFromArray:manifestListInRange];
        } else {
            [self.allManifest addObjectsFromArray:manifestListInRange];
        }
        

        dispatch_async(dispatch_get_main_queue(), ^{
            //全部订单
            {
                //按时间顺序排序
               
                [self.allManifest sortUsingComparator:^NSComparisonResult(ManifestRecord4Cocoa *obj1, ManifestRecord4Cocoa *obj2) {
                    return obj1.manifestTimestamp < obj2.manifestTimestamp;
                }];
          
                
#if 0
                //去除退货单
                for (ManifestRecord4Cocoa *record in manifestListInRange) {
                    if ((record.manifestType == kJCHOrderPurchasesReject) || (record.manifestType == kJCHOrderShipmentReject)) {
                        [self.allManifest removeObject:record];
                    }
                }
#endif
                if (self.allManifest.count != 0) {
                    placeholderView.hidden = YES;
                } else {
                    placeholderView.hidden = NO;
                }

                self.allManifestSectionList = [self subSectionManifest:self.allManifest];
            }
            
            [contentTableView reloadData];
            if (manifestListInRange.count == 0) {
                [contentTableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [contentTableView.mj_footer endRefreshing];
            }
            [contentTableView.mj_header endRefreshing];
            [MBProgressHUD hideHUDForView:self.view animated:NO];
            isFinishedLoadData = YES;
           
#if PERFORMANCETEST
            if (offset == 0) {
                JCHPerformanceTestManager *performanceTestManager = [JCHPerformanceTestManager shareInstance];
                if (performanceTestManager.manifestListLoadTime < TOCKTime) {
                    performanceTestManager.manifestListLoadTime = TOCKTime;
                }
            }
#endif
        });
    });
    
    
    return;
}

- (NSArray *)switchPayWayToPaymentAccountUUIDVector:(NSInteger)payWay
{
    NSMutableArray *paymentAccountUUIDVector = [NSMutableArray array];
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    switch (payWay) {
        case kJCHManifestPayWayAll:
        {
            
        }
            break;
            
        case kJCHManifestPayWayCash:
        {
            NSString *defaultCashAccountUUID = [manifestService getDefaultCashRMBAccountUUID];
            [paymentAccountUUIDVector addObject:defaultCashAccountUUID];
        }
            break;
            
        case kJCHManifestPayWayOnAccount:
        {
            NSString *creditBuyingAccountUUID = [manifestService getCreditBuyingAccountUUID];
            NSString *creditSaleAccountUUID = [manifestService getCreditSaleAccountUUID];
            [paymentAccountUUIDVector addObject:creditBuyingAccountUUID];
            [paymentAccountUUIDVector addObject:creditSaleAccountUUID];
        }
            break;
            
        case kJCHManifestPayWayWeiXin:
        {
            NSString *weiXinAccountUUID = [manifestService getWeiXinPayAccountUUID];
            [paymentAccountUUIDVector addObject:weiXinAccountUUID];
        }
            break;
            
        default:
            break;
    }
    return paymentAccountUUIDVector;
}


- (NSArray *)switchPayStatusToSettleStatusVector:(NSInteger)payStatus
{
    NSMutableArray *settleStatusVector = [NSMutableArray array];
    switch (payStatus) {
        case kJCHManifestPayStatusAll:
        {

        }
            break;
            
        case kJCHManifestPayStatusHasnotReceived:
        {
            [settleStatusVector addObject:@(NotReceived)];
        }
            break;
            
        case kJCHManifestPayStatusHasnotPaid:
        {
            [settleStatusVector addObject:@(NotPaid)];
        }
            break;
            
        case kJCHManifestPayStatusHasReceived:
        {
            [settleStatusVector addObject:@(HasReceived)];
        }
            break;
            
        case kJCHManifestPayStatusHasPaid:
        {
            [settleStatusVector addObject:@(HasPaid)];
        }
            break;
            
        default:
            break;
    }

    return settleStatusVector;
}

- (NSArray *)subSectionManifest:(NSArray *)manifest
{
#if 0
    const int kMaxYearDayCount = 300000;        // 0000-00 ~ 9999-99
    NSMutableArray** manifestGroups = (NSMutableArray**) malloc( sizeof( NSMutableArray * ) * kMaxYearDayCount );
    memset( manifestGroups , 0 , sizeof( NSMutableArray * ) * kMaxYearDayCount );

    for (ManifestRecord4Cocoa *record in manifest) {
        const time_t iManifestTime = record.manifestTimestamp;
        const struct tm *localTime = localtime( &iManifestTime );
        const int datetime = (localTime->tm_year + 1900) * 100 + localTime->tm_mon;
        
        NSMutableArray *manifestInDate = manifestGroups[datetime];
        if (nil == manifestInDate) {
            manifestInDate = [[[NSMutableArray alloc] init] autorelease];
            manifestGroups[datetime] = manifestInDate;
        }
        
        [manifestInDate addObject:record];
    }
  
    
    
    NSMutableArray *manifestList_allSections = [[[NSMutableArray alloc] init] autorelease];
    for (int i = kMaxYearDayCount - 1; i >= 0; --i) {
        if (nil != manifestGroups[i]) {
            [manifestList_allSections addObject:manifestGroups[i]];
        }
    }
    
    free(manifestGroups);
    
    return manifestList_allSections;
#else
    
    NSMutableArray *allMonths = [NSMutableArray array];
    for (ManifestRecord4Cocoa *record in manifest) {
        NSString *dateStr = [NSString stringFromSeconds:record.manifestTimestamp dateStringType:kJCHDateStringType3];
        if (record == manifest[0]) {
            [allMonths addObject:dateStr];
        }
        else if (![allMonths.lastObject isEqualToString:dateStr])
        {
            [allMonths addObject:dateStr];
        }
    }
    
    NSMutableArray *manifestList_allSections = [NSMutableArray array];
    
    for (NSInteger i = 0; i < allMonths.count; i++) {
        NSMutableArray *manifestList_section = [NSMutableArray array];
        for (NSInteger j = 0; j < manifest.count; j++) {
            
            ManifestRecord4Cocoa *record = manifest[j];
            NSString *dateStr = [NSString stringFromSeconds:record.manifestTimestamp dateStringType:kJCHDateStringType3];
            if ([allMonths[i] isEqualToString:dateStr]) {
                [manifestList_section addObject:record];
            }
            
        }
        [manifestList_allSections addObject:manifestList_section];
    }
    return manifestList_allSections;
#endif
}

#pragma mark - 货单筛选
- (void)filterAction
{
#if 0
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;//@"cube";
    transition.subtype = kCATransitionFromLeft;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];

    
    
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:self.manifestFilterViewController] autorelease];
    
    WeakSelf;
    [self.manifestFilterViewController setSendValueBlock:^(BOOL needReloadData) {
        weakSelf.isNeedReloadAllData = needReloadData;
    }];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
#endif
}



#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (viewController != self.navigationController) {
        isNeedShowHudWhenLoadData = NO;
    }
}

@end
