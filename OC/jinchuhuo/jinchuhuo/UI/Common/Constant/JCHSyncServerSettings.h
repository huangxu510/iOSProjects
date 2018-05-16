//
//  JCHSyncServerSettings.h
//  jinchuhuo
//
//  Created by apple on 15/12/23.
//  Copyright © 2015年 apple. All rights reserved.
//

#ifndef JCHSyncServerSettings_h
#define JCHSyncServerSettings_h

//! @brief 指定当前的用户注册，登录，数据同步运行环境
/*
 *  1 -- 正式环境,
 *  0 -- 测试环境
 */

#if DEBUG

    //! @note 在安装测试时，设置为 测试环境
    #define kJCHBuildForAppStoreRelease 0

#else

    //! @note 在打包提交AppStore时，设置为 正式环境
    #define kJCHBuildForAppStoreRelease 1

#endif



#if DEBUG

    //! @note 外网测试环境
    #define kJCHExtranetTestServer  1
#endif


//! @brief 指定当前的云服务环境
/*
 *  在测试环境中， 使用                  私有云
 *  在正式环境发布AppStore时，使用        公有云
 *
 */

// kJCHSyncModeRunInPublicCloud
/*
 *  YES -- 私有云
 *  NO  -- 公有云
 *
 */


#if kJCHBuildForAppStoreRelease

    //
    //! @brief 在正式环境中运行
    //         

    //用户管理服务器
    #ifndef kJCHUserManagerServerIP
    #define kJCHUserManagerServerIP @"http://passport.maimairen.com"
    #endif

    //同步管理服务器
    #ifndef kJCHSyncManagerServerIP
    #define kJCHSyncManagerServerIP @"http://sc1.jinchuhuo.com"
    #endif

    //交易系统服务器
    #ifndef kPaySystemServerIP
    #define kPaySystemServerIP @"http://finance.maimairen.net"
    #endif

    //商城服务器
    #ifndef kStoreServerIP
    #define kStoreServerIP @"http://shop.maimairen.com"
    #endif

    //钱橙贷
    #ifndef kJCHQueryShowQianChengDaiEntranceIP
    #define kJCHQueryShowQianChengDaiEntranceIP @"http://qcd.maimairen.com"
    #endif

    // 钱橙贷入口
    #ifndef kJCHQianChengDaiEntranceIP
    #define kJCHQianChengDaiEntranceIP @"http://qcd.maimairen.com/?from=app"
    #endif

    // M码兑换接口
    #ifndef kJCHMCodeExchangeEntranceIP
    #define kJCHMCodeExchangeEntranceIP @"http://shop.maimairen.com/home/serving/coupon/show"
    #endif

    // 内部测试时，使用私有云环境            NO
    // 发布AppStore时，使用公有云环境       YES
    #ifndef kJCHSyncModeRunInPublicCloud
    #define kJCHSyncModeRunInPublicCloud YES
    #endif

    //经营指数
    #ifndef kManageIndexServerIP
    #define kManageIndexServerIP @"http://dt.maimairen.net/data/efficiency"
    #endif

    // 商品导入
    #ifndef kBatchImportProductServiceIP
    #define kBatchImportProductServiceIP @"http://cp.maimairen.com/device/basedata/goods"
    #endif


    // 服务窗
    #ifndef kServiceWindowServiceIP
    #define kServiceWindowServiceIP @"http://fwc.maimairen.com/window/list"
    #endif

    // 数据采集
    #ifndef kDataStatisticsServiceIP
    #define kDataStatisticsServiceIP @"http://dt.maimairen.net/data/gps/collector"
    #endif

    // 外卖服务器
    #ifndef kTakeoutServerIP
    #define kTakeoutServerIP @""
    #endif

    // 民行支付接口
    #ifndef kCMBCPayServiceURL
    #define kCMBCPayServiceURL @"http://pay.maimairen.com/finance"
    #endif

    // 查询民生支付开通状态
    #ifndef kCMBCQueryBindServiceURL
    #define kCMBCQueryBindServiceURL @"http://cp.maimairen.com/provide/bind/get"
    #endif

    // 查询民生支付开户
    #ifndef kCMBCOpenAccountServiceURL
    #define kCMBCOpenAccountServiceURL @"http://pay.maimairen.com/finance/cmbc/regist.jsp"
    #endif

