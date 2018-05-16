//
//  JCHMyViewController.m
//  jinchuhuo
//
//  Created by apple on 15/8/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <TargetConditionals.h>
#import "JCHPerformanceTestResultViewController.h"
#import "JCHAddedServiceViewController.h"
#import "JCHMyViewController.h"
#import "JCHUnitListViewController.h"
#import "JCHHelpViewController.h"
#import "JCHFeedbackViewController.h"
#import "JCHCategoryListViewController.h"
#import "JCHProductRecordListViewController.h"
#import "JCHSKUTypeListViewController.h"
#import "JCHSecurityVIewController.h"
#import "JCHLoginViewController.h"
#import "JCHAboutViewController.h"
#import "JCHUserInfoViewController.h"
#import "JCHMyShopsViewController.h"
#import "JCHSeparateLineSectionView.h"
#import "JCHMyTableViewCell.h"
#import "JCHUISizeSettings.h"
#import "JCHUISettings.h"
#import "ServiceFactory.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "AppDelegate.h"
#import "JCHSyncStatusManager.h"
#import "JCHServiceResponseSettings.h"
#import "JCHServiceResponseNotification.h"
#import "JCHColorSettings.h"
#import "DataSyncService.h"
#import "JCHControllerNavigationSettings.h"
#import "JCHDisplayNameUtility.h"
#import "CommonHeader.h"
#import "JCHUserInfoView.h"
#import "Masonry.h"
#import <THLabel.h>


enum
{
//    kAccountBookManageRow     = 0,  // 店铺管理
//    kSecurityRow              = 1,  // 安全
//    kFeedbackRow              = 2,  // 意见反馈
//    kAboutUSRow               = 3,  // 关于我们
//    kPerformanceTestResultRow = 4,  // 性能测试
//    kCheckBalanceStatus       = 5,  // 检测平账
    
    kSecurityRow              = 0,  // 安全
    kFeedbackRow              = 1,  // 意见反馈
    kAboutUSRow               = 2,  // 关于我们
    kPerformanceTestResultRow = 3,  // 性能测试
    kCheckBalanceStatus       = 4,  // 检测平账
};

@interface JCHMyViewController ()
{
    UITableView *_contentTableView;
    JCHUserInfoView *_userInfoView;
}
@property (retain, nonatomic, readwrite) NSArray *dataSource;
@property (retain, nonatomic, readwrite) NSString *syncUploadFilePath;
@property (retain, nonatomic, readwrite) NSString *syncDownloadFilePath;

@end

@implementation JCHMyViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"我的";
#if 0
        
        
        
#if PERFORMANCETEST
        self.dataSource = @[@[@"我的店铺"], @[@"安全", @"反映问题", @"关于", @"性能检测", @"平账检测"]];
#else
        self.dataSource = @[@[@"我的店铺"], @[@"安全", @"反映问题", @"关于"]];
#endif
       
        
        
#else
        
        
        
#if PERFORMANCETEST
        self.dataSource = @[@[@"安全", @"反映问题", @"关于", @"性能检测", @"平账检测"]];
#else
        self.dataSource = @[@[@"安全", @"反映问题", @"关于"]];
#endif
        
        
        
#endif
    }
    
    return self;
}

- (void)dealloc
{
    [self.syncUploadFilePath release];
    [self.syncDownloadFilePath release];
    [self.dataSource release];
    
    [super dealloc];
    return;
}

