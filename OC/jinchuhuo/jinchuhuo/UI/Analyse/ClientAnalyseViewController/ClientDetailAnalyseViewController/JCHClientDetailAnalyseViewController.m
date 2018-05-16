//
//  JCHClientDetailAnalyseViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/7/14.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHClientDetailAnalyseViewController.h"
#import "JCHManifestDetailViewController.h"
#import "JCHClientDetailAnalyseHeaderView.h"
#import "JCHClientDetailAnalyseTableView.h"
#import "CommonHeader.h"

@interface JCHClientDetailAnalyseViewController () <JCHClientDetailAnalyseTableViewDelegate>
{
    JCHClientDetailAnalyseHeaderView *_headerView;
    JCHClientDetailAnalyseTableView *_clientDetailAnalyseTableView;
}
@property (nonatomic, retain) NSString *customUUID;
@property (nonatomic, assign) BOOL isReturnedIndex;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger endTime;

@end

@implementation JCHClientDetailAnalyseViewController

- (instancetype)initWithCustomUUID:(NSString *)customUUID
                         startTime:(NSInteger)startTime
                           endTime:(NSInteger)endTime
                   isReturnedIndex:(BOOL)isReturnedIndex
{
    self = [super init];
    if (self) {
        
        if (isReturnedIndex) {
            self.title = @"客户退货明细";
        } else {
            self.title = @"客户订单明细";
        }
        
        self.customUUID = customUUID;
        self.startTime = startTime;
        self.endTime = endTime;
        self.isReturnedIndex = isReturnedIndex;
    }
    return self;
}

- (void)dealloc
{
    self.customUUID = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createUI];
    [self loadData];
}

- (void)createUI
{
    CGFloat headerViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:160.0f];
    
    _headerView = [[[JCHClientDetailAnalyseHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, headerViewHeight) isReturned:self.isReturnedIndex] autorelease];
    [_headerView addSeparateLineWithMasonryTop:NO bottom:YES];
    [self.view addSubview:_headerView];
    
    _clientDetailAnalyseTableView = [[[JCHClientDetailAnalyseTableView alloc] initWithFrame:CGRectZero isReturned:self.isReturnedIndex] autorelease];
    _clientDetailAnalyseTableView.backgroundColor = [UIColor whiteColor];
    _clientDetailAnalyseTableView.delegate = self;
    [self.view addSubview:_clientDetailAnalyseTableView];
    
    [_clientDetailAnalyseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_headerView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)loadData
{
    [MBProgressHUD showHUDWithTitle:@"加载中..."
                             detail:nil
                           duration:100
                               mode:MBProgressHUDModeIndeterminate
                          superView:self.view
                         completion:nil];
    
    id<ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
    id<FinanceCalculateService> financeCalculateService = [[ServiceFactory sharedInstance] financeCalculateService];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        ContactsRecord4Cocoa *contactsReocrd = [contactsService queryContacts:self.customUUID];
        
        CustomDetailReportRecord4Cocoa *customDetailReportRecord = nil;
        NSArray *manifestArray = nil;
        NSArray *categoryArray = nil;
        NSArray *productArray = nil;
        
        //退货指标
        if (self.isReturnedIndex) {
            [financeCalculateService calculateCustomReturnDetailReport:self.startTime
                                                           endDatetime:self.endTime
                                                              customID:self.customUUID
                                                          detailReport:&customDetailReportRecord
                                                        manifestVector:&manifestArray
                                                        categoryVector:&categoryArray
                                                         productVector:&productArray];
            
            
            categoryArray = [categoryArray sortedArrayUsingComparator:^NSComparisonResult(CustomCategoryReturnReportRecord4Cocoa *obj1, CustomCategoryReturnReportRecord4Cocoa *obj2) {
                return obj1.totalSaleAmount < obj2.totalSaleAmount;
            }];
            
            productArray = [productArray sortedArrayUsingComparator:^NSComparisonResult(CustomProductReturnReportRecord4Cocoa *obj1, CustomProductReturnReportRecord4Cocoa *obj2) {
                return obj1.totalSaleAmount < obj2.totalSaleAmount;
            }];
        } else {
            //非退货指标
            [financeCalculateService calculateCustomDetailReport:self.startTime
                                                     endDatetime:self.endTime
                                                        customID:self.customUUID
                                                    detailReport:&customDetailReportRecord
                                                  manifestVector:&manifestArray
                                                  categoryVector:&categoryArray
                                                   productVector:&productArray];
            
            categoryArray = [categoryArray sortedArrayUsingComparator:^NSComparisonResult(CustomCategoryReportRecord4Cocoa *obj1, CustomCategoryReportRecord4Cocoa *obj2) {
                return obj1.totalSaleAmount < obj2.totalSaleAmount;
            }];
            
            productArray = [productArray sortedArrayUsingComparator:^NSComparisonResult(CustomProductReportRecord4Cocoa *obj1, CustomProductReportRecord4Cocoa *obj2) {
                return obj1.totalSaleAmount < obj2.totalSaleAmount;
            }];
        }
        
        manifestArray = [manifestArray sortedArrayUsingComparator:^NSComparisonResult(ManifestRecord4Cocoa *obj1, ManifestRecord4Cocoa *obj2) {
            return obj1.manifestTimestamp < obj2.manifestTimestamp;
        }];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _clientDetailAnalyseTableView.manifestDataSource = manifestArray;
            _clientDetailAnalyseTableView.productCategoryDataSource = categoryArray;
            _clientDetailAnalyseTableView.productNameDataSource = productArray;
            [_clientDetailAnalyseTableView reloadData];
            
            NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:self.startTime];
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:self.endTime];
            
            NSString *startDateString = [dateFormatter stringFromDate:startDate];
            NSString *endDateString = [dateFormatter stringFromDate:endDate];
            
            JCHClientDetailAnalyseHeaderViewData *data = [[[JCHClientDetailAnalyseHeaderViewData alloc] init] autorelease];
            //data.headImageName = @"";
            data.name = contactsReocrd.name;
            data.dateRange = [NSString stringWithFormat:@"%@ 至 %@", startDateString, endDateString];
            data.totalAmount = customDetailReportRecord.totalManifestAmount;
            data.totalCount = customDetailReportRecord.totalManifestCount;
            data.receivableAmount = customDetailReportRecord.totalARAPManifestAmount;
            data.receivableCount = customDetailReportRecord.totalARAPManifestCount;
            
            [_headerView setViewData:data];
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        });
    });
}

#pragma mark - JCHClientDetailAnalyseTableViewDelegate

- (void)handlePushToManifestDetail:(ManifestRecord4Cocoa *)manifestRecord
{
    JCHManifestDetailViewController *viewController = [[[JCHManifestDetailViewController alloc] initWithManifestRecord:manifestRecord] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}


@end