#else


    //
    //! @brief 在测试环境中运行
    //


#if kJCHExtranetTestServer
    // 外网测试环境
    #ifndef kJCHUserManagerServerIP
    #define kJCHUserManagerServerIP @"http://115.159.105.67:8090/usermanager"
    #endif

    #ifndef kJCHSyncManagerServerIP
    #define kJCHSyncManagerServerIP @"http://115.159.105.67:8090/syncmanager"
    #endif

#else
    // 内网测试环境
    #ifndef kJCHUserManagerServerIP
    #define kJCHUserManagerServerIP @"http://192.168.1.9:8088/usermanager"
    #endif

    #ifndef kJCHSyncManagerServerIP
    #define kJCHSyncManagerServerIP @"http://192.168.1.9:8088/syncmanager"
    #endif

#endif


    #ifndef kPaySystemServerIP
    #define kPaySystemServerIP @"http://192.168.1.9:8088/finance"
    #endif

    #ifndef kStoreServerIP
    #define kStoreServerIP @"http://192.168.1.9:8088/paycenter"
    #endif

    #ifndef kJCHQueryShowQianChengDaiEntranceIP
    #define kJCHQueryShowQianChengDaiEntranceIP @"http://192.168.1.9:8088/mmr-credit"
    #endif

    #ifndef kJCHQianChengDaiEntranceIP
    #define kJCHQianChengDaiEntranceIP @"http://192.168.1.9:8088/mmr-credit/"
    #endif

    // M码兑换接口
    #ifndef kJCHMCodeExchangeEntranceIP
    #define kJCHMCodeExchangeEntranceIP @"http://192.168.1.9:8088/paycenter/home/serving/coupon/show"
    #endif

    // 私有云环境
    #ifndef kJCHSyncModeRunInPublicCloud
    #define kJCHSyncModeRunInPublicCloud NO
    #endif

    // 经营指数
    #ifndef kManageIndexServerIP
    #define kManageIndexServerIP @"http://192.168.1.64:8080/efficiency"
    #endif

    // 商品导入
    #ifndef kBatchImportProductServiceIP
    #define kBatchImportProductServiceIP @"http://192.168.1.15:8482/merchants-web/device/basedata/goods"
    #endif

    // 服务窗
    #ifndef kServiceWindowServiceIP
    #define kServiceWindowServiceIP @"http://192.168.1.52:8486/mmr-window/window/list"
    #endif

    // 数据采集
    #ifndef kDataStatisticsServiceIP
    #define kDataStatisticsServiceIP @"http://192.168.1.52:8484/data-web/gps/collector"
    #endif

    // 外卖服务器
    #ifndef kTakeoutServerIP
    #define kTakeoutServerIP @"http://test.maimairen.net/provider" //@"http://192.168.1.15:8185/provider"
    #endif

    // 民行支付接口
    #ifndef kCMBCPayServiceURL
    #define kCMBCPayServiceURL @"http://192.168.1.80:9380/finance"
    #endif

    // 查询民生支付开通状态
    #ifndef kCMBCQueryBindServiceURL
    #define kCMBCQueryBindServiceURL @"http://192.168.1.80:8080/provide/bind/get"
    #endif

    // 查询民生支付开户
    #ifndef kCMBCOpenAccountServiceURL
    #define kCMBCOpenAccountServiceURL @"http://192.168.1.80:9380/finance/cmbc/regist.jsp"
    #endif

#endif


#endif /* JCHSyncServerSettings_h */
