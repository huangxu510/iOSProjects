//
//  BalanceStatusService.h
//  iOSInterface
//
//  Created by apple on 16/9/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#ifndef BalanceStatusService_h
#define BalanceStatusService_h

#import <Foundation/Foundation.h>

@protocol BalanceStatusService <NSObject>

- (NSInteger)checkBalanceStatus;

@end

#endif /* BalanceStatusService_h */
