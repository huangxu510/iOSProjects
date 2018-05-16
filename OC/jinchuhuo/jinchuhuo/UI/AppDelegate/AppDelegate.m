//
//  AppDelegate.m
//  jinchuhuo
//
//  Created by apple on 15/8/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "JCHBluetoothManager.h"
#import "JCHEnforceLoginViewController.h"
#import "JCHShopAssistantHomepageViewController.h"
#import "JCHPinCodeIdentifyView.h"
#import "JCHGuideFirstViewController.h"
#import "JCHManifestViewController.h"
#import "JCHHomepageViewController.h"
#import "JCHInventoryViewController.h"
#import "JCHRadarAnalyseViewController.h"
#import "JCHShopManageViewController.h"
#import "JCHRestaurantShopManageViewController.h"
#import "JCHPinCodeViewController.h"
#import "JCHUISettings.h"
#import "JCHColorSettings.h"
#import "JCHFontSettings.h"
#import "JCHSizeUtility.h"
#import "ServiceFactory.h"
#import "JCHLocationManager.h"
#import "JCHUserInfoHelper.h"
#import "UIImage+JCHImage.h"
#import "AFNetworking.h"
#import "JCHSyncStatusManager.h"
#import "JCHSyncServerSettings.h"
#import "JCHServiceResponseSettings.h"
#import "JCHServiceResponseNotification.h"
#import "RoleRecord4Cocoa+Serialize.h"
#import "CommonHeader.h"
#import "JCHBluetoothManager.h"
#import <IQKeyboardManager.h>
#import <SSKeychain.h>
#import "MiPushSDK.h"
#import "JCHAccountBookViewController.h"
#import "JCHTakeoutShopManageViewController.h"



static const NSString *kSQLiteDatabaseName = @"mmr.sqlite";
static NSString *kSyncPrivateCloudName = @"maimairen";
static NSString *kSyncPublicCloudName = @"public";
static NSString *kDefaultSyncNodeName = @"";

@interface AppDelegate () <UINavigationControllerDelegate, MiPushSDKDelegate, UNUserNotificationCenterDelegate>

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 取消iCloud对Document、Library、Cache目录数据的自动备份
    [self setUpSkipBackupAttribute];
    
    // 创建UUID
    [self createDeviceUUID];
    
    // 注册服务响应通知处理
    [self registerResponseNotificationHandler];
    
    // 申请位置权限
    [JCHLocationManager shareInstance];
    
    // 创建同步相关目录
    [ServiceFactory createDataSyncDirectoryStructure];
    
    // 拷贝数据库
    [self copyDatabaseIfNeed];
    
    //获取identifierForVendor并且写入keychain
    [self writeIdentifierForVendorToKeychain];
    
    // 初始化服务
    int initializeStatus = [self initializeCoreBusiness];
    if (0 != initializeStatus) {
        initializeStatus = [self initializeCoreBusinessWhenFailed];
        if (0 != initializeStatus) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                 message:@"数据库初始化失败，请联系客服咨询"
                                                                delegate:nil
                                                       cancelButtonTitle:@"我知道了"
                                                       otherButtonTitles:nil] autorelease];
            [alertView show];
            
            return YES;
        }
    }
    
    // 升级数据库
    [self upgradeDatabaseIfNeed];
    
    //修复权限关系
    [JCHRepairDataUtility checkAndRepairPermission];
    
    // 设置UI风格
    [self setUIStyle];
    
    //检查并尝试创建存储图片文件夹
    [self createImageDirectory];
    
    //判断是否首次进入app
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isNotFirst = [userDefaults boolForKey:@"isNotFirst"];
    //isNotFirst = YES;
    //首次进入app
    if (!isNotFirst)
    {
        [userDefaults setBool:YES forKey:@"isNotFirst"];
    }
    
    
    // 创建UI视图
#if MMR_RESTAURANT_VERSION
    // 餐饮版
    UITabBarController *rootTabController = [self createRestaurantHomepageTabController];
#elif MMR_TAKEOUT_VERSION
    // 外卖版
    UITabBarController *rootTabController = [self createTakeoutHomepageTabController];
#else
    // 通用版
    UITabBarController *rootTabController = [self createHomepageTabController];
#endif
    
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:rootTabController] autorelease];
    self.rootNavigationController = navigationController;
    
    JCHShopAssistantHomepageViewController *shopAssistantViewController = [[[JCHShopAssistantHomepageViewController alloc] init] autorelease];
    self.shopAssistantHomepageViewController = shopAssistantViewController;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (statusManager.isLogin && ![statusManager.accountBookID isEmptyString]) {
        //如果只有一个账本并且账本类型为默认类型，则继续角色引导
        NSArray *accountBookList = [ServiceFactory getAllAccountBookList:statusManager.userID];
        if (accountBookList.count == 1 && [[((BookInfoRecord4Cocoa *)accountBookList[0]) bookType] isEqualToString:kJCHDefaultShopType]) {
            JCHGuideFirstViewController *guide = [[[JCHGuideFirstViewController alloc] init] autorelease];
            [navigationController pushViewController:guide animated:NO];
        } else {
            //登录 店员
            if (!statusManager.isShopManager) {
                [navigationController pushViewController:shopAssistantViewController animated:NO];
            }
        }
        
        // 自动连接上次的设备
        [[JCHBluetoothManager shareInstance] autoConnectLastPeripheral];
    } else {
        //未登录
        JCHEnforceLoginViewController *enforceLoginViewController = [[[JCHEnforceLoginViewController alloc] init] autorelease];
        [navigationController pushViewController:enforceLoginViewController animated:NO];
    }
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    //删除无效图片
    [self deleteInvalidImage];
    
    //! @brief 创建自动同步定时器
    [self startAutoSyncTimer];
    
    //安全验证
    [self identifySecurityCode];
    
#if MMR_TAKEOUT_VERSION
    // 配置推送信息
    [self setupMiPush:launchOptions];
