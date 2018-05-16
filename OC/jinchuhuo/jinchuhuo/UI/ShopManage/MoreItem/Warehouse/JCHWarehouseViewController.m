//
//  JCHWarehouseViewController.m
//  jinchuhuo
//
//  Created by apple on 16/8/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHWarehouseViewController.h"
#import "JCHAddedServiceViewController.h"
#import "JCHAddWarehouseViewController.h"
#import "JCHItemListTableViewCell.h"
#import "WarehouseRecord4Cocoa.h"
#import "ServiceFactory.h"
#import "CommonHeader.h"
#import <Masonry.h>



@interface JCHWarehouseViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *contentTableView;
}

@property (retain, nonatomic, readwrite) NSArray<WarehouseRecord4Cocoa *> *warehouseList;
@property (retain, nonatomic, readwrite) NSString *deleteWarehouseID;

@end

@implementation JCHWarehouseViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"仓库";
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}

- (void)dealloc
{
    [self.warehouseList release];
    [self.deleteWarehouseID release];
    
    [super dealloc];
    return;
}

- (void)createUI
{
    //
    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_account_add"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(handleAddWarehouse:)] autorelease];
    self.navigationItem.rightBarButtonItems = @[addButton];
    
    //
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
    
    return;
}

- (void)loadData
{
    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
    self.warehouseList = [warehouseService queryAllWarehouse];
    [contentTableView reloadData];
    
    return;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark 添加仓库
- (void)handleAddWarehouse:(id)sender
{
    JCHAddedServiceManager *addedServiceManager = [JCHAddedServiceManager shareInstance];
    if (addedServiceManager.level != kJCHAddedServiceSiverLevel && addedServiceManager.level != kJCHAddedServiceGoldLevel) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"很抱歉，普通用户仅支持默认仓库，无法新建！购买仓库立即升级银麦会员享专线服务" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *addedServiceAction = [UIAlertAction actionWithTitle:@"购买" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            JCHAddedServiceViewController *addedServiceVC = [[[JCHAddedServiceViewController alloc] init] autorelease];
            [self.navigationController pushViewController:addedServiceVC animated:YES];
        }];
        [alertController addAction:cancleAction];
        [alertController addAction:addedServiceAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        JCHAddWarehouseViewController *viewController = [[[JCHAddWarehouseViewController alloc] initWithWarehouseID:@"-1"
                                                                                                     controllerMode:kAddWarehouse] autorelease];
        [self.navigationController pushViewController:viewController animated:YES];
    }

    
    
    return;
}

#pragma mark -
#pragma mark UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.warehouseList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
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
    }
    
    [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
    
    WarehouseRecord4Cocoa *warehouseRecord = [self.warehouseList objectAtIndex:indexPath.row];
    cell.textLabel.text = warehouseRecord.warehouseName;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        WarehouseRecord4Cocoa *warehouseRecord = [self.warehouseList objectAtIndex:indexPath.row];
    
        //判断该仓库是不是默认仓库
        if ([warehouseRecord.warehouseID isEqualToString:[[[ServiceFactory sharedInstance] utilityService] getDefaultWarehouseUUID]]) {
            
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                 message:@"默认仓库不能删除"
                                                                delegate:nil
                                                       cancelButtonTitle:@"我知道了"
                                                       otherButtonTitles:nil] autorelease];
            [alertView show];
            return;
        }
        
        //判断该仓库是否可以删除
        id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
        BOOL warehouseCanBeDelete = [warehouseService isWarehouseCanBeDeleted:warehouseRecord.warehouseID];
        
        if (!warehouseCanBeDelete) {
  
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                 message:@"当前仓库中有库存，不能删除"
                                                                delegate:nil
                                                       cancelButtonTitle:@"我知道了"
                                                       otherButtonTitles:nil] autorelease];
            [alertView show];
            return;
        }
        
        //可以删除
        self.deleteWarehouseID = warehouseRecord.warehouseID;
//        [self doDeleteWarehouse:warehouseRecord.warehouseID];
        [warehouseService deleteWarehouse:warehouseRecord.warehouseID];
        [self loadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WarehouseRecord4Cocoa *record = [self.warehouseList objectAtIndex:indexPath.row];
    JCHAddWarehouseViewController *viewController = [[[JCHAddWarehouseViewController alloc] initWithWarehouseID:record.warehouseID
                                                                                                 controllerMode:kModifyWarehouse] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
    
    return;
}

- (void)doDeleteWarehouse:(NSString *)warehouseID
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    WarehouseManageRequest *request = [[[WarehouseManageRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.token = statusManager.syncToken;
    request.accountBookID = statusManager.accountBookID;
    request.dataType = @"0";
    request.dataKey = warehouseID;
    request.serviceURL = [NSString stringWithFormat:@"%@/control/del", kJCHSyncManagerServerIP];
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    
    [dataSyncService deleteWarehouse:request callback:^(id response) {
        
        NSDictionary *userData = response;
        
        if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
            NSDictionary *responseData = userData[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                //! @todo
                
                [MBProgressHUD showHUDWithTitle:@"删除失败"
                                         detail:responseDescription
                                       duration:kJCHDefaultShowHudTime
                                           mode:MBProgressHUDModeText
                                     completion:nil];
                [self loadData];
            } else {
                //服务器删除成功，本地删除
                
                id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
                [warehouseService deleteWarehouse:self.deleteWarehouseID];
                [self loadData];
            }
            
        } else {
            NSLog(@"request fail: %@", userData[@"data"]);
            
            [MBProgressHUD showNetWorkFailedHud:nil];
            [self loadData];
        }
    }];
}


@end
