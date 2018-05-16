//
//  JCHServiceResponseNotification.h
//  jinchuhuo
//
//  Created by apple on 15/12/8.
//  Copyright © 2015年 apple. All rights reserved.
//

#ifndef JCHServiceResponseNotification_h
#define JCHServiceResponseNotification_h


#ifndef kJCHServiceSuccess
#define kJCHServiceSuccess 0
#endif

#ifndef kJCHServiceFailure
#define kJCHServiceFailure 1
#endif

// 用户管理服务器 - 注册用户
#ifndef kJCHUserRegisterByNameNotification
#define kJCHUserRegisterByNameNotification @"kJCHUserRegisterByNameNotification"
#endif

// 用户管理服务器 - 登录
#ifndef kJCHUserLoginNotification
#define kJCHUserLoginNotification @"kJCHUserLoginNotification"
#endif

// 用户管理服务器 - 系统自动注册用户
#ifndef kJCHAutoSilentUserRegisterNotification
#define kJCHAutoSilentUserRegisterNotification @"kJCHAutoSilentUserRegisterNotification"
#endif

// 用户管理服务器 - 获取验证码
#ifndef kJCHSendMobileCAPTCHANotification
#define kJCHSendMobileCAPTCHANotification @"kJCHSendMobileCAPTCHANotification"
#endif

// 用户管理服务器 - 通过手机号注册
#ifndef kJCHUserRegisterByMobileNotification
#define kJCHUserRegisterByMobileNotification @"kJCHUserRegisterByMobileNotification"
#endif

// 用户管理服务器 - 验证验证码
#ifndef kJCHVerifyMobileCAPTCHANotification
#define kJCHVerifyMobileCAPTCHANotification @"kJCHVerifyMobileCAPTCHANotification"
#endif

// 用户管理服务器 - 修改密码
#ifndef kJCHModifyLoginPasswordNotification
#define kJCHModifyLoginPasswordNotification @"kJCHModifyLoginPasswordNotification"
#endif

// 用户管理服务器 - 更新用户信息
#ifndef kJCHSyncUpdateUserProfileCommandNotification
#define kJCHSyncUpdateUserProfileCommandNotification @"kJCHSyncUpdateUserProfileCommandNotification"
#endif

// 用户管理服务器 - 查询用户信息
#ifndef kJCHSyncQueryUserProfileCommandNotification
#define kJCHSyncQueryUserProfileCommandNotification @"kJCHSyncQueryUserProfileCommandNotification"
#endif

// 用户管理服务器 - 查询专业版购买信息
#ifndef kJCHQueryAddedServiceInfoNotification
#define kJCHQueryAddedServiceInfoNotification @"kJCHQueryAddedServiceInfoNotification"
#endif


// 同步服务器 - new
#ifndef kJCHSyncNewCommandNotification
#define kJCHSyncNewCommandNotification @"kJCHSyncNewCommandNotification"
#endif


// 同步服务器 - push
#ifndef kJCHSyncPushCommandNotification
#define kJCHSyncPushCommandNotification @"kJCHSyncPushCommandNotification"
#endif

// 同步服务器 - pull
#ifndef kJCHSyncPullCommandNotification
#define kJCHSyncPullCommandNotification @"kJCHSyncPullCommandNotification"
#endif



// 同步管理服务器 - create
#ifndef kJCHSyncCreateCommandNotification
#define kJCHSyncCreateCommandNotification @"kJCHSyncCreateCommandNotification"
#endif

// 同步管理服务器 - fetch account books list
#ifndef kJCHSyncFetchAccountBooksCommandNotification
#define kJCHSyncFetchAccountBooksCommandNotification @"kJCHSyncFetchAccountBooksCommandNotification"
#endif  

//同步管理服务器 - 获取用户账本列表
#ifndef kJCHSyncFetchAllAccountBookListCommandNotification
#define kJCHSyncFetchAllAccountBookListCommandNotification @"kJCHSyncFetchAllAccountBookListCommandNotification"
#endif

