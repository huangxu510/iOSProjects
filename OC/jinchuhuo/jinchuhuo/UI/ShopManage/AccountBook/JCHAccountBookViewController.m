//
//  JCHAccountBookViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/7.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAccountBookViewController.h"
#import "JCHAdjustBalanceViewController.h"
#import "JCHTransferBalanceViewController.h"
#import "JCHJournalAccountViewController.h"
#import "JCHChargeAccountViewController.h"
#import "JCHAccountBookTypeSelectViewController.h"
#import "JCHAccountBookStatisticsView.h"
#import "JCHAccountBookTableViewCell.h"
#import "JCHAccountBookTypeTableViewCell.h"
#import "CommonHeader.h"
#import "ServiceFactory.h"
#import "AccountBalanceRecord4Cocoa.h"
#import <Masonry.h>




static NSString *kJCHBalanceRecordCashKey    = @"现金账户";
static NSString *kJCHBalanceRecordEWalletKey = @"电子钱包";
static NSString *kJCHBalanceRecordClaimsKey  = @"债权账户";
static NSString *kJCHBalanceRecordDebtKey    = @"债务账户";



static NSString *kJCHAccountBookTableViewCellResuseID = @"JCHAccountBookTableViewCell";
static NSString *kJCHAccountBookTypeTableViewCellResuseID = @"JCHAccountBookTypeTableViewCell";

@interface JCHAccountBookViewController () <UITableViewDataSource, UITableViewDelegate, JCHAccountBookStatisticsViewDelegate>
{
    JCHAccountBookStatisticsView *_statisticsView;
    UITableView *_contentTableView;
}

//! @brief @[accountName1, accountName2, ...];
@property (nonatomic, retain) NSArray *rootAccountNameArray;

@property (nonatomic, retain) NSDictionary *balanceRecordsForRootAccountName;
@end

@implementation JCHAccountBookViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
#if MMR_TAKEOUT_VERSION || MMR_RESTAURANT_VERSION
    self.navigationItem.title = @"账本";
    self.navigationItem.leftBarButtonItem = nil;
#else
    self.title = @"账本";
#endif
    
    
    [self setUpSavingCardRecord];
    [self createUI];
}

- (void)setUpSavingCardRecord
{
    //如果储值卡折扣规则存在， 检测储值卡账户是否存在，不存在则创建
    id <CardDiscountService> cardDiscountService = [[ServiceFactory sharedInstance] cardDiscountService];
    id<AccountService> accountService = [[ServiceFactory sharedInstance] accountService];
    NSArray *cardDiscountRecordArray = [cardDiscountService queryAllCardDiscount];
    
    if (cardDiscountRecordArray.count > 0 && NO == [accountService isCardAccountExist]) {
        [accountService addCardAccount];
    }
}

- (void)dealloc
{
    self.rootAccountNameArray = nil;
    self.balanceRecordsForRootAccountName = nil;
    
    [super dealloc];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

#if MMR_TAKEOUT_VERSION || MMR_RESTAURANT_VERSION
    self.isNeedReloadAllData = YES;
#endif
    
    if (self.isNeedReloadAllData) {
        [self loadData];
        self.isNeedReloadAllData = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIView *backgroundView = _contentTableView.backgroundView;
    UIView *backgroundTopView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, _statisticsView.frame.size.height)] autorelease];
    backgroundTopView.backgroundColor = JCHColorHeaderBackground;
    [backgroundView addSubview:backgroundTopView];
    
    [_contentTableView deselectRowAtIndexPath:[_contentTableView indexPathForSelectedRow] animated:YES];
}

