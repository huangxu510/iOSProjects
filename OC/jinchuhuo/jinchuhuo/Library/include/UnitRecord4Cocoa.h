//
//  UnitRecord4Cocoa.h
//  iOSInterface
//
//  Created by apple on 15/8/3.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UnitRecord4Cocoa : NSObject

@property (assign, nonatomic, readwrite) NSInteger unitDecimalDigits;            // 小数位数
@property (retain, nonatomic, readwrite) NSString *unitName;                     // 单位名称
@property (retain, nonatomic, readwrite) NSString *unitMemo;                     // 备注
@property (retain, nonatomic, readwrite) NSString *unitProperty;                 // 单位属性
@property (retain, nonatomic, readwrite) NSString *unitUUID;                     // uuid
@property (assign, nonatomic, readwrite) NSInteger sortIndex;                    // 排序索引

@end
