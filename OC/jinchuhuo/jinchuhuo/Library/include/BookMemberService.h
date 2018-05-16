//
//  BookMemberService.h
//  iOSInterface
//
//  Created by apple on 15/12/30.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookMemberRecord4Cocoa.h"

@protocol BookMemberService <NSObject>

- (void)addBookMember:(BookMemberRecord4Cocoa *)record;
- (void)updateBookMember:(BookMemberRecord4Cocoa *)record;
- (void)deleteBookMemeber:(NSString *)userID;
- (BookMemberRecord4Cocoa *)queryBookMemberWithUserID:(NSString *)userID;
- (NSArray *)queryBookMember;
- (NSArray *)queryCashMember;

@end
