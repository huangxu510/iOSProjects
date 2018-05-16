//
//  CardDiscountRecord4Cocoa.h
//  iOSInterface
//
//  Created by apple on 16/4/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CardDiscountRecord4Cocoa : NSObject

//! @brief 记录UUID
@property (retain, nonatomic, readwrite) NSString *recordUUID;

//! @brief 记录状态，0为正常
@property (assign, nonatomic, readwrite) NSInteger status;

//! @brief 充值金额上限值
@property (assign, nonatomic, readwrite) CGFloat amountUpper;

//! @brief 充值金额下限值
@property (assign, nonatomic, readwrite) CGFloat amountLower;

//! @brief 支付折扣
@property (assign, nonatomic, readwrite) CGFloat discount;

//! @brief 规则创建人ID
@property (assign, nonatomic, readwrite) NSInteger createID;

//! @brief 规则修改人ID
@property (assign, nonatomic, readwrite) NSInteger modifyID;

//! @brief 规则创建时间
@property (assign, nonatomic, readwrite) time_t createTime;

//! @brief 规则修改时间
@property (assign, nonatomic, readwrite) time_t modifyTime;

@end
