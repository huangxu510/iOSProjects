//
//  DataSyncService.h
//  iOSInterface
//
//  Created by apple on 15/12/7.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataSyncDataTypes.h"
#import "UserInfoRecord4Cocoa.h"

@protocol DataSyncService <NSObject>


// ===================================== 同步IP相关操作 =================================== //
//! @brief 获取账本同步PULL IP地址
- (NSString *)getSyncAccountBookPullHost;

//! @brief 获取账本同步PULL IP地址
- (NSString *)getSyncAccountBookPushHost;

//! @brief 获取账本同步PIECE IP地址
- (NSString *)getSyncAccountBookPieceHost;

//! @brief 获取同步结点
- (NSString *)getSyncNodeID;

//! @brief 获取账本控制ID
- (NSString *)getSyncAccountBookControlHost;

//! @brief 获取账本同步PULL ALL IP地址
- (NSString *)getSyncAccountBookPullAllHost;

// ===================================== 多店相关操作 =================================== //
- (NSString *)generateQRCodeString:(NSString *)userdID
                     accountBookID:(NSString *)accountBookID
                   accountBookName:(NSString *)accountBookName
                           roleUID:(NSString *)roleUUID
                         validTime:(NSInteger)validTime
                         checkUUID:(NSString *)checkUUID
                          userName:(NSString *)userName;


- (BOOL)parseQRCodeString:(NSString *)urlString
                  qrParam:(NSString **)qrParam
            accountBookID:(NSString **)accountBookID
          accountBookName:(NSString **)accountBookName
                 userName:(NSString **)userName;



// ===================================== 用户账户相关操作 =================================== //
- (UserInfoRecord4Cocoa *)queryUserInfo;
- (void)updateUserAccount:(UserInfoRecord4Cocoa *)record;
- (BOOL)isMemberOfAccountBook:(NSString *)userID;









// ===================================== 同步数据库增量操作 =================================== //
//! @brief 创建上传的增量数据库
- (int)preparePushDatabase:(NSString *)uploadDatabasePath;

- (int)updateFromPushDatabase:(NSString *)uploadDatabasePath;

//! @brief 创建下载的增量数据库
- (int)preparePullDatabase:(NSString *)downloadDatabasePath pullFlag:(NSInteger)pullFlag;

- (int)updateFromPullDatabase:(NSString *)downloadDatabasePath;

//! @brief 全量摘取时的数据库路径
- (int)transfortoUpgradePullData:(NSString *)databasePath;

- (void)checkMigrate;

//! @brief 调整同步时间差
- (void)adjustSyncTime:(long long)serverTime clientTime:(long long)clientTime;

//! @brief 创建增量下载数据库
- (int)preparePullColumn:(NSString *)databasePath;

//! @brief 更新增量下载数据库
- (int)updateAfterPullColumn:(NSString *)databasePath;

//! @brief 获取preparePullDatabase PULL_TYPE_NORMAL_PART
- (int)getPullTypeNormalPart;

//! @brief 获取preparePullDatabase PULL_TYPE_MORE_PART
- (int)getPullTypeMorePart;



// ===================================== 用户管理服务器 ===================================== //
//! @brief 用户管理服务器 - 注册用户
- (void)userRegisterByName:(RegisterByNameRequest *)request responseNotification:(NSString *)responseNotification;

//! @brief 用户管理服务器 - 登录
- (void)userLogin:(UserLoginRequest *)request responseNotification:(NSString *)responseNotification;


//! @brief 用户管理服务器 - 系统自动注册用户
- (void)autoSilentRegister:(AutoSilentRegisterUserRequest *)request responseNotification:(NSString *)responseNotification;


//! @brief 用户管理服务器 - 获取验证码
- (void)sendMobileCAPTCHA:(SendCAPTCHARequest *)request responseNotification:(NSString *)responseNotification;


//! @brief 用户管理服务器 - 通过手机号注册
- (void)userRegisterByMobile:(RegisterByMobileRequest *)request responseNotification:(NSString *)responseNotification;


//! @brief 用户管理服务器 - 验证验证码
- (void)verifyMobileCAPTCHA:(VerifyMobileCAPTCHARequest *)request responseNotification:(NSString *)responseNotification;


//! @brief 用户管理服务器 - 修改密码
- (void)modifyLoginPassword:(ModifyLoginPasswordRequest *)request responseNotification:(NSString *)responseNotification;


//! @brief 用户管理服务器 - 设置用户信息
- (void)updateUserProfile:(UpdateUserProfileRequest *)request responseNotification:(NSString *)responseNotification;


