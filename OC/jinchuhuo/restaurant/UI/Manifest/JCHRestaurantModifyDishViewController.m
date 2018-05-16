//
//  JCHRestaurantModifyDishViewController.m
//  jinchuhuo
//
//  Created by apple on 2017/1/5.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHRestaurantModifyDishViewController.h"
#import "JCHRestaurantChooseDishViewController.h"
#import "JCHRestaurantDishDetailSectionView.h"
#import "JCHRestaurantDishDetailFooterView.h"
#import "JCHRestaurantDishDetailCell.h"
#import "SWTableViewCell.h"
#import "CommonHeader.h"

@interface JCHRestaurantModifyDishViewController ()<UITableViewDataSource,
                                                    UITableViewDelegate,
                                                    SWTableViewCellDelegate,
                                                    JCHRestaurantDishDetailFooterViewDelegate>
{
    UITableView *contentTableView;
    JCHRestaurantDishDetailFooterView *footerView;
}
@end

@implementation JCHRestaurantModifyDishViewController

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

- (void)loadData
{
    
    [contentTableView reloadData];
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
    [cell setRightUtilityButtons:[self createLeftSlideButtons] WithButtonWidth:65.0];
    cell.delegate = self;
    cell.showMenuButton.hidden = YES;
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
#pragma mark 创建左滑菜单
- (NSArray *)createLeftSlideButtons
{
    NSMutableArray *rightButtons = [NSMutableArray array];
    
    [rightButtons sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f) title:@"划菜"];
    UIButton *finishButton = [rightButtons lastObject];
    finishButton.tag = 1000;
    
    [rightButtons sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f) title:@"催菜"];
    UIButton *alertButton = [rightButtons lastObject];
    alertButton.tag = 1001;
    
    [rightButtons sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f) title:@"退菜"];
    UIButton *rejectButton = [rightButtons lastObject];
    rejectButton.tag = 1002;
    
    return rightButtons;
}

#pragma mark - SWTableViewCellDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    UIButton *rightButton = cell.rightUtilityButtons[index];
    
    switch (rightButton.tag) {
        case 1000:  //划菜
        {

        }
            break;
            
        case 1001:  //催菜
        {

        }
            break;
            
        case 1002:  //退菜
        {
            
        }
            break;
            
        default:
            break;
    }
    
    [self loadData];
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{

}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
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
