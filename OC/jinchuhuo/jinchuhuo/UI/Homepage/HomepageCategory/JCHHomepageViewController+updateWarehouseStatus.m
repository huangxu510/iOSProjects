//
//  JCHHomepageViewController+updateWarehouseStatus.m
//  jinchuhuo
//
//  Created by huangxu on 16/11/2.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHHomepageViewController+updateWarehouseStatus.h"
#import "CommonHeader.h"
#import <objc/runtime.h>

static const char *warehouseListWithoutDefaultKey = "warehouseListWithoutDefault";

@implementation JCHHomepageViewController (updateWarehouseStatus)

//每天查询一次服务器的warehouseList
- (void)handleUpdateWarehouseStatus
{
    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
    NSArray *warehouseList = [warehouseService queryAllWarehouse];
    NSMutableArray *warehouseListWithoutDefault = [NSMutableArray array];
    NSString *defaultWarehouseID = [[[ServiceFactory sharedInstance] utilityService] getDefaultWarehouseUUID];
    for (WarehouseRecord4Cocoa *warehouseRecord in warehouseList) {
        if (![warehouseRecord.warehouseID isEqualToString:defaultWarehouseID]) {
            [warehouseListWithoutDefault addObject:warehouseRecord];
        }
    }
    self.warehouseListWithoutDefault = warehouseListWithoutDefault;
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [NSDate date];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                   fromDate:date];
    
    if (statusManager.lastQueryWarehouseInfoDate) {
        NSDateComponents *lastQueryInfoDateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                                    fromDate:statusManager.lastQueryWarehouseInfoDate];
        
        
        if (!(dateComponents.year == lastQueryInfoDateComponents.year &&
              dateComponents.month == lastQueryInfoDateComponents.month &&
              dateComponents.day == lastQueryInfoDateComponents.day)) {
            
            [self doQueryWarehouseList];
        }
    } else {
        [self doQueryWarehouseList];
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
                
            } else {
                //查询成功
                
                //服务端的warehouseList
                NSArray *warehouseListOnServer = responseData[@"data"][@"list"];
                
                //1) 本地有    server有   update
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
                        [self doAddWarehouseToServer:warehouseRecord];
                    }
                }
                
                //3) 刷新每天查询的时间
                JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
                statusManager.lastQueryWarehouseInfoDate = [NSDate date];
                [JCHSyncStatusManager writeToFile];
            }
        } else {
            NSLog(@"request fail: %@", userData[@"data"]);
        }
    }];
}


- (void)doAddWarehouseToServer:(WarehouseRecord4Cocoa *)warehouseRecord
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
                
            } else {
                //添加成功
                
            }
            
        } else {
            NSLog(@"request fail: %@", userData[@"data"]);
        }
    }];
}


//给分类添加属性
- (NSArray *)warehouseListWithoutDefault
{
    return objc_getAssociatedObject(self, warehouseListWithoutDefaultKey);
}

- (void)setWarehouseListWithoutDefault:(NSArray *)warehouseListWithoutDefault
{
    // 第一个参数:给哪个对象添加关联
    // 第二个参数:关联的key，通过这个key获取
    // 第三个参数:关联的value
    // 第四个参数:关联的策略
    objc_setAssociatedObject(self, warehouseListWithoutDefaultKey, warehouseListWithoutDefault, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