- (void)loadView
{
    CGRect viewFrame = [[UIScreen mainScreen] applicationFrame];
    viewFrame.origin = CGPointMake(0.0f, 0.0f);
    self.view = [[[UIView alloc] initWithFrame:viewFrame] autorelease];
    
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    [self createUI];
    return;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [_contentTableView deselectRowAtIndexPath:[_contentTableView indexPathForSelectedRow] animated:YES];
    
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


//找到导航栏下面的细线
- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)createUI
{
    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    _contentTableView.delegate = self;
    _contentTableView.dataSource = self;
    JCHSeparateLineSectionView *headerView = [[[JCHSeparateLineSectionView alloc] initWithTopLine:NO BottomLine:YES] autorelease];
    headerView.frame = CGRectMake(0, 0, kScreenWidth, 20);
    _contentTableView.tableHeaderView = headerView;
    _contentTableView.tableFooterView = [[[UIView alloc] init] autorelease];
    _contentTableView.backgroundColor = JCHColorGlobalBackground;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _contentTableView.bounces = YES;
    _contentTableView.clipsToBounds = NO;
    [self.view addSubview:_contentTableView];
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];

    [_contentTableView registerClass:[JCHMyTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    
    UIView *tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 230)] autorelease];
    _contentTableView.tableHeaderView = tableHeaderView;
    _userInfoView = [[[JCHUserInfoView alloc] initWithImage:nil] autorelease];
    _userInfoView.frame = CGRectMake(0, 0, kScreenWidth, 230);
    _userInfoView.contentMode = UIViewContentModeBottom;
    [tableHeaderView addSubview:_userInfoView];
    
    WeakSelf;
    _userInfoView.openAddedService = ^{
        [weakSelf handleOpenAddedService];
    };
    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleShowUserInfo)] autorelease];
    [_userInfoView addGestureRecognizer:tap];
    
    
    
    
    UIButton *backButton = [JCHUIFactory createButton:CGRectMake(10, 20, 44, 44)
                                               target:self
                                               action:@selector(handlePopAction)
                                                title:nil
                                           titleColor:nil
                                      backgroundColor:nil];
    [backButton setImage:[UIImage imageNamed:@"bt_back"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    
    
    THLabel *titleLabel = (THLabel *)[JCHUIFactory createJCHLabel:CGRectMake(kScreenWidth / 2 - 75, 20, 150, 44)
                                                            title:self.title
                                                             font:[UIFont boldSystemFontOfSize:18]
                                                        textColor:[UIColor whiteColor]
                                                           aligin:NSTextAlignmentCenter];
    titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    titleLabel.shadowOffset = CGSizeMake(0, 1.5);
    titleLabel.shadowBlur = 0;
    [self.view addSubview:titleLabel];
    
#if 0
    UIBarButtonItem *sendMailButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                                                     target:self
                                                                                     action:@selector(handleSendDataByEmail:)] autorelease];
    
    self.navigationItem.rightBarButtonItems = @[sendMailButton];
#endif
    return;
    
}

#pragma mark - LoadData
- (void)loadData
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id <BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
    BookMemberRecord4Cocoa *bookMemberRecord = [bookMemberService queryBookMemberWithUserID:statusManager.userID];
    
    JCHUserInfoViewData *data = [[[JCHUserInfoViewData alloc] init] autorelease];
    data.headImageName = statusManager.headImageName;
    
    data.nickname = [JCHDisplayNameUtility getDisplayNickName:bookMemberRecord];
    data.maimaiNumber = statusManager.userID;
    
    [_userInfoView setViewData:data];
    [_contentTableView reloadData];
}

#pragma mark -
#pragma mark UITableViewDateSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHMyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.arrowImageView.hidden = NO;
    cell.nameLabel.text = self.dataSource[indexPath.section][indexPath.row];
    
    //每段最后一行的底线与左侧边无间隔
    [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[[JCHSeparateLineSectionView alloc] initWithTopLine:NO BottomLine:YES] autorelease];
}


#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = nil;
 

    NSInteger index = 0;
#if 0
    if (indexPath.section == 0) {
        index = 0;
    } else {
        index = indexPath.row + 1;
    }
#else
    index = indexPath.row;
#endif
    
    switch (index) {
        
//        case kAccountBookManageRow:
//        {
//            viewController = [[[JCHMyShopsViewController alloc] init] autorelease];
//        }
//            break;

        case kSecurityRow:
        {
            viewController = [[[JCHSecurityViewController alloc] init] autorelease];
        }
            break;
            
            
        case kFeedbackRow:
        {
            viewController = [[[JCHFeedbackViewController alloc] init] autorelease];
        }
            break;

        case kAboutUSRow:
        {
            viewController = [[[JCHAboutViewController alloc] init] autorelease];
        }
            break;
            
        case kPerformanceTestResultRow:
        {
            viewController = [[[JCHPerformanceTestResultViewController alloc] init] autorelease];
        }
            break;
            
        case kCheckBalanceStatus:
        {
            id<BalanceStatusService> balanceService = [[ServiceFactory sharedInstance] balanceStatusService];
            NSInteger balanceStatus = [balanceService checkBalanceStatus];
            
            NSString *message = [NSString stringWithFormat:@"平账状态码：%ld", balanceStatus];
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                 message:message
                                                                delegate:nil
                                                       cancelButtonTitle:@"我知道了" otherButtonTitles:nil] autorelease];
            [alertView show];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
            break;
            
        default:
        {
            // pass
        }
            break;
    }
    
    if (nil != viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
    return;
}

