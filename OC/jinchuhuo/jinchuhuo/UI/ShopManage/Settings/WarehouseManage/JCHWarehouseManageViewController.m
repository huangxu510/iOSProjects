//
//  JCHWarehouseManageViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/10/24.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHWarehouseManageViewController.h"
#import "JCHAddWarehouseViewController.h"
#import "JCHWarehouseManageTableViewCell.h"
#import "CommonHeader.h"

@interface JCHWarehouseManageViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSArray *warehouseList;
@property (nonatomic, retain) NSArray *warehouseListWithoutDefault;
@property (nonatomic, retain) NSArray *warehouseListOnServer;

@end

@implementation JCHWarehouseManageViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"仓库管理";
    }
    return self;
}

- (void)dealloc
{
    self.warehouseList = nil;
    self.warehouseListOnServer = nil;
    self.warehouseListWithoutDefault = nil;
    
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    self.tableView.tableFooterView = [[[UIView alloc] init] autorelease];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = YES;
    [self.tableView registerClass:[JCHWarehouseManageTableViewCell class] forCellReuseIdentifier:@"JCHWarehouseManageTableViewCell"];
}

- (void)loadData
{
    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
    NSArray *warehouseList = [warehouseService queryAllWarehouse];
    self.warehouseList = warehouseList;
    
    NSString *defaultWarehouseID = [[[ServiceFactory sharedInstance] utilityService] getDefaultWarehouseUUID];
    NSMutableArray *warehouseListWithoutDefault = [NSMutableArray array];
    for (WarehouseRecord4Cocoa *warehouseRecord in warehouseList) {
        if (![warehouseRecord.warehouseID isEqualToString:defaultWarehouseID]) {
            [warehouseListWithoutDefault addObject:warehouseRecord];
        }
    }
    
    self.warehouseListWithoutDefault = warehouseListWithoutDefault;
    
    [self repairWarehouseRecord:nil result:nil];
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.warehouseList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHWarehouseManageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHWarehouseManageTableViewCell"];
    
    [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
    [cell addTopLineForFirstCell:indexPath];

    WeakSelf;
    cell.switchAction = ^(BOOL status){
        [weakSelf switchStatus:status indexPath:indexPath];
    };
    
    WarehouseRecord4Cocoa *warehouseRecord = self.warehouseList[indexPath.row];
    
    JCHWarehouseManageTableViewCellData *data = [[[JCHWarehouseManageTableViewCellData alloc] init] autorelease];
    data.title = warehouseRecord.warehouseName;
    data.status = warehouseRecord.warehouseStatus;

    
    [cell setCellData:data];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WarehouseRecord4Cocoa *warehouseRecord = self.warehouseList[indexPath.row];
    JCHAddWarehouseViewController *viewController = [[[JCHAddWarehouseViewController alloc] initWithWarehouseID:warehouseRecord.warehouseID
                                                                                                 controllerMode:kModifyWarehouse] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void)switchStatus:(BOOL)status indexPath:(NSIndexPath *)indexPath
{
    WarehouseRecord4Cocoa *warehouseRecord = self.warehouseList[indexPath.row];
    
    NSString *defaultWarehouseID = [[[ServiceFactory sharedInstance] utilityService] getDefaultWarehouseUUID];
    if ([warehouseRecord.warehouseID isEqualToString:defaultWarehouseID]) {
        [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                 detail:@"默认仓库不能禁用"
                               duration:kJCHDefaultShowHudTime
                                   mode:MBProgressHUDModeText
                             completion:nil];
        [self.tableView reloadData];
    } else {
        [self repairWarehouseRecord:warehouseRecord result:^(BOOL needAddToServer, BOOL success, NSString *responseDescription) {
            if (success) {
                if (needAddToServer) {
                    //add到server的时候直接就将status传过去，不需要再修改状态
                } else {
                    [self doModifyWarehouseStatus:warehouseRecord];
                }
                
            } else {
                [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                         detail:responseDescription
                                       duration:kJCHDefaultShowHudTime
                                           mode:MBProgressHUDModeText
                                     completion:nil];
                [self.tableView reloadData];
            }
        }];
    }
}



- (void)doQueryWarehouseList
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    WarehouseManageRequest *request = [[[WarehouseManageRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.token = statusManager.syncToken;
    request.accountBookID = statusManager.accountBookID;
    request.dataType = @"0";
    request.serviceURL = [NSString stringWithFormat:@"%@/control/get", kJCHSyncManagerServerIP];
    
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService queryWarehouse:request callback:^(id response) {
        
        NSDictionary *userData = response;
        if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
            NSDictionary *responseData = userData[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                //! @todo
                [self.tableView reloadData];
            } else {
                //查询成功
                
                //服务端的warehouseList
                NSArray *warehouseListOnServer = responseData[@"data"][@"list"];
                self.warehouseListOnServer = warehouseListOnServer;
                //1) 本地有    server有    server update到本地
                id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
                
                for (WarehouseRecord4Cocoa *warehouseRecord in self.warehouseListWithoutDefault) {
                    for (NSDictionary *dict in warehouseListOnServer) {
                        if ([warehouseRecord.warehouseID isEqualToString:dict[@"dataKey"]]) {
                            warehouseRecord.warehouseStatus = [dict[@"status"] intValue];
                            [warehouseService updateWarehouse:warehouseRecord];
                            break;
                        }
                    }
                }
                
                
                BOOL hasRecordNeedAddToServer = NO;
                //2) 本地有   server没有   add到server
                for (WarehouseRecord4Cocoa *warehouseRecord in self.warehouseListWithoutDefault) {
                    BOOL aFlag = NO;  //本地有 server没有的标记
                    for (NSDictionary *dict in warehouseListOnServer) {
                        if ([dict[@"dataKey"] isEqualToString:warehouseRecord.warehouseID]) {
                            aFlag = YES;
                            break;
                        }
                    }
                    
                    if (!aFlag) {
                        hasRecordNeedAddToServer = YES;
                        [self doAddWarehouseToServer:warehouseRecord result:nil];
                    }
                }
                
                
                if (!hasRecordNeedAddToServer) {
                    [self.tableView reloadData];
                }
            }
        } else {
            NSLog(@"request fail: %@", userData[@"data"]);
            [self.tableView reloadData];
        }
    }];
}


- (void)doAddWarehouseToServer:(WarehouseRecord4Cocoa *)warehouseRecord result:(void(^)(BOOL success, NSString *responseDescription))result
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    WarehouseManageRequest *request = [[[WarehouseManageRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.token = statusManager.syncToken;
    request.accountBookID = statusManager.accountBookID;
    request.dataType = @"0";
    request.dataKey = warehouseRecord.warehouseID;
    request.status = warehouseRecord.warehouseStatus;
    request.serviceURL = [NSString stringWithFormat:@"%@/control/add", kJCHSyncManagerServerIP];
    
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService addWarehouse:request callback:^(id response) {
        
        NSDictionary *userData = response;
        
        if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
            NSDictionary *responseData = userData[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                //! @todo
                if (result) {
                    result(NO, responseDescription);
                }
            } else {
                //添加成功
                if (result) {
                    result(YES, responseDescription);
                }
            }
            
        } else {
            NSLog(@"request fail: %@", userData[@"data"]);
            if (result) {
                result(NO, @"连接网络失败");
            }
        }
        [self.tableView reloadData];
    }];
}


// warehouseRecord为nil，则添加所有本地有，server上没的record（除了默认仓库）到server, 否则只添加warehouseRecord到server（先判断server有没有，没有则添加）
- (void)repairWarehouseRecord:(WarehouseRecord4Cocoa *)warehouseRecord result:(void(^)(BOOL needAddToServer, BOOL success, NSString *responseDescription))result
{
    // 1) 查询服务器上的仓库列表
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    WarehouseManageRequest *request = [[[WarehouseManageRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.token = statusManager.syncToken;
    request.accountBookID = statusManager.accountBookID;
    request.dataType = @"0";
    request.serviceURL = [NSString stringWithFormat:@"%@/control/get", kJCHSyncManagerServerIP];
    
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService queryWarehouse:request callback:^(id response) {
        
        NSDictionary *userData = response;
        if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
            NSDictionary *responseData = userData[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                //! @todo
                [self.tableView reloadData];
                if (result) {
                    result(YES, NO, responseDescription);
                }
            } else {
                //查询成功
                
                //服务端的warehouseList
                NSArray *warehouseListOnServer = responseData[@"data"][@"list"];
                self.warehouseListOnServer = warehouseListOnServer;
                
                
                // 2) 将该添加到服务器上的添加的服务器
                
                if (warehouseRecord) {
                    //如果server没有该record则add到server
                    BOOL needAddToServer = YES;
                    for (NSDictionary *dict in warehouseListOnServer) {
                        if ([dict[@"dataKey"] isEqualToString:warehouseRecord.warehouseID]) {
                            needAddToServer = NO;
                            break;
                        }
                    }
                    
                    if (needAddToServer) {
                        [self doAddWarehouseToServer:warehouseRecord result:^(BOOL success, NSString *responseDescription) {
                            if (result) {
                                result(YES, success, responseDescription);
                            }
                        }];
                    } else {
                        if (result) {
                            result(NO, YES, @"");
                        }
                    }
                } else {
                    // 本地有    server有    server update到本地
                    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
                    
                    for (WarehouseRecord4Cocoa *warehouseRecord in self.warehouseListWithoutDefault) {
                        for (NSDictionary *dict in warehouseListOnServer) {
                            if ([warehouseRecord.warehouseID isEqualToString:dict[@"dataKey"]]) {
                                warehouseRecord.warehouseStatus = [dict[@"status"] intValue];
                                [warehouseService updateWarehouse:warehouseRecord];
                                break;
                            }
                        }
                    }
                    
                    
                    BOOL hasRecordNeedAddToServer = NO;
                    // 本地有   server没有   add到server
                    for (WarehouseRecord4Cocoa *warehouseRecord in self.warehouseListWithoutDefault) {
                        BOOL aFlag = NO;  //本地有 server没有的标记
                        for (NSDictionary *dict in warehouseListOnServer) {
                            if ([dict[@"dataKey"] isEqualToString:warehouseRecord.warehouseID]) {
                                aFlag = YES;
                                break;
                            }
                        }
                        
                        if (!aFlag) {
                            hasRecordNeedAddToServer = YES;
                            [self doAddWarehouseToServer:warehouseRecord result:^(BOOL success, NSString *responseDescription) {
                                if (result) {
                                    result(YES, success, responseDescription);
                                }
                            }];
                        }
                    }
                    
                    if (!hasRecordNeedAddToServer) {
                        [self.tableView reloadData];
                    }
                }
            }
        } else {
            NSLog(@"request fail: %@", userData[@"data"]);
            [self.tableView reloadData];
            if (result) {
                result(NO, NO, @"连接服务器失败");
            }
        }
    }];
}

- (void)doModifyWarehouseStatus:(WarehouseRecord4Cocoa *)warehouseRecord
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    WarehouseManageRequest *request = [[[WarehouseManageRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.token = statusManager.syncToken;
    request.accountBookID = statusManager.accountBookID;
    request.dataType = @"0";
    request.dataKey = warehouseRecord.warehouseID;
    
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    
    if (!warehouseRecord.warehouseStatus) {
        request.serviceURL = [NSString stringWithFormat:@"%@/control/disable", kJCHSyncManagerServerIP];
        //当前是启用的，改为禁用
        [dataSyncService disableWarehouse:request callback:^(id response) {
            
            NSDictionary *userData = response;
            if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
                NSDictionary *responseData = userData[@"data"];
                NSInteger responseCode = [responseData[@"code"] integerValue];
                NSString *responseDescription = responseData[@"desc"];
                NSString *responseStatus = responseData[@"status"];
                
                NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
                
                if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                    //! @todo
                    [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                             detail:responseDescription
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                         completion:nil];
                } else {
                    //修改状态成功
                    warehouseRecord.warehouseStatus = 1;
                    
                    for (WarehouseRecord4Cocoa *record in self.warehouseList) {
                        if ([warehouseRecord.warehouseID isEqualToString:record.warehouseID]) {
                            record.warehouseStatus = warehouseRecord.warehouseStatus;
                            break;
                        }
                    }
                    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
                    [warehouseService updateWarehouse:warehouseRecord];
                }
            } else {
                NSLog(@"request fail: %@", userData[@"data"]);
                [MBProgressHUD showNetWorkFailedHud:nil];
            }
            [self.tableView reloadData];
        }];
    } else {
        //当前是禁用的，改为启用
        request.serviceURL = [NSString stringWithFormat:@"%@/control/enable", kJCHSyncManagerServerIP];
        [dataSyncService enableWarehouse:request callback:^(id response) {
            
            NSDictionary *userData = response;
            if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
                NSDictionary *responseData = userData[@"data"];
                NSInteger responseCode = [responseData[@"code"] integerValue];
                NSString *responseDescription = responseData[@"desc"];
                NSString *responseStatus = responseData[@"status"];
                
                NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
                
                if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                    //! @todo
                    [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                             detail:responseDescription
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                         completion:nil];
                } else {
                    //修改状态成功
                    warehouseRecord.warehouseStatus = 0;
                    
                    for (WarehouseRecord4Cocoa *record in self.warehouseList) {
                        if ([warehouseRecord.warehouseID isEqualToString:record.warehouseID]) {
                            record.warehouseStatus = warehouseRecord.warehouseStatus;
                            break;
                        }
                    }
                    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
                    [warehouseService updateWarehouse:warehouseRecord];
                }
            } else {
                NSLog(@"request fail: %@", userData[@"data"]);
                [MBProgressHUD showNetWorkFailedHud:nil];
            }
            [self.tableView reloadData];
        }];
    }
}

@end
