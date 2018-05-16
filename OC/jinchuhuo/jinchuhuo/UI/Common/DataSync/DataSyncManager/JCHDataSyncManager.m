//
//  JCHDataSyncManager.m
//  jinchuhuo
//
//  Created by huangxu on 16/8/2.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHDataSyncManager.h"
#import "DataSyncService.h"
#import "ServiceFactory.h"
#import "CommonHeader.h"
#import "ImageFileSynchronizer.h"


@interface JCHDataSyncManager ()

@property (nonatomic, assign) BOOL isPushing;
@property (nonatomic, copy) void(^pushSuccess)(NSInteger pushFlag, NSInteger pullFlag, NSDictionary *responseData);
@property (nonatomic, copy) void(^pushFailure)(NSInteger responseCode, NSError *error);

@property (nonatomic, copy) void(^pullSuccess)(NSDictionary *responseData);
@property (nonatomic, copy) void(^pullFailure)(NSInteger responseCode, NSError *error);

@property (nonatomic, copy) void(^leaveAccountBookSuccess)(NSDictionary *responseData);
@property (nonatomic, copy) void(^leaveAccountBookFailure)(NSInteger responseCode, NSError *error);


@end

@implementation JCHDataSyncManager

+ (id)shareInstance
{
    static dispatch_once_t dispatchOnce;
    static JCHDataSyncManager *dataSyncManager = nil;
    dispatch_once(&dispatchOnce, ^{
        dataSyncManager = [[JCHDataSyncManager alloc] init];
        [dataSyncManager registerResponseNotificationHandler];
    });
    
    return dataSyncManager;
}

- (void)registerResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(handleSyncPushCommand:)
                               name:kJCHSyncPushCommandNotification
                             object:[UIApplication sharedApplication]];
    
    
    [notificationCenter addObserver:self
                           selector:@selector(handleSyncPullCommand:)
                               name:kJCHSyncPullCommandNotification
                             object:[UIApplication sharedApplication]];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleLeaveAccountBook:)
                               name:kJCHSyncUnJoinCommandNotification
                             object:[UIApplication sharedApplication]];
    
    return;
}

//- (void)unregisterResponseNotificationHandler
//{
    //NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    //[notificationCenter removeObserver:self
                                  //name:kJCHSyncPushCommandNotification
                                //object:[UIApplication sharedApplication]];
    
    //[notificationCenter removeObserver:self
                                  //name:kJCHSyncPullCommandNotification
                                //object:[UIApplication sharedApplication]];
    
    //[notificationCenter removeObserver:self
                                  //name:kJCHSyncHomepageUnJoinCommandNotification
                                //object:[UIApplication sharedApplication]];
    
    
    //return;
//}

#pragma mark - 同步push操作
- (void)doSyncPushCommand:(void(^)(NSInteger pushFlag, NSInteger pullFlag, NSDictionary *responseData))success
                  failure:(void(^)(NSInteger responseCode, NSError *error))failure
{
    if (self.isPushing) {
        return;
    } else {
        self.isPushing = YES;
    }
    
    self.pushSuccess = success;
    self.pushFailure = failure;
    TICK;
    NSString *databasePath = [ServiceFactory getSyncUploadFilePath];
    id<DataSyncService> dataSync = [[ServiceFactory sharedInstance] dataSyncService];
    NSInteger status = [dataSync preparePushDatabase:databasePath];
    TOCK(@"preparePushDatabase");
    if (1 == status) {
        self.syncUploadFilePath = databasePath;
        NSString *syncPushHost = [dataSync getSyncAccountBookPushHost];
        NSString *syncPieceHost = [dataSync getSyncAccountBookPieceHost];
        NSString *syncNodeID = [dataSync getSyncNodeID];
        
        id<DatabaseUpgradeService> upgradeService = [[ServiceFactory sharedInstance] databaseUpgradeService];
        NSInteger databaseVersion = [upgradeService getCurrentDatabaseVersion];
        
        JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
        id<LargeDatabaseSyncService> largeDatabaseSyncService = [[ServiceFactory sharedInstance] largeDatabaseSyncService];
        PushCommandRequest *request = [[[PushCommandRequest alloc] init] autorelease];
        request.deviceUUID = statusManager.deviceUUID;
        request.syncVersion = [NSString stringWithFormat:@"%lld", (long long)databaseVersion];
        request.token = statusManager.syncToken;
        request.accountBookID = statusManager.accountBookID;
        request.syncNode = syncNodeID;
        request.uploadDatabaseFile = databasePath;
        request.serviceURL = syncPushHost;
        request.checkVersion = 1;
        request.pieceServiceURL = syncPieceHost;
        request.dataType = JCH_DATA_TYPE;
        
        [largeDatabaseSyncService pushCommand:request responseNotification:kJCHSyncPushCommandNotification];
    } else {

        //当前无需push数据,标记pushFlag为0
        if (self.pushSuccess) {
            self.pushSuccess(0, 0, nil);
            self.isPushing = NO;
        }
    }
}


