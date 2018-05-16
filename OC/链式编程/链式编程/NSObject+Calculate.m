//
//  NSObject+Calculate.m
//  链式编程
//
//  Created by huangxu on 2017/12/15.
//  Copyright © 2017年 huangxu. All rights reserved.
//

#import "NSObject+Calculate.h"

@implementation NSObject (Calculate)

+ (NSInteger)makeCaculators:(void (^)(CaculatorMaker *))block
{
    CaculatorMaker *maker = [[CaculatorMaker alloc] init];
    
    block(maker);
    
    return maker.result;
}

@end
