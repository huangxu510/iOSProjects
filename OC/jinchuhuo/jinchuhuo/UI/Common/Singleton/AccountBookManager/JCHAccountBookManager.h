//
//  JCHAccountBookManager.h
//  jinchuhuo
//
//  Created by huangxu on 2017/1/5.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCHAccountBookManager : NSObject

+ (instancetype)sharedManager;

- (void)newAccountBook:(void(^)(BOOL success))result;

@end
