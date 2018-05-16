//
//  NSArray+JCHArray.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/3.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "NSArray+JCHArray.h"

@implementation NSArray (JCHArray)

- (NSArray *)reverseArr
{
    NSMutableArray *reverseArr = [NSMutableArray array];
    for (id obj in self) {
        [reverseArr insertObject:obj atIndex:0];
    }
    return reverseArr;
}

@end
