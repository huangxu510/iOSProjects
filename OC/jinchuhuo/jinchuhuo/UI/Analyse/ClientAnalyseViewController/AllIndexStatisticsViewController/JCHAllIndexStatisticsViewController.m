//
//  JCHAllIndexStatisticsViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/7/14.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAllIndexStatisticsViewController.h"
#import "JCHIndexIntroductionViewController.h"
#import "JCHAnalyseIndexStatisticsView.h"
#import "CommonHeader.h"

@interface JCHAllIndexStatisticsViewController ()
{
    UILabel *_dateRangeLabel;
    UIView *_indexStatisticsContainerView;
}
@property (nonatomic, retain) NSString *currentDateRange;
@property (nonatomic, retain) CustomReportSummaryRecord4Cocoa *customReportSummaryRecord;
@property (nonatomic, retain) NSArray *indexStatisticsViews;
@property (nonatomic, retain) NSArray *titleArray;
@end

@implementation JCHAllIndexStatisticsViewController

- (instancetype)initWithDateRange:(NSString *)dateRange
        customReportSummaryRecord:(CustomReportSummaryRecord4Cocoa *)customReportSummaryRecord
{
    self = [super init];
    if (self) {
        self.title = @"客户统计指标";
        self.currentDateRange = dateRange;
        self.customReportSummaryRecord = customReportSummaryRecord;
        self.titleArray = @[@"销售总金额", @"退货总金额", @"净销售金额", @"客户数", @"单均价", @"毛利总额", @"毛利率", @"净赊销金额", @"未收总金额", @"本期货单退货金额"];
    }
    return self;
}

- (void)dealloc
{
    self.currentDateRange = nil;
    self.customReportSummaryRecord = nil;
    self.indexStatisticsViews = nil;
    self.title = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    [self createUI];
    [self loadData];
}

- (void)createUI
{
    UIButton *introductionButton = [JCHUIFactory createButton:CGRectMake(0, 0, 60, 44)
                                                       target:self
                                                       action:@selector(showIndexIntroduction)
                                                        title:@"指标说明"
                                                   titleColor:[UIColor whiteColor]
                                              backgroundColor:nil];
    introductionButton.titleLabel.font = JCHFont(14);
    UIBarButtonItem *barButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:introductionButton] autorelease];
    
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    _dateRangeLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@""
                                           font:JCHFont(14.0)
                                      textColor:JCHColorMainBody
                                         aligin:NSTextAlignmentCenter];
    _dateRangeLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_dateRangeLabel];
    
    [_dateRangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(kStandardItemHeight);
    }];

    UIView *honrizontalLine = [[[UIView alloc] init] autorelease];
    honrizontalLine.backgroundColor = JCHColorSeparateLine;
    [self.view addSubview:honrizontalLine];
    [honrizontalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(_dateRangeLabel);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    const CGFloat indexStatisticsViewHeight = [JCHSizeUtility calculateWidthWithSourceWidth:90.0f];
    const CGFloat indexStatisticsContainerViewHeight = indexStatisticsViewHeight * (ceil(self.titleArray.count / 3.0));
    
    _indexStatisticsContainerView = [[[UIView alloc] initWithFrame:CGRectMake(0, kStandardItemHeight + kStandardSeparateViewHeight, kScreenWidth, indexStatisticsContainerViewHeight)] autorelease];
    _indexStatisticsContainerView.backgroundColor = [UIColor whiteColor];
    [_indexStatisticsContainerView addSeparateLineWithMasonryTop:YES bottom:YES];
    [self.view addSubview:_indexStatisticsContainerView];
    
    NSMutableArray *indexStatisticsViews = [NSMutableArray array];
    CGFloat indexStatisticsViewWidth = kScreenWidth / 3;
    for (NSInteger i = 0; i < self.titleArray.count; i++) {
        CGFloat x = indexStatisticsViewWidth * (i % 3);
        CGFloat y = indexStatisticsViewHeight * (i / 3);
        CGRect frame = CGRectMake(x, y, indexStatisticsViewWidth, indexStatisticsViewHeight);
        JCHAnalyseIndexStatisticsView *indexStatisticsView = [[[JCHAnalyseIndexStatisticsView alloc] initWithFrame:frame] autorelease];
        [indexStatisticsView addSeparateLineWithMasonryTop:NO bottom:YES];
        [_indexStatisticsContainerView addSubview:indexStatisticsView];
        [indexStatisticsViews addObject:indexStatisticsView];
    }
    self.indexStatisticsViews = indexStatisticsViews;
}