#endif
    
    return YES;
}

//删除无效图片
- (void)deleteInvalidImage
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *imageDirectory = [documentsDirectory stringByAppendingPathComponent:@"images"];
    NSArray *images = [fileManager contentsOfDirectoryAtPath:imageDirectory error:nil];
    
    
    for (NSString *imageName in images) {
        NSString *imagePath = [imageDirectory stringByAppendingPathComponent:imageName];
        UIImage *image = [UIImage imageNamed:imagePath];
        if (image == nil) {
            NSError *error = nil;
            NSLog(@"%@", imageName);
            [fileManager removeItemAtPath:imagePath error:&error];
            NSLog(@"error = %@", error);
        }
    }
}

- (void)setUpSkipBackupAttribute
{
    NSURL *documentURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                 inDomains:NSUserDomainMask] firstObject];
    //NSLog(@"[Value For NSURLIsExcludedFromBackupKey]--[%@]",[documentURL resourceValuesForKeys:@[NSURLIsExcludedFromBackupKey]error:nil]);
    [self addSkipBackupAttributeToItemAtURL:documentURL];
    
    
    NSURL *libiraryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory
                                                                 inDomains:NSUserDomainMask] firstObject];
    [self addSkipBackupAttributeToItemAtURL:libiraryURL];
    
    NSURL *cachesURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory
                                                               inDomains:NSUserDomainMask] firstObject];
    [self addSkipBackupAttributeToItemAtURL:cachesURL];
}

