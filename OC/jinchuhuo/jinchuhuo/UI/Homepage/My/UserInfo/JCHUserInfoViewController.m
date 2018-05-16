//
//  JCHUserInfoViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/6.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHUserInfoViewController.h"

#import "JCHHomepageViewController.h"
#import "JCHEnforceLoginViewController.h"
#import "JCHUserInfoUserHeadImageSelectViewController.h"
#import "JCHUserInfoUserNameEditViewController.h"
#import "JCHUserInfoTableViewCell.h"
#import "JCHHeadImageTableViewCell.h"
#import "JCHSeparateLineSectionView.h"
#import "JCHUISettings.h"
#import "JCHColorSettings.h"
#import "JCHUIFactory.h"
#import "JCHSyncStatusManager.h"
#import "AppDelegate.h"
#import "JCHServiceResponseNotification.h"
#import "JCHSyncServerSettings.h"
#import "JCHServiceResponseSettings.h"
#import "ServiceFactory.h"
#import "MBProgressHUD+JCHHud.h"
#import "CommonHeader.h"
#import "AppDelegate.h"
#import <Masonry.h>
#import "MiPushSDK.h"

@interface JCHUserInfoViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_contentTableView;
}
@end

@implementation JCHUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"个人信息";
    
    [self createUI];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self registerResponseNotificationHandler];
    }
    return self;
}

- (void)dealloc
{
    [self unregisterResponseNotificationHandler];
    
    [super dealloc];
    return;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_contentTableView reloadData];
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    _contentTableView.dataSource = self;
    _contentTableView.delegate = self;
    _contentTableView.backgroundColor = JCHColorGlobalBackground;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    JCHSeparateLineSectionView *headerView = [[[JCHSeparateLineSectionView alloc] initWithTopLine:NO BottomLine:YES] autorelease];
    headerView.frame = CGRectMake(0, 0, kScreenWidth, 20);
    _contentTableView.tableHeaderView = headerView;
    
    [self.view addSubview:_contentTableView];

    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
    

    const CGFloat logoutBtnHeight = 50;
    UIButton *logoutBtn = [JCHUIFactory createButton:CGRectMake(0, 0, kScreenWidth, logoutBtnHeight)
                                              target:self
                                              action:@selector(handleLogout)
                                               title:@"退出登录"
                                          titleColor:JCHColorAuxiliary
                                     backgroundColor:[UIColor whiteColor]];
    logoutBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    
    UIView *tableFooterView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, logoutBtnHeight)] autorelease];
    _contentTableView.tableFooterView = tableFooterView;
    [tableFooterView addSubview:logoutBtn];
    
    
    UIView *bottomLine = [[[UIView alloc] init] autorelease];
    bottomLine.backgroundColor = JCHColorSeparateLine;
    
    [logoutBtn addSubview:bottomLine];
    
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(logoutBtn);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
}

- (void)handleLogout
{
    [JCHUserInfoViewController clearUserLoginStatus];

    JCHEnforceLoginViewController *enforceLoginVC = [[[JCHEnforceLoginViewController alloc] init] autorelease];
    [self.navigationController pushViewController:enforceLoginVC animated:NO];
}

