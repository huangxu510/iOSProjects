//
//  CaculatorMaker.m
//  链式编程
//
//  Created by huangxu on 2017/12/15.
//  Copyright © 2017年 huangxu. All rights reserved.
//

#import "CaculatorMaker.h"

@implementation CaculatorMaker

- (CaculatorMaker *(^)(NSInteger))add
{
    return ^CaculatorMaker *(NSInteger value){
        
        _result += value;
        
        return self;
    };
}

@end
