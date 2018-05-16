//
//  AppDelegate+JCHAppDelegate.m
//  jinchuhuo
//
//  Created by huangxu on 16/4/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "AppDelegate+JCHAppDelegate.h"
#import "JCHShopInfoViewController.h"
#import "JCHShopSelectViewController.h"
#import "JCHShopManageViewController.h"
#import "JCHManifestViewController.h"
#import "JCHInventoryViewController.h"
#import "JCHGuideFirstViewController.h"
#import "JCHGuideThirdViewController.h"
#import "JCHSettlementManager.h"
#import "CommonHeader.h"
#import "MiPushSDK.h"

//! @brief 自动同步PUSH时间间隔(以秒计算)
#ifndef kJCHAutoDataSyncPushTimeInterval
#define kJCHAutoDataSyncPushTimeInterval (3000)
#endif

//! @brief 自动同步PULL时间间隔(以秒计算)
#ifndef kJCHAutoDataSyncPullTimeInterval
#define kJCHAutoDataSyncPullTimeInterval (3000)
#endif


static NSInteger g_autoSyncPushInterval = kJCHAutoDataSyncPushTimeInterval;
static NSInteger g_autoSyncPullInterval = kJCHAutoDataSyncPullTimeInterval;
static NSTimer *g_autoSyncPushTimer = nil;
static NSTimer *g_autoSyncPullTimer = nil;


@implementation AppDelegate (JCHAppDelegate)

- (void)switchToHomePage:(UIViewController *)currentViewController completion:(void(^)(void))completion
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    NSArray *accountBookList = [ServiceFactory getAllAccountBookList:statusManager.userID];
    
    //当没有账本，或者只有一个账本并且该账本类型为默认店铺类型时，进行角色引导
    if (accountBookList.count == 0 || (accountBookList.count == 1 && [[((BookInfoRecord4Cocoa *)accountBookList[0]) bookType] isEqualToString:kJCHDefaultShopType])) {
        
        //将登录状态设置为NO，以防在角色引导界面将app关闭，下次进入app后店铺显示异常的情况
        statusManager.isLogin = NO;
        [JCHSyncStatusManager writeToFile];
        
        if (currentViewController.presentingViewController.presentingViewController) {
            [currentViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
        } else {
            [currentViewController dismissViewControllerAnimated:NO completion:nil];
        }

#if MMR_TAKEOUT_VERSION
        JCHGuideThirdViewController *guide = [[[JCHGuideThirdViewController alloc] initWithBookType:@""] autorelease];
#else
        //强注册登录用户的引导页
        JCHGuideFirstViewController *guide = [[[JCHGuideFirstViewController alloc] init] autorelease];
        guide.addedServiceFlag = NO;
#endif
        
        UINavigationController *rootNav = self.rootNavigationController;
        UITabBarController *tabBarController = rootNav.viewControllers[0];
        [self.homePageController.navigationController popToRootViewControllerAnimated:NO];
        [rootNav setViewControllers:@[tabBarController] animated:NO];
        [rootNav setViewControllers:@[tabBarController, guide] animated:YES];
    } else {
        
        //找到不是默认类型并且店铺状态未被禁用的店铺
        NSMutableArray *accountBookListWithOutDefaultAccountBookType = [NSMutableArray array];
        for (BookInfoRecord4Cocoa *bookInfoRecord in accountBookList) {
            if (![bookInfoRecord.bookType isEqualToString:kJCHDefaultShopType] && bookInfoRecord.bookStatus == 0) {
                [accountBookListWithOutDefaultAccountBookType addObject:bookInfoRecord];
            }
        }
        
        //如果只有一个符合条件的，直接进入该店
        if (accountBookListWithOutDefaultAccountBookType.count == 1) {
            
            //切到该店
            BookInfoRecord4Cocoa *bookInfoRecord = [accountBookListWithOutDefaultAccountBookType firstObject];
            [self switchToSelectedAccountBook:bookInfoRecord.bookID
                        currentViewController:currentViewController
                                   completion:nil];
        } else {
            
            //如果有自己的店则进入该店
            BookInfoRecord4Cocoa *selectedBookInfoRecord = nil;
            for (BookInfoRecord4Cocoa *bookInfoRecord in accountBookListWithOutDefaultAccountBookType) {
                BOOL isShopManager = [ServiceFactory isShopManager:statusManager.userID
                                                     accountBookID:bookInfoRecord.bookID];
                if (isShopManager) {
                    selectedBookInfoRecord = bookInfoRecord;
                    break;
                }
            }
            
            if (selectedBookInfoRecord) {
                [self switchToSelectedAccountBook:selectedBookInfoRecord.bookID
                            currentViewController:currentViewController
                                       completion:nil];
            } else {
                
                //进入店铺选择列表
                BOOL showBackButton = YES;
                
                //如果是从退出店铺来的，则店铺选择页面不显示返回按钮
                if ([currentViewController isKindOfClass:[JCHShopInfoViewController class]]) {
                    showBackButton = NO;
                    completion = nil;
                }
                JCHShopSelectViewController *shopSelectViewController = [[[JCHShopSelectViewController alloc] initWithBackButton:showBackButton] autorelease];
                [currentViewController.navigationController pushViewController:shopSelectViewController animated:YES];
            }
        }
    }
    
    if (completion) {
        completion();
    }
}