// 同步管理服务器 - connect
#ifndef kJCHSyncConnectCommandNotification
#define kJCHSyncConnectCommandNotification @"kJCHSyncConnectCommandNotification"
#endif

// 同步管理服务器 - join
#ifndef kJCHSyncJoinCommandNotification
#define kJCHSyncJoinCommandNotification @"kJCHSyncJoinCommandNotification"
#endif

// 同步管理服务器 - unjoin
#ifndef kJCHSyncUnJoinCommandNotification
#define kJCHSyncUnJoinCommandNotification @"kJCHSyncUnJoinCommandNotification"
#endif


#ifndef kJCHSyncJoinThenConnectCommandNotification
#define kJCHSyncJoinThenConnectCommandNotification @"kJCHSyncJoinThenConnectCommandNotification"
#endif


// 同步管理服务器 - 多店 create
#ifndef kJCHSyncCreateShopCreateCommandNotification
#define kJCHSyncCreateShopCreateCommandNotification @"kJCHSyncCreateShopCreateCommandNotification"
#endif

// 同步管理服务器 - 多店 new
#ifndef kJCHSyncCreateShopNewCommandNotification
#define kJCHSyncCreateShopNewCommandNotification @"kJCHSyncCreateShopNewCommandNotification"
#endif


// 同步管理服务器 - unjoin/leave
#ifndef kJCHSyncHomepageUnJoinCommandNotification
#define kJCHSyncHomepageUnJoinCommandNotification @"kJCHSyncHomepageUnJoinCommandNotification"
#endif

// 同步管理服务器 - 修改账本关系状态
#ifndef kJCHModifyAccountBookRelationNotification
#define kJCHModifyAccountBookRelationNotification @"kJCHModifyAccountBookRelationNotification"
#endif

// 同步管理服务器 - 查询账本关系状态
#ifndef kJCHQueryAccountBookRelationNotification
#define kJCHQueryAccountBookRelationNotification @"kJCHQueryAccountBookRelationNotification"
#endif

// 同步管理服务器 - 删除账本
#ifndef kJCHDeleteAccountBookNotification
#define kJCHDeleteAccountBookNotification @"kJCHDeleteAccountBookNotification"
#endif

// 同步管理服务器 - 获取仓库列表
#ifndef kJCHQueryWarehouseListNotification
#define kJCHQueryWarehouseListNotification @"kJCHQueryWarehouseListNotification"
#endif

// 同步管理服务器 - 添加仓库
#ifndef kJCHAddWarehouseNotification
#define kJCHAddWarehouseNotification @"kJCHAddWarehouseNotification"
#endif

// 同步管理服务器 - 删除仓库
#ifndef kJCHDeleteWarehouseNotification
#define kJCHDeleteWarehouseNotification @"kJCHDeleteWarehouseNotification"
#endif

// 同步管理服务器 - 修改仓库状态
#ifndef kJCHModifyWarehouseStatusNotification
#define kJCHModifyWarehouseStatusNotification @"kJCHModifyWarehouseStatusNotification"
#endif

// 在线升级push
#ifndef kJCHOnlineUpgradeDoSyncPushCommandNotification
#define kJCHOnlineUpgradeDoSyncPushCommandNotification @"kJCHOnlineUpgradeDoSyncPushCommandNotification"
#endif

// 在线升级pull
#ifndef kJCHOnlineUpgradeDoSyncPullCommandNotification
#define kJCHOnlineUpgradeDoSyncPullCommandNotification @"kJCHOnlineUpgradeDoSyncPullCommandNotification"
#endif

// 在线升级control
#ifndef kJCHOnlineUpgradeDoSyncControlCommandNotification
#define kJCHOnlineUpgradeDoSyncControlCommandNotification @"kJCHOnlineUpgradeDoSyncControlCommandNotification"
#endif

// 在线升级release
#ifndef kJCHOnlineUpgradeDoSyncReleaseCommandNotification
#define kJCHOnlineUpgradeDoSyncReleaseCommandNotification @"kJCHOnlineUpgradeDoSyncReleaseCommandNotification"
#endif


