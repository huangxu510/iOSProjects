//
//  PermissionService.h
//  iOSInterface
//
//  Created by apple on 15/12/29.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoleRecord4Cocoa.h"

@protocol PermissionService <NSObject>

- (NSArray *)queryRoleRecord;
- (NSString *)getDefaultRoleUUID;
- (NSString *)getShopManagerUUID;
- (RoleRecord4Cocoa *)queryRoleWithByUserID:(NSString *)userID;
- (void)checkAndRepairPermission:(NSString *)userID phoneNumber:(NSString *)phoneNumber;

@end
