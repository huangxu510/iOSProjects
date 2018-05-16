//
//  JCHCustomAnalyseViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/7/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHClientAnalyseViewController.h"
#import "JCHClientDetailAnalyseViewController.h"
#import "JCHAllIndexStatisticsViewController.h"
#import "JCHIndexSelectDropdownMenu.h"
#import "JCHDateRangePickView.h"
#import "JCHDatePickDropdownMenu.h"
#import "JCHAnalyseIndexStatisticsView.h"
#import "JCHClientAnalyseTableViewCell.h"
#import "CommonHeader.h"

typedef NS_ENUM(NSInteger, JCHClientAnalyseIndex)
{
    //销售指标
    kJCHClientAnalyseIndexTotalSaleAmount = 0,          //销售总金额
    kJCHClientAnalyseIndexTotalManifestCount,           //订单数量
    kJCHClientAnalyseIndexSaleAmountRatio,              //销售金额占比
    kJCHClientAnalyseIndexTotalNetSaleAmount,           //净销金额
    kJCHClientAnalyseIndexTotalNetManifestCount,        //净销单数
    kJCHClientAnalyseIndexNetSaleAmountRatio,           //净销金额占比
    kJCHClientAnalyseIndexSaleOnAccountAmount,          //净赊销金额
    kJCHClientAnalyseIndexTotalARAmount,                //赊销未还款金额
    
    //毛利指标
    kJCHClientAnalyseIndexTotalProfitAmount = 9,        //毛利总金额
    kJCHClientAnalyseIndexTotalProfitRation,            //毛利率
    
    //退货指标
    kJCHClientAnalyseIndexTotalReturnAmount = 12,       //退货金额
    kJCHClientAnalyseIndexTotalReturnManifestCount,     //退货订单数量
    kJCHClientAnalyseIndexTotalReturnAmountRatio,       //退货金额占比
    kJCHClientAnalyseIndexReturnAmount,                 //本期货单退货金额:本期原单的退货金额（不管在什么时候退的）
    //kJCHClientAnalyseIndexPerManifestAmount,            //单均价
};

@interface JCHClientAnalyseViewController ()   <UITableViewDelegate,
                                                UITableViewDataSource,
                                                JCHDatePickDropdownMenuDelegate,
                                                JCHDateRangePickViewDelegate,
                                                UIScrollViewDelegate,
                                                JCHIndexSelectDropdownMenuDelegate>
{
    JCHDatePickDropdownMenu *_dropdownMenu;
    UIView *_indexStatisticsContainerView;
    JCHPlaceholderView *_placeholderView;
}
@property (nonatomic, retain) JCHIndexSelectDropdownMenu *sectionView;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger endTime;
@property (nonatomic, retain) NSArray *customReportRecordsInRange;
@property (nonatomic, retain) CustomReportSummaryRecord4Cocoa *customReportSummaryRecord;

@property (nonatomic, retain) NSArray *dataSource;
@property (nonatomic, retain) NSArray *allIndex;
@property (nonatomic, retain) NSMutableArray *visibleIndexPaths;

//! @brief 当前选择的指标
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@end

@implementation JCHClientAnalyseViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"客户统计";
        self.allIndex = @[@[@"销售金额", @"销售单数", @"销售金额占比", @"净销金额", @"净销单数", @"净销金额占比",@"净赊销金额", @"赊销未收款金额", @""],
                          @[@"毛利金额", @"毛利占比", @""],
                          @[@"退货金额", @"退货订单数", @"退货金额占比",@"本期货单退货金额", @"", @""]];
        
        self.selectedIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    return self;
}

- (void)dealloc
{
    self.sectionView = nil;
    self.customReportRecordsInRange = nil;
    self.dataSource = nil;
    self.allIndex = nil;
    self.customReportSummaryRecord = nil;
    self.visibleIndexPaths = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
    [self setInitDateRange];
    [self loadData];
}