- (void)loadData
{
    _dateRangeLabel.text = self.currentDateRange;
    
    for (NSInteger i = 0; i < self.indexStatisticsViews.count; i++) {

        JCHAnalyseIndexStatisticsView *indexStatisticsView = self.indexStatisticsViews[i];
        JCHAnalyseIndexStatisticsViewData *data = [[[JCHAnalyseIndexStatisticsViewData alloc] init] autorelease];
        
        data.title = self.titleArray[i];
        
        switch (i) {
            case 0://销售总金额 / 销售总单数
            {
                data.middleText = [NSString stringWithFormat:@"¥%.2f", self.customReportSummaryRecord.totalSaleAmount];
                data.bottomText = [NSString stringWithFormat:@"%ld单", self.customReportSummaryRecord.totalSaleManifestCount];
            }
                break;
                
            case 1://退货总金额 / 退货单数
            {
                data.middleText = [NSString stringWithFormat:@"¥%.2f", self.customReportSummaryRecord.totalReturnAmount];
                data.bottomText = [NSString stringWithFormat:@"%ld单", self.customReportSummaryRecord.totalReturnManifestCount];
            }
                break;
                
            case 2://净销售金额 / 净销售单数
            {
                data.middleText = [NSString stringWithFormat:@"¥%.2f", self.customReportSummaryRecord.netSaleAmount];
                data.bottomText = [NSString stringWithFormat:@"%ld单", self.customReportSummaryRecord.netSaleManifestCount];
            }
                break;
                
            case 3://客户数
            {
                data.middleText = [NSString stringWithFormat:@"%ld人", self.customReportSummaryRecord.totalCustomCount];
                data.bottomText = nil;
            }
                break;
                
            case 4://单均价
            {
                data.middleText = [NSString stringWithFormat:@"¥%.2f", self.customReportSummaryRecord.perManifestAmount];
                data.bottomText = nil;
            }
                break;
                
            case 5://毛利总额
            {
                data.middleText = [NSString stringWithFormat:@"¥%.2f", self.customReportSummaryRecord.totalProfitAmount];
                data.bottomText = nil;
            }
                break;
                
            case 6://毛利率
            {
                data.middleText = [NSString stringWithFormat:@"%.2f%%", self.customReportSummaryRecord.profitRatio * 100];
                data.bottomText = nil;
            }
                break;
                
            case 7://净赊销总金额/订单数
            {
                data.middleText = [NSString stringWithFormat:@"¥%.2f", self.customReportSummaryRecord.netCreditSaleAmount];
                data.bottomText = [NSString stringWithFormat:@"%ld单", self.customReportSummaryRecord.netCreditSaleManifestCount];
            }
                break;
                
            case 8://未收总金额/订单数
            {
                data.middleText = [NSString stringWithFormat:@"¥%.2f", self.customReportSummaryRecord.totalARAmount];
                data.bottomText = [NSString stringWithFormat:@"%ld单", self.customReportSummaryRecord.arManifestCount];
            }
                break;
                
            case 9://本期货单退货金额/订单数
            {
                data.middleText = [NSString stringWithFormat:@"¥%.2f", self.customReportSummaryRecord.manifestReturnAmount];
                data.bottomText = [NSString stringWithFormat:@"%ld单", self.customReportSummaryRecord.manifestReturnCount];
            }
                break;
                
            default:
                break;
        }
        
        [indexStatisticsView setViewData:data];
    }
    
}

- (void)showIndexIntroduction
{
    JCHIndexIntroductionViewController *introductionViewController = [[[JCHIndexIntroductionViewController alloc] init] autorelease];
    [self.navigationController pushViewController:introductionViewController animated:YES];
}

@end
