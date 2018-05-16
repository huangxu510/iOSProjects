//
//  JCHSettlementViewContrller.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/25.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSettlementViewContrller.h"
#import "JCHHTMLViewController.h"
#import "JCHOpenWeChatPayViewController.h"
#import "JCHSettlementTableViewCell.h"
#import "CommonHeader.h"
#import "JCHSettlementManager.h"
#import "JCHSyncStatusManager.h"
#import "ServiceFactory.h"
#import <Masonry.h>
#import <AFNetworking.h>

enum
{
    kJCHWeiXinPayStatusRow,
    kJCHAlipayStatusRow,
    kUnionPayStatusRow,
};

@interface JCHSettlementViewContrller () <UITableViewDelegate, UITableViewDataSource, JCHSettlementTableViewCellDelegate>
{
    UITableView *_contentTableView;
    BOOL _netStatusNotReachable;
}

@property (nonatomic, retain) NSMutableDictionary *statusForRow;

@end

@implementation JCHSettlementViewContrller

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self registerResponseNotificationHandler];
        
        _netStatusNotReachable = NO;
        self.statusForRow = [NSMutableDictionary dictionaryWithDictionary:@{@(kJCHWeiXinPayStatusRow) : @(kJCHSettlementStatusApply),
                                                                            @(kJCHAlipayStatusRow) : @(kJCHSettlementStatusApply),
                                                                            @(kUnionPayStatusRow) : @(kJCHSettlementStatusApply)}];
    }
    return self;
}

- (void)dealloc
{
    [self unregisterResponseNotificationHandler];
    [self.statusForRow release];
    
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"结算";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadData];
}

- (void)createUI
{
    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    _contentTableView.dataSource = self;
    _contentTableView.delegate = self;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_contentTableView];
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [_contentTableView registerClass:[JCHSettlementTableViewCell class] forCellReuseIdentifier:@"cell"];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *iconNameArr = @[@"icon_wepay", @"icon_zhipay", @"icon_unionpay"];
    NSArray *titleTextArr = @[@"微信支付通道", @"支付宝支付通道", @"银联支付通道"];
    NSArray *detailTextArr = @[@"由微信提供结算服务", @"由支付宝提供结算服务", @"由银联提供结算服务"];
    
    JCHSettlementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    [cell moveBottomLineLeft:YES];
    JCHSettlementTableViewCellData *data = [[[JCHSettlementTableViewCellData alloc] init] autorelease];
    data.imageName = iconNameArr[indexPath.row];
    data.titleText = titleTextArr[indexPath.row];
    data.detailText = detailTextArr[indexPath.row];
    data.settlementStatus = [self.statusForRow[@(indexPath.row)] integerValue];
    
    [cell setCellData:data];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:98.0f];
}

#pragma mark - JCHSettlementTableViewCellDelegate

- (void)handleJCHSettlementTableViewCellDelegateClick:(JCHSettlementTableViewCell *)cell
{
    if (_netStatusNotReachable == NO) {
        [MBProgressHUD showNetWorkFailedHud:nil];
        return;
    }
    
    JCHSettlementManager *settlementManager = [JCHSettlementManager sharedInstance];
    NSIndexPath *indexPath = [_contentTableView indexPathForCell:cell];
    switch (indexPath.row) {
        case 0:
        {
            NSInteger bindStatus = [self.statusForRow[@(indexPath.row)] integerValue];
            NSString *urlStr = [NSString stringWithFormat:@"%@/cmbc/wxbind.jsp?bindId=%@&UA=iOS&status=%d",
                                kCMBCPayServiceURL,
                                [settlementManager getBindID], (int)(bindStatus != 0)];
            
            JCHHTMLViewController *applyVC = [[[JCHHTMLViewController alloc] initWithURL:urlStr postRequest:NO] autorelease];
            [self.navigationController pushViewController:applyVC animated:YES];
        }
            break;
        case 1:
        {
            NSInteger bindStatus = [self.statusForRow[@(indexPath.row)] integerValue];
            NSString *urlStr = [NSString stringWithFormat:@"%@/cmbc/alipaybind.jsp?bindId=%@&UA=iOS&status=%d",
                                kCMBCPayServiceURL,
                                [settlementManager getBindID], (int)(bindStatus != 0)];
            
            JCHHTMLViewController *applyVC = [[[JCHHTMLViewController alloc] initWithURL:urlStr postRequest:NO] autorelease];
            [self.navigationController pushViewController:applyVC animated:YES];
        }
            break;
        case 2:
        {
            [MBProgressHUD showHUDWithTitle:@"暂不支持该通道" detail:nil duration:1.5 mode:MBProgressHUDModeText completion:nil];
            return;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - LoadData

- (void)loadData
{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager startMonitoring];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"networkChagne");
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
            
            _netStatusNotReachable = NO;
            [MBProgressHUD showNetWorkFailedHud:nil];
        } else {
            
            _netStatusNotReachable = YES;
            // [self queryWeiXinPayAccountOpenStatus];
            [self querySettlementMethod];
            
            [manager stopMonitoring];
            [manager setReachabilityStatusChangeBlock:nil];
        }
    }];
}

