//
//  JCHProductDetailTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/17.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHProductDetailTableViewCell.h"
#import "CommonHeader.h"
#import <Masonry.h>

@implementation JCHProductDetailTableViewCellData

- (void)dealloc
{
    [self.skuCombine release];
    [self.count release];
    [self.purchasePrice release];
    [self.shipmentPrice release];
    
    [super dealloc];
}


@end

@interface JCHProductDetailTableViewCell ()
{
    UILabel *_skuCombineLabel;
    UILabel *_countLabel;
    UILabel *_purchasePriceLabel;
    UILabel *_shipmentPriceLabel;
}
@end

@implementation JCHProductDetailTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    UIFont *labelFont = [UIFont jchSystemFontOfSize:12.0f];
    
    _skuCombineLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@""
                                            font:labelFont
                                       textColor:JCHColorAuxiliary
                                          aligin:NSTextAlignmentLeft];
    _skuCombineLabel.numberOfLines = 2;
    [self.contentView addSubview:_skuCombineLabel];
    
    _countLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@""
                                            font:labelFont
                                       textColor:JCHColorAuxiliary
                                          aligin:NSTextAlignmentRight];
    [self.contentView addSubview:_countLabel];
    
    _purchasePriceLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@""
                                            font:labelFont
                                       textColor:JCHColorAuxiliary
                                          aligin:NSTextAlignmentRight];
    [self.contentView addSubview:_purchasePriceLabel];
    
    _shipmentPriceLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@""
                                            font:labelFont
                                       textColor:JCHColorAuxiliary
                                          aligin:NSTextAlignmentRight];
    [self.contentView addSubview:_shipmentPriceLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat skuCombineLabelWidth = (kScreenWidth - 2 * kStandardLeftMargin) / 3;
    CGFloat countLabelWidth = (kScreenWidth - 2 * kStandardLeftMargin) * 2 / 9;
    
    [_skuCombineLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(skuCombineLabelWidth);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    [_countLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_skuCombineLabel.mas_right);
        make.width.mas_equalTo(countLabelWidth);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    [_purchasePriceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_countLabel.mas_right);
        make.width.mas_equalTo(countLabelWidth);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    [_shipmentPriceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_purchasePriceLabel.mas_right);
        make.width.mas_equalTo(countLabelWidth);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

- (void)setCellData:(JCHProductDetailTableViewCellData *)data
{
    _skuCombineLabel.text = data.skuCombine;
    _countLabel.text = data.count;
    
    _shipmentPriceLabel.text = data.shipmentPrice;
    
    
    if ([JCHPerimissionUtility displayCostPrice]) {
        _purchasePriceLabel.text = data.purchasePrice;
    } else {
        _purchasePriceLabel.text = @"--.--";
    }
}

@end
