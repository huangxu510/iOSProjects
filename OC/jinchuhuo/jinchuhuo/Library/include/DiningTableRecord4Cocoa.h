//
//  DiningTable4Cocoa.h
//  iOSInterface
//
//  Created by apple on 2016/12/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableRegionRecord4Cocoa : NSObject

@property(assign, nonatomic, readwrite) long long regionID;         // 区域ID
@property(retain, nonatomic, readwrite) NSString *regionType;       // 区域类型

@end


@interface TableTypeRecord4Cocoa : NSObject

@property(assign, nonatomic, readwrite) long long typeID;            // 类型ID
@property(retain, nonatomic, readwrite) NSString *typeName;          // 类型名称

@end

@interface DiningTableRecord4Cocoa : NSObject

@property(assign, nonatomic, readwrite) long long tableID;           // 餐桌 ID
@property(retain, nonatomic, readwrite) NSString *tableName;         // 餐桌名称
@property(retain, nonatomic, readwrite) NSString *memo;              // 备注
@property(assign, nonatomic, readwrite) long long typeID;            // 餐桌类型 ID
@property(assign, nonatomic, readwrite) long long regionID;          // 区域 ID
@property(assign, nonatomic, readwrite) int sortIndex;               // 排序序号
@property(retain, nonatomic, readwrite) NSString *typeName;          // 类型
@property(retain, nonatomic, readwrite) NSString *regionName;        // 区域
@property(assign, nonatomic, readwrite) NSInteger tableStatus;       // 桌台状态
@property(assign, nonatomic, readwrite) NSInteger seatCount;         // 可就餐人数
@end
