//
//  JCHSyncStatusManager.m
//  jinchuhuo
//
//  Created by apple on 15/12/15.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHSyncStatusManager.h"
#import "RoleRecord4Cocoa+Serialize.h"

static NSString *kUserIDKey = @"sync.status.userID";
static NSString *kUserName = @"sync.status.userName";
static NSString *kPhoneNumber = @"sync.status.phoneNumber";
static NSString *kHeadImageName = @"sync.status.headImageName";
static NSString *kIsLogin = @"sync.status.isLogin";
static NSString *kAccountBookID = @"sync.status.accountBookID";
static NSString *kSyncHost = @"sync.status.syncHost";
static NSString *kSyncToken = @"sync.status.syncToken";
static NSString *kDeviceUUID = @"sync.status.deviceUUID";
static NSString *kHasUserAutoSilentRegisteredOnThisDevice = @"sync.status.hasRegistered";
static NSString *kLastUserInfo = @"sync.status.lastUserInfo";
static NSString *kIsShopManager = @"sync.status.isShopManager";
static NSString *kHasUserLoginOnThisDevice = @"sync.status.hasLogin";
static NSString *kRoleRecord = @"sync.status.roleRecord";
static NSString *kUpgradeAccountBookInfoList = @"upgrade.accountbooks.list";
static NSString *kEnableAutoSync = @"sync.status.enableAutoSync";
static NSString *kShopCoverImageNameKey = @"sync.status.shopCoverImageName";
static NSString *kImageInterHostIPKey = @"sync.status.imageInterHostIP";
static NSString *klastQueryWarehouseInfoDate = @"sync.status.lastQueryWarehouseInfoDate";
static NSString *kLastDataSyncTimestamp = @"sync.status.lastSyncTimestamp";
static NSString *kCMBCPayBindID = @"sync.status.cmbcPayBindID";


#ifndef JCH_CHECK_IF_NIL_AND_SET_EMPTY
#define JCH_CHECK_IF_NIL_AND_SET_EMPTY(value) (((value) != nil) ? (value) : @"")
#endif

@implementation JCHSyncStatusManager

- (id)init
{
    self = [super init];
    if (self) {
        // pass
    }
    
    return self;
}

- (void)dealloc
{
    [self.userID release];
    [self.userName release];
    [self.phoneNumber release];
    [self.headImageName release];
    [self.accountBookID release];
    [self.syncHost release];
    [self.imageInterHostIP release];
    [self.syncToken release];
    [self.deviceUUID release];
    [self.lastUserInfo release];
    [self.shopCoverImageName release];
    self.cmbcPayBindID = nil;
    
    [super dealloc];
    return;
}

+ (id)shareInstance
{
    static dispatch_once_t dispatchOnce;
    static JCHSyncStatusManager *syncStatusManager = nil;
    dispatch_once(&dispatchOnce, ^{
        syncStatusManager = [[JCHSyncStatusManager alloc] init];
    });
    
    return syncStatusManager;
}

+ (void)writeToFile
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults synchronize];
    return;
}

- (NSString *)userID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [NSString stringWithFormat:@"%@", JCH_CHECK_IF_NIL_AND_SET_EMPTY([userDefaults objectForKey:kUserIDKey])];
}

- (void)setUserID:(NSString *)userID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSString stringWithFormat:@"%@", JCH_CHECK_IF_NIL_AND_SET_EMPTY(userID)] forKey:kUserIDKey];
    return;
}

- (NSString *)userName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return JCH_CHECK_IF_NIL_AND_SET_EMPTY([userDefaults objectForKey:kUserName]);
}

- (void)setUserName:(NSString *)userName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:JCH_CHECK_IF_NIL_AND_SET_EMPTY(userName) forKey:kUserName];
    return;
}

- (NSString *)phoneNumber
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [NSString stringWithFormat:@"%@", JCH_CHECK_IF_NIL_AND_SET_EMPTY([userDefaults objectForKey:kPhoneNumber])];
}

- (void)setPhoneNumber:(NSString *)phoneNumber
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSString stringWithFormat:@"%@", JCH_CHECK_IF_NIL_AND_SET_EMPTY(phoneNumber)] forKey:kPhoneNumber];
    return;
}

- (NSString *)headImageName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return JCH_CHECK_IF_NIL_AND_SET_EMPTY([userDefaults objectForKey:kHeadImageName]);
}

- (void)setHeadImageName:(NSString *)headImageName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:JCH_CHECK_IF_NIL_AND_SET_EMPTY(headImageName) forKey:kHeadImageName];
    return;
}

- (NSString *)shopCoverImageName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return JCH_CHECK_IF_NIL_AND_SET_EMPTY([userDefaults objectForKey:kShopCoverImageNameKey]);
}

- (void)setShopCoverImageName:(NSString *)shopCoverImageName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:JCH_CHECK_IF_NIL_AND_SET_EMPTY(shopCoverImageName) forKey:kShopCoverImageNameKey];
    return;
}

- (NSString *)imageInterHostIP
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return JCH_CHECK_IF_NIL_AND_SET_EMPTY([userDefaults objectForKey:kImageInterHostIPKey]);
}

- (void)setImageInterHostIP:(NSString *)imageInterHostIP
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:JCH_CHECK_IF_NIL_AND_SET_EMPTY(imageInterHostIP) forKey:kImageInterHostIPKey];
    return;
}

- (BOOL)isLogin
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [[userDefaults objectForKey:kIsLogin] boolValue];
}

- (void)setIsLogin:(BOOL)isLogin
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(isLogin) forKey:kIsLogin];
    return;
}

- (BOOL)isShopManager
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [[userDefaults objectForKey:kIsShopManager] boolValue];
}

