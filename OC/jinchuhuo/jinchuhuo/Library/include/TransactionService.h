//
//  TransactionService.h
//  iOSInterface
//
//  Created by apple on 15/7/29.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionRecord4Cocoa.h"

@protocol TransactionService <NSObject>

@required
- (void)insertTransaction:(TransactionRecord4Cocoa *)record;

- (void)insertManifest:(NSArray *)transactionList
          manifestType:(int)manifestType
            manifestID:(NSString *)manifestID
      manifestDiscount:(double)manifestDiscount;

@end