- (void)switchToSelectedAccountBook:(NSString *)selectedAccountBookID
              currentViewController:(UIViewController *)currentViewController
                         completion:(void(^)(void))completion
{
    // 选中账本
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    statusManager.accountBookID = selectedAccountBookID;
    statusManager.isLogin = YES;
    // 切换账本
    // 更行重新初始化操作
    NSString *accountBookID = statusManager.accountBookID;
    NSString *userID = statusManager.userID;
    NSString *databasePath = [ServiceFactory getAccountBookDatabasePath:userID accountBookID:accountBookID];
    [ServiceFactory initializeServiceFactory:databasePath userID:userID appType:JCH_BOOK_TYPE];
    
    if (completion) {
        completion();
    }
    
    //判断当前用户是否为选择的这个账本的店长
    statusManager.isShopManager = [ServiceFactory isShopManager:statusManager.userID
                                                  accountBookID:selectedAccountBookID];
    
    //账本切换成功可以触发自动同步
    statusManager.enableAutoSync = YES;
    
    
    id<PermissionService> permissionService = [[ServiceFactory sharedInstance] permissionService];
    RoleRecord4Cocoa *roleRecord =  [permissionService queryRoleWithByUserID:statusManager.userID];
    statusManager.roleRecord = roleRecord;
    statusManager.hasUserLoginOnThisDevice = YES;
    [JCHSyncStatusManager writeToFile];
    
    // 如果需要进行锁库升级，则将数据库升级逻辑放到Homepage中的在线升级逻辑中完成
    if (NO == [[[ServiceFactory sharedInstance] databaseUpgradeService] isNeedLockToUpgrade]) {
        [self upgradeDatabaseIfNeed];
    } else {
        // 标记当前账本需要在线升级
        id<DatabaseUpgradeService> upgradeService = [[ServiceFactory sharedInstance] databaseUpgradeService];
        NSInteger currentDatabaseVersion = [upgradeService getCurrentDatabaseVersion];
        NSMutableDictionary *upgradeList = [NSMutableDictionary dictionaryWithDictionary:statusManager.upgradeAccountBooks];
        [upgradeList setObject:@(currentDatabaseVersion) forKey:accountBookID];
        statusManager.upgradeAccountBooks = upgradeList;
        [JCHSyncStatusManager writeToFile];
    }
    
    if (currentViewController.presentingViewController.presentingViewController) {
        [currentViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
    } else {
        [currentViewController dismissViewControllerAnimated:NO completion:nil];
    }
    
    if (statusManager.isShopManager) {
        //店长
        UINavigationController *rootNav = self.rootNavigationController;
        rootNav.navigationBarHidden = YES;
        UITabBarController *tabBarController = rootNav.viewControllers[0];
        tabBarController.selectedIndex = 0;
        [rootNav setViewControllers:@[tabBarController] animated:NO];
        
        UINavigationController *homePageNav = self.homePageController.navigationController;
        [homePageNav popToRootViewControllerAnimated:NO];
        [homePageNav setViewControllers:@[self.homePageController] animated:NO];
    } else {
        
        //店员
        UINavigationController *rootNav = self.rootNavigationController;
        UITabBarController *tabBarController = rootNav.viewControllers[0];
        [rootNav setViewControllers:@[tabBarController, self.shopAssistantHomepageViewController] animated:YES];
    }
    
#if MMR_TAKEOUT_VERSION
    // 不管店长还是店员，设置推送账号
    [MiPushSDK setAccount:statusManager.accountBookID];
#endif
    
#if MMR_BASE_VERSION
    // 切换到指定账本后，查询当前账本的民生支付通道开通状态
    JCHSettlementManager *settlementManager = [JCHSettlementManager sharedInstance];
    [settlementManager querySettlementMethodStatus:^(NSInteger enableMerchant, NSInteger enableAlipay, NSInteger enableWeiXin, NSString *bindID) {
        [settlementManager setBindID:bindID];
    } failureHandler:^{
        NSLog(@"查询支付通道开通状态失败");
    }];
#endif
    
    
    return;
}


//! @brief 清除tabbar上每个页面的数据
- (void)clearDataOnTabbar
{
    NSLog(@"clear data on tabbar!");
    UINavigationController *nav = self.rootNavigationController;
    UITabBarController *tabBarController = [nav.viewControllers firstObject];
    NSArray *viewControllers = tabBarController.viewControllers;
    for (UINavigationController *navigationController in viewControllers) {
        
        UIViewController *viewController = [navigationController.viewControllers firstObject];
        if ([viewController respondsToSelector:@selector(clearData)]) {
            [viewController performSelector:@selector(clearData) withObject:nil];
        }
    }
    
    UITabBarItem *tabBarItem = [tabBarController.tabBar.items firstObject];
    tabBarItem.badgeValue = nil;
}

- (void)startAutoSyncTimer
{
#if 0
    [self createAutoDataSyncPushTimer];
    [self createAutoDataSyncPullTimer];
#endif
    return;
}

- (void)stopAutoSyncTimer
{
    [g_autoSyncPushTimer invalidate];
    g_autoSyncPushTimer = nil;
    
    [g_autoSyncPullTimer invalidate];
    g_autoSyncPullTimer = nil;
    
    return;
}

- (void)createAutoDataSyncPushTimer
{
    g_autoSyncPushTimer = [NSTimer scheduledTimerWithTimeInterval:g_autoSyncPushInterval
                                                           target:self.homePageController
                                                         selector:@selector(doAutoDataSyncPush)
                                                         userInfo:nil
                                                          repeats:YES];
    return;
}

- (void)createAutoDataSyncPullTimer
{
    g_autoSyncPullTimer = [NSTimer scheduledTimerWithTimeInterval:g_autoSyncPullInterval
                                                           target:self.homePageController
                                                         selector:@selector(doAutoDataSyncPull)
                                                         userInfo:nil
                                                          repeats:YES];
    return;
}

#pragma mark -
#pragma mark property
- (NSInteger)autoSyncPushInterval
{
    return g_autoSyncPushInterval;
}

- (void)setAutoSyncPushInterval:(NSInteger)interval
{
    if (interval < kJCHAutoDataSyncPushTimeInterval) {
        g_autoSyncPushInterval = kJCHAutoDataSyncPushTimeInterval;
    } else {
        g_autoSyncPushInterval = interval;
    }
    
    [g_autoSyncPushTimer invalidate];
    g_autoSyncPushTimer = nil;
    [self createAutoDataSyncPushTimer];
}

- (NSInteger)autoSyncPullInterval
{
    return g_autoSyncPullInterval;
}

- (void)setAutoSyncPullInterval:(NSInteger)interval
{
    if (interval < kJCHAutoDataSyncPullTimeInterval) {
        g_autoSyncPullInterval = kJCHAutoDataSyncPullTimeInterval;
    } else {
        g_autoSyncPullInterval = interval;
    }
    
    [g_autoSyncPullTimer invalidate];
    g_autoSyncPullTimer = nil;
    [self createAutoDataSyncPullTimer];
}

@end
