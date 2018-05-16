//
//  JCHSavingCardTransactionDetailsViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/5/24.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSavingCardTransactionViewController.h"
#import "JCHSavingCardTransactionDetailViewController.h"
#import "JCHSavingCardTransactionDetailsTableViewCell.h"
#import "CommonHeader.h"

static NSString *kSavingCardTransactionDetailsCellID = @"savingCardTransactionDetailsCellID";

@interface JCHSavingCardTransactionViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSArray *rechargeRecordArray;
@property (nonatomic, retain) ContactsRecord4Cocoa *contactRecord;

@end

@implementation JCHSavingCardTransactionViewController

- (instancetype)initWithContanctRecord:(ContactsRecord4Cocoa *)contactRecord
{
    self = [super init];
    if (self) {
        self.title = @"交易明细";
        self.contactRecord = contactRecord;
    }
    return self;
}

- (void)dealloc
{
    self.rechargeRecordArray = nil;
    self.contactRecord = nil;
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createUI];
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)createUI
{
    JCHSeparateLineSectionView *headerView = [[[JCHSeparateLineSectionView alloc] initWithTopLine:NO BottomLine:YES] autorelease];
    headerView.frame = CGRectMake(0, 0, kScreenWidth, kStandardSeparateViewHeight);
    self.tableView.tableHeaderView = headerView;

    [self.tableView registerClass:[JCHSavingCardTransactionDetailsTableViewCell class] forCellReuseIdentifier:kSavingCardTransactionDetailsCellID];
}

- (void)loadData
{
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    NSArray *rechargeRecordArray = nil;
    [manifestService queryCardManifestByUser:self.contactRecord.contactUUID rechargeRecordArray:&rechargeRecordArray];
    
    if (rechargeRecordArray.count == 0) {
        self.tableView.tableHeaderView = nil;
    }
    rechargeRecordArray = [rechargeRecordArray sortedArrayUsingComparator:^NSComparisonResult(CardRechargeRecord4Cocoa *obj1, CardRechargeRecord4Cocoa *obj2) {
        return obj1.manifestTimestamp < obj2.manifestTimestamp;
    }];
    
    self.rechargeRecordArray = rechargeRecordArray;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource / UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rechargeRecordArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHSavingCardTransactionDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSavingCardTransactionDetailsCellID];
    
    [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
    
    CardRechargeRecord4Cocoa *cardRechargeRecord = self.rechargeRecordArray[indexPath.row];
    
    JCHSavingCardTransactionDetailsTableViewCellData *data = [[[JCHSavingCardTransactionDetailsTableViewCellData alloc] init] autorelease];
    data.transactionType = cardRechargeRecord.manifestType;
    data.transactionTimestamp = cardRechargeRecord.manifestTimestamp;
    data.amount = cardRechargeRecord.amount;
    
    
    [cell setCellData:data];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CardRechargeRecord4Cocoa *cardRechargeRecord = self.rechargeRecordArray[indexPath.row];
    JCHSavingCardTransactionDetailViewController *transactionDetailVC = [[[JCHSavingCardTransactionDetailViewController alloc] initWithCardRechargeRecord:cardRechargeRecord] autorelease];
    [self.navigationController pushViewController:transactionDetailVC animated:YES];
}

@end
