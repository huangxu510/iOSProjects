//
//  JCHCashRegisterListViewController.m
//  jinchuhuo
//
//  Created by apple on 2016/11/4.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHCashRegisterListViewController.h"
#import "JCHAddedServiceViewController.h"
#import "JCHBarCodeScannerViewController.h"
#import "JCHItemListTableViewCell.h"
#import "CommonHeader.h"
#import <SWTableViewCell.h>


@interface JCHCashRegisterListViewController ()<UITableViewDelegate,
                                                UITableViewDataSource,
                                                SWTableViewCellDelegate>
{
    UITableView *contentTableView;
    JCHPlaceholderView *_placeholderView;
}

@property (retain, nonatomic, readwrite) NSMutableArray *deviceUserIDList;
@property (retain, nonatomic, readwrite) NSMutableArray *deviceMemberList;
@property (retain, nonatomic, readwrite) NSString *currentUnbindDevice;

@end

@implementation JCHCashRegisterListViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"收银机管理";
        self.deviceUserIDList = [NSMutableArray new];
        self.deviceMemberList = [NSMutableArray new];
        [self registerResponseNotificationHandler];
    }
    
    return self;
}

- (void)dealloc
{
    [self unregisterResponseNotificationHandler];
    self.deviceUserIDList = nil;
    self.currentUnbindDevice = nil;
    self.deviceMemberList = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUI];
    
    return;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self queryBookMember];

    return;
}

- (void)queryBookMember
{
    [MBProgressHUD showHUDWithTitle:@"温馨提示"
                             detail:@"正在查询收银机列表..."
                           duration:1000
                               mode:MBProgressHUDModeText
                         completion:nil];
    
    [self performSelector:@selector(doQueryDeviceList:)
               withObject:nil
               afterDelay:0.1];
    
}

- (void)loadData
{
    [self.deviceMemberList removeAllObjects];
    
    id <BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
    for (NSString *userId in self.deviceUserIDList) {
        BookMemberRecord4Cocoa *bookMemberRecord = [bookMemberService queryBookMemberWithUserID:userId];
        if (bookMemberRecord.userId && ![bookMemberRecord.userId isEqualToString:@""]) {
            [self.deviceMemberList addObject:bookMemberRecord];
        } else {
            bookMemberRecord = [[[BookMemberRecord4Cocoa alloc] init] autorelease];
            bookMemberRecord.userId = userId;
            bookMemberRecord.nickname = userId;
            [self.deviceMemberList addObject:bookMemberRecord];
        }
    }
    
    [contentTableView reloadData];
    
    if (0 == self.deviceMemberList.count) {
        [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                 detail:@"您的店铺当前无绑定的收银机"
                               duration:kJCHDefaultShowHudTime
                                   mode:MBProgressHUDModeText
                             completion:nil];
        _placeholderView.hidden = NO;
    } else {
        _placeholderView.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createUI
{
    UIButton *addButton = [JCHUIFactory createButton:CGRectMake(0, 0, 30, 44)
                                              target:self
                                              action:@selector(addDevice)
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

    
    
    contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero] autorelease];
    [self.view addSubview:contentTableView];
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    contentTableView.backgroundColor = JCHColorGlobalBackground;
    contentTableView.tableHeaderView = [[[UIView alloc] init] autorelease];
    contentTableView.tableFooterView = [[[UIView alloc] init] autorelease];
    contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    _placeholderView = [[[JCHPlaceholderView alloc] initWithFrame:CGRectZero] autorelease];
    _placeholderView.hidden = YES;
    _placeholderView.imageView.image = [UIImage imageNamed:@"default_data_placeholder"];
    _placeholderView.label.text = @"暂无数据";
    [contentTableView addSubview:_placeholderView];
    
    CGFloat placeholderViewHeight = 158;
    
    [_placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(placeholderViewHeight);
        make.width.mas_equalTo(kScreenWidth);
        make.centerX.centerY.equalTo(contentTableView);
    }];
    
    return;
}

