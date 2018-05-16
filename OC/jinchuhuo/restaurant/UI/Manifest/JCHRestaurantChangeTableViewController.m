//
//  JCHRestaurantChangeTableViewController.m
//  jinchuhuo
//
//  Created by apple on 2017/1/5.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHRestaurantChangeTableViewController.h"
#import "JCHRestaurantOpenTableCollectionViewCell.h"
#import "JCHRestuarantReserveViewController.h"
#import "JCHRestaurantModifyDishViewController.h"
#import "JCHRestaurantChooseDishViewController.h"
#import "JCHRestaurantChangeTableViewController.h"
#import "JCHCategoryListTableViewCell.h"
#import "JCHSettingCollectionViewCell.h"
#import "JCHTableOperationView.h"
#import "KLCPopup.h"
#import "CommonHeader.h"

@interface JCHRestaurantChangeTableViewController ()<UIAlertViewDelegate,
                                                    UITableViewDelegate,
                                                    UITableViewDataSource,
                                                    UICollectionViewDelegate,
                                                    UICollectionViewDataSource,
                                                    UICollectionViewDelegateFlowLayout>
{
    UITableView *leftTableView;
    UICollectionView *contentCollectionView;
    CGFloat leftTableViewWidth;
}

@property (retain, nonatomic, readwrite) NSArray *positionList;
@property (retain, nonatomic, readwrite) NSArray *tableList;

@end

@implementation JCHRestaurantChangeTableViewController

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
    
    UICollectionViewFlowLayout *flowLayout = [[[UICollectionViewFlowLayout alloc] init] autorelease];
    //flowLayout.headerReferenceSize = CGSizeMake(kScreenWidth, [JCHSizeUtility calculateHeightWithNavigationBar:NO
    //TabBar:YES
    //sourceHeight:35
    //noStretchingIn6Plus:YES]);
    flowLayout.minimumInteritemSpacing = kSeparateLineWidth;
    flowLayout.minimumLineSpacing = kSeparateLineWidth;
    contentCollectionView = [[[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout] autorelease];
    contentCollectionView.dataSource = self;
    contentCollectionView.delegate = self;
    contentCollectionView.alwaysBounceVertical = YES;
    contentCollectionView.clipsToBounds = NO;
    contentCollectionView.backgroundColor = JCHColorGlobalBackground;
    
    [contentCollectionView registerClass:[JCHRestaurantOpenTableCollectionViewCell class] forCellWithReuseIdentifier:@"JCHRestaurantOpenTableCollectionViewCell"];
    
    [self.view addSubview:contentCollectionView];
    
    [contentCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.left.equalTo(leftTableView.mas_right);
        make.right.equalTo(self.view);
    }];
}

#pragma mark -
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.positionList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHCategoryListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHCategoryListTableViewCell" forIndexPath:indexPath];
    cell.titleLabel.text = self.positionList[indexPath.row];
    cell.titleLabel.numberOfLines = 2;
    return cell;
}

#pragma mark -
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHCategoryListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = YES;
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    JCHCategoryListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
}

#pragma mark -
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemWidth = (kScreenWidth - leftTableViewWidth - 3 * kSeparateLineWidth) / 4;
    return CGSizeMake(itemWidth, itemWidth);
}

#pragma mark -
#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tableList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JCHRestaurantOpenTableCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JCHRestaurantOpenTableCollectionViewCell"forIndexPath:indexPath];
    JCHRestaurantOpenTableCollectionViewCellData *cellData = [[[JCHRestaurantOpenTableCollectionViewCellData alloc] init] autorelease];
    
    int randValue = (rand() + 1);
    if (randValue < 0) {
        randValue = - randValue;
    }
    
    cellData.enumType = randValue % 4;
    [cell setCellData:cellData];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self handleChangeTable:indexPath];
}

#pragma mark -
#pragma mark 显示弹出菜单
- (void)handleChangeTable:(NSIndexPath *)indexPath
{
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"确认换台信息"
                                                         message:@"是否将 A12 开台信息转移到 B10 ?"
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                               otherButtonTitles:@"好的", nil] autorelease];
    [alertView show];
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
        {
            // 确定
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
            
        case 0:
        {
            // 取消
            
        }
            
        default:
            break;
    }
}

@end