- (void)setInitDateRange
{
    //默认显示本月
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd"];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitDay fromDate:date];
    
    NSInteger day = dateComponents.day;
    
    NSString *endDate = [dateFormater stringFromDate:date];
    self.endTime = [endDate stringToSecondsEndTime:YES];
    self.startTime = self.endTime + 1 - day * 24 * 3600;
    NSString *startDate = [NSString stringFromSeconds:self.startTime dateStringType:kJCHDateStringType1];
    
    
    [_dropdownMenu setTitle:[NSString stringWithFormat:@"%@ 至 %@", startDate, endDate]];
}

- (void)createUI
{
    const CGFloat indexStatisticsContainerViewHeight = [JCHSizeUtility calculateWidthWithSourceWidth:94.0f];
    const CGFloat moreButtonHeight = 30;
    UIView *headerView = [[[UIView alloc] init] autorelease];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.frame = CGRectMake(0, 0, kScreenWidth, kStandardItemHeight + indexStatisticsContainerViewHeight + moreButtonHeight);
    
    _dropdownMenu = [[[JCHDatePickDropdownMenu alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kStandardItemHeight) controllerView:self.view] autorelease];
    _dropdownMenu.dataSource = @[@"本周", @"本月", @"上月", @"上上月", @"自定义区间"];
    _dropdownMenu.delegate = self;
    _dropdownMenu.defaultRow = 1;
    [headerView addSubview:_dropdownMenu];
    
    _indexStatisticsContainerView = [[[UIView alloc] initWithFrame:CGRectMake(0, kStandardItemHeight, kScreenWidth, indexStatisticsContainerViewHeight)] autorelease];
    _indexStatisticsContainerView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:_indexStatisticsContainerView];
    
    NSArray *titleArray = @[@"销售总金额", @"净销售总金额", @"毛利金额"];
    NSArray *intialBottomText = @[@"0单", @"0单", @"0.00%"];
    CGFloat indexStatisticsViewWidth = kScreenWidth / 3;
    for (NSInteger i = 0; i < 3; i++) {
        CGRect frame = CGRectMake(indexStatisticsViewWidth * i, 0, indexStatisticsViewWidth, indexStatisticsContainerViewHeight);
        JCHAnalyseIndexStatisticsView *indexStatisticsView = [[[JCHAnalyseIndexStatisticsView alloc] initWithFrame:frame] autorelease];
        [_indexStatisticsContainerView addSubview:indexStatisticsView];
        
        
        JCHAnalyseIndexStatisticsViewData *data = [[[JCHAnalyseIndexStatisticsViewData alloc] init] autorelease];
        data.title = titleArray[i];
        data.middleText = @"¥0.00";
        data.bottomText = intialBottomText[i];
        [indexStatisticsView setViewData:data];
    }
    
    UIButton *moreButton = [JCHUIFactory createButton:CGRectZero
                                               target:self
                                               action:@selector(showMoreIndex)
                                                title:@"查看更多"
                                           titleColor:JCHColorMainBody
                                      backgroundColor:[UIColor whiteColor]];
    moreButton.layer.borderColor = JCHColorMainBody.CGColor;
    moreButton.layer.borderWidth = kSeparateLineWidth;
    moreButton.titleLabel.font = JCHFont(12);
    moreButton.layer.cornerRadius = 4;
    [headerView addSubview:moreButton];
    
    [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_indexStatisticsContainerView.mas_bottom).with.offset(0);
        make.bottom.equalTo(headerView.mas_bottom).with.offset(-10);
        make.centerX.equalTo(headerView);
        make.width.mas_equalTo(70);
    }];
    
    self.tableView.tableHeaderView = headerView;
    [self.tableView registerClass:[JCHClientAnalyseTableViewCell class] forCellReuseIdentifier:@"cellTag"];
    
    _placeholderView = [[[JCHPlaceholderView alloc] initWithFrame:CGRectZero] autorelease];
    _placeholderView.hidden = YES;
    _placeholderView.imageView.image = [UIImage imageNamed:@"default_data_placeholder"];
    _placeholderView.label.text = @"该区间内暂无客户";
    [self.view addSubview:_placeholderView];
    
    CGFloat placeholderViewHeight = 158;
    CGFloat placeholderViewTopOffset = (kScreenHeight - 64) / 2;
    [_placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(placeholderViewHeight);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(self.view).with.offset(placeholderViewTopOffset);
    }];
}