- (void)queryWeiXinPayAccountOpenStatus
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id <OnlineSettlement> settltmentService = [[ServiceFactory sharedInstance] onlineSettlementService];
    
    QueryWeiXinPayAccountBindStatusRequest *request = [[[QueryWeiXinPayAccountBindStatusRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.deviceUUID = statusManager.deviceUUID;
    request.serviceURL = [NSString stringWithFormat:@"%@/common/account/status", kPaySystemServerIP];
    request.bookID = statusManager.accountBookID;
    [settltmentService queryWeiXinPayAccountOpenStatus:request
                                              response:kJCHQueryWeiXinPayAccountOpenStatusNotification];
}

#pragma mark - QueryWeiXinAccountBindNotificationAndMethod

- (void)registerResponseNotificationHandler
{
    [JCHNotificationCenter addObserver:self
                           selector:@selector(handleQueryWeiXinAccountBind:)
                               name:kJCHQueryWeiXinPayAccountOpenStatusNotification
                             object:[UIApplication sharedApplication]];
}

- (void)unregisterResponseNotificationHandler
{
    [JCHNotificationCenter removeObserver:self
                                  name:kJCHQueryWeiXinPayAccountOpenStatusNotification
                                object:[UIApplication sharedApplication]];
    
}


- (void)handleQueryWeiXinAccountBind:(NSNotification *)notify
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
            // fail
            
            
            [MBProgressHUD showHudWithStatusCode:responseCode
                                       sceneType:kJCHMBProgressHUDSceneTypeQueryWeiXinAccountBind];
            
            return;
        } else {
            // success
            NSInteger bindStatus = [responseData[@"data"][@"weixinSl"] integerValue];
            
            NSInteger resultStatus = 0;
            if (bindStatus == 0) {
                resultStatus = kJCHSettlementStatusApply;
            } else if (bindStatus == 1) {
                resultStatus = kJCHSettlementStatusHasApply;
            } else if (bindStatus == 2) {
                resultStatus = kJCHSettlementStatusOnAuditing;
            } else if (bindStatus == 3) {
                resultStatus = kJCHSettlementStatusOpen;
            } else if (bindStatus == 4) {
                resultStatus = kJCHSettlementStatusHasOpen;
            } else {
                NSLog(@"Error BindStatus!!!");
                return;
            }
            
            [self.statusForRow setObject:@(resultStatus) forKey:@(kJCHWeiXinPayStatusRow)];
            //[_contentTableView reloadData];
            [self createUI];
        }
    } else {
        // network error
        [MBProgressHUD showNetWorkFailedHud:nil];
        self.statusForRow = [NSMutableDictionary dictionaryWithDictionary:@{@(kJCHWeiXinPayStatusRow) : @(kJCHSettlementStatusDisable),
                                                                            @(kJCHAlipayStatusRow) : @(kJCHSettlementStatusApply),
                                                                            @(kUnionPayStatusRow) : @(kJCHSettlementStatusApply)}];
        [_contentTableView reloadData];
    }
}

#pragma mark -
#pragma mark 查询当前的结算通道
- (void)querySettlementMethod
{
    [MBProgressHUD showHUDWithTitle:@"温馨提示"
                             detail:@"正在获取结算通道数据"
                           duration:999
                               mode:MBProgressHUDModeIndeterminate
                         completion:nil];
    JCHSettlementManager *settlementManager = [JCHSettlementManager sharedInstance];
    [settlementManager querySettlementMethodStatus:^(NSInteger enableMerchant, NSInteger enableAlipay, NSInteger enableWeiXin, NSString *bindID) {
        if (0 == enableMerchant && 0 == enableAlipay) {
            [self.statusForRow setObject:@(kJCHSettlementStatusHasOpen) forKey:@(kJCHAlipayStatusRow)];
        } else {
            [self.statusForRow setObject:@(0) forKey:@(kJCHAlipayStatusRow)];
        }
        
        [self.statusForRow setObject:@(0) forKey:@(kUnionPayStatusRow)];
        
        if (0 == enableMerchant && 0 == enableWeiXin) {
            [self.statusForRow setObject:@(kJCHSettlementStatusHasOpen) forKey:@(kJCHWeiXinPayStatusRow)];
        } else {
            [self.statusForRow setObject:@(0) forKey:@(kJCHWeiXinPayStatusRow)];
        }
        
        [self createUI];
        
        [MBProgressHUD hideAllHudsForWindow];
    } failureHandler:^{
        [_contentTableView reloadData];
    }];
}

#pragma mark -
#pragma mark 显示查询失败提示
- (void)showQueryFailureAlert:(NSString *)message
{
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"查询失败"
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"我知道了"
                                               otherButtonTitles:nil] autorelease];
    [alertView show];
}

@end
