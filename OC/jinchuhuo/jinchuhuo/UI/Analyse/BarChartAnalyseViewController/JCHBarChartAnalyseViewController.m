//
//  JCHAnalysePurchaseViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/19.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHBarChartAnalyseViewController.h"
#import "JCHDatePickDropdownMenu.h"
#import "JCHDateRangePickView.h"
#import "JCHBarChartView.h"
#import "JCHDatePickerView.h"
#import "JCHAnalysesPurchaseTableView.h"
#import "JCHAnalysePurchaseFooterView.h"
#import "JCHSizeUtility.h"
#import "ServiceFactory.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import "ReportData4Cocoa.h"
#import "NSString+JCHString.h"
#import "CommonHeader.h"
#import <Masonry.h>

@interface JCHBarChartAnalyseViewController () <JCHDateRangePickViewDelegate, JCHDatePickDropdownMenuDelegate>
{
    JCHDatePickDropdownMenu *_dropdownMenu;
    JCHBarChartView *_barChartView;
    JCHAnalysesPurchaseTableView *_contentTableView;
    JCHAnalysePurchaseFooterView *_footerView;
    JCHPlaceholderView *_placeholderView;
    BOOL _isFirstChangeDate;
}

//交易日期
@property (retain, nonatomic, readwrite) NSArray *perDayAmountReportData;
//商品名称
@property (retain, nonatomic, readwrite) NSArray *perProductAmountReportData;
//商品分类
@property (retain, nonatomic, readwrite) NSArray *perCategoryAmountReportData;
@property (assign, nonatomic, readwrite) NSInteger startTime;
@property (assign, nonatomic, readwrite) NSInteger endTime;
@property (assign, nonatomic, readwrite) CGFloat totalProfitValue;
@property (assign, nonatomic, readwrite) CGFloat totalProfitRate;
@property (assign, nonatomic, readwrite) CGFloat totalAmountValue;

@end

@implementation JCHBarChartAnalyseViewController

- (void)dealloc
{
    [self.perDayAmountReportData release];
    [self.perProductAmountReportData release];
    [self.perCategoryAmountReportData release];
    
    [super dealloc];
    return;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if (self.enumAnalyseType == kJCHAnalysePurchase)
    {
        self.title = @"进货分析";
    }
    else if (self.enumAnalyseType == kJCHAnalyseShipment)
    {
        self.title = @"出货分析";
    }
    else if (self.enumAnalyseType == kJCHAnalyseProfit)
    {
        self.title = @"毛利分析";
    } else {
        //pass
    }
    _isFirstChangeDate = YES;
    
    [self createUI];
    
    [self setInitDateRange];
    
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_barChartView setNeedsDisplay];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    return;
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
    CGFloat dateRangePickerViewHeight = 44;
    CGFloat barChartViewHeight = 182;
    
    if (iPhone4) {
        dateRangePickerViewHeight = 40;
        barChartViewHeight = 150;
    }
    
    const CGFloat analysePurchaseFooterViewHeight = 49;

    
    _dropdownMenu = [[[JCHDatePickDropdownMenu alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, dateRangePickerViewHeight) controllerView:self.view] autorelease];
    _dropdownMenu.dataSource = @[@"今日", @"本周", @"本月", @"上月", @"上上月", @"自定义区间（范围最大为31天）"];
    _dropdownMenu.delegate = self;
    _dropdownMenu.defaultRow = 2;
    _dropdownMenu.textColor = [UIColor whiteColor];
    [self.view addSubview:_dropdownMenu];
    
    if (_enumAnalyseType == kJCHAnalyseProfit) {
        _dropdownMenu.backgroundColor =  RGBColor(102, 29, 167, 1.0);
    } else if (_enumAnalyseType == kJCHAnalyseShipment) {
        _dropdownMenu.backgroundColor = RGBColor(237, 116, 36, 1);
    } else {
        _dropdownMenu.backgroundColor = RGBColor(58, 88, 166, 1.0);
    }
    
    _barChartView = [[[JCHBarChartView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, barChartViewHeight) analyseType:self.enumAnalyseType] autorelease];
    _barChartView.selectedBarColor = RGBColor(255, 255, 255, 0.6);
    _barChartView.barBackgroundColor = RGBColor(255, 255, 255, 0.04);
    
    [self.view addSubview:_barChartView];
    
    [_barChartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_dropdownMenu.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(barChartViewHeight);
    }];
    
    _contentTableView = [[[JCHAnalysesPurchaseTableView alloc] initWithFrame:CGRectZero analyseType:self.enumAnalyseType] autorelease];
    _contentTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_contentTableView];
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_barChartView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view).with.offset(-analysePurchaseFooterViewHeight);
    }];
    
    
    _footerView = [[[JCHAnalysePurchaseFooterView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 49 - 64, kScreenWidth, 49) analyseType:self.enumAnalyseType] autorelease];
    [self.view addSubview:_footerView];
    
    _placeholderView = [[[JCHPlaceholderView alloc] initWithFrame:CGRectZero] autorelease];
    _placeholderView.hidden = YES;
    _placeholderView.imageView.image = [UIImage imageNamed:@"default_data_placeholder"];
    _placeholderView.label.text = @"该区间内暂无数据";
    [_contentTableView addSubview:_placeholderView];
    
    CGFloat placeholderViewHeight = 158;
    
    [_placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(placeholderViewHeight);
        make.width.mas_equalTo(kScreenWidth);
        make.centerX.centerY.equalTo(_contentTableView);
    }];
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
            
        case 0:
        {
            self.startTime = self.endTime + 1 - 3600 * 24;
            NSString *startDate = [NSString stringFromSeconds:self.startTime dateStringType:kJCHDateStringType1];
            [_dropdownMenu setTitle:[NSString stringWithFormat:@"%@ 至 %@", startDate, endDate]];
            [self loadData];
        }
            break;
            
        case 1:   //本周
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
            
        case 2:   //本月
        {
            self.startTime = self.endTime + 1 - day * 24 * 3600;
            NSString *startDate = [NSString stringFromSeconds:self.startTime dateStringType:kJCHDateStringType1];
            [_dropdownMenu setTitle:[NSString stringWithFormat:@"%@ 至 %@", startDate, endDate]];
            [self loadData];
        }
            break;
            
        case 3:   //上月
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
            
        case 4:   //上上月
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
            
        case 5:    //自定义区间
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

