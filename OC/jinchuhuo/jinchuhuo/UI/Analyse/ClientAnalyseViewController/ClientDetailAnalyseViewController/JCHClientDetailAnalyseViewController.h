//
//  JCHClientDetailAnalyseViewController.h
//  jinchuhuo
//
//  Created by huangxu on 16/7/14.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

@interface JCHClientDetailAnalyseViewController : JCHBaseViewController

- (instancetype)initWithCustomUUID:(NSString *)customUUID
                         startTime:(NSInteger)startTime
                           endTime:(NSInteger)endTime
                   isReturnedIndex:(BOOL)isReturnedIndex;

@end
