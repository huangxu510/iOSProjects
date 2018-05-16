//
//  JCHAnalysePurchaseFooterView.h
//  jinchuhuo
//
//  Created by huangxu on 15/10/20.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHBarChartAnalyseViewController.h"

@interface JCHAnalysePurchaseFooterView : UIView

- (instancetype)initWithFrame:(CGRect)frame analyseType:(JCHAnalyseType)type;
- (void)setData:(NSString *)amount profitRate:(NSString *)rate;

@end
