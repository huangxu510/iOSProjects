//
//  JCHJournalAccountViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHJournalAccountViewController.h"
#import "JCHAddOtherIncomeAndExpenseViewController.h"
#import "JCHJournalAccountDetailViewController.h"
#import "JCHSavingCardTransactionViewController.h"
#import "JCHAdjustBalanceViewController.h"
#import "JCHAccountBookStatisticsView.h"
#import "JCHJournalAccountTableViewCell.h"
#import "JCHSavingCardJournalCell.h"
#import "CommonHeader.h"
#import "ServiceFactory.h"
#import "JCHManifestType.h"
#import "NSString+JCHString.h"
#import <Masonry.h>
#import <MJRefresh.h>

static NSString *kJournalAccountTableViewCellID = @"JCHSavingCardJournalCell.h";
static NSString *kJCHSavingCardJournalCellID = @"kJCHSavingCardJournalCellID";

@interface JCHJournalAccountViewController () <UITableViewDataSource,
                                                UITableViewDelegate,
                                                JCHAccountBookStatisticsViewDelegate,
                                                SWTableViewCellDelegate>
{
    JCHPlaceholderView *_placeholderView;
    UITableView *_contentTableView;
    JCHAccountBookStatisticsView *_statisticsView;
    JCHJournalAccountType _currentJournalType;
}
@property (nonatomic, retain) NSMutableArray *allJournalAccountRecord;
@property (nonatomic, retain) NSArray *allJournalAccountInSection;
@property (nonatomic, retain) JCHAccountBookStatisticsViewData *statisticsData;
@property (nonatomic, retain) NSArray *allUserCardBalanceArray;

@end

@implementation JCHJournalAccountViewController

- (instancetype)initWithJournalType:(JCHJournalAccountType)type;
{
    self = [super init];
    if (self) {
        _currentJournalType = type;
        self.allJournalAccountRecord = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.title = @"现金流水";
    [self createUI];
}

- (void)dealloc
{
    self.allJournalAccountRecord = nil;
    self.allJournalAccountInSection = nil;
    self.statisticsData = nil;
    self.accountUUID = nil;
    self.allUserCardBalanceArray = nil;
    self.needReloadDataBlock = nil;
    
    [super dealloc];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.isNeedReloadAllData) {
        [self.allJournalAccountRecord removeAllObjects];
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
    //UIBarButtonItem *addJournalAccountButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
    //target:self
    //action:@selector(handleAddJournalAccount)] autorelease];
    //UIBarButtonItem *settingButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
    //target:self
    //action:@selector(handleSetting)] autorelease];
    //self.navigationItem.rightBarButtonItems = @[addJournalAccountButton, settingButton];
    
    _statisticsView = [[[JCHAccountBookStatisticsView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 150.0f)] autorelease];
    _statisticsView.backgroundColor = JCHColorHeaderBackground;
    _statisticsView.delegate = self;
    _statisticsView.topTitle = @"余额";
    _statisticsView.leftTitle = @"流入";
    _statisticsView.rightTitle = @"流出";
    
    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    _contentTableView.dataSource = self;
    _contentTableView.delegate = self;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _contentTableView.tableHeaderView = _statisticsView;
    _contentTableView.tableFooterView = [[[UIView alloc] init] autorelease];
    
    if (_currentJournalType == kJCHJournalAccountTypeCash) {
        //现金账户实现分批加载
        WeakSelf;
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [weakSelf loadData];
        }];
        [footer setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
        [footer setTitle:@"" forState:MJRefreshStateIdle];
        [footer setTitle:@"没有更多数据了" forState:MJRefreshStateNoMoreData];
        _contentTableView.mj_footer = footer;
    }
   
    
    [self.view addSubview:_contentTableView];
    
    UIView *backgroundView = [[[UIView alloc] init] autorelease];
    backgroundView.backgroundColor = JCHColorGlobalBackground;
    _contentTableView.backgroundView = backgroundView;
    

    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        if (_currentJournalType == kJCHJournalAccountTypeCash) {
            make.bottom.equalTo(self.view).offset(-kTabBarHeight);
        } else {
            make.bottom.equalTo(self.view);
        }
    }];
    
    [_contentTableView registerClass:[JCHJournalAccountTableViewCell class] forCellReuseIdentifier:kJournalAccountTableViewCellID];
    [_contentTableView registerClass:[JCHSavingCardJournalCell class] forCellReuseIdentifier:kJCHSavingCardJournalCellID];
    
    if (_currentJournalType == kJCHJournalAccountTypeCash) {
        UIButton *noteButton = [JCHUIFactory createButton:CGRectZero
                                                   target:self
                                                   action:@selector(handleNote)
                                                    title:@"记一笔"
                                               titleColor:JCHColorHeaderBackground
                                          backgroundColor:[UIColor whiteColor]];
        [noteButton setImage:[UIImage imageNamed:@"journalAccount_addNote"] forState:UIControlStateNormal];
        [noteButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xd5d5d5)] forState:UIControlStateHighlighted];
        [noteButton addSeparateLineWithMasonryTop:YES bottom:NO];
        [self.view addSubview:noteButton];
        
        [noteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.height.mas_equalTo(kTabBarHeight);
        }];
    }
    
    
    _placeholderView = [[[JCHPlaceholderView alloc] initWithFrame:CGRectZero] autorelease];
    _placeholderView.hidden = YES;
    _placeholderView.imageView.image = [UIImage imageNamed:@"default_account_placeholder"];
    _placeholderView.label.text = @"暂无账户流水";
    [self.view addSubview:_placeholderView];
    
    
    CGFloat placeholderViewHeight = 158;
    CGFloat placeholderViewTopOffset = (kScreenHeight - 64) / 2 - 20;
    [_placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(placeholderViewHeight);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(self.view).with.offset(placeholderViewTopOffset);
    }];
}

