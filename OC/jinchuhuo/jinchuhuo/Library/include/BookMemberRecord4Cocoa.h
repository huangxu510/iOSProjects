//
//  BookMemberRecord4Cocoa.h
//  iOSInterface
//
//  Created by apple on 15/12/30.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookMemberRecord4Cocoa : NSObject

@property (retain, nonatomic, readwrite) NSString *userId;           // 成员ID
@property (retain, nonatomic, readwrite) NSString *avatarUrl;        // 成员头像地址
@property (retain, nonatomic, readwrite) NSString *nickname;         // 昵称
@property (retain, nonatomic, readwrite) NSString *roleUUID;         // 角色UUID
@property (retain, nonatomic, readwrite) NSString *phone;            // 手机联系方式
@property (retain, nonatomic, readwrite) NSString *province;         // 所在省份
@property (retain, nonatomic, readwrite) NSString *city;             // 所在城市
@property (retain, nonatomic, readwrite) NSString *region;           // 所在区
@property (retain, nonatomic, readwrite) NSString *street;           // 所在小区门牌
@property (retain, nonatomic, readwrite) NSString *signature;        // 个性签名
@property (retain, nonatomic, readwrite) NSString *remarks;          // 备注及标签
@property (retain, nonatomic, readwrite) NSString *post;             // 店内职务
@property (assign, nonatomic, readwrite) NSInteger star;             // 店长点赞
@property (retain, nonatomic, readwrite) NSString *email;            // 联系邮箱
@property (retain, nonatomic, readwrite) NSString *extensionPhone;   // 店内分机
@property (retain, nonatomic, readwrite) NSString *weixin;           // 微信号码
@property (retain, nonatomic, readwrite) NSString *qq;               // QQ号
@property (assign, nonatomic, readwrite) NSInteger type;             // 成员类型

@end
