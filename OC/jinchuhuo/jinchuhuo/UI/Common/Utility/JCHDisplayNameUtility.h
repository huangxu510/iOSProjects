//
//  JCHDisplayNameUtility.h
//  jinchuhuo
//
//  Created by huangxu on 16/1/13.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookMemberRecord4Cocoa.h"
#import "BookInfoRecord4Cocoa.h"

@interface JCHDisplayNameUtility : NSObject

+ (NSString *)getDisplayNickName:(BookMemberRecord4Cocoa *)bookMemberRecord;
+ (NSString *)getDisplayRemark:(BookMemberRecord4Cocoa *)bookMemberRecord;
+ (NSString *)getdisplayShopName:(BookInfoRecord4Cocoa *)bookInfoRecord;

@end
