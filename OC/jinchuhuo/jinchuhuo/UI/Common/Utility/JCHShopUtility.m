//
//  JCHShopUtility.m
//  jinchuhuo
//
//  Created by huangxu on 16/1/14.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHShopUtility.h"
#import "ServiceFactory.h"
#import "CommonHeader.h"

@implementation JCHShopUtility

//! @brief 对店铺列表进行排序，自己的店放在前面
+ (NSArray *)sortShopList:(NSArray *)dataArray
{
    NSMutableArray *shopList_sorted = [NSMutableArray array];
    
    id <PermissionService> permissionService = [[ServiceFactory sharedInstance] permissionService];
    NSString *managerRoleUUID = [permissionService getShopManagerUUID];
    for (BookInfoRecord4Cocoa *bookInfoRecord in dataArray) {
        if ([managerRoleUUID isEqualToString:bookInfoRecord.roleRecord.roleUUID]) {
            [shopList_sorted addObject:bookInfoRecord];
        }
    }
    
    for (BookInfoRecord4Cocoa *bookInfoRecord in dataArray) {
        if (![shopList_sorted containsObject:bookInfoRecord]) {
            [shopList_sorted addObject:bookInfoRecord];
        }
    }
    
    return shopList_sorted;
}

+ (NSArray *)removeDefaultBookInfoRecord:(NSArray *)bookInfoList
{
    NSMutableArray *newBookInfoList = [NSMutableArray array];
    for (BookInfoRecord4Cocoa *bookInfoRecord in bookInfoList) {
        if (![bookInfoRecord.bookType isEqualToString:kJCHDefaultShopType]) {
            [newBookInfoList addObject:bookInfoRecord];
        }
    }
    
    return newBookInfoList;
}

@end
