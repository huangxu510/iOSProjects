//
//  JCHGroupContactsViewController.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/3.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "ContactsRecord4Cocoa.h"

typedef NS_ENUM(NSInteger, kJCHGroupContactsType)
{
    kJCHGroupContactsClient = 1,    //客户
    kJCHGroupContactsSupplier,    //供应商
    kJCHGroupContactsColleague, //同事
};

@interface JCHGroupContactsViewController : JCHBaseViewController

@property (nonatomic, retain) NSMutableDictionary *balanceForContactUUID;
@property (nonatomic, copy) void(^sendValueBlock)(ContactsRecord4Cocoa *contactsRecord);

- (instancetype)initWithType:(kJCHGroupContactsType)type selectMember:(BOOL)selectMember;

@end
