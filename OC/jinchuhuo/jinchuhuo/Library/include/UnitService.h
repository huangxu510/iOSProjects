//
//  UnitService.h
//  iOSInterface
//
//  Created by apple on 15/8/4.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UnitRecord4Cocoa.h"

@protocol UnitService <NSObject>

- (int)insertUnit:(UnitRecord4Cocoa *)record;
- (int)updateUnit:(UnitRecord4Cocoa *)record;
- (int)deleteUnit:(NSString *)unitUUID;
- (BOOL)isUnitCanBeDelete:(NSString *)unitUUID;
- (NSArray *)queryAllUnit;

@end