- (void)handleSendDataByEmail:(id)sender
{
    if (NO == [MFMailComposeViewController canSendMail]){
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"您iPhone上的 \"邮件\" 应用程序没有绑定任何邮箱地址，请绑定后再使用 \"导出数据\" 功能，谢谢!"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    MFMailComposeViewController *mailController = [[[MFMailComposeViewController alloc] init] autorelease];
    [mailController setMailComposeDelegate:self];
    [mailController setSubject:[self getMailTitle]];
    [mailController setToRecipients:@[@"liyong@maimairen.com", @"niefeng@maimairen.com", @"wanghuaqin@maimairen.com"]];
    [mailController setCcRecipients:@[@"liyong@maimairen.com", @"niefeng@maimairen.com", @"wanghuaqin@maimairen.com"]];
    [mailController setBccRecipients:@[]];
    [mailController setMessageBody:[self getMailContent] isHTML:NO];
    
    NSString *databasePath = [AppDelegate  getDatabasePath];
    NSData *sqliteDatabase = [NSData dataWithContentsOfFile:databasePath];
    [mailController addAttachmentData:sqliteDatabase
                             mimeType:@""
                             fileName:[self getDatabaseAttachmentFileName]];
    
    // 弹出邮件发送视图
    [self presentViewController:mailController
                       animated:YES
                     completion:nil];
}

- (NSString *)getMailTitle
{
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *dateString = [dateFormater stringFromDate:[NSDate date]];
    NSString *mailTitle = [NSString stringWithFormat:@"%@%@", @"进出货iOS客户端数据库:", dateString];
    return mailTitle;
}

- (NSString *)getMailContent
{
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *dateString = [dateFormater stringFromDate:[NSDate date]];
    NSString *mailContent = [NSString stringWithFormat:@"%@%@", @"此邮件的附件为进出货iOS客户端数据库，版本号为:", dateString];
    
    return mailContent;
}

- (NSString *)getDatabaseAttachmentFileName
{
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *dateString = [dateFormater stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"maimairen-%@.sqlite", dateString];
    
    return fileName;
}

- (void)handleOpenAddedService
{
#if MMR_TAKEOUT_VERSION || MMR_RESTAURANT_VERSION
    
#else
    JCHAddedServiceManager *addedServiceManager = [JCHAddedServiceManager shareInstance];
    
    if (addedServiceManager.level == kJCHAddedServiceGoldLevel) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"您当前为金麦会员，如需续费，请升级app到最新版本"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
    } else {
        JCHAddedServiceViewController *addedServiceViewController = [[[JCHAddedServiceViewController alloc] init] autorelease];
        [self.navigationController pushViewController:addedServiceViewController animated:YES];
    }
#endif

    
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled: // 用户取消编辑
            NSLog(@"取消发送邮件.");
            break;
        case MFMailComposeResultSaved: // 用户保存邮件
        {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                 message:@"您的邮件草稿已保存到\"邮件\" -> \"草稿\"中"
                                                                delegate:nil
                                                       cancelButtonTitle:@"我知道了"
                                                       otherButtonTitles:nil] autorelease];
            [alertView show];
        }
            NSLog(@"保存草稿");
            break;
        case MFMailComposeResultSent: // 用户点击发送
            NSLog(@"发送成功");
            break;
        case MFMailComposeResultFailed: // 用户尝试保存或发送邮件失败
            NSLog(@"发送失败: %@...", [error localizedDescription]);
            break;
    }
    
    // 关闭邮件发送视图
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)runDataSyncTest
{
    // [self doUserRegisterByName];
    // [self doUserLogin];
    // [self doAutoSilentUserRegister];
    // [self doSendMobileCAPTCHAForRegister];
    
    return;
}

- (void)handleShowUserInfo
{
    JCHUserInfoViewController *userInfo = [[[JCHUserInfoViewController alloc] init] autorelease];
    [self.navigationController pushViewController:userInfo animated:YES];
}

- (void)handlePopAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