#pragma mark - LoadData

- (void)loadData
{
    [MBProgressHUD showHUDWithTitle:@"加载中..."
                             detail:nil
                           duration:100
                               mode:MBProgressHUDModeIndeterminate
                          superView:self.view
                         completion:nil];
    
    id<FinanceCalculateService> financeCalculateService = [[ServiceFactory sharedInstance] financeCalculateService];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *customRecords = nil;
        CustomReportSummaryRecord4Cocoa *customReportSummaryRecord = nil;
        [financeCalculateService calculateCustomSumaryReport:self.startTime
                                                 endDatetime:self.endTime
                                               summaryReport:&customReportSummaryRecord
                                                customRecord:&customRecords];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.customReportRecordsInRange = customRecords;
            self.customReportSummaryRecord = customReportSummaryRecord;
            
            //加载完数据默认显示销售金额指标
            [self indexSelectDropdownMenuDidHideSelectIndexPath:self.selectedIndexPath];
            
            NSArray *titleArray = @[@"销售总金额", @"净销售总金额", @"毛利金额"];
            for (NSInteger i = 0; i < 3; i++) {
                UIView *subView = _indexStatisticsContainerView.subviews[i];
                if ([subView isKindOfClass:[JCHAnalyseIndexStatisticsView class]]) {
                    JCHAnalyseIndexStatisticsView *indexStatisticsView = (JCHAnalyseIndexStatisticsView *)subView;
                    JCHAnalyseIndexStatisticsViewData *data = [[[JCHAnalyseIndexStatisticsViewData alloc] init] autorelease];
                    
                    data.title = titleArray[i];
                    if (i == 0) {
                        data.middleText = [NSString stringWithFormat:@"¥%.2f", customReportSummaryRecord.totalSaleAmount];
                        data.bottomText = [NSString stringWithFormat:@"%ld单", customReportSummaryRecord.totalSaleManifestCount];
                    } else if (i == 1) {
                        data.middleText = [NSString stringWithFormat:@"¥%.2f", customReportSummaryRecord.netSaleAmount];
                        data.bottomText = [NSString stringWithFormat:@"%ld单", customReportSummaryRecord.netSaleManifestCount];
                    } else {
                        data.middleText = [NSString stringWithFormat:@"¥%.2f", customReportSummaryRecord.totalProfitAmount];
                        data.bottomText = [NSString stringWithFormat:@"%.2f%%", customReportSummaryRecord.profitRatio * 100];
                    }
                    
                    [indexStatisticsView setViewData:data];
                }
            }
            [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        });
    });
}

- (void)showMoreIndex
{
    JCHAllIndexStatisticsViewController *allIndexViewController = [[[JCHAllIndexStatisticsViewController alloc] initWithDateRange:[_dropdownMenu dateRange]
                                                                                                        customReportSummaryRecord:self.customReportSummaryRecord] autorelease];
    [self.navigationController pushViewController:allIndexViewController animated:YES];
}

