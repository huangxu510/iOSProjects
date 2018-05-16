//
//  JCHRestaurantChooseDishViewController.m
//  jinchuhuo
//
//  Created by apple on 2017/1/5.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHRestaurantChooseDishViewController.h"
#import "JCHCategoryListTableViewCell.h"
#import "JCHRestaurantChooseDishTableViewCell.h"
#import "JCHRestaurantSKUItemView.h"
#import "JCHAddProductFooterView.h"
#import "KLCPopup.h"
#import "CommonHeader.h"

@interface JCHRestaurantChooseDishViewController ()<UITableViewDelegate,
                                                    UITableViewDataSource,
                                                    JCHAddProductFooterViewDelegate>
{
    UITableView *leftTableView;
    UITableView *contentTableView;
    JCHAddProductFooterView *footerView;
    CGFloat leftTableViewWidth;
    CGFloat footerViewHeight;
}

@property (retain, nonatomic, readwrite) NSArray *positionList;
@property (retain, nonatomic, readwrite) NSArray *tableList;

@end

@implementation JCHRestaurantChooseDishViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"开台";
        self.positionList = @[@"A区", @"B区", @"C区", @"D区"];
        
        NSMutableArray *tableArray = [[[NSMutableArray alloc] init] autorelease];
        for (size_t i = 0; i < 33; ++i) {
            NSString *name = [NSString stringWithFormat:@"桌台%02d", (int)i];
            [tableArray addObject:name];
        }
        
        self.tableList = tableArray;
        footerViewHeight = 49.0;
        leftTableViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:73.0f];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData];
    [self createUI];
}

- (void)loadData
{
//    id<DiningTableService> tableService = [[ServiceFactory sharedInstance] diningTableService];
//    NSArray *tableList = [tableService queryDiningTable];
//    for (DiningTableRecord4Cocoa *table in tableList) {
//        // NSString *tableRegion = table.regionName;
//    }
}

- (void)createUI
{
    
    leftTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    leftTableView.dataSource = self;
    leftTableView.delegate = self;
    leftTableView.backgroundColor = JCHColorGlobalBackground;
    leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    leftTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:leftTableView];
    
    [leftTableView registerClass:[JCHCategoryListTableViewCell class] forCellReuseIdentifier:@"JCHCategoryListTableViewCell"];
    
    [leftTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.view);
        make.height.mas_equalTo(kScreenHeight - kTabBarHeight - 64);
        make.width.mas_equalTo(leftTableViewWidth);
    }];
    
    contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    contentTableView.dataSource = self;
    contentTableView.delegate = self;
    contentTableView.backgroundColor = JCHColorGlobalBackground;
    contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    contentTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:contentTableView];
    
    [contentTableView registerClass:[JCHRestaurantChooseDishTableViewCell class] forCellReuseIdentifier:@"JCHRestaurantChooseDishTableViewCell"];
    
    [self.view addSubview:contentTableView];
    
    [contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view).with.offset(-footerViewHeight);
        make.left.equalTo(leftTableView.mas_right);
        make.right.equalTo(self.view);
    }];
    
    [contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-footerViewHeight);
    }];
    
    footerView = [[[JCHAddProductFooterView alloc] initWithFrame:CGRectZero] autorelease];
    [self.view addSubview:footerView];
    footerView.delegate = self;
    
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
    if (tableView == leftTableView) {
        return self.positionList.count;
    } else if (tableView == contentTableView) {
        return 10;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (leftTableView == tableView) {
        JCHCategoryListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHCategoryListTableViewCell" forIndexPath:indexPath];
        cell.titleLabel.text = self.positionList[indexPath.row];
        cell.titleLabel.numberOfLines = 2;
        return cell;
    } else if (contentTableView == tableView) {
        JCHRestaurantChooseDishTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHRestaurantChooseDishTableViewCell" forIndexPath:indexPath];
        return cell;
    } else {
        return nil;
    }

}

#pragma mark -
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (leftTableView == tableView) {
        return 40;
    } else if (contentTableView == tableView) {
        return 72;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (leftTableView == tableView) {
        return 40;
    } else if (contentTableView == tableView) {
        return 72;
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (leftTableView == tableView) {
        JCHCategoryListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.selected = YES;
    } else if (contentTableView == tableView) {
        [self showMuliSKUItemView];
    } else {
        
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (leftTableView == tableView) {
        JCHCategoryListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.selected = NO;
    } else if (contentTableView == tableView) {
        
    } else {
        
    }
}

#pragma mark -
#pragma mark JCHAddFooterViewDelegate
- (void)handleEditRemark
{
    
}

- (void)handleShowTransactionList
{
    
}

- (void)handleClickSaveOrderList
{
    
}

#pragma mark -
#pragma mark 显示多规格点菜菜单
- (void)showMuliSKUItemView
{
    CGRect popFrame = CGRectMake(0, 0, kScreenWidth - 60, 300);
    JCHRestaurantSKUItemView *itemView = [[[JCHRestaurantSKUItemView alloc] initWithFrame:popFrame] autorelease];
    itemView.backgroundColor = [UIColor whiteColor];
    itemView.layer.cornerRadius = 6.0;
    KLCPopup *popView = [KLCPopup popupWithContentView:itemView
                                              showType:KLCPopupShowTypeSlideInFromTop
                                           dismissType:KLCPopupDismissTypeSlideOutToBottom
                                              maskType:KLCPopupMaskTypeDimmed
                              dismissOnBackgroundTouch:YES
                                 dismissOnContentTouch:NO];
    [popView show];
}

@end