- (void)handleSyncPushCommand:(NSNotification *)notify
{
    NSLog(@"%@", notify);
    self.isPushing = NO;
    NSDictionary *userData = notify.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        NSString *responseDescription = responseData[@"desc"];
        NSString *responseStatus = responseData[@"status"];
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
        
        if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
            
            NSLog(@"sync push fail.");
            
            if (self.pushFailure) {
                self.pushFailure(responseCode, nil);
            }
            
            return;
        } else {
            
            NSLog(@"sync push success");
            // 1) 校正同步时间
            // 如果时间差小于15秒，清零
            const long long timeTheshold = 15 * 1000;
            long long currentTime = [[NSDate date] timeIntervalSince1970] * 1000;
            long long serverTime = [responseData[@"data"][@"time"] longLongValue];
            id<DataSyncService> dataSync = [[ServiceFactory sharedInstance] dataSyncService];
            
            if ((currentTime - serverTime) >= -timeTheshold &&
                (currentTime - serverTime <= timeTheshold)) {
                [dataSync adjustSyncTime:0 clientTime:0];
            } else {
                [dataSync adjustSyncTime:serverTime clientTime:currentTime];
            }
            
            // 2) 检查needCheck标记
            NSInteger syncPullFlag = 0;
            const NSInteger needCheck = [responseData[@"data"][@"needCheck"] integerValue];
            if (1 != needCheck) {
                // 3) 更新同步状态
                [dataSync updateFromPushDatabase:self.syncUploadFilePath];
            } else {
                syncPullFlag = 1;
            }
            
            if (self.pushSuccess) {
                self.pushSuccess(1, syncPullFlag, responseData);
            }
        }
    } else {
        NSError *networkError = userData[@"data"];
        
        if (self.pushFailure) {
            self.pushFailure(kNetWorkErrorCode, networkError);
        }
        NSLog(@"sync push fail.");
    }
    return;
}

