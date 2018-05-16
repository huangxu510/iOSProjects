//
//  JCHRestaurantDishDetailSectionView.m
//  jinchuhuo
//
//  Created by apple on 2017/1/12.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHRestaurantDishDetailSectionView.h"
#import "CommonHeader.h"

@interface JCHRestaurantDishDetailSectionView ()
{
    UILabel *nameLabel;
    UILabel *countLabel;
    UILabel *priceLabel;
}
@end

@implementation JCHRestaurantDishDetailSectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    return;
}

- (void)createUI
{
    UIFont *labelFont = JCHFont(14.0);
    UIColor *labelColor = JCHColorMainBody;
    nameLabel = [JCHUIFactory createLabel:CGRectZero
                                    title:@"菜品"
                                     font:labelFont
                                textColor:labelColor
                                   aligin:NSTextAlignmentLeft];
    [self addSubview:nameLabel];
    
    countLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@"数量"
                                      font:labelFont
                                 textColor:labelColor
                                    aligin:NSTextAlignmentRight];
    [self addSubview:countLabel];
    
    priceLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@"单价"
                                      font:labelFont
                                 textColor:labelColor
                                    aligin:NSTextAlignmentCenter];
    [self addSubview:priceLabel];
    
    self.backgroundColor = JCHColorGlobalBackground;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(kStandardLeftMargin);
        make.top.and.bottom.equalTo(self);
        make.width.equalTo(self.mas_width).with.multipliedBy(0.7);
    }];
    
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-kStandardRightMargin);
        make.top.and.bottom.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.15);
    }];
    
    [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(countLabel.mas_left);
        make.top.and.bottom.equalTo(self);
        make.width.equalTo(self.mas_width).with.multipliedBy(0.15);
    }];
    

}

@end