- (void)createUI
{

    UIButton *addAccountBookButton = [JCHUIFactory createButton:CGRectMake(0, 0, 30, 44)
                                                  target:self
                                                  action:@selector(handleAddAccountBook)
                                                   title:nil
                                              titleColor:nil
                                         backgroundColor:nil];
    [addAccountBookButton setImage:[UIImage imageNamed:@"icon_account_add"] forState:UIControlStateNormal];
    //UIBarButtonItem *addItem = [[[UIBarButtonItem alloc] initWithCustomView:addAccountBookButton] autorelease];
    
    UIButton *transferBalanceButton = [JCHUIFactory createButton:CGRectMake(0, 0, 30, 44)
                                               target:self
                                               action:@selector(handleTransferBalance)
                                                title:nil
                                           titleColor:nil
                                      backgroundColor:nil];
    [transferBalanceButton setImage:[UIImage imageNamed:@"icon_account_convert"] forState:UIControlStateNormal];
    //UIBarButtonItem *transferItem = [[[UIBarButtonItem alloc] initWithCustomView:transferBalanceButton] autorelease];
    
    UIBarButtonItem *fixedSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
    fixedSpace.width = -5;
    
    //self.navigationItem.rightBarButtonItems = @[fixedSpace, addItem, transferItem];
    
    _statisticsView = [[[JCHAccountBookStatisticsView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 150.0f)] autorelease];
    _statisticsView.backgroundColor = JCHColorHeaderBackground;
    [_statisticsView setEditDataButtonHiddeh:YES];
    _statisticsView.topTitle = @"净资产";
    _statisticsView.leftTitle = @"资产";
    _statisticsView.rightTitle = @"负债";
    
    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    _contentTableView.dataSource = self;
    _contentTableView.delegate = self;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _contentTableView.tableHeaderView = _statisticsView;
    _contentTableView.tableFooterView = [[[UIView alloc] init] autorelease];
    [self.view addSubview:_contentTableView];
    
    UIView *backgroundView = [[[UIView alloc] init] autorelease];
    backgroundView.backgroundColor = JCHColorGlobalBackground;
    _contentTableView.backgroundView = backgroundView;
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [_contentTableView registerClass:[JCHAccountBookTableViewCell class] forCellReuseIdentifier:kJCHAccountBookTableViewCellResuseID];
    [_contentTableView registerClass:[JCHAccountBookTypeTableViewCell class] forCellReuseIdentifier:kJCHAccountBookTypeTableViewCellResuseID];
}

- (void)handleAddAccountBook
{
    self.hidesBottomBarWhenPushed = YES;
    JCHAccountBookTypeSelectViewController *typeSelectVC = [[[JCHAccountBookTypeSelectViewController alloc] init] autorelease];
    [self.navigationController pushViewController:typeSelectVC animated:YES];
}

- (void)handleTransferBalance
{
    JCHTransferBalanceViewController *transferBalanceVC = [[[JCHTransferBalanceViewController alloc] init] autorelease];
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:transferBalanceVC] autorelease];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - LoadData

