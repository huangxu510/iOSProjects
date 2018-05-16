//
//  JCHShopAssistantManageViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/4/21.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHShopAssistantManageViewController.h"
#import "JCHShopBarCodeViewController.h"
#import "JCHShopAssistantInfoViewController.h"
#import "JCHShopAssistantManageTableViewCell.h"
#import "JCHSeparateLineSectionView.h"
#import "CommonHeader.h"

@interface JCHShopAssistantManageViewController () <UITableViewDelegate, UITableViewDataSource, JCHShopAssistantManageTableViewCellDelegate>
{
    UITableView *_contentTableView;
    JCHPlaceholderView *_placeholderView;
}
@property (nonatomic, retain) NSArray *shopAssistants;
@property (nonatomic, retain) NSArray *statusList;
@property (nonatomic, retain) NSMutableDictionary *statusForUserId;
@end
@implementation JCHShopAssistantManageViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"店员管理";
        [self registerResponseNotificationHandler];
    }
    return self;
}

- (void)dealloc
{
    [self unregisterResponseNotificationHandler];
    self.shopAssistants = nil;
    self.statusList = nil;
    self.statusForUserId = nil;
    
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self doQueryAccountBookRelation];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_contentTableView deselectRowAtIndexPath:[_contentTableView indexPathForSelectedRow] animated:YES];
}

- (void)createUI
{
    UIButton *addButton = [JCHUIFactory createButton:CGRectMake(0, 0, 30, 44)
                                              target:self
                                              action:@selector(addShopAssistant)
                                               title:nil
                                          titleColor:nil
                                     backgroundColor:nil];
    [addButton setImage:[UIImage imageNamed:@"icon_account_add"] forState:UIControlStateNormal];
    UIBarButtonItem *addItem = [[[UIBarButtonItem alloc] initWithCustomView:addButton] autorelease];
    UIBarButtonItem *fixedSpace = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:self
                                                                                action:nil] autorelease];
    fixedSpace.width = -5;
    
    self.navigationItem.rightBarButtonItems = @[fixedSpace, addItem];
    
    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    _contentTableView.delegate = self;
    _contentTableView.dataSource = self;
    JCHSeparateLineSectionView *headerView = [[[JCHSeparateLineSectionView alloc] initWithTopLine:NO BottomLine:YES] autorelease];
    headerView.frame = CGRectMake(0, 0, kScreenWidth, 20);
    //_contentTableView.tableHeaderView = headerView;
    _contentTableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    _contentTableView.tableFooterView = [[[UIView alloc] init] autorelease];
    _contentTableView.backgroundColor = JCHColorGlobalBackground;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _contentTableView.bounces = YES;
    [_contentTableView registerClass:[JCHShopAssistantManageTableViewCell class] forCellReuseIdentifier:@"shopAssistantManageTableViewCell"];
    [self.view addSubview:_contentTableView];
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    _placeholderView = [[[JCHPlaceholderView alloc] initWithFrame:CGRectZero] autorelease];
    _placeholderView.hidden = YES;
    _placeholderView.imageView.image = [UIImage imageNamed:@"default_data_placeholder"];
    _placeholderView.label.text = @"暂无数据";
    [_contentTableView addSubview:_placeholderView];
    
    CGFloat placeholderViewHeight = 158;
    
    [_placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(placeholderViewHeight);
        make.width.mas_equalTo(kScreenWidth);
        make.centerX.centerY.equalTo(_contentTableView);
    }];
}

- (void)loadData
{
    NSMutableDictionary *statusForUserId = [NSMutableDictionary dictionary];
    NSMutableArray *shopAssistantUserIdArray = [NSMutableArray array];
    for (NSDictionary *dict in self.statusList) {
        NSString *type = [NSString stringWithFormat:@"%@", dict[@"type"]];
        NSString *userId = [NSString stringWithFormat:@"%@", dict[@"userId"]];
        NSString *status = [NSString stringWithFormat:@"%@", dict[@"status"]];   //status  0:启用   1:禁用
        [statusForUserId setObject:status forKey:userId];
        if ([type isEqualToString:@"1"]) {
            [shopAssistantUserIdArray addObject:userId];
        }
    }
    
    self.statusForUserId = statusForUserId;
    
    id <BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
    
    NSMutableArray *shopAssistantRecordArray = [NSMutableArray array];
   
    for (NSString *userId in shopAssistantUserIdArray) {
        BookMemberRecord4Cocoa *bookMemberRecord = [bookMemberService queryBookMemberWithUserID:userId];
        if (bookMemberRecord.userId && ![bookMemberRecord.userId isEqualToString:@""]) {
            [shopAssistantRecordArray addObject:bookMemberRecord];
        } else {
            bookMemberRecord = [[[BookMemberRecord4Cocoa alloc] init] autorelease];
            bookMemberRecord.userId = userId;
            [shopAssistantRecordArray addObject:bookMemberRecord];
        }
    }
    
    self.shopAssistants = shopAssistantRecordArray;
    [_contentTableView reloadData];
    
    if (self.shopAssistants.count == 0) {
        _placeholderView.hidden = NO;
    } else {
        _placeholderView.hidden = YES;
    }
}

