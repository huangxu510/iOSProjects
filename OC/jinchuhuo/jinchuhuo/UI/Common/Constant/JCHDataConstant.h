//
//  JCHDataConstant.h
//  jinchuhuo
//
//  Created by huangxu on 16/4/27.
//  Copyright © 2016年 apple. All rights reserved.
//

#ifndef JCHDataConstant_h
#define JCHDataConstant_h


//! @brief 默认店铺类型
#ifndef kJCHDefaultShopType
#define kJCHDefaultShopType @"系统注册初始化001"
#endif

//! @brief hud默认显示时间
#ifndef kJCHDefaultShowHudTime
#define kJCHDefaultShowHudTime 1.5
#endif

//! @brief Keychain
#ifndef kIdentifierForVendorService
#define kIdentifierForVendorService @"identifierForVendorService"
#endif

#ifndef kIdentifierForVendorAccount
#define kIdentifierForVendorAccount @"identifierForVendorAccount"
#endif

//! @brief 店员首页刷新数据的通知
#ifndef kShopAssistantHomepageUpdateDataNotification
#define kShopAssistantHomepageUpdateDataNotification @"kShopAssistantHomepageUpdateDataNotification"
#endif

//! @brief 店员首页退出登录通知
#ifndef kShopAssistantHomepageLogoutNotification
#define kShopAssistantHomepageLogoutNotification @"kShopAssistantHomepageLogoutNotification"
#endif

//! @brief 角色选择店员后扫码加店成功后发送通知切换页面
#ifndef kSwitchToShopAssistantHomepageNotification
#define kSwitchToShopAssistantHomepageNotification @"kSwitchToShopAssistantHomepageNotification"
#endif


//! @brief 自动同步完成后刷新数据通知
#ifndef kAutoSyncCompleteNotification
#define kAutoSyncCompleteNotification @"kAutoSyncCompleteNotification"
#endif

//! @brief 同步完成拉到数据后改变刷新标记的通知
#ifndef kChangeRefreshMarkAfterPullData 
#define kChangeRefreshMarkAfterPullData @"kChangeRefreshMarkAfterPullData"
#endif


// 自动注册完成
#ifndef kJCHSyncAutoRegisterCompleteNotification
#define kJCHSyncAutoRegisterCompleteNotification @"kJCHSyncAutoRegisterCompleteNotification"
#endif


//! @brief 自动注册失败发送的通知（给注册页面、登录页面、引导页面）
#ifndef kAutoRegisterFailedNotification
#define kAutoRegisterFailedNotification @"kAutoRegisterFailedNotification"
#endif


#ifndef kAddProductListUIStyleKey
#define kAddProductListUIStyleKey @"kAddProductListUIStyleKey"
#endif


//! @brief 外卖版收到推送后的发给接单页面的通知
#ifndef kTakeoutServerPushNotification
#define kTakeoutServerPushNotification @"kTakeoutServerPushNotification"
#endif


//! @brief 应用回到前台的通知
#ifndef kJCHApplicationWillEnterForeground
#define kJCHApplicationWillEnterForeground @"kJCHApplicationWillEnterForeground"
#endif


//! @brief 店铺状态改变的通知
#ifndef kTakeoutShopStatusChangedNotification
#define kTakeoutShopStatusChangedNotification @"kTakeoutShopStatusChangedNotification"
#endif

#endif /* JCHDataConstant_h */
