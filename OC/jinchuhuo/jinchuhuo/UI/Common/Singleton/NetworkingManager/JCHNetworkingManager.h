//
//  JCHNetworkingManager.h
//  jinchuhuo
//
//  Created by huangxu on 16/8/4.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

typedef enum : NSInteger{
    
    StatusUnknown = 0,//未知状态
    StatusNotReachable,//无网状态
    StatusReachableViaWWAN,//手机网络
    StatusReachableViaWiFi,//Wifi网络
    
} NetworkStatus;

@interface JCHNetworkingManager : NSObject

// 给某些请求设置header
@property (nonatomic, retain) AFHTTPRequestSerializer *requestSerializer;

+ (id)shareInstance;

//! @brief GET请求
- (void)GET:(NSString *)url
 Parameters:(NSDictionary *)parameters
    Success:(void(^)(id responseObject))success
    Failure:(void (^)(NSError *error))failure;


//! @brief POST请求
- (void)Post:(NSString *)url
  Parameters:(NSDictionary *)parameters
     Success:(void(^)(id responseObject))success
     Failure:(void(^)(NSError *error))failure;

@end
