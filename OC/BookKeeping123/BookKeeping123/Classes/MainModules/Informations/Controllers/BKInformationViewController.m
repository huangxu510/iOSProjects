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

@interface BKInformationViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) NSMutableArray *newsList;

@end

@implementation BKInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"资讯";
    
    self.newsList = [NSMutableArray array];
    
    [self.tableView.mj_header beginRefreshing];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BKNewsTableViewCell" bundle:nil] forCellReuseIdentifier:@"BKNewsTableViewCell"];
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
    
    NSDictionary *dict = @{
                           @"start" : @(_pageIndex)
                           };
    [PPNetworkHelper GET:@"https://way.jd.com/jisuapi/get?channel=%E8%B4%A2%E7%BB%8F&num=15&appkey=3830f45c87d998708d4d44c7a99f171f" parameters:dict success:^(id responseObject) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSArray *list = [NSArray modelArrayWithClass:[BKNewsModel class] json:responseObject[@"result"][@"result"][@"list"]];
            if (self.pageIndex == 0) {
                [self.newsList removeAllObjects];
            }
            [self.newsList addObjectsFromArray:list];
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
    BKNewsModel *model = self.newsList[indexPath.row];
    if (!empty(model.pic)) {
        return 100;
    }
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BKNewsModel *model = self.newsList[indexPath.row];
    
    BKWebViewController *vc = [[BKWebViewController alloc] init];
    vc.urlString = model.url;
    vc.title = model.title;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
