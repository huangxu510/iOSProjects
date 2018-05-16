//
//  JCHRepairDataUtility.m
//  jinchuhuo
//
//  Created by huangxu on 16/10/17.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHRepairDataUtility.h"
#import "CommonHeader.h"

@implementation JCHRepairDataUtility
/*
    对权限的关系进行检查并修复
     //  旧版本升级上来需要修复权限,补充角色和成员信息, 而由于同步,可能会多个终端产生多条,这种情况需要删除其中一条
     
     1.修复role表
     1) 所内置的角色UUID
     2) 对每一个内置角色进行检查并修复(是否有多个店长角色或店员角色记录)
     3) 处理没有角色的情况
     4) 处理因为同步而产生多条的情况,保留最早创建的
     
     2.修复bookMember表
     1) 修复成员类型没有初始化的问题
     2) 修复无店长或有多个店长的情况
     3) 处理无主账本, 直接成为此账本的店长
     4) 此账本已经有店长,检查这个用户在成员中是否重复
     5) 处理因为同步而产生多条的情况,保留最早创建的
     
     3.修复账本信息表
     1) 如果是店长,则检查一下此账本是否存在基本信息,没有就补充
     2) 检查账本信息是否有重复的,如果有,则只保留最早创建的记录
 */
+ (void)checkAndRepairPermission
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (statusManager.isLogin) {
        id<PermissionService> permissionService = [[ServiceFactory sharedInstance] permissionService];
        [permissionService checkAndRepairPermission:statusManager.userID phoneNumber:statusManager.phoneNumber];
        
        statusManager.isShopManager = [ServiceFactory isShopManager:statusManager.userID
                                                      accountBookID:statusManager.accountBookID];
        [JCHSyncStatusManager writeToFile];
    }
}

@end