- (void)addShopAssistant
{
    JCHShopBarCodeViewController *barCodeVC = [[[JCHShopBarCodeViewController alloc] initWithShopBarCodeType:kJCHShopBarCodeFindShopAssistant] autorelease];
    barCodeVC.navigationBarHiddenAnimation = YES;
    [self.navigationController pushViewController:barCodeVC animated:YES];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.shopAssistants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHShopAssistantManageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shopAssistantManageTableViewCell"];
    
    [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
    [cell addTopLineForFirstCell:indexPath];
    cell.delegate = self;
    BookMemberRecord4Cocoa *bookMemberRecord = self.shopAssistants[indexPath.row];
    
    JCHShopAssistantManageTableViewCellData *data = [[[JCHShopAssistantManageTableViewCellData alloc] init] autorelease];
    data.headImageName = [JCHImageUtility getAvatarImageNameFromAvatarUrl:bookMemberRecord.avatarUrl];;
    data.title = [JCHDisplayNameUtility getDisplayRemark:bookMemberRecord];
    data.status = ![self.statusForUserId[bookMemberRecord.userId] integerValue];
    //TODO: 入店时间
    data.subTitle = @"入店时间:2016/04/17";
    
    [cell setCellData:data];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHShopAssistantInfoViewController *assistantInfoVC = [[[JCHShopAssistantInfoViewController alloc] init] autorelease];
    BookMemberRecord4Cocoa *bookMemberRecord = self.shopAssistants[indexPath.row];
    assistantInfoVC.userID = bookMemberRecord.userId;
    [self.navigationController pushViewController:assistantInfoVC animated:YES];
}

#pragma mark - JCHShopAssistantManageTableViewCellDelegate

- (void)handleSwitchAction:(UISwitch *)statusSwitch inCell:(JCHShopAssistantManageTableViewCell *)cell
{
    BOOL status = statusSwitch.on;
    NSIndexPath *indexPath = [_contentTableView indexPathForCell:cell];
    BookMemberRecord4Cocoa *bookMemberRecord = self.shopAssistants[indexPath.row];
    
    [self doModifyAccountBookRelation:bookMemberRecord.userId status:!status];
}


- (void)registerResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    
    [notificationCenter addObserver:self
                           selector:@selector(handleQueryAccountBookRelation:)
                               name:kJCHQueryAccountBookRelationNotification
                             object:[UIApplication sharedApplication]];
    
    
    [notificationCenter addObserver:self
                           selector:@selector(handleModifyAccountBookRelation:)
                               name:kJCHModifyAccountBookRelationNotification
                             object:[UIApplication sharedApplication]];
}

- (void)unregisterResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter removeObserver:self
                                  name:kJCHQueryAccountBookRelationNotification
                                object:[UIApplication sharedApplication]];
    
    [notificationCenter removeObserver:self
                                  name:kJCHModifyAccountBookRelationNotification
                                object:[UIApplication sharedApplication]];
}

- (void)doQueryAccountBookRelation
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    QueryAccountBookRelationRequest *request = [[[QueryAccountBookRelationRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.token = statusManager.syncToken;
    request.serviceURL = [NSString stringWithFormat:@"%@/terminal/relationList", kJCHSyncManagerServerIP];
    request.accountBookID = statusManager.accountBookID;
    
     id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService queryAccountBookRelation:request responseNotification:kJCHQueryAccountBookRelationNotification];
}

- (void)handleQueryAccountBookRelation:(NSNotification *)notify
{
    NSDictionary *userData = notify.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        NSString *responseDescription = responseData[@"desc"];
        NSString *responseStatus = responseData[@"status"];
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
        
        if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
            //! @todo
            [MBProgressHUD showHUDWithTitle:@"查询失败"
                                     detail:responseDescription
                                   duration:2
                                       mode:MBProgressHUDModeText
                                 completion:nil];
            return;
        } else {
            //! @todo
            
            NSArray *statusList = responseData[@"data"][@"list"];
            self.statusList = statusList;
            [self loadData];
        }
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
        [MBProgressHUD showNetWorkFailedHud:nil];
        
        [_contentTableView reloadData];
    }
    
    return;
}

- (void)doModifyAccountBookRelation:(NSString *)userId status:(BOOL)status
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    ModifyAccountBookRelationRequest *request = [[[ModifyAccountBookRelationRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.token = statusManager.syncToken;
    request.accountBookID = statusManager.accountBookID;
    request.userID = userId;
    request.status = status;
    request.serviceURL = [NSString stringWithFormat:@"%@/terminal/relationStatus", kJCHSyncManagerServerIP];
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService modifyAccountBookRelation:request responseNotification:kJCHModifyAccountBookRelationNotification];
}

- (void)handleModifyAccountBookRelation:(NSNotification *)notify
{
    NSDictionary *userData = notify.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        NSString *responseDescription = responseData[@"desc"];
        NSString *responseStatus = responseData[@"status"];
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
        
        if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
            //! @todo
            [MBProgressHUD showHUDWithTitle:@"操作失败"
                                     detail:responseDescription
                                   duration:2
                                       mode:MBProgressHUDModeText
                                 completion:nil];
            [_contentTableView reloadData];
            return;
        } else {
            //! @todo
            
            if (responseCode != 10000) {
                [_contentTableView reloadData];
            }
        }
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
        [MBProgressHUD showNetWorkFailedHud:nil];
        
        [_contentTableView reloadData];
    }
}


@end
