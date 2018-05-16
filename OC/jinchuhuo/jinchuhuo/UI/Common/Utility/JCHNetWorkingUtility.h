//
//  JCHNetWorkingUtility.h
//  jinchuhuo
//
//  Created by huangxu on 15/9/10.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DataResult)(id obj) ;

@interface JCHNetWorkingUtility : NSObject

+ (void)submitFeedback:(NSString *)userId
           contactInfo:(NSString *)contactInfo
          questionType:(NSInteger)questionType
          feedbackInfo:(NSString *)feedbackInfo
                result:(DataResult)result;

+ (void)showNetworkErrorAlert:(NSError *)error;

@end
