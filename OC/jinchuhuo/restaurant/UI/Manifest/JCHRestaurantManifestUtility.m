//
//  JCHRestaurantManifestUtility.m
//  jinchuhuo
//
//  Created by apple on 2017/2/13.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHRestaurantManifestUtility.h"
#import "JCHManifestMemoryStorage.h"
#import "JCHSyncStatusManager.h"
#import <MBProgressHUD.h>
#import "CommonHeader.h"

@implementation JCHRestaurantManifestUtility

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    return;
}

+ (JCHRestaurantManifestUtility *)sharedInstance
{
    static JCHRestaurantManifestUtility *staticInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticInstance = [[JCHRestaurantManifestUtility alloc] init];
    });
    
    return staticInstance;
}

+ (void)restaurantLockTable:(long long)currentTableID
             successHandler:(void(^)())successHandler
             failureHandler:(void(^)(NSString *))failureHandler
{
    [MBProgressHUD showHUDWithTitle:@"温馨提示"
                             detail:@"正在锁定桌台，请稍候"
                           duration:1000
                               mode:MBProgressHUDModeIndeterminate
                         completion:nil];
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    JCHManifestMemoryStorage *memoryStorage = [JCHManifestMemoryStorage sharedInstance];
    id<BookInfoService> bookInfoService = [[ServiceFactory sharedInstance] bookInfoService];
    id<RestaurantTableService> tableService = [[ServiceFactory sharedInstance] restaurantTableService];
    NSString *tableServiceHost = [bookInfoService queryLocalServerHost];
    NSString *accountBookID = statusManager.accountBookID;
    NSInteger operatorID = statusManager.userID.integerValue;
    NSString *tableID = [@(currentTableID) stringValue];
    
    if (nil == tableServiceHost ||
        [tableServiceHost isEqualToString:@""]) {
        [JCHRestaurantManifestUtility handleNoBindMachineError];
        return;
    }
    
    NSLog(@"host: %@", tableServiceHost);
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeNew ||
        manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeCopy) {
        RestaurantLockTableRequest *request = [[[RestaurantLockTableRequest alloc] init] autorelease];
        request.accountBookID = accountBookID;
        request.tableID = tableID;
        request.numberOfPerson = memoryStorage.restaurantPeopleCount;
        request.orderID = @"";
        request.operatorID = operatorID;
        request.serviceURL = [NSString stringWithFormat:@"%@/book/table/lock", tableServiceHost];
        
        [tableService lockTable:request callback:^(NSDictionary *userData) {
            NSLog(@"%@", userData);
            
            if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
                NSDictionary *responseData = userData[@"data"];
                NSInteger responseCode = [responseData[@"code"] integerValue];
                NSString *responseDescription = responseData[@"desc"];
                NSString *responseStatus = responseData[@"status"];
                
                NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
                
                if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {                    
                    if (nil != failureHandler) {
                        failureHandler(responseDescription);
                    }
                    
                } else {
                    if (nil != successHandler) {
                        successHandler();
                    }
                }
            } else {
                NSError *errorInfo = userData[@"data"];
                if (nil != failureHandler) {
                    failureHandler([errorInfo localizedDescription]);
                }
            }
        }];
    }
}

