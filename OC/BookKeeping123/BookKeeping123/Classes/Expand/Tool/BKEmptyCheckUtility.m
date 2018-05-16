//
//  BKEmptyCheckUtility.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/15.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKEmptyCheckUtility.h"

@implementation BKEmptyCheckUtility

BOOL empty(NSString *string) {
    
    if (string == nil || string == NULL)
    {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]length] == 0)
    {
        return YES;
    }
    
    return NO;
}

@end
