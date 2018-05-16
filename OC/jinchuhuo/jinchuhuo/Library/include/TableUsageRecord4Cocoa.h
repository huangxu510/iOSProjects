//
//  TableUsageRecord4Cocoa.h
//  iOSInterface
//
//  Created by apple on 2016/12/30.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableUsageRecord4Cocoa : NSObject

@property (assign, nonatomic, readwrite) long long tableID;       // 餐桌ID
@property (retain, nonatomic, readwrite) NSString *orderID;           // 货单ID
@property (assign, nonatomic, readwrite) long long operatorID;        // 开台操作员ID
@property (assign, nonatomic, readwrite) unsigned int numOfCustomer;  // 就餐人数

// 查询时返回
@property (assign, nonatomic, readwrite) time_t diningBeginTime;      // 就餐开始时间
@property (assign, nonatomic, readwrite) time_t diningEndTime;        // 就餐结束时间
@property (retain, nonatomic, readwrite) NSString *tableName;         // 餐桌号
@property (retain, nonatomic, readwrite) NSString *regionName;        // 区域名称

@end