//! @brief 用户管理服务器 - 查询用户信息
- (void)queryUserProfile:(QueryUserProfileRequest *)request responseNotification:(NSString *)responseNotification;


//! @brief 用户管理服务器 - 强制注册判断
- (void)checkForceRegister:(CheckForceRegisterRequest *)request responseNotification:(NSString *)responseNotification;

// ========================================================================================//







// ===================================== 同步管理服务器 ===================================== //
//! @brief 同步管理服务器 - 账本创建
- (void)createAccountBook:(CreateAccountBookRequest *)request responseNotification:(NSString *)responseNotification;


//! @brief 同步管理服务器 - 获取用户已有账本信息
- (void)fetchExistedAccountBook:(FetchExistedAccountBookRequest *)request responseNotification:(NSString *)responseNotification;


//! @brief 同步管理服务器 - 加入账本
- (void)joinAccountBook:(JoinAccountBookRequest *)request responseNotification:(NSString *)responseNotification;

//! @brief 同步管理服务器 - 退出账本
- (void)quitAccountBook:(QuitAccountBookRequest *)request responseNotification:(NSString *)responseNotification;

//! @brief 同步服务器 - new
- (void)newCommand:(NewCommandRequest *)request responseNotification:(NSString *)responseNotification;

//! @brief 同步管理服务器 - 专业版购买信息查询
- (void)queryPurchaseInfo:(QueryPurchaseInfoRequest *)request responseNotification:(NSString *)responseNotification;

//! @brief 同步管理服务器 - 账本关系状态查询
- (void)queryAccountBookRelation:(QueryAccountBookRelationRequest *)request responseNotification:(NSString *)responseNotification;

//! @brief 同步管理服务器 - 获取会员的账本权限
- (void)queryVIPAccountBookAuthority:(QueryVIPAccountBookAuthorityRequest *)request callback:(void(^)(id response))callback;

//! @brief 同步管理服务器 - 修改账本关系状态
- (void)modifyAccountBookRelation:(ModifyAccountBookRelationRequest *)request responseNotification:(NSString *)responseNotification;

//! @brief 同步管理服务器 - 删除账本
- (void)deleteAccountBook:(DeleteAccountBookRequest *)request responseNotification:(NSString *)responseNotification;

//! @brief 同步管理服务器 - 获取批量导入商品列表
- (void)fetchBatchImportProductList:(FetchBatchImportProductListRequest *)request responseNotification:(NSString *)responseNotification;

//! @brief 同步管理服务器 - 确认批量导入商品列表
- (void)confirmBatchImportProductList:(ConfirmBatchImportProductListRequest *)request responseNotification:(NSString *)responseNotification;

//! @brief 同步服务器 - 查询服务窗状态
- (void)queryServiceStatusList:(QueryServiceStatusListRequest *)request responseNotification:(NSString *)responseNotification;


//! @brief 同步管理服务器 - 仓库类数据管理 - 获取
- (void)queryWarehouse:(WarehouseManageRequest *)request callback:(void(^)(id response))callback;

//! @brief 同步管理服务器 - 仓库类数据管理 - 添加
- (void)addWarehouse:(WarehouseManageRequest *)request callback:(void(^)(id response))callback;

//! @brief 同步管理服务器 - 仓库类数据管理 - 删除
- (void)deleteWarehouse:(WarehouseManageRequest *)request callback:(void(^)(id response))callback;

//! @brief 同步管理服务器 - 仓库类数据管理 - 启用
- (void)enableWarehouse:(WarehouseManageRequest *)request callback:(void(^)(id response))callback;

//! @brief 同步管理服务器 - 仓库类数据管理 - 停用
- (void)disableWarehouse:(WarehouseManageRequest *)request callback:(void(^)(id response))callback;

// ==================================================================================== //



// ===================================== 统计报表服务 ===================================== //

- (void)requestEfficiencyFirst:(EfficiencyFirstRequest *)request responseNotification:(NSString *)responseNotification;

- (void)requestEfficiencySecond:(EfficiencySecondRequest *)request responseNotification:(NSString *)responseNotification;

- (void)uploadStatistics:(StatisticsRequest *)request callback:(void(^)(id response))callback;


// ==================================================================================== //


// ===================================== 设备管理服务 ===================================== //

//! @brief 同步管理服务器 - 设备类 - 扫码授权
- (void)scanAuth:(ScanQRCodeAuthRequest *)request callback:(void(^)(id response))callback;

//! @brief 同步管理服务器 - 设备类 - 扫码登录
- (void)scanLogin:(ScanQRCodeLoginRequest *)request callback:(void(^)(id response))callback;

// ==================================================================================== //



@end
