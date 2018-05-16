//
//  JCHAnalysesPurchaseTableView.h
//  jinchuhuo
//
//  Created by huangxu on 15/10/19.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHBarChartAnalyseViewController.h"

@interface JCHAnalysesPurchaseTableView : UIView

@property (nonatomic, retain) NSArray *tradeDateDataSource;
@property (nonatomic, retain) NSArray *productCategoryDataSource;
@property (nonatomic, retain) NSArray *productNameDataSource;

- (instancetype)initWithFrame:(CGRect)frame analyseType:(JCHAnalyseType)type;
- (void)reloadData;

@end
