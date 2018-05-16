//
//  JCHRestaurantManifestListViewController.m
//  jinchuhuo
//
//  Created by apple on 2016/12/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHRestaurantManifestListViewController.h"
#import "JCHRestaurantManifestListTableViewCell.h"
#import "JCHRestaurantManifestDetailViewController.h"
#import "JCHManifestTableViewSectionView.h"
#import "JCHManifestUtility.h"
#import "CommonHeader.h"

@interface JCHRestaurantManifestListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *contentTableView;
}

@property (retain, nonatomic, readwrite) NSArray *allManifestList;

//! @brief 将货单依据日期进行分级
@property (retain, nonatomic, readwrite) NSDictionary *manifestMapDictionary;

@end

@implementation JCHRestaurantManifestListViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"货单";
    }
    
    return self;
}

- (void)dealloc
{
    self.allManifestList = nil;
    self.manifestMapDictionary = nil;
    [super dealloc];
    return;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
    [self createUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark 加载数据
- (void)loadData
{
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    NSArray<ManifestRecord4Cocoa *> *allRestaurantManifestList = nil;
    ManifestCondition4Cocoa *conditionRecord = [[[ManifestCondition4Cocoa alloc] init] autorelease];
    [manifestService queryAllManifestList:0
                                 pageSize:100
                                condition:conditionRecord
                      manifestRecordArray:&allRestaurantManifestList];
    
    self.allManifestList = allRestaurantManifestList;
    self.manifestMapDictionary = [self groupAllManifestByDate:self.allManifestList];
    
    [contentTableView reloadData];
}

#pragma mark -
#pragma mark 创建UI
- (void)createUI
{
    self.navigationItem.leftBarButtonItem = nil;
    
    contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    [self.view addSubview:contentTableView];
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.manifestMapDictionary.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionTitle = self.manifestMapDictionary.allKeys[section];
    return [self.manifestMapDictionary[sectionTitle] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 28;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    JCHManifestTableViewSectionView *sectionView = sectionView = [[[JCHManifestTableViewSectionView alloc] initWithTopLine:NO BottomLine:YES] autorelease];
    NSString *sectionTitle = self.manifestMapDictionary.allKeys[section];
    NSInteger manifestCount = [self.manifestMapDictionary[sectionTitle] count];
    sectionTitle = [sectionTitle substringFromIndex:5];
    sectionView.titleLabel.text = [NSString stringWithFormat:@"%@ (共开%d桌, 0桌未结账)", sectionTitle, (int)manifestCount];
    
    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHRestaurantManifestListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHRestaurantManifestListTableViewCell"];
    if (cell == nil) {
        cell = [[[JCHRestaurantManifestListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JCHRestaurantManifestListTableViewCell"] autorelease];
    }
    
    NSString *sectionTitle = self.manifestMapDictionary.allKeys[indexPath.section];
    NSArray *manifestList = self.manifestMapDictionary[sectionTitle];
    ManifestRecord4Cocoa *manifest = manifestList[indexPath.row];
    RestaurantManifestInfo *cellData = [[[RestaurantManifestInfo alloc] init] autorelease];
    cellData.manifestLogoName = nil;
    cellData.manifestOrderID = manifest.manifestID;
    cellData.manifestDate = manifest.manifestDate;
    cellData.manifestAmount = [NSString stringWithFormat:@"%.2f", manifest.manifestAmount];
    cellData.manifestRemark = manifest.manifestRemark;
    cellData.manifestType = manifest.manifestType;
    cellData.hasPayed = YES;
    cellData.manifestProductCount = manifest.productCount;
    cellData.operatorID = manifest.operatorID;
    cellData.usedTime = [JCHManifestUtility restaurantTimeUsed:manifest.manifestTimestamp];
    [cell setCellData:cellData];
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    NSString *sectionTitle = self.manifestMapDictionary.allKeys[indexPath.section];
    NSArray *manifestList = self.manifestMapDictionary[sectionTitle];
    ManifestRecord4Cocoa *manifest = manifestList[indexPath.row];
    NSString *manifestID = [manifest manifestID];
    ManifestRecord4Cocoa *manifestRecord = [manifestService queryManifestDetail:manifestID];
    JCHRestaurantManifestDetailViewController *viewController = [[[JCHRestaurantManifestDetailViewController alloc] initWithManifestRecord:manifestRecord] autorelease];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark 将货单依据日期进行分级
- (NSDictionary *)groupAllManifestByDate:(NSArray *)manifestList
{
    NSMutableDictionary *manifestMap = [[[NSMutableDictionary alloc] init] autorelease];
    for (ManifestRecord4Cocoa *manifest in manifestList) {
        NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormater setDateFormat:@"yyyy年MM月dd日"];
        NSDate *manifestDate = [NSDate dateWithTimeIntervalSince1970:manifest.manifestTimestamp];
        NSString *dateString = [dateFormater stringFromDate:manifestDate];
        
        NSMutableArray *manifestInDate = [manifestMap objectForKey:dateString];
        if (nil == manifestInDate) {
            manifestInDate = [[[NSMutableArray alloc] init] autorelease];
            [manifestMap setObject:manifestInDate forKey:dateString];
        }
        
        [manifestInDate addObject:manifest];
    }
    
    return manifestMap;
}

@end
