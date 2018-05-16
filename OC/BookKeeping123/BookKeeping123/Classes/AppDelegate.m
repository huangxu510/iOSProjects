//
//  AppDelegate.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/15.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "AppDelegate.h"
#import "BKTabBarViewController.h"
#import "BKLoginViewController.h"
#import "BKRegisterViewController.h"
#import "BKBaseNavigationController.h"
#import "BKAdvertisementView.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    [self setupUIStyle];
    
    [self setupRootVC];
    
    return YES;
}

- (void)setupRootVC {

    BKTabBarViewController *mainController = [[BKTabBarViewController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = mainController;
    [self.window makeKeyAndVisible];
    
    BKAdvertisementView *adView = [[NSBundle mainBundle] loadNibNamed:@"BKAdvertisementView" owner:nil options:nil].firstObject;
    adView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [kKeyWindow addSubview:adView];
    
    
    
    // TODO: 在此处调用验证接口替换掉dispatch_after，验证接口把当前app版本号告诉服务器，
    // 在审核期间，要审核的app的版本号是最高的，所以在此期间服务器根据此版本号返回响应的数据告诉app要显示的内容
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (1) {
            // 是正在审核的版本
            BKLoginViewController *loginVC = [[BKLoginViewController alloc] init];
            BKBaseNavigationController *nav = [[BKBaseNavigationController alloc] initWithRootViewController:loginVC];
            [adView removeFromSuperview];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [mainController presentViewController:nav animated:YES completion:nil];
            });
            
        } else {
            // 不是审核的版本，设置自己的tabBarController
        }
    });
}

- (void)setupUIStyle {
    [[UINavigationBar appearance] setBarTintColor:HexColor(0xe77747)];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    // 导航栏透明、去掉导航栏的黑线
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName : [UIFont boldSystemFontOfSize:18]}];
    
    // 调整TabBar UI风格
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    [SVProgressHUD setMinimumDismissTimeInterval:2];
    [SVProgressHUD setMaximumDismissTimeInterval:3];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
