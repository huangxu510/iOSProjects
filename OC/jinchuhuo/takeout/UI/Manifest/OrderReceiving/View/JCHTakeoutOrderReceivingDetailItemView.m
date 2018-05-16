//
//  JCHTakeoutOrderReceivingDetailItemView.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTakeoutOrderReceivingDetailItemView.h"
#import "CommonHeader.h"


@implementation JCHTakeoutOrderReceivingDetailItemView
{
    UILabel *_dishNameLabel;
    UILabel *_dishCountLabel;
    UILabel *_dishPriceLabel;
}

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
    _dishNameLabel = [JCHUIFactory createLabel:CGRectZero
                                         title:@"宫保鸡丁"
                                          font:JCHFont(12.0)
                                     textColor:JCHColorMainBody
                                        aligin:NSTextAlignmentLeft];
    [self addSubview:_dishNameLabel];
    
    
    [_dishNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kStandardLeftMargin);
        make.top.bottom.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.6);
    }];
    
    _dishCountLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@"x1"
                                           font:JCHFont(12.0)
                                      textColor:JCHColorMainBody
                                         aligin:NSTextAlignmentLeft];
    [self addSubview:_dishCountLabel];
    
    [_dishCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_dishNameLabel.mas_right).offset(kStandardLeftMargin);
        make.top.bottom.equalTo(self);
        make.width.equalTo(self).multipliedBy(1.0 / 6);
    }];
    
    _dishPriceLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@"¥24"
                                            font:JCHFont(12.0)
                                       textColor:JCHColorMainBody
                                          aligin:NSTextAlignmentRight];
    [self addSubview:_dishPriceLabel];
    
    [_dishPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_dishCountLabel.mas_right);
        make.top.bottom.equalTo(self);
        make.right.equalTo(self).offset(-kStandardLeftMargin);
    }];
}

- (void)setViewData:(JCHTakeoutOrderInfoDishModel *)dishModel
{
    if ([dishModel.skuName isEqualToString:dishModel.foodName]) {
        dishModel.skuName = @"";
    }
    if ([dishModel.skuName isEmptyString] && [dishModel.foodProperty isEmptyString]) {
        _dishNameLabel.text = dishModel.foodName;
    } else if ([dishModel.skuName isEmptyString] && ![dishModel.foodProperty isEmptyString]) {
        _dishNameLabel.text = [NSString stringWithFormat:@"%@(%@)", dishModel.foodName, dishModel.foodProperty];
    } else if (![dishModel.skuName isEmptyString] && [dishModel.foodProperty isEmptyString]) {
        _dishNameLabel.text = [NSString stringWithFormat:@"%@(%@)", dishModel.foodName, dishModel.skuName];
    } else {
        _dishNameLabel.text = [NSString stringWithFormat:@"%@(%@,%@)", dishModel.foodName, dishModel.skuName, dishModel.foodProperty];
    }
    
    _dishCountLabel.text = [NSString stringWithFormat:@"x%ld", dishModel.quantity];
    _dishPriceLabel.text = [NSString stringWithFormat:@"¥%.2f", dishModel.price];
}

@end
