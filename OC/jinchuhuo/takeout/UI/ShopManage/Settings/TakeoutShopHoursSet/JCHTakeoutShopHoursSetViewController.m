//
//  JCHTakeoutShopHoursSetViewController.m
//  jinchuhuo
//
//  Created by huangxu on 2017/1/4.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHTakeoutShopHoursSetViewController.h"
#import "JCHDateRangePickView.h"
#import "JCHBaseTableViewCell.h"
#import "JCHAddSKUValueFooterView.h"
#import "CommonHeader.h"

typedef NS_ENUM(NSInteger, JCHShopTimeSetType) {
    kJCHShopTimeSetTypeNew = 0,
    kJCHShopTimeSetTypeEdit,
};

@interface JCHTakeoutShopHoursSetViewController ()
<UITableViewDelegate,
UITableViewDataSource,
JCHAddSKUValueFooterViewDelegate,
JCHDateRangePickViewDelegate>

@property (retain, nonatomic) NSMutableArray *shopOpenTimeList;
@property (retain, nonatomic) NSString *currentEditTimeRange;

@end

@implementation JCHTakeoutShopHoursSetViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"营业时间段";
        self.shopOpenTimeList = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    self.shopOpenTimeList = nil;
    self.currentEditTimeRange = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(handleSaveData)] autorelease];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    [self queryShopInfo];
}

- (void)queryShopInfo
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    
    QueryShopInfoRequest *request = [[[QueryShopInfoRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.serviceURL = [NSString stringWithFormat:@"%@/book/queryBook", kTakeoutServerIP];
    
    [MBProgressHUD showHUDWithTitle:@"加载中..." detail:@"" duration:9999 mode:MBProgressHUDModeIndeterminate superView:self.view completion:nil];
    
    [takeoutService queryShopInfo:request callback:^(id response) {
        
        NSDictionary *data = response;
        
        if (kJCHServiceSuccess == [data[@"status"] integerValue]) {
            NSDictionary *responseData = data[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                //! @todo
                if (responseCode == 22000) {
                    [MBProgressHUD showHUDWithTitle:@"用户验证失败"
                                             detail:@"请重新登录"
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                          superView:self.view
                                         completion:nil];
                } else {
                    [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"%ld", responseCode]
                                             detail:responseDescription
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                          superView:self.view
                                         completion:nil];
                }
            } else {
                NSLog(@"responseData = %@", responseData);
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
                
                NSDictionary *bookInfo = responseData[@"data"][@"bookInfo"];
                NSString *openTime = bookInfo[@"openTime"];
                [self.shopOpenTimeList addObjectsFromArray:[openTime componentsSeparatedByString:@","]];
                [self createUI];
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            [MBProgressHUD showNetWorkFailedHud:@""
                                      superView:self.view];
        }
    }];
}


- (void)createUI
{
    JCHAddSKUValueFooterView *tableFooterView = [[[JCHAddSKUValueFooterView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)] autorelease];
    [tableFooterView setTitleName:@"添加时间段"];
    tableFooterView.delegate = self;
    [tableFooterView addSeparateLineWithMasonryTop:NO bottom:YES];
    self.tableView.tableFooterView = tableFooterView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.shopOpenTimeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHBaseTableViewCell"];
    if (cell == nil) {
        cell = [[[JCHBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JCHBaseTableViewCell"] autorelease];
        cell.textLabel.font = JCHFont(15);
        cell.textLabel.textColor = JCHColorMainBody;
        cell.arrowImageView.hidden = NO;
    }
    
    
    NSString *timeRange = self.shopOpenTimeList[indexPath.row];
    cell.textLabel.text = timeRange;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *timeRange = self.shopOpenTimeList[indexPath.row];
    NSArray *timeList = [timeRange componentsSeparatedByString:@"-"];
    if (timeList.count == 2) {
        NSString *beginTime = [timeList firstObject];
        NSString *endTime = [timeList lastObject];
        
        JCHDateRangePickView *dateRangePickView = [[[JCHDateRangePickView alloc] initWithFrame:CGRectZero title:@"设置时间段" beginTimeTitle:@"开始时间" endTimeTitle:@"结束时间"] autorelease];
        dateRangePickView.tag = kJCHShopTimeSetTypeEdit;
        dateRangePickView.delegate = self;
        dateRangePickView.datePickerMode = UIDatePickerModeTime;
        dateRangePickView.defaultStartTime = beginTime;
        dateRangePickView.defaultEndTime = endTime;
        [dateRangePickView showView];
        
        self.currentEditTimeRange = timeRange;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.shopOpenTimeList removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

#pragma mark - JCHAddSpecificationFooterViewDelegate

- (void)addItem
{
    if (self.shopOpenTimeList.count == 3) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"最多设置三个营业时间段，请直接修改已有营业时间段" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles: nil] autorelease];
        [alertView show];
        return;
    }
    JCHDateRangePickView *dateRangePickView = [[[JCHDateRangePickView alloc] initWithFrame:CGRectZero title:@"添加时间段" beginTimeTitle:@"开始时间" endTimeTitle:@"结束时间"] autorelease];
    dateRangePickView.tag = kJCHShopTimeSetTypeNew;
    dateRangePickView.delegate = self;
    dateRangePickView.datePickerMode = UIDatePickerModeTime;

    [dateRangePickView showView];
}

#pragma mark - JCHDateRangePickViewDelegate

- (void)dateRangePickViewSelectDateRange:(JCHDateRangePickView *)dateRangePickView withStartTime:(NSString *)startTime endTime:(NSString *)endTime
{
    // 结束时间和起始时间相差要大于1小时
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *startDate = [dateFormatter dateFromString:startTime];
    NSDate *endDate = [dateFormatter dateFromString:endTime];
    
    if ([endDate timeIntervalSinceDate:startDate] < 3600) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"同一时间段的启示时间和结束时间至少相差1小时，请重新设置" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles: nil] autorelease];
        [alertView show];
        return;
    }
    
    if (dateRangePickView.tag == kJCHShopTimeSetTypeNew) {
        // 需要判断是否和已经设置的时间段重叠
        for (NSString *timeRange in self.shopOpenTimeList) {
            NSArray *timeList = [timeRange componentsSeparatedByString:@"-"];
            if (timeList.count == 2) {
                NSString *beginTimeAlready = [timeList firstObject];
                NSString *endTimeAlready = [timeList lastObject];
                
                if (([startTime compare:beginTimeAlready] == NSOrderedDescending && [startTime compare:endTimeAlready] == NSOrderedAscending) ||
                    ([endTime compare:beginTimeAlready] == NSOrderedDescending && [endTime compare:endTimeAlready] == NSOrderedAscending) ||
                    ([startTime compare:beginTimeAlready] == NSOrderedAscending && [endTime compare:endTimeAlready] == NSOrderedDescending)) {
                    // 有重叠
                    NSString *message = [NSString stringWithFormat:@"营业时间段%@-%@与%@-%@重叠，请重新设置", startTime, endTime, beginTimeAlready, endTimeAlready];
                    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:message delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles: nil] autorelease];
                    [alertView show];
                    return;
                }
            }
        }
        // 新增时间段
        NSString *newTimeRange = [NSString stringWithFormat:@"%@-%@", startTime, endTime];
        [self.shopOpenTimeList addObject:newTimeRange];
        
        [self.shopOpenTimeList sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [[obj1 substringToIndex:2] compare:[obj2 substringToIndex:2]];
        }];
        
        [self.tableView reloadData];
    } else {
        // 需要判断和其它时间段重叠
        for (NSString *timeRange in self.shopOpenTimeList) {
            if (![timeRange isEqualToString:self.currentEditTimeRange]) {
                NSArray *timeList = [timeRange componentsSeparatedByString:@"-"];
                if (timeList.count == 2) {
                    NSString *beginTimeAlready = [timeList firstObject];
                    NSString *endTimeAlready = [timeList lastObject];
                    
                    if (([startTime compare:beginTimeAlready] == NSOrderedDescending && [startTime compare:endTimeAlready] == NSOrderedAscending) ||
                        ([endTime compare:beginTimeAlready] == NSOrderedDescending && [endTime compare:endTimeAlready] == NSOrderedAscending) ||
                        ([startTime compare:beginTimeAlready] == NSOrderedAscending && [endTime compare:endTimeAlready] == NSOrderedDescending)) {
                        // 有重叠
                        NSString *message = [NSString stringWithFormat:@"营业时间段%@-%@与%@-%@重叠，请重新设置", startTime, endTime, beginTimeAlready, endTimeAlready];
                        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:message delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles: nil] autorelease];
                        [alertView show];
                        return;
                    }
                }
            }
        }
        
        NSString *newTimeRange = [NSString stringWithFormat:@"%@-%@", startTime, endTime];
        [self.shopOpenTimeList replaceObjectAtIndex:[self.shopOpenTimeList indexOfObject:self.currentEditTimeRange] withObject:newTimeRange];
        [self.tableView reloadData];
    }
}

