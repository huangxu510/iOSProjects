//
//  JCHStatisticsManager.m
//  jinchuhuo
//
//  Created by apple on 2016/11/7.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHStatisticsManager.h"
#import "JCHLocationManager.h"
#import "ServiceFactory.h"
#import "CommonHeader.h"

//! @brief 6小时对应的秒数
#ifndef k6HourAsSeconds
#define k6HourAsSeconds (1 * 60 * 60)
// #define k6HourAsSeconds (1)
#endif

@interface JCHStatisticsManager()

@end

@implementation JCHStatisticsManager

+ (id)sharedInstance
{
    static JCHStatisticsManager *staticInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticInstance = [[JCHStatisticsManager alloc] init];
    });
    
    return staticInstance;
}

- (void)dealloc
{
    [super dealloc];
    return;
}

- (void)uploadStatistics:(NSString *)appModule
{
    [[JCHLocationManager shareInstance] getLocationAndCoordinate2D:^(NSString *country, NSString *state, NSString *city, NSString *subLocality, NSString *street, NSString *detail, CLLocationCoordinate2D coordinate2D) {
        JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
        StatisticsRequest *request = [[[StatisticsRequest alloc] init] autorelease];
        
        NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormater setDateFormat:@"yyyy-MM-dd"];
        NSString *currentDate = [dateFormater stringFromDate:[NSDate date]];
        
        request.token = statusManager.syncToken;
        request.accountBookID = statusManager.accountBookID;
        request.serviceURL = kDataStatisticsServiceIP;
        request.datetime = currentDate;
        request.deviceType = @"iOS";
        request.appModule = appModule;
        request.userID = statusManager.userID;
        request.deviceUUID = statusManager.deviceUUID;
        request.country = country ? country : @"";
        request.state = state ? state : @"";
        request.city = city ? city : @"";
        request.district = subLocality ? subLocality : @"";
        request.street = street ? street : @"";
        request.detail = detail ? detail : @"";
        request.longitude = [NSString stringWithFormat:@"%f", coordinate2D.longitude];
        request.latitude = [NSString stringWithFormat:@"%f", coordinate2D.latitude];;
        
        id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
        [dataSyncService uploadStatistics:request callback:^(id result) {
            NSDictionary *response = (NSDictionary *)result;
            
            if (0 == [response[@"status"] integerValue]) {
                response = response[@"data"];
                if (10000 == [response[@"code"] integerValue]) {
                    NSLog(@"upload statistics response success");
                } else {
                    NSLog(@"upload statistics response fail: %ld, %@",
                          (long)response[@"status"],
                          response[@"desc"]);
                }
            } else {
                NSLog(@"upload statistics response fail: %@", response[@"data"]);
            }
        }];
    }];
    

}

//! @brief 用户登录统计信息
- (void)loginStatistics
{
    [self uploadStatistics:@"用户登录"];
}

//! @brief 新建店铺统计信息
- (void)createShopStatistics
{
    [self uploadStatistics:@"新建店铺"];
}

//! @brief 手动同步统计信息
- (void)manualDataSyncStatistics
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    NSInteger lastSyncTimestamp = [statusManager lastSyncTimestamp];
    NSInteger currentTimestamp = (NSInteger)[[NSDate date] timeIntervalSince1970];
    if (currentTimestamp - lastSyncTimestamp < (k6HourAsSeconds)) {
        return;
    }
    
    statusManager.lastSyncTimestamp = currentTimestamp;
    [JCHSyncStatusManager writeToFile];
    
    [self uploadStatistics:@"手动同步"];
}

//! @brief 自动同步统计信息
- (void)autoDataSyncStatistics
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    NSInteger lastSyncTimestamp = [statusManager lastSyncTimestamp];
    NSInteger currentTimestamp = (NSInteger)[[NSDate date] timeIntervalSince1970];
    if (currentTimestamp - lastSyncTimestamp < (k6HourAsSeconds)) {
        return;
    }
    
    statusManager.lastSyncTimestamp = currentTimestamp;
    [JCHSyncStatusManager writeToFile];
    
    [self uploadStatistics:@"自动同步"];
}

@end