+ (void)restaurantOpenTable:(ManifestRecord4Cocoa *)manifestRecord
                    tableID:(long long)currentTableID
                  tableName:(NSString *)tableName
         oldTransactionList:(NSArray *)oldTransactionList
       navigationController:(UINavigationController *)navigationController
{
    [MBProgressHUD showHUDWithTitle:@"温馨提示"
                             detail:@"正在下单中，请稍候"
                           duration:1000
                               mode:MBProgressHUDModeIndeterminate
                         completion:nil];
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id<BookInfoService> bookInfoService = [[ServiceFactory sharedInstance] bookInfoService];
    id<RestaurantTableService> tableService = [[ServiceFactory sharedInstance] restaurantTableService];
    NSString *tableServiceHost = [bookInfoService queryLocalServerHost];
    NSString *accountBookID = statusManager.accountBookID;
    NSInteger operatorID = manifestRecord.operatorID;
    NSString *tableID = [@(currentTableID) stringValue];
    
    if (nil == tableServiceHost ||
        [tableServiceHost isEqualToString:@""]) {
        [JCHRestaurantManifestUtility handleNoBindMachineError];
        return;
    }
    
    NSLog(@"host: %@", tableServiceHost);
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeNew ||
        manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeCopy) {
        RestaurantPreInsertManifest *request = [[[RestaurantPreInsertManifest alloc] init] autorelease];
        request.accountBookID = accountBookID;
        request.tableID = tableID;
        request.operatorID = operatorID;
        request.manifest = manifestRecord;
        request.tableName = tableName;
        request.oldTransactionList = oldTransactionList;
        request.serviceURL = [NSString stringWithFormat:@"%@/book/manifest/preinsert", tableServiceHost];;
        
        [tableService preInsertManifest:request callback:^(NSDictionary *userData) {
            NSLog(@"%@", userData);
            
            if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
                NSDictionary *responseData = userData[@"data"];
                NSInteger responseCode = [responseData[@"code"] integerValue];
                NSString *responseDescription = responseData[@"desc"];
                NSString *responseStatus = responseData[@"status"];
                
                NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
                
                if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                    [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                             detail:[NSString stringWithFormat:@"下单失败: %@，请重试", responseDescription]
                                           duration:3
                                               mode:MBProgressHUDModeIndeterminate
                                         completion:nil];
                } else {
                    [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                             detail:@"下单成功，请进行数据同步操作"
                                           duration:3
                                               mode:MBProgressHUDModeIndeterminate
                                         completion:nil];
                    
                    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
                    [navigationController popToViewController:appDelegate.switchToTargetController animated:YES];
                }
            } else {
                NSError *errorInfo = userData[@"data"];
                [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                         detail:[NSString stringWithFormat:@"操作失败: %@", [errorInfo localizedDescription]]
                                       duration:3
                                           mode:MBProgressHUDModeText
                                     completion:nil];
            }
        }];
    } else if (manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeEdit) {
        RestaurantPreInsertManifest *request = [[[RestaurantPreInsertManifest alloc] init] autorelease];
        request.accountBookID = accountBookID;
        request.tableID = tableID;
        request.operatorID = operatorID;
        request.manifest = manifestRecord;
        request.tableName = tableName;
        request.oldTransactionList = oldTransactionList;
        request.serviceURL = [NSString stringWithFormat:@"%@/book/manifest/preinsert", tableServiceHost];;
        
        [tableService preInsertManifest:request callback:^(NSDictionary *userData) {
            if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
                NSDictionary *responseData = userData[@"data"];
                NSInteger responseCode = [responseData[@"code"] integerValue];
                NSString *responseDescription = responseData[@"desc"];
                NSString *responseStatus = responseData[@"status"];
                
                NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
                
                if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                    [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                             detail:[NSString stringWithFormat:@"改单失败: %@，请重试", responseDescription]
                                           duration:3
                                               mode:MBProgressHUDModeIndeterminate
                                         completion:nil];
                } else {
                    [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                             detail:@"改单成功"
                                           duration:3
                                               mode:MBProgressHUDModeIndeterminate
                                         completion:nil];
                    
                    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
                    [navigationController popToViewController:appDelegate.switchToTargetController animated:YES];
                }
            } else {
                NSError *errorInfo = userData[@"data"];
                [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                         detail:[NSString stringWithFormat:@"操作失败: %@", [errorInfo localizedDescription]]
                                       duration:3
                                           mode:MBProgressHUDModeText
                                     completion:nil];
            }
        }];
    }
}

+ (void)handleNoBindMachineError
{
    [MBProgressHUD showHUDWithTitle:@"温馨提示"
                             detail:@"当前账号未绑定收银机，请绑定后重试"
                           duration:3
                               mode:MBProgressHUDModeText
                         completion:nil];
}

@end
