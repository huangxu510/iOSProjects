//
//  JCHTakeoutPutawaySectionView.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/13.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTakeoutPutawaySectionView.h"
#import "CommonHeader.h"

@implementation JCHTakeoutPutawaySectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = JCHColorGlobalBackground;
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    CGFloat buttonWidth = 30;
    CGFloat labelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:70];
    
    UILabel *skuNameLabel = [JCHUIFactory createLabel:CGRectZero
                                                title:@"菜品"
                                                 font:JCHFont(13.0)
                                            textColor:JCHColorAuxiliary
                                               aligin:NSTextAlignmentLeft];
    [self addSubview:skuNameLabel];
    
    [skuNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kStandardLeftMargin);
        make.width.mas_equalTo(100);
        make.top.bottom.equalTo(self);
    }];
    
    UILabel *inventoryLabel = [JCHUIFactory createLabel:CGRectZero
                                                  title:@"库存"
                                                   font:JCHFont(13.0)
                                              textColor:JCHColorAuxiliary
                                                 aligin:NSTextAlignmentRight];
    [self addSubview:inventoryLabel];
    
    [inventoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-kStandardLeftMargin * 3 - buttonWidth);
        make.width.mas_equalTo(labelWidth);
        make.top.bottom.equalTo(self);
    }];
    
    
    UILabel *priceLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"价格"
                                               font:JCHFont(13.0)
                                          textColor:JCHColorAuxiliary
                                             aligin:NSTextAlignmentRight];
    [self addSubview:priceLabel];
    
    [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(inventoryLabel.mas_left).offset(-kStandardLeftMargin);
        make.top.bottom.width.equalTo(inventoryLabel);
    }];
}

@end