- (void)loadData
{
    [MBProgressHUD showHUDWithTitle:@"加载中..."
                             detail:nil
                           duration:100
                               mode:MBProgressHUDModeIndeterminate
                          superView:self.view
                         completion:nil];
    
    // id <AccountService> accountService = [[ServiceFactory sharedInstance] accountService];
    //id <ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    id <FinanceCalculateService> financeCalculateService = [[ServiceFactory sharedInstance] financeCalculateService];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSArray *allBalanceRecords = [financeCalculateService calculateAccountBalance];
        
        JCHAccountBookStatisticsViewData *data = [[[JCHAccountBookStatisticsViewData alloc] init] autorelease];
        data.netAsset = 0.0f;
        data.asset = 0.0f;
        data.debt = 0.0f;
        
        //NSString *weiXinPayUUID = [manifestService getWeiXinPayAccountUUID];
        
        
        NSMutableArray *cashRecordArray = [NSMutableArray array];
        NSMutableArray *eWalletRecordArray = [NSMutableArray array];
        NSMutableArray *claimsRecordArray = [NSMutableArray array];
        NSMutableArray *debtRecordArray = [NSMutableArray array];
        
        //FIXME: 判断跟是否属于某个跟节点
        for (AccountBalanceRecord4Cocoa *record in allBalanceRecords) {
            
            NSString *codePrefix = @"";
            if (record.accountCode.length > 4) {
                codePrefix = [record.accountCode substringToIndex:4];
            }

            
            // 现金账户 1001
            if ([codePrefix isEqualToString:@"1001"]) {
                [cashRecordArray addObject:record];
                data.asset += record.balance;
            }
            // 电子钱包 1012
            if ([codePrefix isEqualToString:@"1012"]) {
                [eWalletRecordArray addObject:record];
                data.asset += record.balance;
            }
            
            // 债权账户 1122
            if ([codePrefix isEqualToString:@"1122"]) {
                [claimsRecordArray addObject:record];
                data.asset += record.balance;
            }
            
            // 债务账户 2202/2203
            if ([codePrefix isEqualToString:@"2202"] || [codePrefix isEqualToString:@"2203"]) {
                if ([record.accountName isEqualToString:@"应付账款"]) {
                    [debtRecordArray insertObject:record atIndex:0];
                } else {
                    [debtRecordArray addObject:record];
                }
                data.debt += record.balance;
            }
            
            // 银行账户 1002
        }
        
        NSMutableDictionary *balanceRecordsForRootAccountName = [NSMutableDictionary dictionary];
        [balanceRecordsForRootAccountName setObject:cashRecordArray forKey:kJCHBalanceRecordCashKey];
        
        if (eWalletRecordArray.count > 0) {
            [balanceRecordsForRootAccountName setObject:eWalletRecordArray forKey:kJCHBalanceRecordEWalletKey];
        }
        
        [balanceRecordsForRootAccountName setObject:claimsRecordArray forKey:kJCHBalanceRecordClaimsKey];
        [balanceRecordsForRootAccountName setObject:debtRecordArray forKey:kJCHBalanceRecordDebtKey];
        
        self.balanceRecordsForRootAccountName = balanceRecordsForRootAccountName;
        
        if (eWalletRecordArray.count > 0) {
            self.rootAccountNameArray = @[kJCHBalanceRecordCashKey, kJCHBalanceRecordEWalletKey, kJCHBalanceRecordClaimsKey, kJCHBalanceRecordDebtKey];
        } else {
            self.rootAccountNameArray = @[kJCHBalanceRecordCashKey, kJCHBalanceRecordClaimsKey, kJCHBalanceRecordDebtKey];
        }
        
        
        data.netAsset = data.asset - data.debt;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.view animated:NO];
            [_statisticsView setViewData:data];
            [_contentTableView reloadData];
        });
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.balanceRecordsForRootAccountName.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.balanceRecordsForRootAccountName[self.rootAccountNameArray[section]] count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *iconArray = @[@"accountbook_ic_cash",
                           @"accountbook_ic_wallet",
                           @"accountbook_ic_creditor",
                           @"accountbook_ic_debt",
                           @"accountbook_ic_storagecard"]; //@"accountbook_ic_bank",


    NSArray *recordArray = [self.balanceRecordsForRootAccountName objectForKey:self.rootAccountNameArray[indexPath.section]];
    
    CGFloat totalValueInSection = 0.0f;
    for (AccountBalanceRecord4Cocoa *record in recordArray) {
        totalValueInSection += record.balance;
    }
    
    if (indexPath.row == 0) {
        
        JCHAccountBookTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJCHAccountBookTypeTableViewCellResuseID];
        cell -> _bottomLine.hidden = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        JCHAccountBookTypeTableViewCellData *data = [[[JCHAccountBookTypeTableViewCellData alloc] init] autorelease];
       
        data.title = self.rootAccountNameArray[indexPath.section];
        data.value = [self convertFloatAmountToString:totalValueInSection];
        data.imageName = iconArray[indexPath.section];
        
        [cell setViewData:data];
        return cell;
    } else {
        AccountBalanceRecord4Cocoa *balanceRecord = recordArray[indexPath.row - 1];
        
        JCHAccountBookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJCHAccountBookTableViewCellResuseID];
        cell -> _bottomLine.hidden = YES;
        [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
        if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
            cell -> _bottomLine.hidden = NO;
        }

        NSString *balance = [self convertFloatAmountToString:balanceRecord.balance];

        [cell setViewData:balance title:balanceRecord.accountName];
        
        
        return cell;
    }
}