//标记目录不被iCloud备份
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //通过UIBackgroundTaskIdentifier可以实现有限时间内在后台运行程序
    self.backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundTask];
    }];
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (statusManager.isLogin) {
        // 1) 显示密码保护界面
        JCHUserInfoHelper *userInfoHelper = [JCHUserInfoHelper shareHelper];
        NSDictionary *securityCodeForUserID = [userInfoHelper getsecurityCodeForUserID];
        NSDictionary *securityCodeDict = securityCodeForUserID[statusManager.userID];
        
        if ([[securityCodeDict objectForKey:kSecurityCodeStatus] boolValue]) {
            
            JCHPinCodeIdentifyView *identifyView = [[[JCHPinCodeIdentifyView alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
            
            UIWindow *keyWindow = [UIApplication sharedApplication].windows[0];
            [keyWindow addSubview:identifyView];
        }
        //TODO: 4.0.0 在线升级和后台同步有冲突，关闭该功能
#if 0
        // 2) 进行PUSH操作
        JCHDataSyncManager *dataSyncManager = [JCHDataSyncManager shareInstance];
        [dataSyncManager doSyncPushCommand:^(NSInteger pushFlag, NSInteger pullFlag, NSDictionary *responseData) {
            
            NSLog(@"Push success in background!");
        } failure:^(NSInteger responseCode, NSError *error) {
            
            NSLog(@"Push fail in background!");
        }];
        
        // 3) 图片同步
        [dataSyncManager doSyncImageFiles:statusManager.imageInterHostIP];
#endif
    }
    
    
#if 0
    // 4) 在测试模式下，生成代码覆盖率文件
#if BUILD_FOR_CODE_COVERAGE
    
#if TARGET_OS_SIMULATOR
    extern void __gcov_flush(void);
    __gcov_flush();
#endif
    
#endif
    
#endif
    
    
    return;
}

- (void)endBackgroundTask
{
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    //当应用回到前台，如果我们的后台任务还在执行中，要停止该任务
    if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
        [self endBackgroundTask];
    }
    
    [JCHNotificationCenter postNotificationName:kJCHApplicationWillEnterForeground object:[UIApplication sharedApplication] userInfo:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // 注销服务响应通知处理
    [self unregisterResponseNotificationHandler];
}

- (void)identifySecurityCode
{
    //安全验证
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    JCHUserInfoHelper *userInfoHelper = [JCHUserInfoHelper shareHelper];
    NSDictionary *securityCodeForUserID = [userInfoHelper getsecurityCodeForUserID];
    NSDictionary *securityCodeDict = securityCodeForUserID[statusManager.userID];
    
    
    if ([[securityCodeDict objectForKey:kSecurityCodeStatus] boolValue]) {
        JCHPinCodeIdentifyView *identifyView = [[[JCHPinCodeIdentifyView alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
        
        [self.window addSubview:identifyView];
    }
}

- (void)setUIStyle
{
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName : [UIFont boldSystemFontOfSize:18]}];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:JCHColorHeaderBackground];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //导航栏透明、去掉导航栏的黑线
    [[UINavigationBar appearance] setBackgroundImage:[[[UIImage alloc] init] autorelease] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[[UIImage alloc] init] autorelease]];
    
    if([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        [[UINavigationBar appearance] setTranslucent:NO];
    }
    
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager];
    keyboardManager.enableAutoToolbar = NO;
}
/**
 *  创建内置数据图片路径
 */
- (void)createImageDirectory
{
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *imageDirectory = [document stringByAppendingString:@"/images"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL isDirectoryExist = [fileManager fileExistsAtPath:imageDirectory isDirectory:&isDirectory];
    if(NO == isDirectory && NO == isDirectoryExist)
    {
        [fileManager createDirectoryAtPath:imageDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
}

- (void)writeIdentifierForVendorToKeychain
{
    //获取identifierForVendor并且写入keychain
    NSString *identifierForVendor = [SSKeychain passwordForService:kIdentifierForVendorService
                                                           account:kIdentifierForVendorAccount];
    if (identifierForVendor == nil) {
        NSString *identifierForVendor = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SSKeychain setPassword:identifierForVendor forService:kIdentifierForVendorService account:kIdentifierForVendorAccount];
    }
}

+ (AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UITabBarController *)createHomepageTabController
{
    // 生成TabBarController
    JCHHomepageViewController *homepageController = [[[JCHHomepageViewController alloc] init] autorelease];
    self.homePageController = homepageController;
    UINavigationController *homePageNavigateController = [[[UINavigationController alloc] initWithRootViewController:homepageController] autorelease];
    
    self.switchToTargetController = homepageController;

    JCHManifestViewController *manifestController = [[[JCHManifestViewController alloc] init] autorelease];
    UINavigationController *manifestNavigateController = [[[UINavigationController alloc] initWithRootViewController:manifestController] autorelease];
    
    JCHInventoryViewController *inventoryController = [[[JCHInventoryViewController alloc] init] autorelease];
    UINavigationController *inventoryNavigateController = [[[UINavigationController alloc] initWithRootViewController:inventoryController] autorelease];
    
    //JCHAnalyseViewController *analyseController = [[[JCHAnalyseViewController alloc] init] autorelease];
    JCHRadarAnalyseViewController *analyseController = [[[JCHRadarAnalyseViewController alloc] init] autorelease];
    UINavigationController *analyseNavigateController = [[[UINavigationController alloc] initWithRootViewController:analyseController] autorelease];
    
    JCHShopManageViewController *myController = [[[JCHShopManageViewController alloc] init] autorelease];
    UINavigationController *myNavigateController = [[[UINavigationController alloc] initWithRootViewController:myController] autorelease];
    
    UITabBarController *tabController = [[[UITabBarController alloc] init] autorelease];
    tabController.viewControllers = @[homePageNavigateController,
                                      manifestNavigateController,
                                      inventoryNavigateController,
                                      analyseNavigateController,
                                      myNavigateController];
    
    // 设置底部TabBar
    UITabBarItem *homepageItem = [[[UITabBarItem alloc] initWithTitle:@"首页"
                                                                image:[[UIImage imageNamed:@"nav_1_home_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                        selectedImage:[[UIImage imageNamed:@"nav_1_home_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]] autorelease];
    
    UITabBarItem *manifestItem = [[[UITabBarItem alloc] initWithTitle:@"货单"
                                                                image:[[UIImage imageNamed:@"nav_2_manifest_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                        selectedImage:[[UIImage imageNamed:@"nav_2_manifest_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]] autorelease];
    UITabBarItem *inventoryItem = [[[UITabBarItem alloc] initWithTitle:@"仓库"
                                                                 image:[[UIImage imageNamed:@"nav_3_inventory_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                         selectedImage:[[UIImage imageNamed:@"nav_3_inventory_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]] autorelease];
    UITabBarItem *analyseItem = [[[UITabBarItem alloc] initWithTitle:@"分析"
                                                               image:[[UIImage imageNamed:@"nav_4_analysis_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                       selectedImage:[[UIImage imageNamed:@"nav_4_analysis_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]] autorelease];
    UITabBarItem *myItem = [[[UITabBarItem alloc] initWithTitle:@"管店"
                                                          image:[[UIImage imageNamed:@"nav_5_store_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                  selectedImage:[[UIImage imageNamed:@"nav_5_store_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]] autorelease];
    //调整tabbai文字位置
    CGFloat offsetY = -2;
    
    [homepageItem setTitlePositionAdjustment:UIOffsetMake(0, offsetY)];
    [manifestItem setTitlePositionAdjustment:UIOffsetMake(0, offsetY)];
    [inventoryItem setTitlePositionAdjustment:UIOffsetMake(0, offsetY)];
    [analyseItem setTitlePositionAdjustment:UIOffsetMake(0, offsetY)];
    [myItem setTitlePositionAdjustment:UIOffsetMake(0, offsetY)];
    
    homepageController.tabBarItem = homepageItem;
    manifestController.tabBarItem = manifestItem;
    inventoryController.tabBarItem = inventoryItem;
    analyseController.tabBarItem = analyseItem;
    myController.tabBarItem = myItem;
    
    // 调整TabBar UI风格
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x808080)} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : JCHColorHeaderBackground} forState:UIControlStateSelected];
    
    return tabController;
}

- (UITabBarController *)createRestaurantHomepageTabController
{
    // 生成TabBarController
    JCHHomepageViewController *homepageController = [[[JCHHomepageViewController alloc] init] autorelease];
    self.homePageController = homepageController;
    UINavigationController *homePageNavigateController = [[[UINavigationController alloc] initWithRootViewController:homepageController] autorelease];
    
    self.switchToTargetController = homepageController;
    
    JCHManifestViewController *manifestController = [[[JCHManifestViewController alloc] init] autorelease];
    UINavigationController *manifestNavigateController = [[[UINavigationController alloc] initWithRootViewController:manifestController] autorelease];
    
    JCHAccountBookViewController *accountBookController = [[[JCHAccountBookViewController alloc] init] autorelease];
    UINavigationController *accountBookNavigateController = [[[UINavigationController alloc] initWithRootViewController:accountBookController] autorelease];
    
    JCHRestaurantShopManageViewController *myController = [[[JCHRestaurantShopManageViewController alloc] init] autorelease];
    UINavigationController *myNavigateController = [[[UINavigationController alloc] initWithRootViewController:myController] autorelease];
    
    UITabBarController *tabController = [[[UITabBarController alloc] init] autorelease];
    tabController.viewControllers = @[homePageNavigateController,
                                      manifestNavigateController,
                                      accountBookNavigateController,
                                      myNavigateController];
    
    // 设置底部TabBar
    UITabBarItem *homepageItem = [[[UITabBarItem alloc] initWithTitle:@"首页"
                                                                image:[[UIImage imageNamed:@"nav_1_home_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                        selectedImage:[[UIImage imageNamed:@"nav_1_home_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]] autorelease];
    
    UITabBarItem *manifestItem = [[[UITabBarItem alloc] initWithTitle:@"货单"
                                                                image:[[UIImage imageNamed:@"nav_2_manifest_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                        selectedImage:[[UIImage imageNamed:@"nav_2_manifest_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]] autorelease];
    UITabBarItem *accountBookItem = [[[UITabBarItem alloc] initWithTitle:@"账本"
                                                                   image:[[UIImage imageNamed:@"nav_3_account_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                           selectedImage:[[UIImage imageNamed:@"nav_3_account_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]] autorelease];
    UITabBarItem *myItem = [[[UITabBarItem alloc] initWithTitle:@"管店"
                                                          image:[[UIImage imageNamed:@"nav_5_store_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                  selectedImage:[[UIImage imageNamed:@"nav_5_store_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]] autorelease];
    //调整tabbai文字位置
    CGFloat offsetY = -2;
    [homepageItem setTitlePositionAdjustment:UIOffsetMake(0, offsetY)];
    [manifestItem setTitlePositionAdjustment:UIOffsetMake(0, offsetY)];
    [accountBookItem setTitlePositionAdjustment:UIOffsetMake(0, offsetY)];
    [myItem setTitlePositionAdjustment:UIOffsetMake(0, offsetY)];
    
    homepageController.tabBarItem = homepageItem;
    manifestController.tabBarItem = manifestItem;
    accountBookController.tabBarItem = accountBookItem;
    myController.tabBarItem = myItem;
    
    // 调整TabBar UI风格
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x808080)} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : JCHColorHeaderBackground} forState:UIControlStateSelected];
    
    return tabController;
}

- (UITabBarController *)createTakeoutHomepageTabController
{
    // 生成TabBarController
    JCHHomepageViewController *homepageController = [[[JCHHomepageViewController alloc] init] autorelease];
    self.homePageController = homepageController;
    UINavigationController *homePageNavigateController = [[[UINavigationController alloc] initWithRootViewController:homepageController] autorelease];
    
    self.switchToTargetController = homepageController;
    
    JCHManifestViewController *manifestController = [[[JCHManifestViewController alloc] init] autorelease];

    
    UINavigationController *manifestNavigateController = [[[UINavigationController alloc] initWithRootViewController:manifestController] autorelease];
    
    JCHAccountBookViewController *accountBookController = [[[JCHAccountBookViewController alloc] init] autorelease];
    UINavigationController *accountBookNavigateController = [[[UINavigationController alloc] initWithRootViewController:accountBookController] autorelease];
    
    JCHTakeoutShopManageViewController *myController = [[[JCHTakeoutShopManageViewController alloc] init] autorelease];
    UINavigationController *myNavigateController = [[[UINavigationController alloc] initWithRootViewController:myController] autorelease];
    
    UITabBarController *tabController = [[[UITabBarController alloc] init] autorelease];
    tabController.viewControllers = @[homePageNavigateController,
                                      manifestNavigateController,
                                      accountBookNavigateController,
                                      myNavigateController];
    
    // 设置底部TabBar
    UITabBarItem *homepageItem = [[[UITabBarItem alloc] initWithTitle:@"首页"
                                                                image:[[UIImage imageNamed:@"nav_1_home_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                        selectedImage:[[UIImage imageNamed:@"nav_1_home_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]] autorelease];
    
    UITabBarItem *manifestItem = [[[UITabBarItem alloc] initWithTitle:@"货单"
                                                                image:[[UIImage imageNamed:@"nav_2_manifest_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                        selectedImage:[[UIImage imageNamed:@"nav_2_manifest_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]] autorelease];
    UITabBarItem *accountBookItem = [[[UITabBarItem alloc] initWithTitle:@"账本"
                                                                   image:[[UIImage imageNamed:@"nav_3_account_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                           selectedImage:[[UIImage imageNamed:@"nav_3_account_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]] autorelease];
    UITabBarItem *myItem = [[[UITabBarItem alloc] initWithTitle:@"管店"
                                                          image:[[UIImage imageNamed:@"nav_5_store_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                  selectedImage:[[UIImage imageNamed:@"nav_5_store_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]] autorelease];
    //调整tabbai文字位置
    CGFloat offsetY = -2;
    [homepageItem setTitlePositionAdjustment:UIOffsetMake(0, offsetY)];
    [manifestItem setTitlePositionAdjustment:UIOffsetMake(0, offsetY)];
    [accountBookItem setTitlePositionAdjustment:UIOffsetMake(0, offsetY)];
    [myItem setTitlePositionAdjustment:UIOffsetMake(0, offsetY)];
    
    homepageController.tabBarItem = homepageItem;
    manifestController.tabBarItem = manifestItem;
    accountBookController.tabBarItem = accountBookItem;
    myController.tabBarItem = myItem;
    
    // 调整TabBar UI风格
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x808080)} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : JCHColorHeaderBackground} forState:UIControlStateSelected];
    
    return tabController;
}


#pragma mark -
#pragma mark 获取默认本地数据库路径，位于APP Document目录中
+ (NSString *)getOldVersionDatabasePath
{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,
                                                             YES);
    
    NSString *directoryPath = [pathArray objectAtIndex:0];
    NSString *targetDatabasePath = [NSString stringWithFormat:@"%@/%@", directoryPath, kSQLiteDatabaseName];
    
    return targetDatabasePath;
}

#pragma mark -
#pragma mark 初始化底层业务库
- (int)initializeCoreBusiness
{
    NSString *targetDatabasePath = [AppDelegate getDatabasePath];
    NSString *userID = [self generateRandomUserID];
    int status = [ServiceFactory initializeServiceFactory:targetDatabasePath userID:userID appType:JCH_BOOK_TYPE];
    if (0 != status) {
        NSLog(@"initialize database: %@ fail, errno: %d", targetDatabasePath, status);
        return status;
    }
    
    // 当前账本用户作为第一个用户，作为店长角色
    id<PermissionService> permissionService = [[ServiceFactory sharedInstance] permissionService];
    NSString *shopManagerRoleUUID = [permissionService getShopManagerUUID];
    
    // 对于自己创建的店铺，如果店铺成员为空，默认将自己做为店长添加到店铺成员中
    id <BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
    NSArray *bookMemberArray = [bookMemberService queryBookMember];
    if (bookMemberArray.count == 0) {
        JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
        statusManager.roleRecord = [RoleRecord4Cocoa createShopManagerRoleRecord:shopManagerRoleUUID];
        [JCHSyncStatusManager writeToFile];
    }
    
    
    
    NSLog(@"database: %@", targetDatabasePath);
    
    return status;
}

#pragma mark -
#pragma mark 初始化底层业务库
- (int)initializeCoreBusinessWhenFailed
{
    NSString *targetDatabasePath = [ServiceFactory getDefaultDatabasePath];
    NSString *userID = [self generateRandomUserID];
    int status = [ServiceFactory initializeServiceFactory:targetDatabasePath userID:userID appType:JCH_BOOK_TYPE];
    if (0 != status) {
        NSLog(@"initialize database: %@ fail, errno: %d", targetDatabasePath, status);
        return status;
    }
    
    // 当前账本用户作为第一个用户，作为店长角色
    id<PermissionService> permissionService = [[ServiceFactory sharedInstance] permissionService];
    NSString *shopManagerRoleUUID = [permissionService getShopManagerUUID];
    
    // 对于自己创建的店铺，如果店铺成员为空，默认将自己做为店长添加到店铺成员中
    id <BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
    NSArray *bookMemberArray = [bookMemberService queryBookMember];
    if (bookMemberArray.count == 0) {
        JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
        statusManager.roleRecord = [RoleRecord4Cocoa createShopManagerRoleRecord:shopManagerRoleUUID];
        [JCHSyncStatusManager writeToFile];
    }
    
    NSLog(@"database: %@", targetDatabasePath);
    
    return status;
}

#pragma mark -
#pragma mark 升级数据库
- (void)upgradeDatabaseIfNeed
{
    // 如果是第一次启动APP，则不需要进行在线升级
    BOOL isNeedFixupDatabase = YES;
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isNotFirst = [userDefaults boolForKey:@"isNotFirst"];
    if (YES == isNotFirst)
    {
        // 如果用户未进行注册，那么所有的升级操作都为本地操作
        BOOL hasUserRegisteredOnThisMachine = statusManager.hasUserAutoSilentRegisteredOnThisDevice;
        if (YES == hasUserRegisteredOnThisMachine) {
            // 判断当前是否需要进行在线升级，并进行标记
            id<DatabaseUpgradeService> upgradeService = [[ServiceFactory sharedInstance] databaseUpgradeService];
            BOOL isNeedUpgrade = [upgradeService isNeedUpgrade];
            if (YES == isNeedUpgrade) {
                BOOL isNeedOnlineUpgrade = [upgradeService isNeedOnlineUpgrade];
                if (YES == isNeedOnlineUpgrade) {
                    NSString *accountBookID = statusManager.accountBookID;
                    if ((nil != accountBookID) &&
                        (NO == [accountBookID isEqualToString:@""])) {
                        if (YES == statusManager.isLogin) {
                            // 标记当前账本需要在线升级
                            NSInteger currentDatabaseVersion = [upgradeService getCurrentDatabaseVersion];
                            NSMutableDictionary *upgradeList = [NSMutableDictionary dictionaryWithDictionary:statusManager.upgradeAccountBooks];
                            [upgradeList setObject:@(currentDatabaseVersion) forKey:accountBookID];
                            statusManager.upgradeAccountBooks = upgradeList;
                            [JCHSyncStatusManager writeToFile];
                            
                            isNeedFixupDatabase = NO;
                        } else {
                            isNeedFixupDatabase = NO;
                        }
                    }
                }
            }
        }
    }
    
    id<DatabaseUpgradeService> databaseUpgradeService = [[ServiceFactory sharedInstance] databaseUpgradeService];
    const NSInteger currentDatabaseVersion = [databaseUpgradeService getCurrentDatabaseVersion];
    [databaseUpgradeService upgradeDatabase];
    
    // 如果需要在线升级，当前不升级数据库数据
    if ((nil != statusManager.accountBookID) &&
        (NO == [statusManager.accountBookID isEqualToString:@""])) {
        if (YES == statusManager.isLogin) {
            NSNumber *versionNumber = [statusManager.upgradeAccountBooks objectForKey:statusManager.accountBookID];
            if (nil != versionNumber) {
                if (0 != versionNumber.integerValue) {
                    isNeedFixupDatabase = NO;
                }
            }
        }
    }
    
    if (YES == isNeedFixupDatabase) {
        [databaseUpgradeService upgradeBuiltinData:currentDatabaseVersion];
    }
    
    return;
}


- (void)registerResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(handleAutoSilentUserRegister:)
                               name:kJCHAutoSilentUserRegisterNotification
                             object:[UIApplication sharedApplication]];
    
    
    [notificationCenter addObserver:self
                           selector:@selector(handleSyncCreateCommand:)
                               name:kJCHSyncCreateCommandNotification
                             object:[UIApplication sharedApplication]];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleSyncNewCommand:)
                               name:kJCHSyncNewCommandNotification
                             object:[UIApplication sharedApplication]];
    
    return;
}

