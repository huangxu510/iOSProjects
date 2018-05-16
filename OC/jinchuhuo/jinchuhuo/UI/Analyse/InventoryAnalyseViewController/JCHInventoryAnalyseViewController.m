//
//  JCHAnalyseInventoryViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/26.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHInventoryAnalyseViewController.h"
#import "JCHAnalyseInventoryMiddleView.h"
#import "JCHPieChartView.h"
#import "JCHAnalyseInventoryFooterView.h"
#import "JCHAnalyseInventoryTableViewCell.h"
#import "JCHAnalyseInventoryTableSectionVIew.h"
#import "ServiceFactory.h"
#import "ReportData4Cocoa.h"
#import "NSString+JCHString.h"
#import "CommonHeader.h"
#import "JCHTitleArrowButton.h"
#import "JCHMenuView.h"
#import <Masonry.h>

@interface JCHInventoryAnalyseViewController () <UITableViewDataSource, UITableViewDelegate, JCHPieChartViewDelegate, JCHMenuViewDelegate>
{
    JCHTitleArrowButton *_titleButton;
    JCHPieChartView *_pieChartView;
    JCHAnalyseInventoryMiddleView *_middleView;
    UITableView *_contentTableView;
    JCHAnalyseInventoryFooterView *_footerView;
    BOOL viewDidAppear;
}

@property (nonatomic, retain) NSArray *productReportData;
@property (nonatomic, retain) NSArray *categoryReportData;
@property (nonatomic, retain) NSMutableArray *productsInCategory;
@property (nonatomic, assign) CGFloat totalAmount;

@property (nonatomic, retain) NSArray *warehouseList;
@property (nonatomic, retain) NSString *selectedWarehouseID;

@end

@implementation JCHInventoryAnalyseViewController

- (void)dealloc
{
    [self.productReportData release];
    [self.categoryReportData release];
    [self.productsInCategory release];
    [self.warehouseList release];
    [self.selectedWarehouseID release];
    
    _pieChartView.delegate = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *defaultWarehouseID = [[[ServiceFactory sharedInstance] utilityService] getDefaultWarehouseUUID];
    
    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
    WarehouseRecord4Cocoa *warehouseRecord = [warehouseService queryWarehouseByUUID:defaultWarehouseID];
    
    
    _titleButton = [JCHTitleArrowButton buttonWithType:UIButtonTypeCustom];
    _titleButton.frame = CGRectMake(0, 0, 40, 50);
    _titleButton.autoReverseArrow = YES;
    _titleButton.autoAdjustButtonWidth = YES;
    _titleButton.maxWidth = 100;
    [_titleButton setImage:[UIImage imageNamed:@"homepage_storename_open"] forState:UIControlStateNormal];
    _titleButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [_titleButton setTitle:warehouseRecord.warehouseName forState:UIControlStateNormal];
    [_titleButton addTarget:self action:@selector(handleShowWarehouseSelectMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = _titleButton;
    self.productsInCategory = [NSMutableArray array];
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    viewDidAppear = YES;
    [_pieChartView startAnimation];
}

- (void)createUI
{
    if (self.categoryReportData.count == 0) {
        
        UIImageView *backgroundImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"analyse_inventory_bg"]] autorelease];
        [self.view addSubview:backgroundImageView];
        
        [backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        
        return;
    }
    
    self.view.backgroundColor = JCHColorGlobalBackground;
    CGFloat pieChartViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:260];
    if (iPhone4) {
        pieChartViewHeight = 190;
    }
    const CGFloat middleViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:45];
    
    _pieChartView = [[[JCHPieChartView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, pieChartViewHeight) values:self.categoryReportData] autorelease];
    
    _pieChartView.delegate = self;
    [self.view addSubview:_pieChartView];
    
    [_pieChartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.height.mas_equalTo(pieChartViewHeight);
    }];
    
    _middleView = [[[JCHAnalyseInventoryMiddleView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, middleViewHeight)] autorelease];
    [self.view addSubview:_middleView];
    
    [_middleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(_pieChartView.mas_bottom);
        make.height.mas_equalTo(middleViewHeight);
    }];
    
    
    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    _contentTableView.delegate = self;
    _contentTableView.dataSource = self;
    _contentTableView.bounces = YES;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_contentTableView];
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_middleView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view).with.offset(-49);
    }];
    
    _footerView = [[[JCHAnalyseInventoryFooterView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 49 - 64, kScreenWidth, 49)] autorelease];
    [self.view addSubview:_footerView];
    [_footerView setData:[NSString stringWithFormat:@"%.2f", self.totalAmount]];
}

