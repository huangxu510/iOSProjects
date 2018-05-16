//
//  JCHAnalyseInventoryTableSectionVIew.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/26.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHAnalyseInventoryTableSectionVIew.h"
#import "JCHSizeUtility.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHColorSettings.h"

@implementation JCHAnalyseInventoryTableSectionVIew

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGB(0xeeeeee);
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    CGFloat leftMargin = 20;
    CGFloat labelWidth = (kScreenWidth - 2 * leftMargin) / 4;
    
    UIFont *titleFont = [UIFont systemFontOfSize:12];
    UILabel *productNameLabel = [JCHUIFactory createLabel:CGRectMake(leftMargin, 0, labelWidth + leftMargin, kHeight)
                                             title:@"商品名称"
                                              font:titleFont
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentLeft];
    [self addSubview:productNameLabel];
    
    UILabel *productCount = [JCHUIFactory createLabel:CGRectMake(labelWidth + leftMargin * 2, 0, labelWidth - leftMargin / 2, kHeight)
                                               title:@"数量"
                                                font:titleFont
                                           textColor:JCHColorMainBody
                                              aligin:NSTextAlignmentCenter];
    [self addSubview:productCount];
    
    UILabel *amountLable = [JCHUIFactory createLabel:CGRectMake(labelWidth * 2 + leftMargin * 1.5, 0, labelWidth, kHeight)
                                                title:@"库存金额"
                                                 font:titleFont
                                            textColor:JCHColorMainBody
                                               aligin:NSTextAlignmentRight];
    [self addSubview:amountLable];
    
    UILabel *proportionLabel = [JCHUIFactory createLabel:CGRectMake(labelWidth * 3 + leftMargin * 1.5, 0, labelWidth - leftMargin / 2, kHeight)
                                                title:@"占比"
                                                 font:titleFont
                                            textColor:JCHColorMainBody
                                               aligin:NSTextAlignmentRight];
    [self addSubview:proportionLabel];
}

@end