#pragma mark - UITableViewDataSource
 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *headImageCellIdentifier = @"headImageCell";
    static NSString *userInfoCellIdentifier = @"userInfoCell";
    NSArray *userInfoDataSource = @[@"昵称", @"麦号"];
    JCHSyncStatusManager *manager = [JCHSyncStatusManager shareInstance];
    
    if (indexPath.row == 0) {
        JCHHeadImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:headImageCellIdentifier];
        if (cell == nil) {
            cell = [[[JCHHeadImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headImageCellIdentifier] autorelease];
        }
        [cell setData:manager.headImageName];
    
        return cell;
    }
    else
    {
        JCHUserInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:userInfoCellIdentifier];
        if (cell == nil) {
            cell = [[[JCHUserInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userInfoCellIdentifier] autorelease];
        }
        [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
        [cell setTitleLabelText:userInfoDataSource[indexPath.row - 1]];
        if (indexPath.row == 2) {
            [cell setArrowImageViewHidden:YES];
            [cell setDetailLabelText:manager.userID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if (indexPath.row == 1)
        {
            [cell setArrowImageViewHidden:NO];
            [cell setDetailLabelText:manager.userName];
        }
        else
        {
            //pass
        }
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 62;
    }
    else
    {
        return 44;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[[JCHSeparateLineSectionView alloc] initWithTopLine:NO BottomLine:YES] autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = nil;
    if (indexPath.row == 0) {
        viewController = [[[JCHUserInfoUserHeadImageSelectViewController alloc] init] autorelease];
    }
    else if (indexPath.row == 1)
    {
        viewController = [[[JCHUserInfoUserNameEditViewController alloc] init] autorelease];
    }
    
    if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
}

#pragma mark - LonginNotificationAndMethod

- (void)registerResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    // 用户信息相关
    [notificationCenter addObserver:self
                           selector:@selector(handleUpdateUserProfile:)
                               name:kJCHSyncUpdateUserProfileCommandNotification
                             object:[UIApplication sharedApplication]];
}

- (void)unregisterResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    
    // 用户信息相关
    [notificationCenter removeObserver:self
                                  name:kJCHSyncUpdateUserProfileCommandNotification
                                object:[UIApplication sharedApplication]];
}

// 用户信息相关
- (void)doUpdateUserProfile
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    id <BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
    BookMemberRecord4Cocoa *bookMemberRecord = [bookMemberService queryBookMemberWithUserID:statusManager.userID];

    UpdateUserProfileRequest *request = [[[UpdateUserProfileRequest alloc] init] autorelease];
    request.serviceURL = [NSString stringWithFormat:@"%@/terminal/updateProfile", kJCHUserManagerServerIP];
    request.token = statusManager.syncToken;
    request.deviceUUID = statusManager.deviceUUID;
    request.nickname = bookMemberRecord.nickname;        // 昵称
    request.avatarUrl = bookMemberRecord.avatarUrl;       // 头像地址
    //request.realname = @"";        // 真实姓名
    //request.signature = @"";       // 签名
    //request.province = @"";        // 省
    //request.city = @"";            // 市
    //request.district = @"";        // 区
    //request.job = @"";             // 工作
    request.genderType = 0;      // 性别，0为男，1为女
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService updateUserProfile:request responseNotification:kJCHSyncUpdateUserProfileCommandNotification];
    
    return;
}

- (void)handleUpdateUserProfile:(NSNotification *)notify
{   
    NSDictionary *userData = notify.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        NSString *responseDescription = responseData[@"desc"];
        NSString *responseStatus = responseData[@"status"];
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
        
        if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
            //! @todo
            NSLog(@"update user profile fail.");
            return;
        } else {
            //! @todo
            // your code here
            NSLog(@"success.");
            
            [MBProgressHUD showHUDWithTitle:@"保存成功" detail:nil duration:1.5 mode:MBProgressHUDModeText completion:nil];
        }
        
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
    }
}

//! @brief 用户退出登录时，清理用户登录状态
+ (void)clearUserLoginStatus
{
    //! @note 清楚statusManager上的数据
    [JCHSyncStatusManager clearStatus];
    
    // 关闭自动同步定时器
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    [appDelegate stopAutoSyncTimer];
    
    //! @note 清除增值服务信息
    [JCHAddedServiceManager clearStatus];
    

    //! @note 清除tabbar上每个页面的数据
    [appDelegate clearDataOnTabbar];
    
    //! @note 清除浏览器缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    //! @note 清除cookies
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    
#if MMR_TAKEOUT_VERSION
    // 取消推送账号
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    [MiPushSDK unsetAccount:statusManager.accountBookID];
#endif
}


@end