- (void)unregisterResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self
                                  name:kJCHAutoSilentUserRegisterNotification
                                object:[UIApplication sharedApplication]];
    
    [notificationCenter removeObserver:self
                                  name:kJCHSyncCreateCommandNotification
                                object:[UIApplication sharedApplication]];
    
    [notificationCenter removeObserver:self
                                  name:kJCHSyncNewCommandNotification
                                object:[UIApplication sharedApplication]];
    
    return;
}

// ===================================== 用户管理服务器 - 系统自动注册用户 ==================== //
- (void)doAutoSilentUserRegister
{
    AutoSilentRegisterUserRequest *request = [[[AutoSilentRegisterUserRequest alloc] init] autorelease];
    request.serviceURL = [NSString stringWithFormat:@"%@/terminal/join", kJCHUserManagerServerIP];
    request.deviceUUID = [[JCHSyncStatusManager shareInstance] deviceUUID];
    id<DataSyncService> syncService = [[ServiceFactory sharedInstance] dataSyncService];
    [syncService autoSilentRegister:request responseNotification:kJCHAutoSilentUserRegisterNotification];
    
    return;
}

- (void)handleAutoSilentUserRegister:(NSNotification *)notify
{
    if (NO == self.enableHandlingAutoRegisterResponse) {
        return;
    }
    
    NSDictionary *userData = notify.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        NSString *responseDescription = responseData[@"desc"];
        NSString *responseStatus = responseData[@"status"];
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
        
        if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
            //! @todo
            NSLog(@"auto register fail.");
            
            //发送通知告诉注册页面  自动注册失败
            [JCHNotificationCenter postNotificationName:kAutoRegisterFailedNotification
                                                 object:[UIApplication sharedApplication]
                                               userInfo:@{@"responseCode" : @(responseCode)}];
            return;
        } else {
            NSDictionary *serviceResponse = responseData[@"data"];
            NSString *userID = [NSString stringWithFormat:@"%@", serviceResponse[@"id"]];
            NSString *token = serviceResponse[@"token"];
            
            AutoSilentRegisterUserResponse *response = [[[AutoSilentRegisterUserResponse alloc] init] autorelease];
            response.code = responseCode;
            response.descriptionString = responseDescription;
            response.status = responseStatus;
            response.userID = userID;
            response.token = token;
            
            // 创建当前用户对应的目录并初始化数据库
            [ServiceFactory createDirectoryForUserAccount:userID];
            
            // 更新用户信息
            id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
            UserInfoRecord4Cocoa *userInfoRecord = [[[UserInfoRecord4Cocoa alloc] init] autorelease];
            userInfoRecord.userId = userID;
            [dataSyncService updateUserAccount:userInfoRecord];
            
            // 保存当前状态
            JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
            statusManager.userID = userID;
            statusManager.syncToken = token;
            [JCHSyncStatusManager writeToFile];
            
            NSLog(@"******自动注册--创建用户ID完成:%@******", userID);
            
            // 完成自动注册后，在服务器上创建一个新账本
            [self doSyncCreateCommand];
        }
    } else {
        [MBProgressHUD showNetWorkFailedHud:nil];
        NSLog(@"request fail: %@", userData[@"data"]);
    }
}

