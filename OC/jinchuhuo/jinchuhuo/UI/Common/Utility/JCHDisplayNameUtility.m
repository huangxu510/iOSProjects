//
//  JCHDisplayNameUtility.m
//  jinchuhuo
//
//  Created by huangxu on 16/1/13.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHDisplayNameUtility.h"

@implementation JCHDisplayNameUtility

+ (NSString *)getDisplayNickName:(BookMemberRecord4Cocoa *)bookMemberRecord
{
    if (bookMemberRecord.nickname != nil && ![bookMemberRecord.nickname isEqualToString:@""]) {
        return bookMemberRecord.nickname;
    } else if (bookMemberRecord.email != nil && ![bookMemberRecord.email isEqualToString:@""]) {
        return bookMemberRecord.email;
    } else {
        return bookMemberRecord.phone;
    }
}

+ (NSString *)getDisplayRemark:(BookMemberRecord4Cocoa *)bookMemberRecord
{
    if (bookMemberRecord.remarks != nil && ![bookMemberRecord.remarks isEqualToString:@""]) {
        return bookMemberRecord.remarks;
    } else if (bookMemberRecord.nickname != nil && ![bookMemberRecord.nickname isEqualToString:@""]) {
        return bookMemberRecord.nickname;
    } else if (bookMemberRecord.email != nil && ![bookMemberRecord.email isEqualToString:@""]) {
        return bookMemberRecord.email;
    } else {
        return bookMemberRecord.phone;
    }
}

+ (NSString *)getdisplayShopName:(BookInfoRecord4Cocoa *)bookInfoRecord
{
    if (bookInfoRecord.bookName != nil && ![bookInfoRecord.bookName isEqualToString:@""]) {
        return bookInfoRecord.bookName;
    } else {
        return bookInfoRecord.bookID;
    }
}

@end
