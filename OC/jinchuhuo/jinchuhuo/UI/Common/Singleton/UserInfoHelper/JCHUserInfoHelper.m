//
//  UserInfoHelper.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/30.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHUserInfoHelper.h"

const NSString *kUserInfo = @"userInfoHelper.status.userInfo";
const NSString *kEquipmentInfo = @"userInfoHelper.status.equipmentInfo";
const NSString *kSecurityCodeForUserID = @"userInfoHelper.status.securityCodeForUserID";

@interface JCHUserInfoHelper ()
@property (retain, nonatomic, readwrite) NSArray *currentUserInfo;
@property (retain, nonatomic, readwrite) NSArray *currentEquipmentInfo;
@property (retain, nonatomic, readwrite) NSDictionary *currentsecurityCodeForUserID;
@end

@implementation JCHUserInfoHelper


+ (instancetype)shareHelper
{
    static JCHUserInfoHelper *helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (helper == nil) {
            helper = [[JCHUserInfoHelper alloc] init];
        }
    });
    
    NSString *filePath = [JCHUserInfoHelper getConfigFilePath];
   
    helper.currentEquipmentInfo = [[NSDictionary dictionaryWithContentsOfFile:filePath] objectForKey:kEquipmentInfo];
    helper.currentUserInfo = [[NSDictionary dictionaryWithContentsOfFile:filePath] objectForKey:kUserInfo];
    helper.currentsecurityCodeForUserID = [[NSDictionary dictionaryWithContentsOfFile:filePath] objectForKey:kSecurityCodeForUserID];

    [helper syncToPlist];
    
    return  helper;
}

- (void)dealloc
{
    [self.currentUserInfo release];
    [self.currentEquipmentInfo release];
    [self.currentsecurityCodeForUserID release];
    [super dealloc];
}

- (NSArray *)getEquipmentInfo
{
    return [[NSDictionary dictionaryWithContentsOfFile:[JCHUserInfoHelper getConfigFilePath]] objectForKey:kEquipmentInfo];
}

- (NSArray *)getUserInfo
{
    return [[NSDictionary dictionaryWithContentsOfFile:[JCHUserInfoHelper getConfigFilePath]] objectForKey:kUserInfo];
}

- (NSDictionary *)getsecurityCodeForUserID
{
    return [[NSMutableDictionary dictionaryWithContentsOfFile:[JCHUserInfoHelper getConfigFilePath]] objectForKey:kSecurityCodeForUserID];
}

- (void)setUserInfo:(NSArray *)userInfo
{
    self.currentUserInfo = userInfo;
    [self syncToPlist];
}
- (void)setEquipmenInfo:(NSArray *)equipmentInfo
{
    self.currentEquipmentInfo = equipmentInfo;
    [self syncToPlist];
}

/**
 *  securityCodeForUserID -> @{userID : @{@"securityCode" : code, 
                                          @"securityCodeStatus" : status}}
 *  
 */
- (void)setSecurityCodeForUserID:(NSDictionary *)securityCodeForUserID
{
    self.currentsecurityCodeForUserID = securityCodeForUserID;
    [self syncToPlist];
}

- (void)syncToPlist
{
    if (self.currentUserInfo == nil) self.currentUserInfo = @[];
    if (self.currentEquipmentInfo == nil) self.currentEquipmentInfo = @[];
    if (self.currentsecurityCodeForUserID == nil) self.currentsecurityCodeForUserID = @{};
    
    NSDictionary *info = @{kUserInfo : self.currentUserInfo,
                           kEquipmentInfo : self.currentEquipmentInfo,
                           kSecurityCodeForUserID : self.currentsecurityCodeForUserID};

    [info writeToFile:[JCHUserInfoHelper getConfigFilePath] atomically:YES];
    
    return;
}

+ (NSString *)getConfigFilePath
{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"info.plist"];
    
    return filePath;
}


@end
