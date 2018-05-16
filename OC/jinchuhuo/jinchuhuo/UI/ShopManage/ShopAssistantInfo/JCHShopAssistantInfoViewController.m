//
//  JCHShopAssistantInfoViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/25.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHShopAssistantInfoViewController.h"
#import "JCHShopAssistantInfoEditViewController.h"
#import "JCHShopAssistantInfoTableViewCell.h"
#import "JCHSeparateLineSectionView.h"
#import "UIView+JCHView.h"
#import "CommonHeader.h"
#import "ServiceFactory.h"
#import "JCHSyncStatusManager.h"
#import "JCHServiceResponseNotification.h"
#import "JCHServiceResponseSettings.h"
#import "JCHSyncServerSettings.h"
#import "AppDelegate.h"
#import "MBProgressHUD+JCHHud.h"
#import "CommonHeader.h"
#import <Masonry.h>

@interface JCHShopAssistantInfoViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_contentTableView;
    UIButton *_deleteButton;
    BOOL _hasPermission;  //修改备注的权限
}
@property (nonatomic, retain) BookMemberRecord4Cocoa *bookMemberRecord;

@end

@implementation JCHShopAssistantInfoViewController

- (id)init
{
    self = [super init];
    if (self) {
        // pass
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _hasPermission = NO;
    [self createUI];
}

- (void)dealloc
{
    [self.bookMemberRecord release];
    [self.userID release];
    [super dealloc];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_contentTableView deselectRowAtIndexPath:[_contentTableView indexPathForSelectedRow] animated:YES];
    [self loadData];
    [_contentTableView reloadData];
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    _contentTableView.delegate = self;
    _contentTableView.dataSource = self;
    _contentTableView.backgroundColor = JCHColorGlobalBackground;
    JCHSeparateLineSectionView *headerView = [[[JCHSeparateLineSectionView alloc] initWithTopLine:NO BottomLine:YES] autorelease];
    headerView.frame = CGRectMake(0, 0, kScreenWidth, 20);
    _contentTableView.tableHeaderView = headerView;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_contentTableView];
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    const CGFloat logoutBtnHeight = 50;
    _deleteButton = [JCHUIFactory createButton:CGRectMake(0, 20, kScreenWidth, logoutBtnHeight)
                                              target:self
                                              action:@selector(deleteShopAssistant)
                                               title:@"删除"
                                          titleColor:JCHColorMainBody
                                     backgroundColor:[UIColor whiteColor]];
    _deleteButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [_deleteButton addSeparateLineWithFrameTop:YES bottom:YES];
    
    UIView *tableFooterView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, logoutBtnHeight + 20)] autorelease];
    tableFooterView.backgroundColor = JCHColorGlobalBackground;
    _contentTableView.tableFooterView = tableFooterView;
    [tableFooterView addSubview:_deleteButton];
}

