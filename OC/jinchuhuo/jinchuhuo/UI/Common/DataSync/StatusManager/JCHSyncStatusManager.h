//
//  JCHSyncStatusManager.h
//  jinchuhuo
//
//  Created by apple on 15/12/15.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoleRecord4Cocoa.h"

@interface JCHSyncStatusManager : NSObject

@property (retain, nonatomic, readwrite) NSString *userID;
@property (retain, nonatomic, readwrite) NSString *userName;
@property (retain, nonatomic, readwrite) NSString *phoneNumber;
@property (retain, nonatomic, readwrite) NSString *headImageName;
@property (retain, nonatomic, readwrite) NSString *accountBookID;
@property (retain, nonatomic, readwrite) NSString *syncToken;
@property (retain, nonatomic, readwrite) NSString *syncHost;
@property (retain, nonatomic, readwrite) NSString *deviceUUID;
@property (retain, nonatomic, readwrite) NSString *imageInterHostIP;                        //图片同步hostIP
@property (retain, nonatomic, readwrite) NSString *shopCoverImageName;                      //管店北京图片
@property (retain, nonatomic, readwrite) NSDictionary *lastUserInfo;
@property (retain, nonatomic, readwrite) RoleRecord4Cocoa *roleRecord;
@property (assign, nonatomic, readwrite) BOOL     hasUserAutoSilentRegisteredOnThisDevice;  //记录是否在这台设备上自动注册过
@property (assign, nonatomic, readwrite) BOOL     isLogin;
@property (assign, nonatomic, readwrite) BOOL     isShopManager;
@property (assign, nonatomic, readwrite) BOOL     hasUserLoginOnThisDevice;                 //记录用户是否在这台设备上登录过
@property (assign, nonatomic, readwrite) BOOL     enableAutoSync;
@property (assign, nonatomic, readwrite) NSDictionary *upgradeAccountBooks;                 // 在线升级相关的账本信息


//! @brief 上次查询仓库列表的时间
@property (retain, nonatomic, readwrite) NSDate *lastQueryWarehouseInfoDate;

//! @brief 上次手动同步/自动同步的时间
@property (assign, nonatomic, readwrite) NSInteger lastSyncTimestamp;

//! @brief 当前用户开通支付通道开通bindID
@property (retain, nonatomic, readwrite) NSString *cmbcPayBindID;


+ (id)shareInstance;
+ (void)writeToFile;
+ (void)clearStatus;

@end
