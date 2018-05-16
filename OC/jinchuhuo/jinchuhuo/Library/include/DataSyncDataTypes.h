//
//  DataSyncDataTypes.h
//  iOSInterface
//
//  Created by apple on 15/12/8.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCHServiceResponse : NSObject
@property (retain, nonatomic, readwrite) NSString *status;                // 状态，字符串，有"success"、"failure"两个固定的值
@property (assign, nonatomic, readwrite) NSInteger code;                  // 状态编码，数字
@property (retain, nonatomic, readwrite) NSString *descriptionString;     // 状态描述
@end






// ===================================== 用户管理服务器 - 注册用户 =========================== //
@interface RegisterByNameRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@property (retain, nonatomic, readwrite) NSString *userID;
@property (retain, nonatomic, readwrite) NSString *userName;
@property (retain, nonatomic, readwrite) NSString *userPassword;
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@end

@interface RegisterByNameResponse : JCHServiceResponse
@property (retain, nonatomic, readwrite) NSString *userID;
@property (retain, nonatomic, readwrite) NSString *token;
@end
// ========================================================================================//






// ===================================== 用户管理服务器 - 登录 ============================== //
@interface UserLoginRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@property (retain, nonatomic, readwrite) NSString *userName;
@property (retain, nonatomic, readwrite) NSString *userPassword;
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@end

@interface UserLoginResponse : JCHServiceResponse
@property (retain, nonatomic, readwrite) NSString *userID;
@property (retain, nonatomic, readwrite) NSString *token;
@end
// ========================================================================================//






// ===================================== 用户管理服务器 - 系统自动注册用户 ==================== //
@interface AutoSilentRegisterUserRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@end

@interface AutoSilentRegisterUserResponse : JCHServiceResponse
@property (retain, nonatomic, readwrite) NSString *userID;
@property (retain, nonatomic, readwrite) NSString *token;
@end
// ========================================================================================//






// ===================================== 用户管理服务器 - 获取验证码 ========================== //
@interface SendCAPTCHARequest : NSObject
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@property (retain, nonatomic, readwrite) NSString *phoneNumber;
@property (retain, nonatomic, readwrite) NSString *requestType;
@property (assign, nonatomic, readwrite) BOOL isVoiceCAPTCHA;
@end

@interface SendCAPTCHAResponse : JCHServiceResponse

@end
// ========================================================================================//






// ===================================== 用户管理服务器 - 通过手机号注册 ====================== //
@interface RegisterByMobileRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@property (retain, nonatomic, readwrite) NSString *userID;
@property (retain, nonatomic, readwrite) NSString *userName;
@property (retain, nonatomic, readwrite) NSString *userPassword;
@property (retain, nonatomic, readwrite) NSString *captchaCode;
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@end

@interface RegisterByMobileResponse : JCHServiceResponse
@property (retain, nonatomic, readwrite) NSString *userID;
@property (retain, nonatomic, readwrite) NSString *token;
@end
// ========================================================================================//






// ===================================== 用户管理服务器 - 验证验证码 ========================= //
@interface VerifyMobileCAPTCHARequest : NSObject
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@property (retain, nonatomic, readwrite) NSString *phoneNumber;
@property (retain, nonatomic, readwrite) NSString *requestType;
@property (retain, nonatomic, readwrite) NSString *captchaCode;
@end

@interface VerifyMobileCAPTCHAResponse : JCHServiceResponse
@property (retain, nonatomic, readwrite) NSString *captchaCode;
@end
// ========================================================================================//






// ===================================== 用户管理服务器 - 修改密码 ========================== //
@interface ModifyLoginPasswordRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@property (retain, nonatomic, readwrite) NSString *userName;
@property (retain, nonatomic, readwrite) NSString *userPassword;
@property (retain, nonatomic, readwrite) NSString *captchaCode;
@end

@interface ModifyLoginPasswordResponse : JCHServiceResponse

@end
// ========================================================================================//






