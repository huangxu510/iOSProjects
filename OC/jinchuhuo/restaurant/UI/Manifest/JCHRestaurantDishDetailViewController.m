//
//  JCHRestaurantDishDetailViewController.m
//  jinchuhuo
//
//  Created by apple on 2017/1/12.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHRestaurantDishDetailViewController.h"
#import "JCHRestaurantDishDetailSectionView.h"
#import "JCHRestaurantDishDetailFooterView.h"
#import "JCHRestaurantChooseDishViewController.h"
#import "JCHRestaurantDishDetailCell.h"
#import "CommonHeader.h"

@interface JCHRestaurantDishDetailViewController ()<UITableViewDataSource,
                                                    UITableViewDelegate,
                                                    JCHRestaurantDishDetailFooterViewDelegate>
{
    UITableView *contentTableView;
    JCHRestaurantDishDetailFooterView *footerView;
}
@end

@implementation JCHRestaurantDishDetailViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"B17号";
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
    
    return;
}

- (void)createUI
{
    contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    contentTableView.dataSource = self;
    contentTableView.delegate = self;
    contentTableView.backgroundColor = JCHColorGlobalBackground;
    contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    contentTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:contentTableView];
    
    [contentTableView registerClass:[JCHRestaurantDishDetailCell class] forCellReuseIdentifier:@"JCHRestaurantDishDetailCell"];
    
    [self.view addSubview:contentTableView];
    
    CGFloat footerViewHeight = 64;
    [contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view).with.offset(-footerViewHeight);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
    
    [contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-footerViewHeight);
    }];
    
    footerView = [[[JCHRestaurantDishDetailFooterView alloc] initWithFrame:CGRectZero] autorelease];
    footerView.delegate = self;
    [self.view addSubview:footerView];
    
    [footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(footerViewHeight);
        make.bottom.equalTo(self.view);
    }];
}

#pragma mark -
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHRestaurantDishDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHRestaurantDishDetailCell" forIndexPath:indexPath];
    return cell;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect viewFrame = CGRectMake(0, 0, kScreenWidth, 32.0);
    JCHRestaurantDishDetailSectionView *sectionView = [[[JCHRestaurantDishDetailSectionView alloc] initWithFrame:viewFrame] autorelease];
    
    return sectionView;
}

#pragma mark -
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32.0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{

}

#pragma mark -
#pragma mark JCHRestaurantDishDetailFooterViewDelegate
- (void)handleRestaurantAddDish
{
    NSMutableArray *controlerList = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    JCHRestaurantChooseDishViewController *viewController = [[[JCHRestaurantChooseDishViewController alloc] init] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
    
    [controlerList removeLastObject];
    [controlerList addObject:viewController];
    
    [self.navigationController setViewControllers:controlerList animated:YES];
}

- (void)handleRestaurantFinish
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
