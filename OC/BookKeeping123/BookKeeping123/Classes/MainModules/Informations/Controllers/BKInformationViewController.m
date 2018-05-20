//
//  BKInformationViewController.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/15.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKInformationViewController.h"
#import "BKNewsModel.h"
#import "BKNewsTableViewCell.h"
#import "BKWebViewController.h"
#import <SDCycleScrollView/SDCycleScrollView.h>

@interface BKInformationViewController () <UITableViewDelegate, UITableViewDataSource, SDCycleScrollViewDelegate>

@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) NSMutableArray *newsList;
@property (nonatomic, copy) NSArray *bannerList;
@property (nonatomic, strong) SDCycleScrollView *cycleView;

@end

@implementation BKInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"资讯";
    
    self.newsList = [NSMutableArray array];
    
    [self.tableView.mj_header beginRefreshing];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BKNewsTableViewCell" bundle:nil] forCellReuseIdentifier:@"BKNewsTableViewCell"];
    
//    [self setupUI];
}

- (void)setupUI {
    CGRect frame = CGRectMake(0, 0, kScreenWidth, AdaptedHeight(200));
    SDCycleScrollView *cycleView = [SDCycleScrollView cycleScrollViewWithFrame:frame delegate:self placeholderImage:IMG(@"es_hold_2")];
    self.tableView.tableHeaderView = cycleView;
}

- (SDCycleScrollView *)cycleView {
    if (_cycleView == nil) {
        CGRect frame = CGRectMake(0, 0, kScreenWidth, AdaptedHeight(200));
        _cycleView = [SDCycleScrollView cycleScrollViewWithFrame:frame delegate:self placeholderImage:[UIImage imageNamed:@"es_hold_2"]];
//        _cycleView.showPageControl = NO;
        _cycleView.autoScrollTimeInterval = 3;
        _cycleView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
        _cycleView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
        _cycleView.currentPageDotColor = [UIColor whiteColor]; // 自定义分页控件小圆标颜色
        self.tableView.tableHeaderView = _cycleView;
    }
    return _cycleView;
}

- (void)setupBannerViewDataSource {
    NSMutableArray *imageList = [NSMutableArray array];
    NSMutableArray *titleList = [NSMutableArray array];
    for (BKNewsModel *model in self.bannerList) {
        [imageList addObject:model.pic];
        [titleList addObject:model.title];
    }
    self.cycleView.imageURLStringsGroup = imageList;
    self.cycleView.titlesGroup = titleList;
}

- (void)headerRefreshing {
    _pageIndex = 0;
    [self loadData];
}

- (void)footerRefreshing {
    _pageIndex++;
    [self loadData];
}

- (void)loadData {
    
    NSInteger pageSize = 40;
    NSString *url = [[NSString stringWithFormat:@"https://way.jd.com/jisuapi/get?channel=财经&num=%ld&appkey=3830f45c87d998708d4d44c7a99f171f&start=%ld", pageSize, pageSize * _pageIndex] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [PPNetworkHelper GET:url parameters:nil success:^(id responseObject) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSArray *list = [NSArray modelArrayWithClass:[BKNewsModel class] json:responseObject[@"result"][@"result"][@"list"]];
            NSMutableArray *list1 = [NSMutableArray array];
            NSMutableArray *bannerList = [NSMutableArray array];
            for (BKNewsModel *model in list) {
                if (!empty(model.pic)) {
                    if (self.pageIndex == 0 && bannerList.count < 3) {
                        [bannerList addObject:model];
                    } else {
                        [list1 addObject:model];
                    }
                }
            }
            if (self.pageIndex == 0) {
                [self.newsList removeAllObjects];
                self.bannerList = bannerList;
                [self setupBannerViewDataSource];
            }
            [self.newsList addObjectsFromArray:list1];
            [self.tableView reloadData];
        }
        
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.newsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BKNewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BKNewsTableViewCell"];
    BKNewsModel *model = self.newsList[indexPath.row];
    cell.data = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BKNewsModel *model = self.newsList[indexPath.row];
    
    BKWebViewController *vc = [[BKWebViewController alloc] init];
    vc.urlString = model.url;
    vc.title = model.title;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    BKNewsModel *model = self.bannerList[index];
    BKWebViewController *vc = [[BKWebViewController alloc] init];
    vc.urlString = model.url;
    vc.title = model.title;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
