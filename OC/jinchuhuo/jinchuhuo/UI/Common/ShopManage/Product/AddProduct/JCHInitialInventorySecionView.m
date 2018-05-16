//
//  JCHInitialInventorySecionView.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/7.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHInitialInventorySecionView.h"
#import "JCHSizeUtility.h"
#import "JCHUIFactory.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import <Masonry.h>

@implementation JCHInitialInventorySecionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    UIFont *titleFont = [UIFont jchSystemFontOfSize:14.0f];
    UILabel *skuNameLabel = [JCHUIFactory createLabel:CGRectZero
                                                title:@"规格单品"
                                                 font:titleFont
                                            textColor:JCHColorAuxiliary
                                               aligin:NSTextAlignmentLeft];
    [self addSubview:skuNameLabel];
    
    [skuNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.right.equalTo(self.mas_centerX);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    CGFloat countLabelWidth = (kScreenWidth / 2 - kStandardLeftMargin) / 2;
    UILabel *countLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"库存数量"
                                               font:titleFont
                                          textColor:JCHColorAuxiliary
                                             aligin:NSTextAlignmentRight];
    [self addSubview:countLabel];
    
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(skuNameLabel.mas_right);
        make.width.mas_equalTo(countLabelWidth);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    UILabel *priceLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"初始成本"
                                               font:titleFont
                                          textColor:JCHColorAuxiliary
                                             aligin:NSTextAlignmentRight];
    [self addSubview:priceLabel];
    
    [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(countLabel.mas_right);
        make.right.equalTo(self).with.offset(-kStandardLeftMargin);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
}

@end
