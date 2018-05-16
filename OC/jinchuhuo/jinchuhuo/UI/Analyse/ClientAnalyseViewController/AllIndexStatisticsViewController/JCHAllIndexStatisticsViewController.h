//
//  JCHAllIndexStatisticsViewController.h
//  jinchuhuo
//
//  Created by huangxu on 16/7/14.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "ServiceFactory.h"

@interface JCHAllIndexStatisticsViewController : JCHBaseViewController

- (instancetype)initWithDateRange:(NSString *)dateRange
        customReportSummaryRecord:(CustomReportSummaryRecord4Cocoa *)customReportSummaryRecord;

@end
