//
//  PieChartView.h
//  drawRectTest
//
//  Created by huangxu on 15/10/21.
//  Copyright © 2015年 huangxu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReportData4Cocoa.h"

@protocol JCHPieChartViewDelegate <NSObject>

- (void)reloadData:(InventoryCategoryReportData4Cocoa *)categoryReportData;

@end

@interface ArrowLayer : CALayer

@end


@interface JCHPieChartView : UIImageView

@property (nonatomic, assign) id <JCHPieChartViewDelegate> delegate;
@property (nonatomic, assign) BOOL isInAnimation;

- (instancetype)initWithFrame:(CGRect)frame values:(NSArray *)values;
- (void)startAnimation;

@end