- (void)loadData
{
    id <BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
    self.bookMemberRecord = [bookMemberService queryBookMemberWithUserID:self.userID];
    self.title = [JCHDisplayNameUtility getDisplayRemark:self.bookMemberRecord];
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    //当前是店长
    if (statusManager.isShopManager) {
        _hasPermission = YES;
        _deleteButton.hidden = NO;
    } else {
        _hasPermission = NO;
    }
    
    id <PermissionService> permissionService = [[ServiceFactory sharedInstance] permissionService];
    RoleRecord4Cocoa *roleRecord = [permissionService queryRoleWithByUserID:statusManager.userID];
    RoleRecord4Cocoa *currentRoleRecord = [permissionService queryRoleWithByUserID:self.bookMemberRecord.userId];
    //当前店员是自己
    if ([currentRoleRecord.roleUUID isEqualToString:roleRecord.roleUUID]) {
        _deleteButton.hidden = YES;
        _hasPermission = YES;
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"JCHShopAssistantTableViewCell";
    JCHShopAssistantInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[JCHShopAssistantInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    
    switch (indexPath.row) {
        case 0:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.titleLabel.text = @"麦号";
            cell.detailLabel.text = self.bookMemberRecord.userId;
        }
            break;
            
        case 1:
        {
            cell.titleLabel.text = @"备注";
            cell.detailLabel.text = [JCHDisplayNameUtility getDisplayRemark:self.bookMemberRecord];
            cell.arrowImageView.hidden = _hasPermission ? NO : YES;
        }
            break;
            
        case 2:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.titleLabel.text = @"角色";
            
            id <PermissionService> permissionService = [[ServiceFactory sharedInstance] permissionService];
            RoleRecord4Cocoa *roleRecord = [permissionService queryRoleWithByUserID:self.userID];
            NSString *shopManagerUUID = [permissionService getShopManagerUUID];
            
            if ([shopManagerUUID isEqualToString:roleRecord.roleUUID]) {
                [cell setMarkLabelType:kJCHShopMarkTypeShopkeeper hidden:NO];
            }
            else{
                [cell setMarkLabelType:kJCHShopMarkTypeShopAssistant hidden:NO];
            }
        }
            break;
            
        case 3:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.titleLabel.text = @"电话";
            cell.detailLabel.text = self.bookMemberRecord.phone;
            cell.arrowImageView.hidden = YES;
        }
            break;
            
        default:
            break;
    }
    
    [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHShopAssistantInfoEditViewController *viewController = nil;
    
    switch (indexPath.row) {
        case 0: return;
            break;
        case 1:
        {
            viewController = [[[JCHShopAssistantInfoEditViewController alloc] initWithType:kJCHShopAssistantInfoEditTypeRemark] autorelease];
            viewController.bookMemberRecord = self.bookMemberRecord;
        }
            break;
        case 2: return;
            break;
        case 3:
        {
            return;
            //viewController = [[[JCHShopAssistantInfoEditViewController alloc] initWithType:kJCHShopAssistantInfoEditTypePhoneNumber] autorelease];
        }
            break;
            
        default:
            break;
    }
    
    if (viewController && _hasPermission) {
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - 删除店员
- (void)deleteShopAssistant
{
    WeakSelf;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"确定删除该店员?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf makeSureDeleteShopAssistant];
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:alertAction];
    [alertController addAction:cancleAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)makeSureDeleteShopAssistant
{
    //1)请求服务器删除
    //2)从成员列表中删除店员
    //3)push
    [MBProgressHUD showHUDWithTitle:@"删除中..."
                             detail:@""
                           duration:1000
                               mode:MBProgressHUDModeIndeterminate
                         completion:nil];
    WeakSelf;
    JCHDataSyncManager *dataSyncManager = [JCHDataSyncManager shareInstance];
    [dataSyncManager doLeaveAccountBook:self.userID success:^(NSDictionary *responseData) {
        [weakSelf deleteShopAssistantSuccess];
    } failure:^(NSInteger responseCode, NSError *error) {
        if (error) {
            [MBProgressHUD showNetWorkFailedHud:nil];
        } else {
            [MBProgressHUD showHudWithStatusCode:responseCode
                                       sceneType:kJCHMBProgressHUDSceneTypeDeleteMember];
        }
    }];

}

- (void)deleteShopAssistantSuccess
{
    id <BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
    [bookMemberService deleteBookMemeber:self.userID];
    
    //PUSH
    WeakSelf;
    JCHDataSyncManager *dataSyncManager = [JCHDataSyncManager shareInstance];
    [dataSyncManager doSyncPushCommand:^(NSInteger pushFlag, NSInteger pullFlag, NSDictionary *responseData) {
        [MBProgressHUD showHUDWithTitle:@"删除成功"
                                 detail:@""
                               duration:kJCHDefaultShowHudTime
                                   mode:MBProgressHUDModeText
                             completion:^ {
                                 [weakSelf.navigationController popViewControllerAnimated:YES];
                             }];
    } failure:^(NSInteger responseCode, NSError *error) {
        
        if (error) {
            [MBProgressHUD showNetWorkFailedHud:nil];
        }
    }];
}

@end
