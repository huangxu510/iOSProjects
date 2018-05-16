//
//  JCHProductDetailTableSectionView.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/17.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHProductDetailTableSectionView.h"
#import "CommonHeader.h"
#import <Masonry.h>

@implementation JCHProductDetailTableSectionView

- (id)initWithTopLine:(BOOL)topLine BottomLine:(BOOL)bottomLine
{
    self = [super initWithTopLine:topLine BottomLine:bottomLine];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    UIFont *labelFont = [UIFont jchSystemFontOfSize:12.0f];
    CGFloat skuTitleLabelWidth = (kScreenWidth - 2 * kStandardLeftMargin) / 3;
    CGFloat countLabelWidth = (kScreenWidth - 2 * kStandardLeftMargin) * 2 / 9;
    
    UILabel *skuTitleLable = [JCHUIFactory createLabel:CGRectZero
                                                 title:@"单品"
                                                  font:labelFont
                                             textColor:JCHColorAuxiliary
                                                aligin:NSTextAlignmentLeft];
    [self addSubview:skuTitleLable];
    
    [skuTitleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(skuTitleLabelWidth);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    UILabel *countLable = [JCHUIFactory createLabel:CGRectZero
                                                 title:@"数量"
                                                  font:labelFont
                                             textColor:JCHColorAuxiliary
                                                aligin:NSTextAlignmentRight];
    [self addSubview:countLable];
    
    [countLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(skuTitleLable.mas_right);
        make.width.mas_equalTo(countLabelWidth);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    UILabel *purchasePriceLabel = [JCHUIFactory createLabel:CGRectZero
                                                 title:@"平均成本"
                                                  font:labelFont
                                             textColor:JCHColorAuxiliary
                                                aligin:NSTextAlignmentRight];
    [self addSubview:purchasePriceLabel];
    
    [purchasePriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(countLable.mas_right);
        make.width.mas_equalTo(countLabelWidth);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    UILabel *shipmentPriceLabel = [JCHUIFactory createLabel:CGRectZero
                                                 title:@"出售价"
                                                  font:labelFont
                                             textColor:JCHColorAuxiliary
                                                aligin:NSTextAlignmentRight];
    [self addSubview:shipmentPriceLabel];
    
    [shipmentPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(purchasePriceLabel.mas_right);
        make.width.mas_equalTo(countLabelWidth);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
}

@end
