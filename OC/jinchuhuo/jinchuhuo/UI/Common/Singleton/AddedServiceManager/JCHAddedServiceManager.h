//
//  JCHAddedServiceManager.h
//  jinchuhuo
//
//  Created by huangxu on 16/5/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JCHAddedServiceLevel)
{
    kJCHAddedServiceNormalLevel = 0,        //普通会员
    kJCHAddedServiceCopperLevel,            //铜麦会员
    kJCHAddedServiceSiverLevel,             //银麦会员
    kJCHAddedServiceGoldLevel,              //金麦会员
};

@interface JCHAddedServiceManager : NSObject

//! @brief  status服务状态  0正常  -1已过期  -2未购买
//@property (nonatomic, assign) NSInteger status;

//! @brief 会员等级  0普通  1铜麦  2银麦  3金麦
@property (nonatomic, assign) NSInteger level;

//! @brief 到期时间，格式为yyyy-MM-dd HH:mm:ss
@property (nonatomic, retain) NSString *endTime;

//! @brief 剩余天数
@property (nonatomic, assign) NSInteger remainingDays;

//! @brief 未验证凭证的transactionID
@property (nonatomic, retain) NSArray *notVerifiedTransactionIDList;

//! @brief 上次查询服务状态的日期
@property (nonatomic, retain) NSDate *lastQueryInfoDate;

+ (id)shareInstance;
+ (void)clearStatus;

@end
