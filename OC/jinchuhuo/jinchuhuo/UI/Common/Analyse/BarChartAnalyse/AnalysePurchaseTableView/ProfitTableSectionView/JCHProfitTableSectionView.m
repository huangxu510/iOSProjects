//
//  JCHProfitTableSectionView.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/27.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHProfitTableSectionView.h"
#import "JCHSizeUtility.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHColorSettings.h"

@interface JCHProfitTableSectionView ()
{
    JCHProfitTableViewType _enumProfitTableViewType;
}
@end
@implementation JCHProfitTableSectionView

- (instancetype)initWithFrame:(CGRect)frame tableViewType:(JCHProfitTableViewType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGB(0xeeeeee);
        _enumProfitTableViewType = type;
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    const CGFloat leftMargin = [JCHSizeUtility calculateWidthWithSourceWidth:15.0f];
    UIFont *titleFont = [UIFont systemFontOfSize:12];
    const CGFloat labelHeight = self.frame.size.height;
    
    UILabel *categoryLabel = [JCHUIFactory createLabel:CGRectMake(leftMargin, 0, kScreenWidth * 0.25, labelHeight)
                                                 title:@"商品分类"
                                                  font:titleFont
                                             textColor:JCHColorMainBody
                                                aligin:NSTextAlignmentLeft];
    [self addSubview:categoryLabel];
    if (_enumProfitTableViewType == kJCHProfitTableViewTypeProductName) {
        categoryLabel.text = @"商品名称";
    }
    else if (_enumProfitTableViewType == kJCHProfitTableViewTypeTradeDate)
    {
        categoryLabel.text = @"交易日期";
    }
    
    UILabel *saleAmountLabel = [JCHUIFactory createLabel:CGRectMake(kScreenWidth * 0.25 + leftMargin, 0, kScreenWidth * 0.225, labelHeight)
                                              title:@"销售金额"
                                               font:titleFont
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentRight];
    [self addSubview:saleAmountLabel];
    
    UILabel *profitAmountLabel = [JCHUIFactory createLabel:CGRectMake(kScreenWidth * 0.475 + leftMargin, 0, kScreenWidth * 0.225, labelHeight)
                                              title:@"毛利额"
                                               font:titleFont
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentRight];
    [self addSubview:profitAmountLabel];
    
    UILabel *profitRateLabel = [JCHUIFactory createLabel:CGRectMake(kScreenWidth * 0.7 + leftMargin, 0, kScreenWidth * 0.3 - 2 * leftMargin, labelHeight)
                                               title:@"毛利率"
                                                font:titleFont
                                           textColor:JCHColorMainBody
                                              aligin:NSTextAlignmentRight];
    [self addSubview:profitRateLabel];
}


@end