// ===================================== 用户管理服务器 - 设置用户信息 ========================== //
@interface UpdateUserProfileRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property(retain, nonatomic, readwrite) NSString *nickname;        // 昵称
@property(retain, nonatomic, readwrite) NSString *avatarUrl;       // 头像地址
@property(retain, nonatomic, readwrite) NSString *realname;        // 真实姓名
@property(retain, nonatomic, readwrite) NSString *signature;       // 签名
@property(retain, nonatomic, readwrite) NSString *province;        // 省
@property(retain, nonatomic, readwrite) NSString *city;            // 市
@property(retain, nonatomic, readwrite) NSString *district;        // 区
@property(retain, nonatomic, readwrite) NSString *job;             // 工作
@property(assign, nonatomic, readwrite) NSInteger genderType;      // 性别，0为男，1为女
@end

@interface UpdateUserProfileResponse : JCHServiceResponse

@end
// ========================================================================================//





// ===================================== 用户管理服务器 - 设置用户信息 ========================== //
@interface QueryUserProfileRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@end

@interface QueryUserProfileResponse : JCHServiceResponse
@property(retain, nonatomic, readwrite) NSString *cellphone;       // 手机号码
@property(retain, nonatomic, readwrite) NSString *email;           // 邮箱
@property(retain, nonatomic, readwrite) NSString *nickname;        // 昵称
@property(retain, nonatomic, readwrite) NSString *avatarUrl;       // 头像地址
@property(retain, nonatomic, readwrite) NSString *realname;        // 真实姓名
@property(retain, nonatomic, readwrite) NSString *signature;       // 签名
@property(retain, nonatomic, readwrite) NSString *province;        // 省
@property(retain, nonatomic, readwrite) NSString *city;            // 市
@property(retain, nonatomic, readwrite) NSString *district;        // 区
@property(retain, nonatomic, readwrite) NSString *job;             // 工作
@property(assign, nonatomic, readwrite) NSInteger genderType;      // 性别，0为男，1为女
@end
// ========================================================================================//






// ===================================== 用户管理服务器 - 强制注册判断 ========================== //
@interface CheckForceRegisterRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@end

@interface CheckForceRegisterResponse : JCHServiceResponse
@property(retain, nonatomic, readwrite) NSString *rand;       // 0或1
@end
// ========================================================================================//









// ===================================== 同步管理服务器 - 账本创建 =========================== //
@interface CreateAccountBookRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (assign, nonatomic, readwrite) NSInteger bookType;
@end

@interface CreateAccountBookResponse : JCHServiceResponse
@property (retain, nonatomic, readwrite) NSString *accountBookID;
@property (retain, nonatomic, readwrite) NSString *syncHost;
@end
// ========================================================================================//






// ===================================== 同步管理服务器 - 获取用户已有账本信息 ================== //
@interface FetchExistedAccountBookRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (assign, nonatomic, readwrite) NSInteger bookType;
@end

@interface FetchExistedAccountBookRecord : NSObject
@property (retain, nonatomic, readwrite) NSString *accountBookID;
@property (retain, nonatomic, readwrite) NSString *innerSyncHost;
@property (retain, nonatomic, readwrite) NSString *accountBookSyncHost;
@end

@interface FetchExistedAccountBookResponse : JCHServiceResponse
@property (retain, nonatomic, readwrite) NSMutableArray *accountBookList;
@end
// =========================================================================================//






// ===================================== 同步管理服务器 - 加入账本 =========================== //
@interface JoinAccountBookRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *param;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

@interface JoinAccountBookResponse : JCHServiceResponse
@property (retain, nonatomic, readwrite) NSString *accountBookID;
@property (retain, nonatomic, readwrite) NSString *syncHost;
@property (retain, nonatomic, readwrite) NSString *interHost;
@property (retain, nonatomic, readwrite) NSString *roleUUID;
@end
// ========================================================================================//






// ===================================== 同步管理服务器 - 退出账本 =========================== //
@interface QuitAccountBookRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *userID;
@property (retain, nonatomic, readwrite) NSString *accountBookID;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

