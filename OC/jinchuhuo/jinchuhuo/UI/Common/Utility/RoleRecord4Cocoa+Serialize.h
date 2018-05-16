//
//  RoleRecord4Cocoa+Serialize.h
//  jinchuhuo
//
//  Created by huangxu on 16/1/13.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "RoleRecord4Cocoa.h"

@interface RoleRecord4Cocoa (Serialize)

- (NSDictionary *)toDictionary;
+ (RoleRecord4Cocoa *)fromDictionary:(NSDictionary *)dictionary;
+ (RoleRecord4Cocoa *)createShopManagerRoleRecord:(NSString *)roleUUID;

@end
