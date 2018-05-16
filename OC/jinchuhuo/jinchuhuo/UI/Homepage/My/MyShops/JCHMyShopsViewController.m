//
//  JCHMyShopsViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/10/25.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHMyShopsViewController.h"
#import "JCHWarehouseManageTableViewCell.h"
#import "CommonHeader.h"

@interface JCHMyShopsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSArray *accountBookList;
@end

@implementation JCHMyShopsViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"我的店铺";
        [self registerResponseNotificationHandler];
    }
    return self;
}

- (void)dealloc
{
    [self unregisterResponseNotificationHandler];
    self.accountBookList = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createUI];
    [self loadData];
}

- (void)createUI
{
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    self.tableView.tableFooterView = [[[UIView alloc] init] autorelease];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = YES;
    [self.tableView registerClass:[JCHWarehouseManageTableViewCell class] forCellReuseIdentifier:@"JCHWarehouseManageTableViewCell"];
}


- (void)loadData
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    self.accountBookList = [ServiceFactory getAllAccountBookList:statusManager.userID];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.accountBookList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHWarehouseManageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHWarehouseManageTableViewCell" forIndexPath:indexPath];
    
    [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
    
    
    BookInfoRecord4Cocoa *bookInfoRecord = self.accountBookList[indexPath.row];
    JCHWarehouseManageTableViewCellData *data = [[[JCHWarehouseManageTableViewCellData alloc] init] autorelease];
    data.title = bookInfoRecord.bookName;
    data.status = YES;
    [cell setCellData:data];
    
    return cell;
}

- (void)handleFetchAllAccountBookInfoList:(NSNotificationCenter *)nofity
{
    
}


- (void)registerResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    
    [notificationCenter addObserver:self
                           selector:@selector(handleFetchAllAccountBookInfoList:)
                               name:kJCHSyncFetchAllAccountBookListCommandNotification
                             object:[UIApplication sharedApplication]];
}

- (void)unregisterResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter removeObserver:self
                                  name:kJCHSyncFetchAllAccountBookListCommandNotification
                                object:[UIApplication sharedApplication]];
    
}



@end