// 在线升级release并忽略响应数据包
#ifndef kJCHOnlineUpgradeDoSyncReleaseCommandIgnoreResponseNotification
#define kJCHOnlineUpgradeDoSyncReleaseCommandIgnoreResponseNotification @"kJCHOnlineUpgradeDoSyncReleaseCommandIgnoreResponseNotification"
#endif

// 在线升级push column
#ifndef kJCHOnlineUpgradeDoSyncPushColumnCommandNotification
#define kJCHOnlineUpgradeDoSyncPushColumnCommandNotification @"kJCHOnlineUpgradeDoSyncPushColumnCommandNotification"
#endif

// 在线升级pull column
#ifndef kJCHOnlineUpgradeDoSyncPullColumnCommandNotification
#define kJCHOnlineUpgradeDoSyncPullColumnCommandNotification @"kJCHOnlineUpgradeDoSyncPullColumnCommandNotification"
#endif

// 在线升级最后的push操作
#ifndef kJCHOnlineUpgradeDoSyncFinalPushCommandNotification
#define kJCHOnlineUpgradeDoSyncFinalPushCommandNotification @"kJCHOnlineUpgradeDoSyncFinalPushCommandNotification"
#endif


// 批量导入商品
#ifndef kJCHFetchBatchImportProductListNotification
#define kJCHFetchBatchImportProductListNotification @"kJCHFetchBatchImportProductListNotification"
#endif

// 确认批量导入商品
#ifndef kJCHConfirmBatchImportProductListNotification
#define kJCHConfirmBatchImportProductListNotification @"kJCHConfirmBatchImportProductListNotification"
#endif

//交易系统服务器 - 查询微信支付结果
#ifndef kJCHQueryWeiXinPayResultNotification
#define kJCHQueryWeiXinPayResultNotification @"kJCHQueryWeiXinPayResultNotification"
#endif

//交易系统服务器 - 微信支付
#ifndef kJCHWeiXinPayNotification
#define kJCHWeiXinPayNotification @"kJCHWeiXinPayNotification"
#endif


//交易系统服务器 - 绑定微信账户
#ifndef kJCHBindWeiXinAccountNotification
#define kJCHBindWeiXinAccountNotification @"kJCHBindWeiXinAccountNotification"
#endif


//交易系统服务器 - 查询微信是否已绑定
#ifndef kJCHQueryWeiXinPayAccountOpenStatusNotification
#define kJCHQueryWeiXinPayAccountOpenStatusNotification @"kJCHQueryWeiXinPayAccountOpenStatusNotification"
#endif


//交易系统服务器 - 微信退款
#ifndef kJCHWeiXinRefundNotification
#define kJCHWeiXinRefundNotification @"kJCHWeiXinRefundNotification"
#endif

//交易系统服务器 - 查询微信退款
#ifndef kJCHQueryWeiXinRefundResultNotification
#define kJCHQueryWeiXinRefundResultNotification @"kJCHQueryWeiXinRefundResultNotification"
#endif

//商城服务器 - 上传应用内购买凭证
#ifndef kJCHUploadIAPReceiptNotification
#define kJCHUploadIAPReceiptNotification @"kJCHUploadIAPReceiptNotification"
#endif



//查询服务窗信息
#ifndef kJCHQueryServiceWindowInfoNotification
#define kJCHQueryServiceWindowInfoNotification @"kJCHQueryServiceWindowInfoNotification"
#endif


//统计报表服务器 - 经营指数
#ifndef kJCHQueryManageIndexNotification
#define kJCHQueryManageIndexNotification @"kJCHQueryManageIndexNotification"
#endif

//统计报表服务器 - 经营指数详情
#ifndef kJCHQueryManageIndexDetailNotification
#define kJCHQueryManageIndexDetailNotification @"kJCHQueryManageIndexDetailNotification"
#endif



#endif /* JCHServiceResponseNotification_h */