- (void)handleSelectDateRange:(UIButton *)sender
{
    sender.selected = !sender.selected;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHClientAnalyseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellTag" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell -> _bottomLine.hidden = YES;
    if (indexPath.row % 2) {
        cell.backgroundColor = UIColorFromRGB(0xf8f8f8);
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    JCHClientAnalyseTableViewCellData *data = self.dataSource[indexPath.row];
    
    [cell setViewData:data];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.sectionView == nil) {
        self.sectionView = [[[JCHIndexSelectDropdownMenu alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kJCHIndexSelectDropdownMenuHeight) superView:self.view] autorelease];
        self.sectionView.dataSource = self.allIndex;
        self.sectionView.delegate = self;
        [self.sectionView addSeparateLineWithMasonryTop:YES bottom:YES];
    }
    
    self.sectionView.defaultOrignY = tableView.tableHeaderView.frame.size.height;
    [self.sectionView setManifestCount:self.dataSource.count];
    return self.sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kJCHIndexSelectDropdownMenuHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHClientAnalyseTableViewCellData *data = self.dataSource[indexPath.row];
    
    JCHClientDetailAnalyseViewController *clientDetailAnalyseViewController = [[[JCHClientDetailAnalyseViewController alloc] initWithCustomUUID:data.customUUID
                                                                                                                                      startTime:self.startTime
                                                                                                                                        endTime:self.endTime
                                                                                                                                isReturnedIndex:data.isReturnedIndex] autorelease];

    [self.navigationController pushViewController:clientDetailAnalyseViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.visibleIndexPaths containsObject:indexPath]) {
        JCHClientAnalyseTableViewCell *currentCell = (JCHClientAnalyseTableViewCell *)cell;
        [currentCell startAnimation];
        [self.visibleIndexPaths removeObject:indexPath];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.sectionView.superview) {
        self.sectionView.offsetY = scrollView.contentOffset.y;
    }
    
    _dropdownMenu.offsetY = scrollView.contentOffset.y;
}

- (NSInteger)getNumberOfDaysInMonth:(NSDate *)date
{
    NSCalendar * calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] autorelease]; // 指定日历的算法
    
    // 只要个时间给日历,就会帮你计算出来。这里的时间取当前的时间。
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay
                                   inUnit:NSCalendarUnitMonth
                                  forDate:date];
    return range.length;
}

#pragma mark - JCHDatePickDropdownMenuDelegate

- (void)datePickDropdownMenuDidHideSelectRow:(NSInteger)row
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd"];
    NSString *endDate = [dateFormater stringFromDate:date];
    self.endTime = [endDate stringToSecondsEndTime:YES];
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger calendarUnits = NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSDateComponents *dateComponents = [calendar components:calendarUnits fromDate:date];
    
    NSInteger day = dateComponents.day;
    NSInteger weakday = dateComponents.weekday;

    switch (row) {
        case 0:   //本周
        {
            //weakday 1 - 周日   2 - 周一
            
            if (weakday == 1) {
                weakday = 7;
            } else {
                weakday--;
            }
            self.startTime = self.endTime + 1 - weakday * 24 * 3600;
            NSString *startDate = [NSString stringFromSeconds:self.startTime dateStringType:kJCHDateStringType1];
            [_dropdownMenu setTitle:[NSString stringWithFormat:@"%@ 至 %@", startDate, endDate]];
            [self loadData];
        }
            break;
            
        case 1:   //本月
        {
            self.startTime = self.endTime + 1 - day * 24 * 3600;
            NSString *startDate = [NSString stringFromSeconds:self.startTime dateStringType:kJCHDateStringType1];
            [_dropdownMenu setTitle:[NSString stringWithFormat:@"%@ 至 %@", startDate, endDate]];
            [self loadData];
        }
            break;
            
        case 2:   //上月
        {
            //上个月的截至日期就是本月初的时间减1
            self.endTime = self.endTime - day * 24 * 3600;
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:self.endTime];
            NSString *endDateString = [dateFormater stringFromDate:endDate];
            
            //上个月的天数
            NSInteger numberOfDaysLastMonth = [self getNumberOfDaysInMonth:endDate];
            
            self.startTime = self.endTime + 1 - numberOfDaysLastMonth * 24 * 3600;
            NSString *startDateString = [NSString stringFromSeconds:self.startTime dateStringType:kJCHDateStringType1];
            [_dropdownMenu setTitle:[NSString stringWithFormat:@"%@ 至 %@", startDateString, endDateString]];
            [self loadData];
        }
            break;
            
        case 3:   //上上月
        {
            //上个月的截至日期就是本月初的时间减1
            self.endTime = self.endTime - day * 24 * 3600;
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:self.endTime];
            
            
            //上个月的天数
            NSInteger numberOfDaysLastMonth = [self getNumberOfDaysInMonth:endDate];
            
            //上上个月的截至日期
            self.endTime = self.endTime - numberOfDaysLastMonth * 24 * 3600;
            endDate = [NSDate dateWithTimeIntervalSince1970:self.endTime];
            NSString *endDateString = [dateFormater stringFromDate:endDate];
            
            NSInteger numberOfDaysLastLastMonth = [self getNumberOfDaysInMonth:endDate];
            
            self.startTime = self.endTime + 1 - numberOfDaysLastLastMonth * 24 * 3600;
            NSString *startDateString = [NSString stringFromSeconds:self.startTime dateStringType:kJCHDateStringType1];
            [_dropdownMenu setTitle:[NSString stringWithFormat:@"%@ 至 %@", startDateString, endDateString]];
            [self loadData];
        }
            break;
            
        case 4:    //自定义区间
        {
            JCHDateRangePickView *dateRangePickView = [[[JCHDateRangePickView alloc] initWithFrame:CGRectZero] autorelease];
            dateRangePickView.delegate = self;
            dateRangePickView.datePickerMode = UIDatePickerModeDate;
            dateRangePickView.defaultStartTime = [_dropdownMenu startTime];
            dateRangePickView.defaultEndTime = [_dropdownMenu endTime];
            [dateRangePickView showView];
        }
            
        default:
            break;
    }
}