- (void)handleAddJournalAccount
{
    
}

- (void)handleSetting
{
    
}

- (void)handleNote
{
    JCHAddOtherIncomeAndExpenseViewController *viewController = [[[JCHAddOtherIncomeAndExpenseViewController alloc] initWithType:kCreateIncomeExpense transaction:nil] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - LoadData

- (void)loadData
{
    if (self.allJournalAccountRecord.count == 0) {
        [MBProgressHUD showHUDWithTitle:@"加载中..."
                                 detail:nil
                               duration:100
                                   mode:MBProgressHUDModeIndeterminate
                              superView:self.view
                             completion:nil];
    }
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *allManifestListInRange = nil;
        
        //流入
        CGFloat income = 0.0f;
        //流出
        CGFloat expense = 0.0f;
        //! @note 储值卡流水
        if (_currentJournalType == kJCHJournalAccountTypeSavingCard) {
            
            [manifestService queryAllUserCardBalance:&allManifestListInRange];
            
            //筛选出余额不为0的记录
            NSMutableArray *allUserCardBalanceArray = [NSMutableArray array];
            for (UserCardBalanceRecord4Cocoa *record in allManifestListInRange) {
                if (record.incomeBalance != record.outcomeBalance) {
                    [allUserCardBalanceArray addObject:record];
                }
            }
            
            self.allUserCardBalanceArray = allUserCardBalanceArray;
            
            //统计资产和负债的时候要统计所有的记录
            for (UserCardBalanceRecord4Cocoa *record in allManifestListInRange) {
                income += record.incomeBalance;
                expense += record.outcomeBalance;
            }
            
            JCHAccountBookStatisticsViewData *data = [[[JCHAccountBookStatisticsViewData alloc] init] autorelease];
            data.netAsset = income - expense;
            data.asset = income;
            data.debt = expense;
            self.statisticsData = data;
        } else if (_currentJournalType == kJCHJournalAccountTypeCash || _currentJournalType == kJCHJournalAccountTypeEWallet) {
            
            NSInteger pageSize = 10;
            TICK;
            [manifestService queryManifestPayByAccount:self.allJournalAccountRecord.count
                                              pageSize:pageSize
                                           accountUUID:self.accountUUID
                                              inAmount:&income
                                             outAmount:&expense
                                   manifestRecordArray:&allManifestListInRange];
            TOCK(@"queryManifestPayByAccount");
            if (self.allJournalAccountRecord.count == 0) {
                JCHAccountBookStatisticsViewData *data = [[[JCHAccountBookStatisticsViewData alloc] init] autorelease];
                data.netAsset = income - expense;
                data.asset = income;
                data.debt = expense;
                self.statisticsData = data;
            }
            
            [self.allJournalAccountRecord addObjectsFromArray:allManifestListInRange];
            
            [self.allJournalAccountRecord sortUsingComparator:^NSComparisonResult(AccountTransactionRecord4Cocoa *obj1, AccountTransactionRecord4Cocoa *obj2) {
                return obj1.transTime < obj2.transTime;
            }];
            TOCK(@"sortUsingComparator");
            self.allJournalAccountInSection = [self subSectionManifest:self.allJournalAccountRecord];
            TOCK(@"subSectionManifest");
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.view animated:NO];
            if (_currentJournalType == kJCHJournalAccountTypeSavingCard) {
                [_statisticsView setEditDataButtonHiddeh:YES];
            }
            [_statisticsView setViewData:self.statisticsData];
            [_contentTableView reloadData];
            
            if (allManifestListInRange.count == 0 && self.allUserCardBalanceArray.count != 0) {
                [_contentTableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [_contentTableView.mj_footer endRefreshing];
            }
            
            if (_currentJournalType == kJCHJournalAccountTypeSavingCard) {
                if (self.allUserCardBalanceArray.count == 0) {
                    _placeholderView.hidden = NO;
                } else {
                    _placeholderView.hidden = YES;
                };
            } else {
                if (self.allJournalAccountInSection.count == 0) {
                    _placeholderView.hidden = NO;
                } else {
                    _placeholderView.hidden = YES;
                };
            }
        });
    });
}

