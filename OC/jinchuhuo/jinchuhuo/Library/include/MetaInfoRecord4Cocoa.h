//
//  MetaInfo4Cocoa.h
//  iOSInterface
//
//  Created by apple on 15/8/4.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MetaInfoRecord4Cocoa : NSObject

@property (assign, nonatomic, readwrite) NSInteger record_id;                  // 自增主键
@property (assign, nonatomic, readwrite) NSInteger version;                    // APP版本号: 6位数字: XXYYZZ
@property (assign, nonatomic, readwrite) NSInteger appType;                    // APP类型: 1: 标准版，2: 专业版，3: 定制版
@property (assign, nonatomic, readwrite) NSInteger deviceType;                 // APP运行设置类型: 1: iOS, 2: Android


@end
