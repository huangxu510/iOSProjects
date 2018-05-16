//
//  JCHProductCategoryTableSectionView.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/19.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHProductCategoryTableSectionView.h"
#import "JCHSizeUtility.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHColorSettings.h"

@implementation JCHProductCategoryTableSectionView
{
    JCHAnalyseType _enumAnalyseType;
}
- (instancetype)initWithFrame:(CGRect)frame anasyseType:(JCHAnalyseType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGB(0xeeeeee);
        _enumAnalyseType = type;
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    UIFont *titleFont = [UIFont systemFontOfSize:12];
    const CGFloat leftMargin = [JCHSizeUtility calculateWidthWithSourceWidth:20.0f];
    const CGFloat labelHeight = self.frame.size.height;

    UILabel *categoryLabel = [JCHUIFactory createLabel:CGRectMake(leftMargin, 0, kWidth / 3, labelHeight)
                                             title:@"商品分类"
                                              font:titleFont
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentLeft];
    [self addSubview:categoryLabel];
    
    UILabel *countLabel = [JCHUIFactory createLabel:CGRectMake(kWidth / 3, 0, kWidth / 3, labelHeight)
                                             title:@"品类数量(个)"
                                              font:titleFont
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentCenter];
    [self addSubview:countLabel];
    
    UILabel *amountLabel = [JCHUIFactory createLabel:CGRectMake(kWidth * 2 / 3 - leftMargin, 0, kWidth / 3, labelHeight)
                                               title:@"进货金额"
                                                font:titleFont
                                           textColor:JCHColorMainBody
                                              aligin:NSTextAlignmentRight];
    if (_enumAnalyseType == kJCHAnalyseShipment) {
        amountLabel.text = @"出货金额";
    }
    [self addSubview:amountLabel];
}

@end