- (void)loadData
{
    [MBProgressHUD showHUDWithTitle:@"加载中..."
                             detail:nil
                           duration:100
                               mode:MBProgressHUDModeIndeterminate
                          superView:self.view
                         completion:nil];
    
    // 库存分析
    id<FinanceCalculateService> calculateService = [[ServiceFactory sharedInstance] financeCalculateService];
    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *productReportData = nil;
        NSArray *categoryReportData = nil;
        CGFloat totalAmount = 0;
        [calculateService calculateInventoryReportData:self.selectedWarehouseID
                                         productReport:&productReportData
                                        categoryReport:&categoryReportData
                                  totalInventoryAmount:&totalAmount];

        
        self.totalAmount = totalAmount;
        
        
        //过滤金额为0的类型
        NSMutableArray *filteredCategoryReportData = [NSMutableArray array];
        for (InventoryCategoryReportData4Cocoa *data in categoryReportData) {
            if (data.totalAmount != 0) {
                [filteredCategoryReportData addObject:data];
            }
            
            //如果该类型的所有商品库存都不为正，过滤
            BOOL categoryShouleRemoved = YES;
            for (InventoryProductReportData4Cocoa *productData in productReportData) {
                if ([productData.categoryName isEqualToString:data.categoryName]) {
                    if (productData.totalAmount > 0) {
                        categoryShouleRemoved = NO;
                        break;
                    }
                }
            }
            if (categoryShouleRemoved) {
                [filteredCategoryReportData removeObject:data];
            }
        }
        self.categoryReportData = filteredCategoryReportData;
        
        
        //过滤库存不为正的商品
        NSMutableArray *filteredProductReportData = [NSMutableArray array];
        for (InventoryProductReportData4Cocoa *data in productReportData) {
            if (data.totalCount > 0) {
                [filteredProductReportData addObject:data];
            }
        }
        
        self.productReportData = filteredProductReportData;
        
        NSArray *warehouseArray = [warehouseService queryAllWarehouse];
        
        NSMutableArray *enableWarehouseArray = [NSMutableArray array];
        for (WarehouseRecord4Cocoa *warehouseRecord in warehouseArray) {
            if (warehouseRecord.warehouseStatus == 0) {
                [enableWarehouseArray addObject:warehouseRecord];
            }
        }
        self.warehouseList = enableWarehouseArray;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [self createUI];
            [MBProgressHUD hideHUDForView:self.view animated:NO];
            if (viewDidAppear) {
                [_pieChartView startAnimation];
            }
        });
    });
}

- (void)handleShowWarehouseSelectMenu:(UIButton *)sender
{
    sender.selected = !sender.selected;
    CGFloat menuViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:120];
    CGFloat maxHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:200];
    
    NSMutableArray *titles = [NSMutableArray array];
    for (WarehouseRecord4Cocoa *warehouseRecord in self.warehouseList) {
        [titles addObject:warehouseRecord.warehouseName];
    }
    JCHMenuView *menuView = [[[JCHMenuView alloc] initWithTitleArray:titles
                                                          imageArray:nil
                                                              origin:CGPointMake(kScreenWidth / 2 - menuViewWidth / 2 - 10, 55)
                                                               width:menuViewWidth
                                                           rowHeight:kStandardItemHeight
                                                           maxHeight:maxHeight
                                                              Direct:kCenterTriangle] autorelease];
    menuView.delegate = self;
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    [window addSubview:menuView];
}

#pragma mark - JCHMenuViewDelegate
- (void)menuItemDidSelected:(JCHMenuView *)menuView indexPath:(NSIndexPath*)indexPath
{
    WarehouseRecord4Cocoa *warehouseRecord = self.warehouseList[indexPath.row];
    
    if ([self.selectedWarehouseID isEqualToString:warehouseRecord.warehouseID]) {
        return;
    } else {
        self.selectedWarehouseID = warehouseRecord.warehouseID;
        [_titleButton setTitle:warehouseRecord.warehouseName forState:UIControlStateNormal];
        [self loadData];
    }

}
- (void)menuViewDidHide
{
    _titleButton.selected = NO;
}

#pragma mark - JCHPieChartViewDelegate
- (void)reloadData:(InventoryCategoryReportData4Cocoa *)categoryReportData
{
    JCHAnalyseInventoryMiddleViewData *data = [[[JCHAnalyseInventoryMiddleViewData alloc] init] autorelease];
    
    data.categoryName = categoryReportData.categoryName;
    data.rate = [NSString stringWithFormat:@"%.1f%%", categoryReportData.rate * 100];
    data.amount = [NSString stringWithFormat:@"%.2f", categoryReportData.totalAmount];
    
    [_middleView setData:data];
    
    [self.productsInCategory removeAllObjects];
    for (InventoryProductReportData4Cocoa *productReportData in self.productReportData) {
        if ([productReportData.categoryName isEqualToString:categoryReportData.categoryName]) {
            [self.productsInCategory addObject:productReportData];
        }
    }
    [_contentTableView reloadData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.productsInCategory.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHAnalyseInventoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHAnalyseInventoryTableViewCell"];
    if (cell == nil) {
        cell = [[[JCHAnalyseInventoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JCHAnalyseInventoryTableViewCell"] autorelease];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row % 2 == 1) {
        cell.backgroundColor = RGBColor(248, 248, 248, 1);
    }
    else
    {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    JCHAnalyseInventoryTableViewCellData *data = [[[JCHAnalyseInventoryTableViewCellData alloc] init] autorelease];
    
    InventoryProductReportData4Cocoa *reportData = self.productsInCategory[indexPath.row];
    data.productName = [NSString stringWithFormat:@"%@/%@", reportData.productName, reportData.productUnit];
    data.productCount = [NSString stringFromCount:reportData.totalCount unitDigital:reportData.unitDigitCount];
    data.productAmount = [NSString stringWithFormat:@"¥ %.2f", reportData.totalAmount];
    data.productRate = [NSString stringWithFormat:@"%.1f%%", reportData.rate * 100];
    
    [cell setData:data];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return iPhone4 ? 25 : 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return iPhone4 ? 30 : 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[[JCHAnalyseInventoryTableSectionVIew alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, iPhone4 ? 25 : 30)] autorelease];
}
@end
