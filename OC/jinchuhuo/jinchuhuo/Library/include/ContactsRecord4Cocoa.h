//
//  ContactsRecord4Cocoa.h
//  iOSInterface
//
//  Created by apple on 16/3/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef kContactsRecordMale
#define kContactsRecordMale 0
#endif

#ifndef kContactsRecordFemale
#define kContactsRecordFemale 1
#endif

@interface ContactsRecord4Cocoa : NSObject

@property (retain, nonatomic, readwrite) NSString *contactUUID;
@property (retain, nonatomic, readwrite) NSString *avatar;             // 头像
@property (retain, nonatomic, readwrite) NSString *name;               // 联系人姓名
@property (retain, nonatomic, readwrite) NSString *phone;              // 联系电话
@property (retain, nonatomic, readwrite) NSArray  *relationshipVector; // 关系
@property (assign, nonatomic, readwrite) NSInteger gender;             // 性别 0:男 1:女
@property (assign, nonatomic, readwrite) NSInteger birthday;           // 生日
@property (retain, nonatomic, readwrite) NSString *company;            // 公司名字
@property (retain, nonatomic, readwrite) NSString *companyAddr;        // 公司地址
@property (retain, nonatomic, readwrite) NSString *memo;               // 备注
@property (retain, nonatomic, readwrite) NSString *pinyin;             // 拼音
@property (retain, nonatomic, readwrite) NSString *cardID;             // 储值卡ID
@property (assign, nonatomic, readwrite) NSInteger cardStatus;         // 储值卡状态
@property (assign, nonatomic, readwrite) CGFloat cardDiscount;         // 储值卡折扣
@property (retain, nonatomic, readwrite) NSString *address;            // 地址


@end