- (NSInteger)getNumberOfDaysInMonth:(NSDate *)date
{
    NSCalendar * calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] autorelease]; // 指定日历的算法
    
    // 只要个时间给日历,就会帮你计算出来。这里的时间取当前的时间。
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay
                                   inUnit:NSCalendarUnitMonth
                                  forDate:date];
    return range.length;
}

#pragma mark - JCHDateRangePickViewDelegate

- (void)dateRangePickViewSelectDateRange:(JCHDateRangePickView *)dateRangePickView withStartTime:(NSString *)startTime endTime:(NSString *)endTime
{
    self.endTime = [endTime stringToSecondsEndTime:YES];
    self.startTime = [startTime stringToSecondsEndTime:NO];
    
    if ((self.endTime - self.startTime) > 31 * 24 * 3600) {
        
        //如果用户第一次选择日期超出范围，弹窗提示
        if (_isFirstChangeDate) {
            UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"时间范围请控制在31天内!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] autorelease];
            [av show];
            _isFirstChangeDate = NO;
        }
        
        self.endTime = self.startTime + 31 * 24 * 3600 - 1;
        endTime = [NSString stringFromSeconds:self.endTime dateStringType:kJCHDateStringType1];
    }
    
    NSString *dateRange = [NSString stringWithFormat:@"%@ 至 %@", startTime, endTime];
    [_dropdownMenu setTitle:dateRange];
    [self loadData];
}