- (NSString *)convertFloatAmountToString:(CGFloat)amount
{
    if (amount < 0) {
        return [NSString stringWithFormat:@"- ¥ %.2f", fabs(amount)];
    } else {
        return [NSString stringWithFormat:@"¥ %.2f", amount];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 36.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.rootAccountNameArray.count == 4) {
        
        if (section == 0 || section == 3) {
            return 20;
        }
        return 0;
    } else {
        
        if (section == 0 || section == 2) {
            return 20;
        }
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)] autorelease];
    sectionView.backgroundColor = JCHColorGlobalBackground;
    
    [sectionView addSeparateLineWithFrameTop:NO bottom:YES];
    return sectionView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return;
    }
    
    NSArray *recordArray = [self.balanceRecordsForRootAccountName objectForKey:self.rootAccountNameArray[indexPath.section]];
    AccountBalanceRecord4Cocoa *record = recordArray[indexPath.row - 1];
    
    UIViewController *viewController = nil;
    
    NSString *codePrefix = [record.accountCode substringToIndex:4];
    
    // 现金账户 1001
    if ([codePrefix isEqualToString:@"1001"]) {
        JCHJournalAccountViewController *cashJournalAccountVC = [[[JCHJournalAccountViewController alloc] initWithJournalType:kJCHJournalAccountTypeCash] autorelease];
        cashJournalAccountVC.title = record.accountName;
        cashJournalAccountVC.accountUUID = record.accountUUID;
        viewController = cashJournalAccountVC;
        WeakSelf;
        [cashJournalAccountVC setNeedReloadDataBlock:^(BOOL needReloadData) {
            weakSelf.isNeedReloadAllData = needReloadData;
        }];
    }

    // 电子钱包 1012
    if ([codePrefix isEqualToString:@"1012"]) {
        JCHJournalAccountViewController *eWalletJournalAccountVC = [[[JCHJournalAccountViewController alloc] initWithJournalType:kJCHJournalAccountTypeEWallet] autorelease];
        eWalletJournalAccountVC.title = [NSString stringWithFormat:@"%@流水", record.accountName];
        eWalletJournalAccountVC.accountUUID = record.accountUUID;
        viewController = eWalletJournalAccountVC;
    }

    // 债权账户 1122
    if ([codePrefix isEqualToString:@"1122"]) {
        viewController = [[[JCHChargeAccountViewController alloc] initWithChargeAccountType:kJCHChargeAccountReceipt] autorelease];
        viewController.title = @"应收款";
    }
    
    // 债务账户 2202/2203
    if ([codePrefix isEqualToString:@"2202"] || [codePrefix isEqualToString:@"2203"]) {
        if ([record.accountName isEqualToString:@"储值卡"]) {
            JCHJournalAccountViewController *savingCardJournalAccountVC = [[[JCHJournalAccountViewController alloc] initWithJournalType:kJCHJournalAccountTypeSavingCard] autorelease];
            savingCardJournalAccountVC.title = @"储值卡流水";
            savingCardJournalAccountVC.accountUUID = record.accountUUID;
            viewController = savingCardJournalAccountVC;
        } else {
            viewController = [[[JCHChargeAccountViewController alloc] initWithChargeAccountType:kJCHChargeAccountPayment] autorelease];
            viewController.title = @"应付款";
        }
    }

    if (viewController) {
        viewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;

    UIView *topView = [_contentTableView.backgroundView.subviews firstObject];
    CGRect topViewFrame = topView.frame;
    topViewFrame.size.height = MAX(_contentTableView.tableHeaderView.frame.size.height - offset.y, 0);
    topView.frame = topViewFrame;
}



@end