- (void)setIsShopManager:(BOOL)isShopManager
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(isShopManager) forKey:kIsShopManager];
    return;
}

- (BOOL)hasUserAutoSilentRegisteredOnThisDevice
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [[userDefaults objectForKey:kHasUserAutoSilentRegisteredOnThisDevice] boolValue];
}

- (void)setHasUserAutoSilentRegisteredOnThisDevice:(BOOL)hasUserAutoSilentRegisteredOnThisDevice
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(hasUserAutoSilentRegisteredOnThisDevice) forKey:kHasUserAutoSilentRegisteredOnThisDevice];
    return;
}

- (BOOL)hasUserLoginOnThisDevice
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [[userDefaults objectForKey:kHasUserLoginOnThisDevice] boolValue];
}

- (void)setHasUserLoginOnThisDevice:(BOOL)hasUserLoginOnThisDevice
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(hasUserLoginOnThisDevice) forKey:kHasUserLoginOnThisDevice];
    return;
}

- (BOOL)enableAutoSync
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [[userDefaults objectForKey:kEnableAutoSync] boolValue];
}

- (void)setEnableAutoSync:(BOOL)enableAutoSync
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(enableAutoSync) forKey:kEnableAutoSync];
    return;
}

- (NSString *)accountBookID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [NSString stringWithFormat:@"%@", JCH_CHECK_IF_NIL_AND_SET_EMPTY([userDefaults objectForKey:kAccountBookID])];
}

- (void)setAccountBookID:(NSString *)accountBookID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSString stringWithFormat:@"%@", JCH_CHECK_IF_NIL_AND_SET_EMPTY(accountBookID)] forKey:kAccountBookID];
    return;
}

- (NSString *)syncHost
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return JCH_CHECK_IF_NIL_AND_SET_EMPTY([userDefaults objectForKey:kSyncHost]);
}

- (void)setSyncHost:(NSString *)syncHost
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:JCH_CHECK_IF_NIL_AND_SET_EMPTY(syncHost) forKey:kSyncHost];
    return;
}

- (NSString *)syncToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return JCH_CHECK_IF_NIL_AND_SET_EMPTY([userDefaults objectForKey:kSyncToken]);
}

- (void)setSyncToken:(NSString *)syncToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:JCH_CHECK_IF_NIL_AND_SET_EMPTY(syncToken) forKey:kSyncToken];
    return;
}



- (NSString *)deviceUUID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return JCH_CHECK_IF_NIL_AND_SET_EMPTY([userDefaults objectForKey:kDeviceUUID]);
}

- (void)setDeviceUUID:(NSString *)deviceUUID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:JCH_CHECK_IF_NIL_AND_SET_EMPTY(deviceUUID) forKey:kDeviceUUID];
    return;
}

- (NSDictionary *)lastUserInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:kLastUserInfo];
}

- (void)setLastUserInfo:(NSDictionary *)lastUserInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:lastUserInfo forKey:kLastUserInfo];
    return;
}

- (RoleRecord4Cocoa *)roleRecord
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [RoleRecord4Cocoa fromDictionary:(NSDictionary *)[userDefaults objectForKey:kRoleRecord]];
}

- (void)setRoleRecord:(RoleRecord4Cocoa *)roleRecord
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[roleRecord toDictionary] forKey:kRoleRecord];
    return;
}

- (NSDictionary *)upgradeAccountBooks
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *upgradeList = [userDefaults objectForKey:kUpgradeAccountBookInfoList];
    if (nil == upgradeList) {
        upgradeList = [[[NSDictionary alloc] init] autorelease];
    }
    
    return upgradeList;
}

- (void)setUpgradeAccountBooks:(NSDictionary *)accountBooks
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:accountBooks forKey:kUpgradeAccountBookInfoList];
    return;
}

- (NSDate *)lastQueryWarehouseInfoDate
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:klastQueryWarehouseInfoDate];
}

- (void)setLastQueryWarehouseInfoDate:(NSDate *)lastQueryWarehouseInfoDate
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:lastQueryWarehouseInfoDate forKey:klastQueryWarehouseInfoDate];
}

- (NSInteger)lastSyncTimestamp
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *value = [userDefaults objectForKey:kLastDataSyncTimestamp];
    if (nil == value) {
        return 0;
    } else {
        return [value integerValue];
    }
}

- (void)setLastSyncTimestamp:(NSInteger)syncTimestamp
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(syncTimestamp) forKey:kLastDataSyncTimestamp];
}

- (NSString *)cmbcPayBindID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [userDefaults objectForKey:kCMBCPayBindID];
    return JCH_CHECK_IF_NIL_AND_SET_EMPTY(value);
}

- (void)setCmbcPayBindID:(NSString *)cmbcPayBindID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:JCH_CHECK_IF_NIL_AND_SET_EMPTY(cmbcPayBindID) forKey:kCMBCPayBindID];
    return;
}

+ (void)clearStatus
{
    NSLog(@"clear SyncStatusManager status!");
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    statusManager.isLogin = NO;
    statusManager.userID = @"";
    statusManager.userName = nil;
    statusManager.phoneNumber = nil;
    statusManager.headImageName = nil;
    statusManager.accountBookID = nil;
    statusManager.syncToken = nil;
    statusManager.cmbcPayBindID = nil;
    //statusManager.shopCoverImageName = nil;
    statusManager.hasUserAutoSilentRegisteredOnThisDevice = NO;
    statusManager.hasUserLoginOnThisDevice = YES;
    statusManager.enableAutoSync = NO;
    [JCHSyncStatusManager writeToFile];
}

@end