- (void)dateRangePickViewDidHide
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - SaveData
- (void)handleSaveData
{
    if (self.shopOpenTimeList.count == 0) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"未添加营业时间段" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles: nil] autorelease];
        [alertView show];
        return;
    }
    
    NSString *shopTime = [self.shopOpenTimeList componentsJoinedByString:@","];
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    
    SetServiceTimeRequest *request = [[[SetServiceTimeRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.serviceURL = [NSString stringWithFormat:@"%@/book/setTime", kTakeoutServerIP];
    request.serviceTime = shopTime;
    
    [MBProgressHUD showHUDWithTitle:@"加载中..." detail:@"" duration:9999 mode:MBProgressHUDModeIndeterminate superView:self.view completion:nil];
    
    [takeoutService setServiceTime:request callback:^(id response) {
        
        NSDictionary *data = response;
        
        if (kJCHServiceSuccess == [data[@"status"] integerValue]) {
            NSDictionary *responseData = data[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                //! @todo
                if (responseCode == 22000) {
                    [MBProgressHUD showHUDWithTitle:@"用户验证失败"
                                             detail:@"请重新登录"
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                          superView:self.view
                                         completion:nil];
                } else {
                    [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"%ld", responseCode]
                                             detail:responseDescription
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                          superView:self.view
                                         completion:nil];
                }
            } else {
                NSLog(@"responseData = %@", responseData);
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
                
                
                // 保存营业时间到本地
                JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
                id <BookInfoService> bookInfoService = [[ServiceFactory sharedInstance] bookInfoService];
                BookInfoRecord4Cocoa *bookInfoRecord = [bookInfoService queryBookInfo:statusManager.userID];
                bookInfoRecord.bizHours = request.serviceTime;
                [bookInfoService updateBookInfo:bookInfoRecord];
                
                
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            [MBProgressHUD showNetWorkFailedHud:@""
                                      superView:self.view];
        }
    }];
}

@end