- (void)datePickDropdownMenuWillShow
{
    if (self.sectionView.isShow) {
        [self.sectionView hideView];
    }
}


#pragma mark - JCHDateRangePickViewDelegate

- (void)dateRangePickViewSelectDateRange:(JCHDateRangePickView *)dateRangePickView withStartTime:(NSString *)startTime endTime:(NSString *)endTime
{
    NSString *dateRange = [NSString stringWithFormat:@"%@ 至 %@", startTime, endTime];
    [_dropdownMenu setTitle:dateRange];
    

    self.endTime = [endTime stringToSecondsEndTime:YES];
    self.startTime = [startTime stringToSecondsEndTime:NO];;
    
    [self loadData];
}

#pragma mark - JCHIndexSelectDropdownMenuDelegate
- (void)indexSelectDropdownMenuDidShow;
{
    self.tableView.scrollEnabled = NO;
}
- (void)indexSelectDropdownMenuDidHide
{
    self.tableView.scrollEnabled = YES;
}

- (void)indexSelectDropdownMenuSortData:(BOOL)ascending
{
    self.dataSource = [self.dataSource sortedArrayUsingComparator:^NSComparisonResult(JCHClientAnalyseTableViewCellData *obj1, JCHClientAnalyseTableViewCellData *obj2) {
        if (ascending) {
            return obj1.rightAmount > obj2.rightAmount;
        } else {
            return obj1.rightAmount < obj2.rightAmount;
        }
        
    }];
    
    if (self.dataSource.count == 0) {
        _placeholderView.hidden = NO;
    } else {
        _placeholderView.hidden = YES;
    }
    
    [self.tableView reloadData];
    NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
    self.visibleIndexPaths = [NSMutableArray arrayWithArray:visibleIndexPaths];
    
    //! @note 强制刷新tableview 这样后面的代码在tableview刷新完了才走
    [self.tableView layoutIfNeeded];
    self.sectionView.offsetY = self.tableView.contentOffset.y;
}

