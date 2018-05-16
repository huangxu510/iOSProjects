//
//  JCHPerformanceTestResultViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/7/7.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHPerformanceTestResultViewController.h"
#import "CommonHeader.h"

@interface JCHPerformanceTestResultViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSArray *titles;
@property (nonatomic, retain) NSArray *times;
@end

@implementation JCHPerformanceTestResultViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        JCHPerformanceTestManager *performanceTestManager = [JCHPerformanceTestManager shareInstance];
        self.title = @"性能报告";
        self.titles = @[@"货单列表", @"货单详情", @"库存列表", @"库存详情", @"商品列表", @"出货分析", @"进货分析", @"毛利分析", @"库存分析", @"账户首页", @"现金账户", @"总应收账款", @"个人应收账款", @"总应付账款", @"个人应付账款", @"储值卡账户流水"];
        self.times = @[@(performanceTestManager.manifestListLoadTime),
                       @(performanceTestManager.manifestDetailLoadTime),
                       @(performanceTestManager.inventoryListLoadTime),
                       @(performanceTestManager.inventoryDetailLoadTime),
                       @(performanceTestManager.productListLoadTime),
                       @(performanceTestManager.shipmentAnalyseLoadTime),
                       @(performanceTestManager.purchaseAnalyseLoadTime),
                       @(performanceTestManager.profitAnalyseLoadTime),
                       @(performanceTestManager.inventoryAnalyseLoadTime),
                       @(performanceTestManager.accountBookLoadTime),
                       @(performanceTestManager.cashAccountLoadTime),
                       @(performanceTestManager.receiptAccountLoadTime),
                       @(performanceTestManager.receiptAccountForSomebodyLoadTime),
                       @(performanceTestManager.paymentAccountLoadTime),
                       @(performanceTestManager.paymentAccountForSomebodyLoadTime),
                       @(performanceTestManager.savingCardAccountLoadTime)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)dealloc
{
    self.titles = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDatesource UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *performanceTestResultTableViewCellTag = @"performanceTestResultTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:performanceTestResultTableViewCellTag];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:performanceTestResultTableViewCellTag] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = self.titles[indexPath.row];
    NSNumber *time = self.times[indexPath.row];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fs", [time doubleValue]];
    
    return cell;
}



@end
