//
//  UserInfoHelper.h
//  jinchuhuo
//
//  Created by huangxu on 15/10/30.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCHUserInfoHelper : NSObject

+ (instancetype)shareHelper;

- (NSArray *)getUserInfo;
- (NSArray *)getEquipmentInfo;
- (NSDictionary *)getsecurityCodeForUserID;

- (void)setUserInfo:(NSArray *)userInfo;
- (void)setEquipmenInfo:(NSArray *)equipmentInfo;
- (void)setSecurityCodeForUserID:(NSMutableDictionary *)securityCodeForUserID;

@end
