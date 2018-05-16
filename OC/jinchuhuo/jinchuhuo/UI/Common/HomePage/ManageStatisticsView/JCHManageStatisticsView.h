//
//  JCHManageStatisticsView.h
//  jinchuhuo
//
//  Created by apple on 15/8/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHManageStatisticsViewData : NSObject

@property (retain, nonatomic, readwrite) NSString *todayPurchaseAmount;
@property (retain, nonatomic, readwrite) NSString *todayShipmentAmount;
@property (retain, nonatomic, readwrite) NSString *monthProfitAmount;
@property (retain, nonatomic, readwrite) NSString *todayShipmentManifest;
@property (retain, nonatomic, readwrite) NSString *thisMonthShipmentAmount;

@end

@interface JCHManageStatisticsView : UIView

- (void)setViewData:(JCHManageStatisticsViewData *)viewData;

@end