- (NSArray *)subSectionManifest:(NSArray *)manifest
{
    NSMutableArray *allDays = [NSMutableArray array];
    for (AccountTransactionRecord4Cocoa *record in manifest) {
        NSString *dateStr = [NSString stringFromSeconds:record.transTime dateStringType:kJCHDateStringType6];
        if (record == manifest[0]) {
            [allDays addObject:dateStr];
        }
        else if (![allDays.lastObject isEqualToString:dateStr])
        {
            [allDays addObject:dateStr];
        }
    }
    
    NSMutableArray *manifestList_allSections = [NSMutableArray array];
    
    for (NSInteger i = 0; i < allDays.count; i++) {
        NSMutableArray *manifestList_section = [NSMutableArray array];
        for (NSInteger j = 0; j < manifest.count; j++) {
            
            AccountTransactionRecord4Cocoa *record = manifest[j];
            NSString *dateStr = [NSString stringFromSeconds:record.transTime dateStringType:kJCHDateStringType6];
            if ([allDays[i] isEqualToString:dateStr]) {
                [manifestList_section addObject:record];
            }
            
        }
        [manifestList_allSections addObject:manifestList_section];
    }
    return manifestList_allSections;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //储值卡
    if (_currentJournalType == kJCHJournalAccountTypeSavingCard) {
        return 1;
    } else {
        return self.allJournalAccountInSection.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_currentJournalType == kJCHJournalAccountTypeSavingCard) {
        return self.allUserCardBalanceArray.count;
    } else {
        return [self.allJournalAccountInSection[section] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_currentJournalType == kJCHJournalAccountTypeSavingCard) {
        
        JCHSavingCardJournalCell *cell = [tableView dequeueReusableCellWithIdentifier:kJCHSavingCardJournalCellID forIndexPath:indexPath];
        [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
        UserCardBalanceRecord4Cocoa *record = self.allUserCardBalanceArray[indexPath.row];
        
        JCHSavingCardJournalCellData *data = [[[JCHSavingCardJournalCellData alloc] init] autorelease];
        id <ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
        ContactsRecord4Cocoa *contactRecord = [contactsService queryContacts:record.userUUID];
        data.headImageName = nil;
        data.phone = contactRecord.phone;
        data.name = [record.userName isEmptyString] ? @"匿名" : record.userName;
        data.totalAmount = record.incomeBalance - record.outcomeBalance;
        [cell setCellData:data];
        return cell;
    } else {
        
        JCHJournalAccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJournalAccountTableViewCellID forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
        
        AccountTransactionRecord4Cocoa *record = self.allJournalAccountInSection[indexPath.section][indexPath.row];
        
        JCHJournalAccountTableViewCellData *data = [[[JCHJournalAccountTableViewCellData alloc] init] autorelease];
        data.manifestID = record.manifestID;
        data.manifestTimestamp = record.transTime;
        data.manifestType = record.manifestType;
        data.value = record.amount;
        data.manifestDescription = record.recordDescription;
        data.date = [NSString stringFromSeconds:record.transTime dateStringType:kJCHDateStringType7];
        cell.delegate = self;
        
        if ((_currentJournalType == kJCHJournalAccountTypeCash) && (record.manifestType == kJCHManifestExtraIncome ||
            record.manifestType == kJCHManifestExtraExpenses)) {
            NSMutableArray *buttonsArray = [NSMutableArray array];
            [buttonsArray sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f)
                                                  icon:[UIImage imageNamed:@"manifest_more_open_delete"]];
            [buttonsArray sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f)
                                                  icon:[UIImage imageNamed:@"manifest_more_open_edit"]];
            cell.rightUtilityButtons = buttonsArray;
        } else {
            cell.rightUtilityButtons = nil;
        }

        [cell setCellData:data];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_currentJournalType == kJCHJournalAccountTypeSavingCard) {
        UserCardBalanceRecord4Cocoa *record = self.allUserCardBalanceArray[indexPath.row];
        id <ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
        ContactsRecord4Cocoa *contactRecord = [contactsService queryContacts:record.userUUID];
        JCHSavingCardTransactionViewController *transactionVC = [[[JCHSavingCardTransactionViewController alloc] initWithContanctRecord:contactRecord] autorelease];
        [self.navigationController pushViewController:transactionVC animated:YES];
    } else if (_currentJournalType == kJCHJournalAccountTypeCash) {
        AccountTransactionRecord4Cocoa *record = self.allJournalAccountInSection[indexPath.section][indexPath.row];
        
        JCHJournalAccountDetailViewController *detailVC = [[[JCHJournalAccountDetailViewController alloc] initWithAccountTransactionRecord:record] autorelease];
        [self.navigationController pushViewController:detailVC animated:YES];
    } else {
        return;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_currentJournalType == kJCHJournalAccountTypeSavingCard) {
        return 0;
    } else {
        return 30.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_currentJournalType == kJCHJournalAccountTypeSavingCard) {
        return nil;
    } else {
        UIView *sectionView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30.0f)] autorelease];
        sectionView.backgroundColor = JCHColorGlobalBackground;
        [sectionView addSeparateLineWithFrameTop:NO bottom:YES];
        
        UILabel *dateTitleLabel = [JCHUIFactory createLabel:CGRectMake(kStandardLeftMargin, 0, kScreenWidth -  2 * kStandardLeftMargin, 30.0f)
                                                      title:@""
                                                       font:[UIFont systemFontOfSize:12.0f]
                                                  textColor:JCHColorMainBody
                                                     aligin:NSTextAlignmentLeft];
        [sectionView addSubview:dateTitleLabel];
        
        AccountTransactionRecord4Cocoa *record = [self.allJournalAccountInSection[section] firstObject];
        
        NSString *dateString = [NSString stringFromSeconds:record.transTime dateStringType:kJCHDateStringType6];
        
        dateTitleLabel.text = dateString;
        
        return sectionView;
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    
    UIView *topView = _contentTableView.backgroundView.subviews[0];
    CGRect topViewFrame = topView.frame;
    topViewFrame.size.height = MAX(_contentTableView.tableHeaderView.frame.size.height - offset.y, 0);
    topView.frame = topViewFrame;
}