- (void)indexSelectDropdownMenuDidHideSelectIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    
    NSInteger index = 0;

    if (indexPath.section == 0) {
        index = indexPath.row;
    } else if (indexPath.section == 1) {
        index = indexPath.row + [self.allIndex[0] count];
    } else {
        index = indexPath.row + [self.allIndex[0] count] + [self.allIndex[1] count];
    }
    NSMutableArray *dataSource = [NSMutableArray array];
    switch (index) {
        case kJCHClientAnalyseIndexTotalSaleAmount:         //销售总金额
        {
            //找到该指标的最大值
            CGFloat maxIndexValue = 0;
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                maxIndexValue = MAX(maxIndexValue, customReportRecord.totalSaleAmount);
            }
            
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                JCHClientAnalyseTableViewCellData *data = [[[JCHClientAnalyseTableViewCellData alloc] init] autorelease];
                data.name = customReportRecord.customName;
                data.rightAmount = customReportRecord.totalSaleAmount;
                data.percentage = maxIndexValue ? MAX(0, customReportRecord.totalSaleAmount / maxIndexValue) : 0;
                data.customUUID = customReportRecord.customUUID;
                data.numberType = kJCHClientAnalyseTableViewCellDataNumberTypeAmount;
                data.isReturnedIndex = NO;
                
                if (data.rightAmount != 0) {
                    [dataSource addObject:data];
                }
            }
        }
            break;
          
        case kJCHClientAnalyseIndexTotalManifestCount:      //订单数量
        {
            CGFloat maxIndexValue = 0;
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                maxIndexValue = (CGFloat)MAX(maxIndexValue, customReportRecord.totalManifestCount);
            }
            
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                JCHClientAnalyseTableViewCellData *data = [[[JCHClientAnalyseTableViewCellData alloc] init] autorelease];
                data.name = customReportRecord.customName;
                data.rightAmount = customReportRecord.totalManifestCount;
                data.percentage = maxIndexValue ? MAX(0, customReportRecord.totalManifestCount / maxIndexValue) : 0;
                data.customUUID = customReportRecord.customUUID;
                data.numberType = kJCHClientAnalyseTableViewCellDataNumberTypeCount;
                data.isReturnedIndex = NO;
                
                if (data.rightAmount != 0) {
                    [dataSource addObject:data];
                }
            }
        }
            break;
            
        case kJCHClientAnalyseIndexSaleAmountRatio:           //销售金额占比
        {
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                JCHClientAnalyseTableViewCellData *data = [[[JCHClientAnalyseTableViewCellData alloc] init] autorelease];
                data.name = customReportRecord.customName;
                data.rightAmount = customReportRecord.saleAmountRatio;
                data.percentage = customReportRecord.saleAmountRatio;
                data.customUUID = customReportRecord.customUUID;
                data.numberType = kJCHClientAnalyseTableViewCellDataNumberTypeRatio;
                data.isReturnedIndex = NO;
                
                if (data.rightAmount != 0) {
                    [dataSource addObject:data];
                }
            }
        }
            break;

        case kJCHClientAnalyseIndexTotalNetSaleAmount:              //净销金额: 总销售金额 - 退货金额
        {
            CGFloat maxIndexValue = 0;
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                maxIndexValue = MAX(maxIndexValue, customReportRecord.netSaleAmount);
            }
            
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                JCHClientAnalyseTableViewCellData *data = [[[JCHClientAnalyseTableViewCellData alloc] init] autorelease];
                data.name = customReportRecord.customName;
                data.rightAmount = customReportRecord.netSaleAmount;
                data.percentage = maxIndexValue ? MAX(0, (customReportRecord.netSaleAmount) / maxIndexValue) : 0;
                data.customUUID = customReportRecord.customUUID;
                data.numberType = kJCHClientAnalyseTableViewCellDataNumberTypeAmount;
                data.isReturnedIndex = NO;
                
                if (data.rightAmount != 0) {
                    [dataSource addObject:data];
                }
            }
        }
            break;
            
        case kJCHClientAnalyseIndexTotalNetManifestCount:           //净销单数: 总销售单数 - 退货单数
        {
            CGFloat maxIndexValue = 0;
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                maxIndexValue = (CGFloat)MAX(maxIndexValue, customReportRecord.netSaleManifestCount);
            }
            
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                JCHClientAnalyseTableViewCellData *data = [[[JCHClientAnalyseTableViewCellData alloc] init] autorelease];
                data.name = customReportRecord.customName;;
                data.rightAmount = customReportRecord.netSaleManifestCount;
                data.percentage = maxIndexValue ? MAX(0, (customReportRecord.netSaleManifestCount) / maxIndexValue) : 0;
                data.customUUID = customReportRecord.customUUID;
                data.numberType = kJCHClientAnalyseTableViewCellDataNumberTypeCount;;
                data.isReturnedIndex = NO;
                
                if (data.rightAmount != 0) {
                    [dataSource addObject:data];
                }
            }
        }
            break;
            
        case kJCHClientAnalyseIndexNetSaleAmountRatio:              //净销金额占比: 净销售金额 / 总销售金额
        {
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                JCHClientAnalyseTableViewCellData *data = [[[JCHClientAnalyseTableViewCellData alloc] init] autorelease];
                data.name = customReportRecord.customName;
                data.rightAmount = customReportRecord.netSaleAmountRatio;
                data.percentage = data.rightAmount;
                data.customUUID = customReportRecord.customUUID;
                data.numberType = kJCHClientAnalyseTableViewCellDataNumberTypeRatio;
                data.isReturnedIndex = NO;
                
                if (data.rightAmount != 0) {
                    [dataSource addObject:data];
                }
            }
        }
            break;
            
        case kJCHClientAnalyseIndexSaleOnAccountAmount:             //净赊销金额
        {
            //找到该指标的最大值
            CGFloat maxIndexValue = 0;
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                maxIndexValue = MAX(maxIndexValue, customReportRecord.totalCreditSaleAmount);
            }
            
            
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                JCHClientAnalyseTableViewCellData *data = [[[JCHClientAnalyseTableViewCellData alloc] init] autorelease];
                data.name = customReportRecord.customName;
                data.rightAmount = customReportRecord.totalCreditSaleAmount;
                data.percentage = maxIndexValue ? MAX(0, customReportRecord.totalCreditSaleAmount / maxIndexValue) : 0;
                data.customUUID = customReportRecord.customUUID;
                data.numberType = kJCHClientAnalyseTableViewCellDataNumberTypeAmount;
                data.isReturnedIndex = NO;
                
                if (data.rightAmount != 0) {
                    [dataSource addObject:data];
                }
            }
        }
            break;
            
        case kJCHClientAnalyseIndexTotalARAmount:                   //赊销未还款金额
        {
            CGFloat maxIndexValue = 0;
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                maxIndexValue = MAX(maxIndexValue, customReportRecord.totalARAmount);
            }
            
            
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                JCHClientAnalyseTableViewCellData *data = [[[JCHClientAnalyseTableViewCellData alloc] init] autorelease];
                data.name = customReportRecord.customName;
                data.rightAmount = customReportRecord.totalARAmount;
                data.percentage = maxIndexValue ? MAX(0, customReportRecord.totalARAmount / maxIndexValue) : 0;
                data.customUUID = customReportRecord.customUUID;
                data.numberType = kJCHClientAnalyseTableViewCellDataNumberTypeAmount;
                data.isReturnedIndex = NO;
                
                if (data.rightAmount != 0) {
                    [dataSource addObject:data];
                }
            }
        }
            break;
            
        case kJCHClientAnalyseIndexTotalProfitAmount:           //毛利总金额
        {
            CGFloat maxIndexValue = 0;
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                maxIndexValue = MAX(maxIndexValue, customReportRecord.totalProfitAmount);
            }
            
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                JCHClientAnalyseTableViewCellData *data = [[[JCHClientAnalyseTableViewCellData alloc] init] autorelease];
                data.name = customReportRecord.customName;;
                data.rightAmount = customReportRecord.totalProfitAmount;
                data.percentage = maxIndexValue ? MAX(0, customReportRecord.totalProfitAmount / maxIndexValue) : 0;
                data.customUUID = customReportRecord.customUUID;
                data.numberType = kJCHClientAnalyseTableViewCellDataNumberTypeAmount;
                data.isReturnedIndex = NO;
                
                if (data.rightAmount != 0) {
                    [dataSource addObject:data];
                }
            }
        }
            break;
            
        case kJCHClientAnalyseIndexTotalProfitRation:           //毛利率
        {
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                JCHClientAnalyseTableViewCellData *data = [[[JCHClientAnalyseTableViewCellData alloc] init] autorelease];
                data.name = customReportRecord.customName;;
                data.rightAmount = customReportRecord.profitRatio;
                data.percentage = customReportRecord.profitRatio;
                data.customUUID = customReportRecord.customUUID;
                data.numberType = kJCHClientAnalyseTableViewCellDataNumberTypeRatio;
                data.isReturnedIndex = NO;
                
                if (data.rightAmount != 0) {
                    [dataSource addObject:data];
                }
            }
        }
            break;
            
        case kJCHClientAnalyseIndexTotalReturnAmount:            //退货金额
        {
            CGFloat maxIndexValue = 0;
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                maxIndexValue = MAX(maxIndexValue, customReportRecord.totalReturnAmount);
            }
            
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                JCHClientAnalyseTableViewCellData *data = [[[JCHClientAnalyseTableViewCellData alloc] init] autorelease];
                data.name = customReportRecord.customName;;
                data.rightAmount = customReportRecord.totalReturnAmount;
                data.percentage = maxIndexValue ? MAX(0, customReportRecord.totalReturnAmount / maxIndexValue) : 0;
                data.customUUID = customReportRecord.customUUID;
                data.numberType = kJCHClientAnalyseTableViewCellDataNumberTypeAmount;
                data.isReturnedIndex = YES;
                
                if (data.rightAmount != 0) {
                    [dataSource addObject:data];
                }
            }
        }
            break;
            
        case kJCHClientAnalyseIndexTotalReturnManifestCount:        //退货订单数量
        {
            CGFloat maxIndexValue = 0;
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                maxIndexValue = (CGFloat)MAX(maxIndexValue, customReportRecord.totalReturnManifestCount);
            }
            
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                JCHClientAnalyseTableViewCellData *data = [[[JCHClientAnalyseTableViewCellData alloc] init] autorelease];
                data.name = customReportRecord.customName;;
                data.rightAmount = customReportRecord.totalReturnManifestCount;
                data.percentage = maxIndexValue ? MAX(0, customReportRecord.totalReturnManifestCount / maxIndexValue) : 0;
                data.customUUID = customReportRecord.customUUID;
                data.numberType = kJCHClientAnalyseTableViewCellDataNumberTypeCount;
                data.isReturnedIndex = YES;
                
                if (data.rightAmount != 0) {
                    [dataSource addObject:data];
                }
            }
        }
            break;
            
        case kJCHClientAnalyseIndexTotalReturnAmountRatio:          //退货金额占比
        {
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                JCHClientAnalyseTableViewCellData *data = [[[JCHClientAnalyseTableViewCellData alloc] init] autorelease];
                data.name = customReportRecord.customName;;
                data.rightAmount = customReportRecord.returnAmountRatio;
                data.percentage = MAX(0, customReportRecord.returnAmountRatio);
                data.customUUID = customReportRecord.customUUID;
                data.numberType = kJCHClientAnalyseTableViewCellDataNumberTypeRatio;
                data.isReturnedIndex = YES;
                
                if (data.rightAmount != 0) {
                    [dataSource addObject:data];
                }
            }
        }
            break;
            
        case kJCHClientAnalyseIndexReturnAmount:            //本期退货金额:本期原单的退货金额（不管在什么时候退的）
        {
            CGFloat maxIndexValue = 0;
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                maxIndexValue = MAX(maxIndexValue, customReportRecord.manifestReturnAmount);
            }
            
            for (NSInteger i = 0; i < self.customReportRecordsInRange.count; i++) {
                CustomReportRecord4Cocoa *customReportRecord = self.customReportRecordsInRange[i];
                JCHClientAnalyseTableViewCellData *data = [[[JCHClientAnalyseTableViewCellData alloc] init] autorelease];
                data.name = customReportRecord.customName;;
                data.rightAmount = customReportRecord.manifestReturnAmount;
                data.percentage = maxIndexValue ? MAX(0, customReportRecord.manifestReturnAmount / maxIndexValue) : 0;
                data.customUUID = customReportRecord.customUUID;
                data.numberType = kJCHClientAnalyseTableViewCellDataNumberTypeAmount;
                data.isReturnedIndex = YES;
                
                if (data.rightAmount != 0) {
                    [dataSource addObject:data];
                }
            }
        }
            break;
            
        default:
        {
            
        }
            break;
    }
    self.dataSource = dataSource;
    [self indexSelectDropdownMenuSortData:self.sectionView.ascending];
}

@end
