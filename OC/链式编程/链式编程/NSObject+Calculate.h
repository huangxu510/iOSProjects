//
//  NSObject+Calculate.h
//  链式编程
//
//  Created by huangxu on 2017/12/15.
//  Copyright © 2017年 huangxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CaculatorMaker.h"

@interface NSObject (Calculate)

+ (NSInteger)makeCaculators:(void(^)(CaculatorMaker *make))block;

@end
