//
//  UserInfoRecord4Cocoa.h
//  iOSInterface
//
//  Created by apple on 15/12/11.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoRecord4Cocoa : NSObject

@property(retain, nonatomic, readwrite) NSString *userId;        // 用户id
@property(retain, nonatomic, readwrite) NSString *token;         // 服务器分配的用户token
@property(retain, nonatomic, readwrite) NSString *displayName;   // 用于显示的名称,优先级为昵称->手机->邮箱
@property(assign, nonatomic, readwrite) BOOL isLogin;            // 标识此用户是否已经登录了
@property(retain, nonatomic, readwrite) NSString *nickname;      // 用户设置的昵称
@property(retain, nonatomic, readwrite) NSString *phone;         // 用户绑定的手机
@property(retain, nonatomic, readwrite) NSString *email;         // 用户绑定的邮箱
@property(retain, nonatomic, readwrite) NSString *avatarUrl;     // 头像地址
@property(retain, nonatomic, readwrite) NSString *city;          // 用户所在城市
@property(retain, nonatomic, readwrite) NSString *job;           // 用户所从事的行业

@end