- (void)addDevice
{
    JCHAddedServiceManager *addedServiceManager = [JCHAddedServiceManager shareInstance];
    if (addedServiceManager.level != kJCHAddedServiceSiverLevel && addedServiceManager.level != kJCHAddedServiceGoldLevel) {
        if (self.deviceMemberList.count >= 1) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"很抱歉，普通用户仅支持1台机具，无法添加！购买机具数立即升级银麦会员享专线服务" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *addedServiceAction = [UIAlertAction actionWithTitle:@"购买" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                JCHAddedServiceViewController *addedServiceVC = [[[JCHAddedServiceViewController alloc] init] autorelease];
                addedServiceVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:addedServiceVC animated:YES];
            }];
            [alertController addAction:cancleAction];
            [alertController addAction:addedServiceAction];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
    }

    
    JCHBarCodeScannerViewController *barCodeScanerVC = [[[JCHBarCodeScannerViewController alloc] init] autorelease];
    barCodeScanerVC.title = @"扫码";
    barCodeScanerVC.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    barCodeScanerVC.barCodeBlock = ^(NSString *barCode){
        AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
        [appDelegate.homePageController handleFinishScanQRCode:barCode
                                                   joinAccount:NO
                                                  authorizePad:YES
                                                      loginPad:YES];
    };
    [self presentViewController:barCodeScanerVC animated:YES completion:nil];
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)self.deviceMemberList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *kCellReuseTag = @"kCellReuseTag";
    JCHItemListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseTag];
    if (nil == cell) {
        cell = [[[JCHItemListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellReuseTag] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
        cell.textLabel.textColor = JCHColorMainBody;
        cell.arrowImageView.hidden = YES;
        cell.delegate = self;
        NSMutableArray *buttonsArray = [NSMutableArray array];
        [buttonsArray sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f)
                                               icon:[UIImage imageNamed:@"more_open_relieve"]];
        cell.rightUtilityButtons = buttonsArray;
    }
    
    [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
    
    BookMemberRecord4Cocoa *bookMember = [self.deviceMemberList objectAtIndex:indexPath.row];
    
    if ([bookMember.nickname isEqualToString:@""]) {
        cell.textLabel.text = bookMember.userId;
    } else {
        cell.textLabel.text = bookMember.nickname;
    }
    
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - SWTableViewCellDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    if (0 == index) {
        NSIndexPath *indexPath = [contentTableView indexPathForCell:cell];
        BookMemberRecord4Cocoa *deviceRecord = [self.deviceMemberList objectAtIndex:indexPath.row];
        self.currentUnbindDevice = deviceRecord.userId;
        [self deleteShopAssistant];
    }
    
    return;
}

#pragma mark -
#pragma mark 消息通知相关
- (void)registerResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleDoQueryDeviceList:)
                               name:kJCHQueryAccountBookRelationNotification
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

- (void)doQueryDeviceList:(id)sender
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

- (void)handleDoQueryDeviceList:(NSNotification *)notify
{
    [MBProgressHUD hideAllHudsForWindow];
    [self.deviceUserIDList removeAllObjects];
    
    NSDictionary *userData = notify.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        NSString *responseDescription = responseData[@"desc"];
        NSString *responseStatus = responseData[@"status"];
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
        
        if (YES == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
            NSArray *statusList = responseData[@"data"][@"list"];
            for (NSDictionary *dict in statusList) {
                NSString *type = [NSString stringWithFormat:@"%@", dict[@"type"]];
                NSString *userId = [NSString stringWithFormat:@"%@", dict[@"userId"]];
                if ([type isEqualToString:@"2"]) {
                    [self.deviceUserIDList addObject:userId];
                }
            }
            
            [self loadData];
            return;
        }
    }

    NSLog(@"request fail: %@", userData[@"data"]);
    
    id <BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
    NSArray *bookMemberList = [bookMemberService queryCashMember];
    for (BookMemberRecord4Cocoa *record in bookMemberList) {
        [self.deviceUserIDList addObject:record.userId];
    }
    
    [self loadData];
    
    return;
}


#pragma mark - 解绑收银机
- (void)deleteShopAssistant
{
    WeakSelf;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"确定解除对此收银机的绑定?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                 detail:@"正在对收银机解除绑定..."
                               duration:1000
                                   mode:MBProgressHUDModeText
                             completion:nil];
        
        [weakSelf makeSureDeleteShopAssistant];
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:alertAction];
    [alertController addAction:cancleAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)makeSureDeleteShopAssistant
{
    //1)请求服务器删除
    //2)从成员列表中删除店员
    //3)push
    [MBProgressHUD showHUDWithTitle:@"解绑中..."
                             detail:@""
                           duration:1000
                               mode:MBProgressHUDModeIndeterminate
                         completion:nil];
    WeakSelf;
    JCHDataSyncManager *dataSyncManager = [JCHDataSyncManager shareInstance];
    [dataSyncManager doLeaveAccountBook:self.currentUnbindDevice success:^(NSDictionary *responseData) {
        [weakSelf deleteShopAssistantSuccess];
    } failure:^(NSInteger responseCode, NSError *error) {
        if (error) {
            [MBProgressHUD showNetWorkFailedHud:nil];
        } else {
            [MBProgressHUD showHudWithStatusCode:responseCode
                                       sceneType:kJCHMBProgressHUDSceneTypeDeleteMember];
        }
    }];
    
}

- (void)deleteShopAssistantSuccess
{
    id <BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
    [bookMemberService deleteBookMemeber:self.currentUnbindDevice];
    
    //PUSH
    WeakSelf;
    JCHDataSyncManager *dataSyncManager = [JCHDataSyncManager shareInstance];
    [dataSyncManager doSyncPushCommand:^(NSInteger pushFlag, NSInteger pullFlag, NSDictionary *responseData) {
        [MBProgressHUD showHUDWithTitle:@"解绑成功"
                                 detail:@""
                               duration:kJCHDefaultShowHudTime
                                   mode:MBProgressHUDModeText
                             completion:^ {
                                 [weakSelf queryBookMember];
                             }];
    } failure:^(NSInteger responseCode, NSError *error) {
        
        if (error) {
            [MBProgressHUD showNetWorkFailedHud:nil];
        }
    }];
}



@end
