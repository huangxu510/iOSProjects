//
//  JCHNetworkingManager.m
//  jinchuhuo
//
//  Created by huangxu on 16/8/4.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHNetworkingManager.h"
#import "CommonHeader.h"

//超时时间
#ifndef kNetworkTimeoutInterval 
#define kNetworkTimeoutInterval 20
#endif

@implementation JCHNetworkingManager

+ (id)shareInstance
{
    static dispatch_once_t dispatchOnce;
    static JCHNetworkingManager *networkingManager = nil;
    dispatch_once(&dispatchOnce, ^{
        networkingManager = [[JCHNetworkingManager alloc] init];
        networkingManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    });
    
    return networkingManager;
}

/**
 *  GET请求
 */
- (void)GET:(NSString *)url Parameters:(NSDictionary *)parameters Success:(void (^)(id))success Failure:(void (^)(NSError *))failure{
    
    //网络检查
    if ([[JCHNetworkingManager shareInstance] checkingNetwork] == StatusNotReachable) {
        [MBProgressHUD showNetWorkFailedHud:nil];
        return;
    }
    
    //断言
    NSAssert(url != nil, @"url不能为空");
    
    //使用AFNetworking进行网络请求
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //因为服务器返回的数据如果不是application/json格式的数据
    //需要以NSData的方式接收,然后自行解析
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = kNetworkTimeoutInterval;
    //发起get请求
    [manager GET:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //将返回的数据转成json数据格式
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments error:nil];
        
        //通过block，将数据回掉给用户
        if (success) {
            success(result);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //通过block,将错误信息回传给用户
        if (failure) {
            failure(error);
        }
    }];
}

/**
 *  POST请求
 */
- (void)Post:(NSString *)url Parameters:(NSDictionary *)parameters Success:(void (^)(id))success Failure:(void (^)(NSError *))failure{
    
    //网络检查
    if ([[JCHNetworkingManager shareInstance] checkingNetwork] == StatusNotReachable) {
        [MBProgressHUD showNetWorkFailedHud:nil];
        return;
    }
    
    //断言
    NSAssert(url != nil, @"url不能为空");
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    
    manager.requestSerializer = self.requestSerializer;
    
    manager.requestSerializer.timeoutInterval = kNetworkTimeoutInterval;
    
    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //将返回的数据转成json数据格式
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments error:nil];
        
        //通过block，将数据回掉给用户
        success(result);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //通过block,将错误信息回传给用户
        failure(error);
    }];
    
    //还原requestSerializer
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
}




/**
 *   监听网络状态的变化
 */
- (NetworkStatus)checkingNetwork{
    
    __block NSInteger statusTag = 0;
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager manager];
    
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (status == AFNetworkReachabilityStatusUnknown) {
            
            statusTag = StatusUnknown;
            
        }else if (status == AFNetworkReachabilityStatusNotReachable){
            
            statusTag = StatusNotReachable;
            
        }else if (status == AFNetworkReachabilityStatusReachableViaWWAN){
            
            statusTag = StatusReachableViaWWAN;
            
        }else if (status == AFNetworkReachabilityStatusReachableViaWiFi){
            
            statusTag = StatusReachableViaWiFi;
            
        }
    }];
    return statusTag;
}



@end
