//
//  JCHDataSyncManager.h
//  jinchuhuo
//
//  Created by huangxu on 16/8/2.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNetWorkErrorCode -9999

@interface JCHDataSyncManager : NSObject

@property (nonatomic, retain) NSString *syncUploadFilePath;
@property (nonatomic, retain) NSString *syncDownloadFilePath;

+ (id)shareInstance;

//! @brief 同步push操作
- (void)doSyncPushCommand:(void(^)(NSInteger pushFlag,  NSInteger pullFlag, NSDictionary *responseData))success
                  failure:(void(^)(NSInteger responseCode, NSError *error))failure;

//! @brief 同步pull操作
- (void)doSyncPullCommand:(NSInteger)pullFlag
                  success:(void(^)(NSDictionary *responseData))success
                  failure:(void(^)(NSInteger responseCode, NSError *error))failure;

//! @brief 解除账本关系
- (void)doLeaveAccountBook:(NSString *)userID
                   success:(void(^)(NSDictionary *responseData))success
                   failure:(void(^)(NSInteger responseCode, NSError *error))failure;

//! @brief 同步图片
- (void)doSyncImageFiles:(NSString *)imageInterHostIP;


@end