@interface QuitAccountBookResponse : JCHServiceResponse

@end
// ========================================================================================//







// ===================================== 同步服务器 - new ================================== //
@interface NewCommandRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (assign, nonatomic, readwrite) NSInteger dataType;
@property (retain, nonatomic, readwrite) NSString *accountBookID;
@property (retain, nonatomic, readwrite) NSString *syncVersion;
@property (retain, nonatomic, readwrite) NSString *syncNode;
@property (retain, nonatomic, readwrite) NSString *organize;
@property (retain, nonatomic, readwrite) NSString *uploadDatabaseFile;
@property (retain, nonatomic, readwrite) NSString *downloadDatabaseFile;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

@interface NewCommandResponse : JCHServiceResponse

@end
// ========================================================================================//






// ===================================== 同步服务器 - pull ================================= //
@interface PullCommandRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *accountBookID;
@property (retain, nonatomic, readwrite) NSString *syncVersion;
@property (retain, nonatomic, readwrite) NSString *syncNode;
@property (retain, nonatomic, readwrite) NSString *uploadDatabaseFile;
@property (retain, nonatomic, readwrite) NSString *downloadDatabaseFile;
@property (assign, nonatomic, readwrite) NSInteger dataType;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@property (retain, nonatomic, readwrite) NSString *pieceServiceURL;

//! @note upgradeCommand 字段只在进行在线升级时设置，一般情况的同步pull操作忽略此字段
@property (retain, nonatomic, readwrite) NSString *upgradeCommand;
@end

@interface PullCommandResponse : JCHServiceResponse

@end
// ========================================================================================//






// ===================================== 同步服务器 - push ================================== //
@interface PushCommandRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *accountBookID;
@property (retain, nonatomic, readwrite) NSString *syncVersion;
@property (retain, nonatomic, readwrite) NSString *syncNode;
@property (retain, nonatomic, readwrite) NSString *uploadDatabaseFile;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@property (assign, nonatomic, readwrite) NSInteger dataType;
@property (assign, nonatomic, readwrite) NSInteger checkVersion;
@property (retain, nonatomic, readwrite) NSString *pieceServiceURL;

//! @note upgradeCommand 字段只在进行在线升级时设置，一般情况的同步push操作忽略此字段
@property (retain, nonatomic, readwrite) NSString *upgradeCommand;
@end

@interface PushCommandResponse : JCHServiceResponse

@end
// ========================================================================================//






// ===================================== 同步服务器 - connect ============================== //
@interface ConnectCommandRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *accountBookID;
@property (retain, nonatomic, readwrite) NSString *syncVersion;
@property (retain, nonatomic, readwrite) NSString *syncNode;
@property (assign, nonatomic, readwrite) NSInteger dataType;
@property (retain, nonatomic, readwrite) NSString *uploadDatabaseFile;
@property (retain, nonatomic, readwrite) NSString *downloadDatabaseFile;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@property (retain, nonatomic, readwrite) NSString *pieceServiceURL;
@end

@interface ConnectCommandResponse : JCHServiceResponse

@end
// ========================================================================================//



// ===================================== 同步服务器 - control ============================== //
@interface ControlCommandRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *userID;
@property (assign, nonatomic, readwrite) NSInteger dataType;
@property (retain, nonatomic, readwrite) NSString *accountBookID;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@property (retain, nonatomic, readwrite) NSString *nodeKey;
@end
// ========================================================================================//


// =============================== 同步管理服务器 - 专业版购买信息查询 ======================== //
@interface QueryPurchaseInfoRequest : NSObject

@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *serviceURL;

@end

// ========================================================================================//


// ================================= 同步管理服务器 - 账本关系状态查询 ======================== //
@interface QueryAccountBookRelationRequest : NSObject

@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *accountBookID;
@property (retain, nonatomic, readwrite) NSString *serviceURL;

@end
// ========================================================================================//


