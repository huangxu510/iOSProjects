//
//  JCHSecurityVIewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/30.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHSecurityVIewController.h"
#import "JCHPinCodeViewController.h"
#import "JCHMutipleSelectedTableViewCell.h"
#import "JCHSeparateLineSectionView.h"
#import "JCHColorSettings.h"
#import "ServiceFactory.h"
#import "JCHUISettings.h"
#import "JCHUserInfoHelper.h"
#import "JCHSyncStatusManager.h"
#import <Masonry.h>

@interface JCHSecurityViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    UITableView *_contentTableView;
    UISwitch *_codeSwitch;
}
@end

@implementation JCHSecurityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"安全";
    self.view.backgroundColor = JCHColorGlobalBackground;
    self.navigationController.navigationBar.translucent = NO;
    [self createUI];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //BOOL securityCodeStatus = [[NSUserDefaults standardUserDefaults] boolForKey:@"securityCodeStatus"];
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    JCHUserInfoHelper *userInfoHelper = [JCHUserInfoHelper shareHelper];
    NSDictionary *securityCodeForUserID = [userInfoHelper getsecurityCodeForUserID];
    NSDictionary *securityCodeDict = securityCodeForUserID[statusManager.userID];
    [_codeSwitch setOn:[[securityCodeDict objectForKey:kSecurityCodeStatus] boolValue] animated:YES];
}

- (void)createUI
{
    _backBtn = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bt_back"] style:UIBarButtonItemStylePlain target:self action:@selector(handlePopAction)] autorelease];
    self.navigationItem.leftBarButtonItem = _backBtn;
    
    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kStatusBarHeight - kNavigatorBarHeight) style:UITableViewStylePlain] autorelease];
    _contentTableView.dataSource = self;
    _contentTableView.delegate = self;
    _contentTableView.backgroundColor = JCHColorGlobalBackground;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _contentTableView.tableFooterView = [[[UIView alloc] init] autorelease];
    JCHSeparateLineSectionView *headerView = [[[JCHSeparateLineSectionView alloc] initWithTopLine:NO BottomLine:YES] autorelease];
    headerView.frame = CGRectMake(0, 0, kScreenWidth, 20);
    _contentTableView.tableHeaderView = headerView;
    
    [self.view addSubview:_contentTableView];
}

- (void)changeValue:(UISwitch *)sender
{
    JCHPinCodeViewController *pinVC = [[[JCHPinCodeViewController alloc] init] autorelease];
    if (sender.on) { //设置密码
        pinVC.type = kJCHPinCodeViewControllerTypeSet;
    }
    else //清除密码
    {
        pinVC.type = kJCHPinCodeViewControllerTypeClose;
    }
    
    [self.navigationController performSelector:@selector(pushViewController:animated:) withObject:pinVC afterDelay:0.25];
    //    [self.navigationController pushViewController:pinVC animated:YES];
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *dataSource = @[@"密码保护"];
    
    JCHMutipleSelectedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil)
    {
        cell = [[[JCHMutipleSelectedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
    }

    //每段最后一行的底线与左侧边无间隔
    [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
    
    if (indexPath.row == 0) {
        _codeSwitch = [[[UISwitch alloc] init] autorelease];
        [_codeSwitch addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
        
        JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
        JCHUserInfoHelper *userInfoHelper = [JCHUserInfoHelper shareHelper];
        NSDictionary *securityCodeForUserID = [userInfoHelper getsecurityCodeForUserID];
        NSMutableDictionary *securityCodeDict = securityCodeForUserID[statusManager.userID];
        _codeSwitch.on = [[securityCodeDict objectForKey:kSecurityCodeStatus] boolValue];
        //_codeSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"securityCodeStatus"];
        
        [cell.contentView addSubview:_codeSwitch];
        
        [_codeSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(cell.contentView).with.offset(-kStandardLeftMargin);
            make.width.mas_equalTo(51);
            make.height.mas_equalTo(31);
            make.centerY.equalTo(cell.contentView);
        }];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    
    cell.textLabel.text = dataSource[indexPath.row];
    cell.textLabel.textColor = JCHColorMainBody;
    cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
    
    return cell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)handlePopAction
{
    [self.navigationController popViewControllerAnimated:YES];
}



@end
