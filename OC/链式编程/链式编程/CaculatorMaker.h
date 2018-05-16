//
//  CaculatorMaker.h
//  链式编程
//
//  Created by huangxu on 2017/12/15.
//  Copyright © 2017年 huangxu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CaculatorMaker : NSObject

@property (nonatomic, assign) NSInteger result;

- (CaculatorMaker *(^)(NSInteger))add;

@end