// ================================ 同步管理服务器 - 修改账本关系状态 ========================= //
@interface ModifyAccountBookRelationRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *accountBookID;
@property (retain, nonatomic, readwrite) NSString *userID;
@property (assign, nonatomic, readwrite) NSInteger status;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end
// ========================================================================================//


// ================================ 同步管理服务器 - 删除账本 ========================= //
@interface DeleteAccountBookRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *accountBookID;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end
// ========================================================================================//


// ================================ 同步管理服务器 - 获取指导入商品列表 ========================= //
@interface FetchBatchImportProductListRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *accountBookID;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end

@interface ConfirmBatchImportProductListRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *accountBookID;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end


// ========================================================================================//


// ================================ 同步管理服务器 - 查询服务窗状态 ========================= //
@interface QueryServiceStatusListRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end
// ========================================================================================//


// ================================ 同步管理服务器 - 仓库操作相关 ========================= //
@interface WarehouseManageRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *accountBookID;
@property (retain, nonatomic, readwrite) NSString *dataType;
@property (retain, nonatomic, readwrite) NSString *dataKey;
@property (assign, nonatomic, readwrite) NSInteger status;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end
// ========================================================================================//



@interface EfficiencyFirstRequest : NSObject

@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *accountBookID;
@property (assign, nonatomic, readwrite) NSString *endDate;
@property (retain, nonatomic, readwrite) NSString *serviceURL;

@end


@interface EfficiencySecondRequest : NSObject

@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *accountBookID;
@property (assign, nonatomic, readwrite) NSString *endDate;
@property (retain, nonatomic, readwrite) NSString *serviceURL;

@end



// ================================ 同步管理服务器 - 上传统计信息 ========================= //
@interface StatisticsRequest : NSObject

@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *accountBookID;
@property (retain, nonatomic, readwrite) NSString *serviceURL;

//! @brief 日志时间
@property (retain, nonatomic, readwrite) NSString *datetime;

//! @brief 来源应用（买卖人开店/买卖人收银）
@property (retain, nonatomic, readwrite) NSString *deviceType;

//! @brief 应用模块（新建店铺/登录/同步）
@property (retain, nonatomic, readwrite) NSString *appModule;

//! @brief 用户ID
@property (retain, nonatomic, readwrite) NSString *userID;

//! @brief 设备ID
@property (retain, nonatomic, readwrite) NSString *deviceUUID;

//! @brief 国家
@property (retain, nonatomic, readwrite) NSString *country;

//! @brief 省
@property (retain, nonatomic, readwrite) NSString *state;

//! @brief 市
@property (retain, nonatomic, readwrite) NSString *city;

//! @brief 区
@property (retain, nonatomic, readwrite) NSString *district;

//! @brief 街道
@property (retain, nonatomic, readwrite) NSString *street;

//! @brief 详情
@property (retain, nonatomic, readwrite) NSString *detail;

//! @brief 经度
@property (retain, nonatomic, readwrite) NSString *longitude;

//! @brief 纬度
@property (retain, nonatomic, readwrite) NSString *latitude;

@end

// ========================================================================================//




// ================================ 同步管理服务器 - 设备类 - 扫码授权 ========================= //
@interface ScanQRCodeAuthRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *userID;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@property (retain, nonatomic, readwrite) NSString *authParam;
@property (retain, nonatomic, readwrite) NSString *accountBookID;
@end

// ========================= 同步管理服务器 - 设备类 - 扫码授权查询/登录/登录查询 ================ //
@interface ScanQRCodeLoginRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@property (retain, nonatomic, readwrite) NSString *authParam;
@property (retain, nonatomic, readwrite) NSString *accountBookID;

@end


//! @brief 同步管理服务器 - 获取会员的账本权限
@interface QueryVIPAccountBookAuthorityRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (assign, nonatomic, readwrite) NSInteger bookType;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end



// ================================ 民生银行支付接口 ========================= //
@interface CMBCPayRequest : NSObject
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *token;
@property (retain, nonatomic, readwrite) NSString *userID;
@property (retain, nonatomic, readwrite) NSString *serviceURL;
@end