#pragma mark - JCHAccountBookStatisticsViewDelegate

- (void)handleEditData
{
    JCHAdjustBalanceViewController *adjustBalanceVC = [[[JCHAdjustBalanceViewController alloc] initWithAccountUUID:self.accountUUID
                                                                                              currentBalanceAmount:self.statisticsData.netAsset] autorelease];
    WeakSelf;
    [adjustBalanceVC setNeedReloadDataBlock:^(BOOL needReloadData) {
        weakSelf.isNeedReloadAllData = needReloadData;
        if (weakSelf.needReloadDataBlock) {
            weakSelf.needReloadDataBlock(YES);
        }
    }];
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:adjustBalanceVC] autorelease];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark -
#pragma 编辑现金收支
#pragma mark - SWTableViewCellDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [_contentTableView indexPathForCell:cell];
    AccountTransactionRecord4Cocoa *record = self.allJournalAccountInSection[indexPath.section][indexPath.row];

    if (0 == index) {
        id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
        [manifestService deleteManifest:record.manifestType manifestID:record.manifestID];
        self.isNeedReloadAllData = YES;
        [self.allJournalAccountRecord removeAllObjects];
        [self loadData];
    } else if (1 == index) {
        JCHAddOtherIncomeAndExpenseViewController *editVC = [[[JCHAddOtherIncomeAndExpenseViewController alloc] initWithType:kModifyIncomeExpense transaction:record] autorelease];
        [self.navigationController pushViewController:editVC animated:YES];
        [_contentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    
    
    return;
}

@end
