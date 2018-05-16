//
//  JCHClientDetailAnalyseCategorySectionView.m
//  jinchuhuo
//
//  Created by huangxu on 16/7/14.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHClientDetailAnalyseCategorySectionView.h"
#import "CommonHeader.h"

@implementation JCHClientDetailAnalyseCategorySectionView
{
    BOOL _returned;
}

- (instancetype)initWithFrame:(CGRect)frame returned:(BOOL)returned
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGB(0xf8f8f8);
        _returned = returned;
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    UIFont *titleFont = JCHFont(12.0);
    
    CGFloat labelWidth;
    if (_returned) {
        labelWidth = (kScreenWidth - 4 * kStandardLeftMargin) / 3.0;
    } else {
        labelWidth = (kScreenWidth - 5 * kStandardLeftMargin) / 4.5;
    }
    
    UILabel *categoryLabel = [JCHUIFactory createLabel:CGRectZero
                                         title:@"商品分类"
                                          font:titleFont
                                     textColor:JCHColorMainBody
                                        aligin:NSTextAlignmentLeft];
    categoryLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:categoryLabel];
    
    [categoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        if (_returned) {
            make.width.mas_equalTo(labelWidth);
        } else {
            make.width.mas_equalTo(labelWidth * 1.5);
        }
        
        make.top.bottom.equalTo(self);
    }];
    
    
    UILabel *saleAmountLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@"销售金额"
                                            font:titleFont
                                       textColor:JCHColorMainBody
                                          aligin:NSTextAlignmentRight];
    saleAmountLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:saleAmountLabel];
    
    [saleAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.equalTo(categoryLabel.mas_right).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(labelWidth);
    }];
    
    UILabel *profitAmountLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@"毛利额"
                                              font:titleFont
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentRight];
    [self addSubview:profitAmountLabel];
    
    [profitAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(saleAmountLabel.mas_right).with.offset(kStandardLeftMargin);
        make.top.bottom.with.equalTo(categoryLabel);
        make.width.mas_equalTo(labelWidth);
    }];
    
    UILabel *profitRateLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@"毛利率"
                                            font:titleFont
                                       textColor:JCHColorMainBody
                                          aligin:NSTextAlignmentRight];
    profitRateLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:profitRateLabel];
    
    [profitRateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (_returned) {
            make.left.equalTo(saleAmountLabel.mas_right).with.offset(kStandardLeftMargin);
        } else {
            make.left.equalTo(profitAmountLabel.mas_right).with.offset(kStandardLeftMargin);
        }
        
        make.top.bottom.with.equalTo(categoryLabel);
        make.width.mas_equalTo(labelWidth);
    }];
    
    if (_returned) {
        profitAmountLabel.hidden = YES;
        categoryLabel.text = @"商品名称";
        saleAmountLabel.text = @"退货金额";
        //saleAmountLabel.textAlignment = NSTextAlignmentCenter;
        profitRateLabel.text = @"退货金额占比";
    }
}


@end
