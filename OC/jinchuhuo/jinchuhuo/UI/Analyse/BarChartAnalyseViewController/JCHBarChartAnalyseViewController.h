//
//  JCHAnalysePurchaseViewController.h
//  jinchuhuo
//
//  Created by huangxu on 15/10/19.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

typedef NS_ENUM(NSInteger, JCHAnalyseType)
{
    kJCHAnalysePurchase, //进货
    kJCHAnalyseShipment, //出货
    kJCHAnalyseProfit,   //毛利
};

@interface JCHBarChartAnalyseViewController : JCHBaseViewController

@property (nonatomic, assign) JCHAnalyseType enumAnalyseType;

@end