#pragma mark - JCHDatePickerViewDelegate
#if 0
- (void)handleDatePickerViewDidHide:(JCHDatePickerView *)datePicker selectedDate:(NSDate *)selectedDate
{
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //    [dateFormater setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSString *selectedDateString = [[dateFormater stringFromDate:selectedDate] substringToIndex:10];
    
    
    
    //修改起始时间
    if (_datePickerView.tag == 10000) {
        
        self.startTime = [selectedDateString stringToSecondsEndTime:NO];
        
        
        //当截止日期大于起始日期
        if (self.endTime > self.startTime) {
            //当截止日期减去起始日期大于31天,提示用户,并且将截止日期自动设为起始日期+30天
            if ((self.endTime - self.startTime) > 31 * 24 * 3600) {
                
                //如果用户第一次选择日期超出范围，弹窗提示
                if (_isFirstChangeDate) {
                    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"时间范围请控制在31天内!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] autorelease];
                    [av show];
                    _isFirstChangeDate = NO;
                }
                
                self.endTime = self.startTime + 31 * 24 * 3600 - 1;
                NSString *endDate = [NSString stringFromSeconds:self.endTime dateStringType:kJCHDateStringType1];
                [self loadData];
            }
            else
            {
                [self loadData];
            }
        }
        else //起始日期大于截止日期  截止日期自动设为起始日期+30天
        {
            self.endTime = self.startTime + 31 * 24 * 3600 - 1;
            NSString *startDate = [NSString stringFromSeconds:self.endTime dateStringType:kJCHDateStringType1];
            [self loadData];
        }
    }//修改结束时间
    else if (_datePickerView.tag == 10001)
    {
        self.endTime = [selectedDateString stringToSecondsEndTime:YES];
        
        //当截止日期大于起始日期
        if (self.endTime > self.startTime) {
            //当截止日期减去起始日期大于31天,提示用户,起始日期自动设为截止日期 - 30天
            if ((self.endTime - self.startTime) > 31 * 24 * 3600) {
                
                //如果用户第一次选择日期超出范围，弹窗提示
                if (_isFirstChangeDate) {
                    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"时间范围请控制在31天内!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] autorelease];
                    [av show];
                    _isFirstChangeDate = NO;
                }
                
                self.startTime = self.endTime + 1 - 31 * 24 * 3600;
                NSString *startDate = [NSString stringFromSeconds:self.startTime dateStringType:kJCHDateStringType1];
                [self loadData];
            }
            else
            {
                [self loadData];
            }
        }
        else //起始日期大于截止日期  起始日期设为截止日期 - 30天
        {
            self.startTime = self.endTime + 1 - 31 * 24 * 3600;
            NSString *startDate = [NSString stringFromSeconds:self.startTime dateStringType:kJCHDateStringType1];
            [self loadData];
        }
    }
    
    return;
}
#endif

