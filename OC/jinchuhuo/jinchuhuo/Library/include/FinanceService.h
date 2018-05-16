//
//  FinanceService.h
//  iOSInterface
//
//  Created by apple on 16/7/7.
//  Copyright © 2016年 apple. All rights reserved.
//

#ifndef FinanceService_h
#define FinanceService_h

#import "FinanceServiceRecord4Cocoa.h"

@protocol FinanceService <NSObject>

//! @brief 贷款入口是否要显示的接口
- (int)checkShowFinanceEntry:(CheckShowFinanceEntryRequest *)request
                    response:(NSString *)responseNotification;

@end

#endif /* FinanceService_h */
