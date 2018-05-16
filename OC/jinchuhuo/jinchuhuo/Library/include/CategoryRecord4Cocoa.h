//
//  CategoryRecord4Cocoa.h
//  iOSInterface
//
//  Created by apple on 15/8/21.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryRecord4Cocoa : NSObject

@property (retain, nonatomic, readwrite) NSString *categoryName;                     // 分类名称
@property (retain, nonatomic, readwrite) NSString *categoryMemo;                     // 备注
@property (retain, nonatomic, readwrite) NSString *categoryProperty;                 // 分类属性
@property (retain, nonatomic, readwrite) NSString *categoryUUID;                     // category uuid
@property (assign, nonatomic, readwrite) NSInteger categorySortIndex;                // 分类排序值，默认值为0


@end