// ===================================== 同步create命令 ==================== //
- (void)doSyncCreateCommand
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    CreateAccountBookRequest *request = [[[CreateAccountBookRequest alloc] init] autorelease];
    request.serviceURL = [NSString stringWithFormat:@"%@/terminal/create", kJCHSyncManagerServerIP];
    request.deviceUUID = statusManager.deviceUUID;
    request.token = statusManager.syncToken;
    request.bookType = JCH_BOOK_TYPE;
    
    id<DataSyncService> syncService = [[ServiceFactory sharedInstance] dataSyncService];
    [syncService createAccountBook:request responseNotification:kJCHSyncCreateCommandNotification];
    
    return;
}

- (void)handleSyncCreateCommand:(NSNotification *)notify
{
    if (NO == self.enableHandlingAutoRegisterResponse) {
        return;
    }
    
    NSDictionary *userData = notify.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        NSString *responseDescription = responseData[@"desc"];
        NSString *responseStatus = responseData[@"status"];
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
        
        if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
            //! @todo
            NSLog(@"auto register fail.");
            
            //发送通知告诉引导、注册、登陆、页面  自动注册失败
            [JCHNotificationCenter postNotificationName:kAutoRegisterFailedNotification
                                                 object:[UIApplication sharedApplication]
                                               userInfo:@{@"responseCode" : @(responseCode)}];
            return;
        } else {
            NSDictionary *serviceResponse = responseData[@"data"];
            NSString *accountBookID = serviceResponse[@"id"];
            NSString *syncHost = serviceResponse[@"host"];
            
            CreateAccountBookResponse *response = [[[CreateAccountBookResponse alloc] init] autorelease];
            response.code = responseCode;
            response.descriptionString = responseDescription;
            response.status = responseStatus;
            response.syncHost = syncHost;
            response.accountBookID = accountBookID;
            
            NSLog(@"[%@, %@]", syncHost, accountBookID);
            
            // 保存当前同步状态
            JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
            statusManager.syncHost = syncHost;
            statusManager.accountBookID = accountBookID;
            [JCHSyncStatusManager writeToFile];
            
            NSLog(@"******自动注册--创建账本ID完成:%@******", accountBookID);
            
            // 进行同步 new 操作
            [self doSyncNewCommand];
        }
        
    } else {
        [MBProgressHUD showNetWorkFailedHud:nil];
        JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
        statusManager.userID = @"";
        [JCHSyncStatusManager writeToFile];
        NSLog(@"request fail: %@", userData[@"data"]);
    }
    
    return;
}


