//
//  JCHAccountBookTypeSelectViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/7.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAccountBookTypeSelectViewController.h"
#import "JCHAddAccountBookViewController.h"
#import "JCHAccountBookTypeSelectTableViewCell.h"
#import "CommonHeader.h"
#import <Masonry.h>

static NSString *kJCHAccountBookTypeSelectTableViewCellResuseID = @"JCHAccountBookTypeSelectTableViewCell";

@interface JCHAccountBookTypeSelectViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_contentTableView;
}
@end

@implementation JCHAccountBookTypeSelectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_contentTableView deselectRowAtIndexPath:[_contentTableView indexPathForSelectedRow] animated:YES];
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;

    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    _contentTableView.dataSource = self;
    _contentTableView.delegate = self;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _contentTableView.tableFooterView = [[[UIView alloc] init] autorelease];
    [self.view addSubview:_contentTableView];
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [_contentTableView registerClass:[JCHAccountBookTypeSelectTableViewCell class] forCellReuseIdentifier:kJCHAccountBookTypeSelectTableViewCellResuseID];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *titleArray = @[@"现金", @"银行账户", @"电子钱包", @"负债账户", @"债券账户"];
    NSArray *iconArray = @[@"accountbook_ic_cash", @"accountbook_ic_bank", @"accountbook_ic_wallet", @"accountbook_ic_debt", @"accountbook_ic_creditor"];//, @"accountbook_ic_storagecard"];

    JCHAccountBookTypeSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJCHAccountBookTypeSelectTableViewCellResuseID];
    
    [cell moveBottomLineLeft:YES];
    [cell setImageName:iconArray[indexPath.row] title:titleArray[indexPath.row]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 74.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || section == 3) {
        return 20;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)] autorelease];
    sectionView.backgroundColor = JCHColorGlobalBackground;
    
    [sectionView addSeparateLineWithFrameTop:NO bottom:YES];
    return sectionView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHAddAccountBookViewController *addVC = [[[JCHAddAccountBookViewController alloc] init] autorelease];
    [self.navigationController pushViewController:addVC animated:YES];
}

@end
