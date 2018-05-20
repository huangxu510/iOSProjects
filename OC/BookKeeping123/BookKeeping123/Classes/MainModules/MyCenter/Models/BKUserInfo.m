//
//  BKUserInfo.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/20.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKUserInfo.h"

@implementation BKUserInfo

+ (instancetype)shareInstance {
    static BKUserInfo *staticInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticInstance = [[BKUserInfo alloc] init];
        BKUserInfo *archiver = [staticInstance loadCache];
        if (archiver) {
            staticInstance = archiver;
        }
    });
    
    return staticInstance;
}


@end
