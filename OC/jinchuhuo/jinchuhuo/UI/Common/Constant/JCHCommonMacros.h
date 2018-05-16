//
//  JCHCommonMacros.h
//  jinchuhuo
//
//  Created by huangxu on 16/5/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#ifndef JCHCommonMacros_h
#define JCHCommonMacros_h


//校验用
#define kTelephoneNumberPredicate @"^(\\d{3,4}-)\\d{7,8}$"
#define kPhoneNumberPredicate @"^1[3|4|5|7|8][0-9]\\d{8}$"
#define kEmailPredicate @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"

// 常用的对象
#define JCHNotificationCenter [NSNotificationCenter defaultCenter]
#define JCHUserDefaults [NSUserDefaults standardUserDefaults]
#define WeakSelf __block typeof(self) weakSelf = self

//查看代码执行时间用
#define TICK   NSDate *startTime = [NSDate date]
#define TOCK(action)   NSLog(@"%@ Time: %f", action,  -[startTime timeIntervalSinceNow])
#define TOCKTime   -[startTime timeIntervalSinceNow]

#define JCH_CHECK_IF_NIL_AND_SET_EMPTY(value) (((value) != nil) ? (value) : @"")


#define JCHSafeString(value) (((value) != nil) ? (value) : @"")


#endif /* JCHCommonMacros_h */
