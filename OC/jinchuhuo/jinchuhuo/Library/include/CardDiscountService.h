//
//  CardDiscountService.h
//  iOSInterface
//
//  Created by apple on 16/4/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardDiscountRecord4Cocoa.h"

@protocol CardDiscountService <NSObject>

- (int)insertAccount:(CardDiscountRecord4Cocoa *)record;
- (int)updateAccount:(CardDiscountRecord4Cocoa *)record;
- (int)deleteAccount:(NSString *)recordUUID;
- (NSArray *)queryAllCardDiscount;

@end