// ===================================== 同步new命令 ==================== //
- (void)doSyncNewCommand
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id<DatabaseUpgradeService> upgradeService = [[ServiceFactory sharedInstance] databaseUpgradeService];
    id<DataSyncService> syncService = [[ServiceFactory sharedInstance] dataSyncService];
    NSInteger databaseVersion = [upgradeService getCurrentDatabaseVersion];
    
    // 如果用户第一次在当前设备上注册，那么在new操作时，需要上传用户当前的数据库
    // 如果用户已在当前设备上注册/或者用户已在当前设备上注册成功，那么需要上传一个空数据库
    NSString *uploadDatabasePath = [AppDelegate getDatabasePath];
    if (YES == statusManager.hasUserLoginOnThisDevice) {
        uploadDatabasePath = [ServiceFactory createSyncConnectNewUploadDatabase:[AppDelegate getOldVersionDatabasePath]];
    }
    
    NSString *downloadDatabasePath = [ServiceFactory getAccountBookDatabasePath:statusManager.userID accountBookID:statusManager.accountBookID];
    [ServiceFactory createDirectoryForUserAccount:statusManager.userID accountBookID:statusManager.accountBookID];
    
    NewCommandRequest *request = [[[NewCommandRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.syncVersion = [NSString stringWithFormat:@"%lld", (long long)databaseVersion];
    request.token = statusManager.syncToken;
    request.accountBookID = statusManager.accountBookID;
    request.syncNode = kDefaultSyncNodeName;
    request.dataType = JCH_DATA_TYPE;
    request.organize = kJCHSyncModeRunInPublicCloud ? kSyncPublicCloudName : kSyncPrivateCloudName;
    
    
    request.uploadDatabaseFile = uploadDatabasePath;
    request.downloadDatabaseFile = downloadDatabasePath;
    request.serviceURL = statusManager.syncHost;
    
    NSLog(@"%@\n%@", uploadDatabasePath, downloadDatabasePath);
    
    [syncService newCommand:request responseNotification:kJCHSyncNewCommandNotification];
    
    return;
}

- (void)handleSyncNewCommand:(NSNotification *)notify
{
    if (NO == self.enableHandlingAutoRegisterResponse) {
        return;
    }
    
    NSDictionary *userData = notify.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        NSString *responseDescription = responseData[@"desc"];
        NSString *responseStatus = responseData[@"status"];
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
        
        if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
            //! @todo
            NSLog(@"auto register fail.");
            
            [JCHNotificationCenter postNotificationName:kAutoRegisterFailedNotification
                                                 object:[UIApplication sharedApplication]
                                               userInfo:@{@"responseCode" : @(responseCode)}];
            return;
        } else {
            JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
            NewCommandResponse *response = [[[NewCommandResponse alloc] init] autorelease];
            response.code = responseCode;
            response.descriptionString = responseDescription;
            response.status = responseStatus;
            
            NSString *accountBookID = statusManager.accountBookID;
            NSString *userID = statusManager.userID;
            
            
            // 切换账本
            // 更行重新初始化操作
            NSString *databasePath = [ServiceFactory getAccountBookDatabasePath:userID accountBookID:accountBookID];
            int iInitStatus = [ServiceFactory initializeServiceFactory:databasePath userID:userID appType:JCH_BOOK_TYPE];
            if (0 != iInitStatus) {
                NSLog(@"打开数据库失败: %@", databasePath);
                NSString *alertMessage = [NSString stringWithFormat:@"数据库初始化失败，错误码: %d，请联系客服咨询", iInitStatus];
                UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                     message:alertMessage
                                                                    delegate:nil
                                                           cancelButtonTitle:@"我知道了"
                                                           otherButtonTitles:nil] autorelease];
                [alertView show];
                return;
            }
            
            [self upgradeDatabaseIfNeed];
            
            [[[ServiceFactory sharedInstance] dataSyncService] checkMigrate];
            
            // 当前账本用户作为第一个用户，作为店长角色  checkAndRepairPermission 对于自己创建的店铺，默认将自己做为店长添加到店铺成员中
            id<PermissionService> permissionService = [[ServiceFactory sharedInstance] permissionService];
            [permissionService checkAndRepairPermission:statusManager.userID phoneNumber:statusManager.phoneNumber];
            
            
            RoleRecord4Cocoa *roleRecord = [permissionService queryRoleWithByUserID:userID];
            statusManager.roleRecord = roleRecord;
            
            //新创建的店铺类型改为默认类型
            id <BookInfoService> bookInfoService = [[ServiceFactory sharedInstance] bookInfoService];
            BookInfoRecord4Cocoa *bookInfoRecord = [bookInfoService queryBookInfo:statusManager.userID];
            bookInfoRecord.bookType = kJCHDefaultShopType;
            bookInfoRecord.bookID = accountBookID;
            [bookInfoService updateBookInfo:bookInfoRecord];
            
            // 保存当前同步状态
            statusManager.hasUserAutoSilentRegisteredOnThisDevice = YES;
            [JCHSyncStatusManager writeToFile];
            
            NSLog(@"******自动注册--上传并下载数据库成功******");
            
            // 自动注册完成
            [self postAutoRegisterComplete];
        }
    } else {
        [MBProgressHUD showNetWorkFailedHud:nil];
        JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
        statusManager.userID = @"";
        [JCHSyncStatusManager writeToFile];
        NSLog(@"request fail: %@", userData[@"data"]);
    }
}