#pragma mark - 同步pull操作
- (void)doSyncPullCommand:(NSInteger)pullFlag
                  success:(void(^)(NSDictionary *responseData))success
                  failure:(void(^)(NSInteger responseCode, NSError *error))failure
{
    self.pullSuccess = success;
    self.pullFailure = failure;
    
    NSString *downloadDatabasePath = [ServiceFactory getSyncDownloadFilePath];
    NSString *uploadDatabasePath = [ServiceFactory getSyncUploadFilePath];
    id<DataSyncService> dataSync = [[ServiceFactory sharedInstance] dataSyncService];
    
    //! @note 这里是否统一使用PullTypeNormalPart待确认
    NSInteger pullType = [dataSync getPullTypeMorePart];
    [dataSync preparePullDatabase:uploadDatabasePath pullFlag:pullType];
    
    NSString *syncPullHost = [dataSync getSyncAccountBookPullHost];
    NSString *syncPieceHost = [dataSync getSyncAccountBookPieceHost];
    self.syncDownloadFilePath = downloadDatabasePath;
    NSString *syncNodeID = [dataSync getSyncNodeID];
    
    id<DatabaseUpgradeService> upgradeService = [[ServiceFactory sharedInstance] databaseUpgradeService];
    NSInteger databaseVersion = [upgradeService getCurrentDatabaseVersion];
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id<LargeDatabaseSyncService> largeDatabaseSyncService = [[ServiceFactory sharedInstance] largeDatabaseSyncService];
    PullCommandRequest *request = [[[PullCommandRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.syncVersion = [NSString stringWithFormat:@"%lld", (long long)databaseVersion];
    request.token = statusManager.syncToken;
    request.accountBookID = statusManager.accountBookID;
    request.syncNode = syncNodeID;
    request.uploadDatabaseFile = uploadDatabasePath;
    request.downloadDatabaseFile = downloadDatabasePath;
    request.serviceURL = syncPullHost;
    request.pieceServiceURL = syncPieceHost;
    request.upgradeCommand = @"part";
    request.dataType = JCH_DATA_TYPE;
    
    [largeDatabaseSyncService pullCommand:request
                     responseNotification:kJCHSyncPullCommandNotification];
}

- (void)handleSyncPullCommand:(NSNotification *)notify
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
            NSLog(@"sync pull fail.");
           
            if (self.pullFailure) {
                self.pullFailure(responseCode, nil);
            }
            return;
        } else {
            
            
            if (self.pullSuccess) {
                self.pullSuccess(responseData);
            }
        }
    } else {
        
        NSError *networkError = userData[@"data"];
        
        if (self.pullFailure) {
            self.pullFailure(kNetWorkErrorCode, networkError);
        }
        NSLog(@"sync pull fail.");
    }
    return;
}

#pragma mark - 解除账本关系
- (void)doLeaveAccountBook:(NSString *)userID
                   success:(void(^)(NSDictionary *responseData))success
                   failure:(void(^)(NSInteger responseCode, NSError *error))failure
{
    self.leaveAccountBookSuccess = success;
    self.leaveAccountBookFailure = failure;
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    QuitAccountBookRequest *request = [[[QuitAccountBookRequest alloc] init] autorelease];
    request.serviceURL = [NSString stringWithFormat:@"%@/terminal/leave", kJCHSyncManagerServerIP];
    request.token = statusManager.syncToken;
    request.userID = userID;
    request.accountBookID = statusManager.accountBookID;
    request.deviceUUID = statusManager.deviceUUID;
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService quitAccountBook:request responseNotification:kJCHSyncUnJoinCommandNotification];
    
    return;
}

- (void)handleLeaveAccountBook:(NSNotification *)notify
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
            NSLog(@"send captcha fail.");
            if (self.leaveAccountBookFailure) {
                self.leaveAccountBookFailure(responseCode, nil);
            }
            return;
        } else {
            //! @todo
            // your code here
            NSLog(@"leave account book success");
            
            if (self.leaveAccountBookSuccess) {
                self.leaveAccountBookSuccess(responseData);
            }
        }
        
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
        NSError *networkError = userData[@"data"];
        if (self.leaveAccountBookFailure) {
            self.leaveAccountBookFailure(kNetWorkErrorCode, networkError);
        }
    }
}


#pragma mark - 同步图片
- (void)doSyncImageFiles:(NSString *)imageInterHostIP
{
    if (imageInterHostIP == nil || [imageInterHostIP isEmptyString]) {
        return;
    }
    id<DatabaseUpgradeService> upgradeService = [[ServiceFactory sharedInstance] databaseUpgradeService];
    id<DataSyncService> dataSync = [[ServiceFactory sharedInstance] dataSyncService];
    NSInteger databaseVersion = [upgradeService getCurrentDatabaseVersion];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = infoDictionary[@"CFBundleShortVersionString"];
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[ImageFileSynchronizer sharedInstance] syncImageFile:statusManager.userID
                                                   deviceUUID:statusManager.deviceUUID
                                                        token:statusManager.syncToken
                                                accountBookID:statusManager.accountBookID
                                                   serviceURL:[NSString stringWithFormat:@"%@/service/qiniu", imageInterHostIP]
                                                   appVersion:appVersion
                                                  syncVersion:[NSString stringWithFormat:@"%d", (int)databaseVersion]
                                                     syncNode:[dataSync getSyncNodeID]];
 
    });
    
    return;
}

@end