- (void)loadData
{
    [MBProgressHUD showHUDWithTitle:@"加载中..."
                             detail:nil
                           duration:100
                               mode:MBProgressHUDModeIndeterminate
                          superView:self.view
                         completion:nil];
    
    id<FinanceCalculateService> calculateService = [[ServiceFactory sharedInstance] financeCalculateService];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int iBeginTimestamp = (int)self.startTime;//1441036800;
        int iEndTimestamp = (int)self.endTime;//1443542400;
        NSArray *amountReportData = nil;
        NSArray *productReportData = nil;
        NSArray *categoryReportData = nil;
        CGFloat curentTotalAmount = 0.0f;
        if (self.enumAnalyseType == kJCHAnalysePurchase) //进货
        {
            [calculateService calculatePurchaseReportData:iBeginTimestamp
                                                  endTime:iEndTimestamp
                                             amountReport:&amountReportData
                                            productReport:&productReportData
                                           categoryReport:&categoryReportData
                                              totalAmount:&curentTotalAmount];
        }
        else if (self.enumAnalyseType == kJCHAnalyseShipment) //出货
        {
            [calculateService calculateShipmentReportData:iBeginTimestamp
                                                  endTime:iEndTimestamp
                                             amountReport:&amountReportData
                                            productReport:&productReportData
                                           categoryReport:&categoryReportData
                                              totalAmount:&curentTotalAmount];
        }
        else if (self.enumAnalyseType == kJCHAnalyseProfit) //毛利
        {
            CGFloat profitValue = 0.0f;
            CGFloat profitRate = 0.0f;
            [calculateService calculateProfitReportData:iBeginTimestamp
                                                endTime:iEndTimestamp
                                           amountReport:&amountReportData
                                          productReport:&productReportData
                                         categoryReport:&categoryReportData
                                            profitValue:&profitValue
                                             profitRate:&profitRate];
            self.totalProfitValue = profitValue;
            self.totalProfitRate = profitRate;
        } else {
            //pass
        }
        
        self.perDayAmountReportData = amountReportData;
        self.perProductAmountReportData = productReportData;
        self.perCategoryAmountReportData = categoryReportData;
        self.totalAmountValue = curentTotalAmount;
        
        //barChartView的数据源
        NSMutableArray *values = [NSMutableArray array];
        NSMutableArray *dates = [NSMutableArray array];
        NSMutableArray *rates = [NSMutableArray array];
        CGFloat totalAmount = 0;
        
        if (_enumAnalyseType == kJCHAnalyseProfit) {
            for (ProfitAmountReportData4Cocoa *data in self.perDayAmountReportData) {
                [values addObject:[NSString stringWithFormat:@"%.2f", data.totalProfit]];
                [dates addObject:[NSString stringFromSeconds:data.timestamp dateStringType:kJCHDateStringType1]];
                [rates addObject:[NSString stringWithFormat:@"%.2f%%", data.profitRate * 100]];
            }
            
            totalAmount = self.totalProfitValue;
        }
        else
        {
            for (PurchaseShipmentAmountReportData4Cocoa *data in self.perDayAmountReportData) {
                [values addObject:[NSString stringWithFormat:@"%.2f", data.totalAmount]];
                [dates addObject:[NSString stringFromSeconds:data.timestamp dateStringType:kJCHDateStringType1]];
            }
            
            totalAmount = self.totalAmountValue;
        }

        //去掉金额为0的数据(交易日期)
        NSMutableArray *perDayAmountReportDataWithoutZeroAmount = [NSMutableArray array];
        if (_enumAnalyseType == kJCHAnalyseProfit) {
            for (ProfitAmountReportData4Cocoa *reportData in self.perDayAmountReportData) {
                if (reportData.totalProfit != 0) {
                    [perDayAmountReportDataWithoutZeroAmount addObject:reportData];
                }
            }
        } else {
            for (PurchaseShipmentAmountReportData4Cocoa *reportData in self.perDayAmountReportData) {
                if (reportData.totalAmount != 0) {
                    [perDayAmountReportDataWithoutZeroAmount addObject:reportData];
                }
            }
        }
        
        //按照日期降序排序
        [perDayAmountReportDataWithoutZeroAmount sortUsingComparator:^NSComparisonResult(PurchaseShipmentAmountReportData4Cocoa *obj1, PurchaseShipmentAmountReportData4Cocoa *obj2) {
            return obj1.timestamp < obj2.timestamp;
        }];
        
        self.perDayAmountReportData = perDayAmountReportDataWithoutZeroAmount;
        
        _contentTableView.tradeDateDataSource = self.perDayAmountReportData;
        
        NSMutableArray *productCategoryDataSource = [NSMutableArray array];
        NSMutableArray *productNameDataSource = [NSMutableArray array];
        if (_enumAnalyseType == kJCHAnalyseProfit) {
            
            for (ProfitCategoryReportData4Cocoa *data in self.perCategoryAmountReportData) {
                if ((data.totalProfit != 0) || (data.profitRate != 0))
                {
                    [productCategoryDataSource addObject:data];
                }
            }
            
            for (ProfitProductReportData4Cocoa *data in self.perProductAmountReportData) {
                if ((data.totalProfit != 0) || (data.profitRate != 0))
                {
                    [productNameDataSource addObject:data];
                }
            }
        }
        else
        {
            //去掉数量为0的类型
            for (PurchaseShipmentCategoryReportData4Cocoa *data in self.perCategoryAmountReportData) {
                if (data.totalCount != 0) {
                    [productCategoryDataSource addObject:data];
                }
            }
            
            
            //去掉数量为0的商品
            for (PurchaseShipmentProductReportData4Cocoa *data in self.perProductAmountReportData) {
                if (data.totalCount != 0) {
                    [productNameDataSource addObject:data];
                }
            }
        }
        
        _contentTableView.productCategoryDataSource = productCategoryDataSource;
        _contentTableView.productNameDataSource = productNameDataSource;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.view animated:NO];
            //刷新footerView数据
            [_footerView setData:[NSString stringWithFormat:@"%.2f", totalAmount]
                      profitRate:[NSString stringWithFormat:@"%.2f", self.totalProfitRate * 100]];
            
            
            //刷新柱状图
            _barChartView.values = values;
            _barChartView.dates = dates;
            _barChartView.rates = rates;
            [_barChartView setNeedsDisplay];
            
            [_contentTableView reloadData];
            
            if (self.perDayAmountReportData.count == 0) {
                _placeholderView.hidden = NO;
            } else {
                _placeholderView.hidden = YES;
            }
        });
    });
    

    return;
}

@end