- (void)copyDatabaseIfNeed
{
    // 为了兼容已发布版本，此处需要进行两步拷贝操作
    // 1) 检查本地数据库是否存在，如果存在，无需进行后续拷贝操作
    // AppBundle/ -> Document/
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *oldLocalDatabasePath = [AppDelegate getOldVersionDatabasePath];
    BOOL fileExisted = [[NSFileManager defaultManager] fileExistsAtPath:oldLocalDatabasePath];
    if (NO == fileExisted) {
        NSString *appPath = [[NSBundle mainBundle] resourcePath];
        NSString *sourceDatabasePath = [NSString stringWithFormat:@"%@/%@", appPath, kSQLiteDatabaseName];
        [fileManager copyItemAtPath:sourceDatabasePath
                             toPath:oldLocalDatabasePath
                              error:nil];
    }
    
    // Document/ -> Local
    NSString *currentDatabasePath = [AppDelegate getDatabasePath];
    if (FALSE == [fileManager fileExistsAtPath:currentDatabasePath]) {
        if (NO == [[JCHSyncStatusManager shareInstance] hasUserAutoSilentRegisteredOnThisDevice]) {
            [fileManager copyItemAtPath:oldLocalDatabasePath
                                 toPath:currentDatabasePath
                                  error:nil];
        }
    }
    
    return;
}

