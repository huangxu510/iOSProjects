//
//  BezierPathVuew.h
//  drawRectTest
//
//  Created by huangxu on 15/10/15.
//  Copyright © 2015年 huangxu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHBarChartAnalyseViewController.h"

@interface JCHBarChartView : UIView

@property (nonatomic, strong)CAShapeLayer *shapeLayer;
//@property (nonatomic, strong)UIColor *barColor;
@property (nonatomic, strong)UIColor *barBackgroundColor;
@property (nonatomic, strong)UIColor *selectedBarColor;
@property (nonatomic, strong)NSArray *values;
@property (nonatomic, strong)NSArray *dates;
@property (nonatomic, strong)NSArray *rates;

- (instancetype)initWithFrame:(CGRect)frame analyseType:(JCHAnalyseType)type;
- (void)startAnimation:(CGFloat)duration;
@end
