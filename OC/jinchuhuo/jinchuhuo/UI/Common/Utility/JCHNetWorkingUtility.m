//
//  JCHNetWorkingUtility.m
//  jinchuhuo
//
//  Created by huangxu on 15/9/10.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHNetWorkingUtility.h"
#import "JCHDeviceUtility.h"
#import "MBProgressHUD+JCHHud.h"
#import <AFNetworking.h>

#define kFeedbackHost @"http://www.maimairen.com/feedback/addfeedback.html"
#define kFeedbackTestHost @"http://192.168.1.15:8380//website/feedback/addfeedback.html"

@implementation JCHNetWorkingUtility

+ (void)submitFeedback:(NSString *)userId
           contactInfo:(NSString *)contactInfo
          questionType:(NSInteger)questionType
          feedbackInfo:(NSString *)feedbackInfo
                result:(DataResult)result
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //当前设备类型
    NSString *currentDevice = [JCHDeviceUtility getDeviceString];
    
    //当前版本号
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = infoDictionary[@"CFBundleShortVersionString"];
    
    //注册要提交的数据
    NSDictionary *para = @{@"userId" : userId,
                           @"cellPhone" : contactInfo,
                           @"questionType" : @(questionType),
                           @"useEnvironment" : @"iOS",
                           @"equipmentType" : currentDevice,
                           @"feedbackInfo" : feedbackInfo,
                           @"deviceVersionNo" : appVersion};
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:para options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonRequest = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
    
    [manager POST:kFeedbackHost
       parameters:@{@"data" : jsonRequest}
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:NSJSONReadingMutableLeaves
                                                               error:nil];
        if (dict){
            result(dict);
        }
    }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failure, error = %@", error.localizedDescription);
        result(nil);
    }];
}

+ (void)showNetworkErrorAlert:(NSError *)error
{
    NSString *errorMessage = [NSString stringWithFormat:@"%@", error.localizedDescription];
    [MBProgressHUD showHUDWithTitle:@"网络连接异常"
                             detail:errorMessage
                           duration:3
                               mode:MBProgressHUDModeText
                         completion:nil];
}

@end