+ (NSString *)getDatabasePath
{
    NSString *targetDatabasePath = nil;
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    BOOL hasUserRegisteredOnThisMachine = statusManager.hasUserAutoSilentRegisteredOnThisDevice;
    if (NO == hasUserRegisteredOnThisMachine) {
        targetDatabasePath = [ServiceFactory getDefaultDatabasePath];
    } else {
        NSString *userID = statusManager.userID;
        NSString *accountBookID = statusManager.accountBookID;
        if ((nil == userID) ||
            ([userID isEqualToString:@""]) ||
            (nil == accountBookID) ||
            ([accountBookID isEqualToString:@""])) {
            targetDatabasePath = [ServiceFactory getDefaultDatabasePath];
        } else {
            targetDatabasePath = [ServiceFactory getAccountBookDatabasePath:userID accountBookID:accountBookID];
        }
    }
    
    return targetDatabasePath;
}

- (void)createDeviceUUID
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    NSString *oldUUID = statusManager.deviceUUID;
    if (nil == oldUUID || [oldUUID isEqualToString:@""]) {
        NSString *deviceUUID = [[NSUUID UUID] UUIDString];
        statusManager.deviceUUID = deviceUUID;
        [JCHSyncStatusManager writeToFile];
    }
    
    return;
}

- (void)postAutoRegisterComplete
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter postNotificationName:kJCHSyncAutoRegisterCompleteNotification
                                 object:[UIApplication sharedApplication]
                               userInfo:@{}];
}

- (NSString *)generateRandomUserID
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (YES == statusManager.isLogin &&
        nil != statusManager.userID &&
        (NO == [statusManager.userID isEqualToString:@""])) {
        return statusManager.userID;
    } else {
        return @"00000";
    }
}

#pragma mark - 小米推送

- (void)setupMiPush:(NSDictionary *)launchOptions
{
    // 只启动APNs
//    [MiPushSDK registerMiPush:self];
    
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable) {
            NSLog(@"没有网络");
        } else {
            // 同时启用APNs跟应用内长连接
            [MiPushSDK registerMiPush:self type:0 connect:YES];
        }
    }];
    [manager startMonitoring];
    
    
    // 处理点击通知打开app的逻辑
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        [self handlePushInfo:userInfo];
    }
}

#pragma mark - UIApplicationDelegate
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // 注册APNs成功，注册deviceToken
    [MiPushSDK bindDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    // 注册APNs失败
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError:%@", error.localizedDescription);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // 当同时启动APNs与内部长连接时, 把两处收到的消息合并. 通过miPushReceiveNotification返回
    [MiPushSDK handleReceiveRemoteNotification:userInfo];
    
    [self handlePushInfo:userInfo];
}


// iOS10新加入的回调方法
// 应用在前台收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [MiPushSDK handleReceiveRemoteNotification:userInfo];
        
        [self handlePushInfo:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionSound);
}

// 点击通知进入应用
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler
{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [MiPushSDK handleReceiveRemoteNotification:userInfo];
        
        [self handlePushInfo:userInfo];
    }
    completionHandler();
}


#pragma mark - MiPushSDKDelegate
- (void)miPushRequestSuccWithSelector:(NSString *)selector data:(NSDictionary *)data
{
    // 请求成功，可在此获取regId
    if ([selector isEqualToString:@"bindDeviceToken:"]) {
        NSLog(@"regid = %@", data[@"regid"]);
        
        
        JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
        if (statusManager.isLogin) {
            // 设置账号
            [MiPushSDK setAccount:statusManager.accountBookID];
        }
    }
}

- (void)miPushRequestErrWithSelector:(NSString *)selector error:(int)error data:(NSDictionary *)data
{
    // 请求失败
}


// 处理推送逻辑
- (void)handlePushInfo:(NSDictionary *)userInfo
{
    NSLog(@"PushInfo = %@", userInfo);
    NSString *method = userInfo[@"method"];
    NSString *resource = userInfo[@"resource"];
    NSString *orderID = userInfo[@"orderId"];
    
    JCHTakeoutManager *takeoutManager = [JCHTakeoutManager sharedInstance];
    
    if ([method isEqualToString:@"bind"]) {
        
        // 绑定成功 同步数据
        [takeoutManager syncTakeoutData:resource.integerValue];
    } else if ([method isEqualToString:@"bookStatus"]) {
        // 店铺状态
        [JCHNotificationCenter postNotificationName:kTakeoutShopStatusChangedNotification
                                             object:[UIApplication sharedApplication]
                                           userInfo:userInfo];
        
    } else if ([method isEqualToString:@"orderStatus"] || [method isEqualToString:@"orderShipping"]) {
        // 订单状态 / 配送完成
        [JCHNotificationCenter postNotificationName:kTakeoutServerPushNotification
                                             object:[UIApplication sharedApplication]
                                           userInfo:userInfo];
        
        JCHTakeoutOrderSubfieldType subfieldType = [userInfo[@"clientStatus"] integerValue];
        JCHTakeoutOrderSubfieldType oldSubfieldType = [userInfo[@"oldClientStatus"] integerValue];
        if (subfieldType == kJCHTakeoutOrderSubfieldTypeCompleted) {
            // 已完成单推送，要拉取已完成货单列表，存本地
            [takeoutManager fetchCompletedOrders];
        } else if (subfieldType == kJCHTakeoutOrderSubfieldTypeNew) {
            // 有新订单来要查询新订单数量
            [takeoutManager queryTakeoutNewOrder:NO];
        } else if (subfieldType == kJCHTakeoutOrderSubfieldTypeBacked) {
            // 拉取已退单订单
            [takeoutManager fetchRefundedOrders];
        }
        
        // 只有接单后oldSubfieldType为kJCHTakeoutOrderSubfieldTypeNew
        if (oldSubfieldType == kJCHTakeoutOrderSubfieldTypeNew && subfieldType != kJCHTakeoutOrderSubfieldTypeNew) {
            // 查询该订单的详情然后打印
            [takeoutManager queryOrderInfo:@[orderID] resource:resource print:YES];
        }
    } else {
        // pass
    }
}

@end
