
//
//  AppDelegate.h
//  jinchuhuo
//
//  Created by apple on 15/8/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHHomepageViewController.h"
#import "JCHShopAssistantHomePageViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) UINavigationController *rootNavigationController;
@property (assign, nonatomic, readwrite) UIViewController *switchToTargetController;
@property (assign, nonatomic, readwrite) JCHHomepageViewController *homePageController;
@property (retain, nonatomic, readwrite) JCHShopAssistantHomepageViewController *shopAssistantHomepageViewController;
@property (assign, nonatomic, readwrite) BOOL enableHandlingAutoRegisterResponse;

+ (AppDelegate *)sharedAppDelegate;
+ (NSString *)getDatabasePath;
// 获取默认本地数据库路径，位于APP Document目录中
+ (NSString *)getOldVersionDatabasePath;

//自动注册
- (void)doAutoSilentUserRegister;

//自动注册后两步
- (void)doSyncCreateCommand;

//升级数据库
- (void)upgradeDatabaseIfNeed;

@end

