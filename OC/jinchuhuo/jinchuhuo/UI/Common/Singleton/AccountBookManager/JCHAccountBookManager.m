//
//  JCHAccountBookManager.m
//  jinchuhuo
//
//  Created by huangxu on 2017/1/5.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHAccountBookManager.h"
#import "CommonHeader.h"

@interface JCHAccountBookManager ()

@property (copy, nonatomic) void(^newAccountResult)(BOOL success);

@end

@implementation JCHAccountBookManager

+ (instancetype)sharedManager
{
    static JCHAccountBookManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JCHAccountBookManager alloc] init];
        [manager registerResponseNotificationHandler];
    });
    return manager;
}

#pragma mark - 创建新账本
- (void)newAccountBook:(void(^)(BOOL success))result
{
    self.newAccountResult = result;
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    // 在这里要判断所有的账本列表里面是否有 系统注册初始化001 类型的账本，没有则创建
    NSArray *bookInfoList = [ServiceFactory getAllAccountBookList:statusManager.userID];
    
    BookInfoRecord4Cocoa *bookInfoRecordDefaultType = nil;
    BOOL hasDefaultShopType = NO;
    for (BookInfoRecord4Cocoa *bookInfoRecord in bookInfoList) {
        if ([bookInfoRecord.bookType isEqualToString:kJCHDefaultShopType]) {
            hasDefaultShopType = YES;
            bookInfoRecordDefaultType = bookInfoRecord;
            break;
        }
    }
    
    //如果有 系统注册初始化001 类型的账本，打开该账本
    if (hasDefaultShopType) {
        
        NSString *accountBookPath = [ServiceFactory getAccountBookDatabasePath:statusManager.userID
                                                                 accountBookID:bookInfoRecordDefaultType.bookID];
        
        
        int status = [ServiceFactory initializeServiceFactory:accountBookPath
                                                       userID:statusManager.userID
                                                      appType:JCH_BOOK_TYPE];
        
        if (0 != status) {
            //! @todo handle error here
            NSLog(@"initialize database: %@, %@ fail, errno: %d", accountBookPath, statusManager.userID, status);
        } else {
            
            if (self.newAccountResult) {
                self.newAccountResult(YES);
            }
            statusManager.accountBookID = bookInfoRecordDefaultType.bookID;
        }
    } else {
        //如果没有 则创建一个账本
        AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
        
        [appDelegate doSyncCreateCommand];
        
        [MBProgressHUD showHUDWithTitle:@"请稍候..."
                                 detail:@""
                               duration:1000
                                   mode:MBProgressHUDModeIndeterminate
                             completion:nil];
    }
}

- (void)handleAutoRegisterFailedInAppDelegate:(NSNotification *)notify
{
    NSDictionary *userInfo = notify.userInfo;
    NSInteger responseCode = [userInfo[@"responseCode"] integerValue];
    NSLog(@"responseCode = %ld", responseCode);
    
    if (responseCode == 20209) {
        [MBProgressHUD showHUDWithTitle:@"创建店铺失败"
                                 detail:@"店铺数量超过限制"
                               duration:kJCHDefaultShowHudTime
                                   mode:MBProgressHUDModeText
                             completion:nil];
    } else if (responseCode == 20201) {
        [MBProgressHUD showHUDWithTitle:@"创建店铺失败"
                                 detail:@"请重新登录"
                               duration:kJCHDefaultShowHudTime
                                   mode:MBProgressHUDModeText
                             completion:nil];
    }
}

- (void)handleAutoRegisterSuccessInAppDelegate:(NSNotification *)notify
{
    [MBProgressHUD hideAllHudsForWindow];
    
    if (self.newAccountResult) {
        self.newAccountResult(YES);
    }
}



- (void)registerResponseNotificationHandler
{
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleAutoRegisterFailedInAppDelegate:)
                                  name:kAutoRegisterFailedNotification
                                object:[UIApplication sharedApplication]];
    
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleAutoRegisterSuccessInAppDelegate:)
                                  name:kJCHSyncAutoRegisterCompleteNotification
                                object:[UIApplication sharedApplication]];
    
}

- (void)unregisterResponseNotificationHandler
{
    [JCHNotificationCenter removeObserver:self
                                     name:kAutoRegisterFailedNotification
                                   object:[UIApplication sharedApplication]];
    
    [JCHNotificationCenter removeObserver:self
                                     name:kJCHSyncAutoRegisterCompleteNotification
                                   object:[UIApplication sharedApplication]];
}



@end
