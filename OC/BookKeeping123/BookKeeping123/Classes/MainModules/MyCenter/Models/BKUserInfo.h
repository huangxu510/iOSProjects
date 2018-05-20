//
//  BKUserInfo.h
//  BookKeeping123
//
//  Created by huangxu on 2018/5/20.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKBaseArchiver.h"

@interface BKUserInfo : BKBaseArchiver

@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *password;

+ (instancetype)shareInstance;

@end
