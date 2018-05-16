//
//  JCHChargeAccountViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHChargeAccountViewController.h"
#import "JCHAccountBookViewController.h"
#import "JCHChargeAccountDetailViewController.h"
#import "JCHAccountBookStatisticsView.h"
#import "JCHChargeAccountTableViewCell.h"
#import "CommonHeader.h"
#import "ServiceFactory.h"
#import <Masonry.h>

@interface JCHChargeAccountViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_contentTableView;
    JCHAccountBookStatisticsView *_statisticsView;
    JCHChargeAccountType _currentChargeAccountType;
    JCHPlaceholderView *_placeholderView;
}
@property (nonatomic, retain) NSArray *dataSource;
@end

@implementation JCHChargeAccountViewController

- (instancetype)initWithChargeAccountType:(JCHChargeAccountType)chargeAccountType
{
    self = [super init];
    if (self) {
        _currentChargeAccountType = chargeAccountType;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createUI];
}

- (void)dealloc
{
    [self.dataSource release];
    
    [super dealloc];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
 
    if (self.isNeedReloadAllData) {
        [self loadData];
        self.isNeedReloadAllData = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSIndexPath *indexPath = [_contentTableView indexPathForSelectedRow];
    [_contentTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIView *backgroundView = _contentTableView.backgroundView;
    UIView *backgroundTopView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, _statisticsView.frame.size.height)] autorelease];
    backgroundTopView.backgroundColor = JCHColorHeaderBackground;
    [backgroundView addSubview:backgroundTopView];
}

- (void)createUI
{
    _statisticsView = [[[JCHAccountBookStatisticsView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 150.0f)] autorelease];
    _statisticsView.backgroundColor = JCHColorHeaderBackground;
    [_statisticsView setEditDataButtonHiddeh:YES];
    _statisticsView.topTitle = @"应付总额";
    _statisticsView.leftTitle = @"本月新增";
    _statisticsView.rightTitle = @"本月已还";
    if (_currentChargeAccountType == kJCHChargeAccountReceipt) {
        _statisticsView.topTitle = @"应收总额";
        _statisticsView.rightTitle = @"本月已收";
    }
    
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
    
    [_contentTableView registerClass:[JCHChargeAccountTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    
    _placeholderView = [[[JCHPlaceholderView alloc] initWithFrame:CGRectZero] autorelease];
    _placeholderView.hidden = YES;
    _placeholderView.imageView.image = [UIImage imageNamed:@"default_data_placeholder"];
    _placeholderView.label.text = @"暂无数据";
    [self.view addSubview:_placeholderView];
    
    CGFloat placeholderViewHeight = 158;
    CGFloat placeholderViewTopOffset = (kScreenHeight - 64) / 2 - 20;
    [_placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(placeholderViewHeight);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(self.view).with.offset(placeholderViewTopOffset);
    }];
}


#pragma mark - LoadData
- (void)loadData
{
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
        [MBProgressHUD showHUDWithTitle:@"加载中..."
                                 detail:nil
                               duration:100
                                   mode:MBProgressHUDModeIndeterminate
                              superView:self.view
                             completion:nil];
    }
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        CounterPartyARAPReportRecord4Cocoa *counterPartyARPReportRecord = nil;
        NSArray *receipt = nil;
        NSArray *payment = nil;
        //[manifestService calculateCounterPartyARAP:&counterPartyARPReportRecord receipt:&receipt payment:&payment];
        
        JCHAccountBookStatisticsViewData *data = [[[JCHAccountBookStatisticsViewData alloc] init] autorelease];
        
        //应收款
        if (_currentChargeAccountType == kJCHChargeAccountReceipt) {
            
            [manifestService calculateCounterPartyAR:&counterPartyARPReportRecord receipt:&receipt];
            NSMutableArray *receiptMutableArray = [NSMutableArray arrayWithArray:receipt];
            //过滤掉笔数为0的record
            for (CounterPartyARAPRecord4Cocoa *record in receipt) {
                if (record.manifestCount == 0) {
                    [receiptMutableArray removeObject:record];
                }
            }
            
            self.dataSource = receiptMutableArray;
            data.netAsset = counterPartyARPReportRecord.totalARAmount;
            data.asset = counterPartyARPReportRecord.thisMonthARAmountNew;
            data.debt = counterPartyARPReportRecord.thisMonthARAmountPayed;

        } else {
            //应付款
            
            [manifestService calculateCounterPartyAP:&counterPartyARPReportRecord payment:&payment];
            NSMutableArray *paymentMutableArray = [NSMutableArray arrayWithArray:payment];
            for (CounterPartyARAPRecord4Cocoa *record in payment) {
                if (record.manifestCount == 0) {
                    [paymentMutableArray removeObject:record];
                }
            }
            
            self.dataSource = paymentMutableArray;
            data.netAsset = counterPartyARPReportRecord.totalAPAmount;
            data.asset = counterPartyARPReportRecord.thisMonthAPAmountNew;
            data.debt = counterPartyARPReportRecord.thisMonthAPAmountPayed;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_statisticsView setViewData:data];
            [_contentTableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:NO];
            
            if (self.dataSource.count == 0) {
                _placeholderView.hidden = NO;
            } else {
                _placeholderView.hidden = YES;
            }
            isFinishedLoadData = YES;
        });
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHChargeAccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
    JCHChargeAccountTableViewCellData *data = [[[JCHChargeAccountTableViewCellData alloc] init] autorelease];
    
    CounterPartyARAPRecord4Cocoa *counterPartyARAPRecord = self.dataSource[indexPath.row];
    
    id<ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
    ContactsRecord4Cocoa *contactsRecord = [contactsService queryContacts:counterPartyARAPRecord.counterPartyUUID];
    data.debtAmount = counterPartyARAPRecord.amount;
    data.memberName = contactsRecord.name;
    data.phoneNumber = contactsRecord.phone;
    data.count = counterPartyARAPRecord.manifestCount;
    
    [cell setCellData:data];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CounterPartyARAPRecord4Cocoa *counterPartyARAPRecord = self.dataSource[indexPath.row];
    JCHChargeAccountDetailViewController *chargeAccountDetailVC = [[[JCHChargeAccountDetailViewController alloc] initWithContactsUUID:counterPartyARAPRecord.counterPartyUUID
                                                                                                                    chargeAccountType:_currentChargeAccountType] autorelease];
    [self.navigationController pushViewController:chargeAccountDetailVC animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    
    UIView *topView = _contentTableView.backgroundView.subviews[0];
    CGRect topViewFrame = topView.frame;
    topViewFrame.size.height = MAX(_contentTableView.tableHeaderView.frame.size.height - offset.y, 0);
    topView.frame = topViewFrame;
}


@end
