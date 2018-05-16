//
//  JCHRestaurantDishDetailCell.m
//  jinchuhuo
//
//  Created by apple on 2017/1/12.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHRestaurantDishDetailCell.h"
#import "CommonHeader.h"

@interface JCHRestaurantDishDetailCell ()
{
    UIImageView *dishImageView;
    UILabel *dishNameLabel;
    UILabel *dishPriceLabel;
    UILabel *skuLabel;
    UILabel *dishCountLabel;
    UIView *bottomLineView;
}
@end

@implementation JCHRestaurantDishDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)createUI
{
    dishImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    dishImageView.layer.cornerRadius = 8.0;
    dishImageView.image = [UIImage imageNamed:@"icon_default_116"];
    [self.contentView addSubview:dishImageView];
    
    dishNameLabel = [JCHUIFactory createLabel:CGRectZero
                                        title:@"娃哈哈AD钙奶300ml"
                                         font:JCHFont(14.0)
                                    textColor:JCHColorMainBody
                                       aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:dishNameLabel];
    
    dishPriceLabel = [JCHUIFactory createLabel:CGRectZero
                                         title:@"2.50"
                                          font:JCHFont(14.0)
                                     textColor:JCHColorHeaderBackground
                                        aligin:NSTextAlignmentCenter];
    [self.contentView addSubview:dishPriceLabel];
    
    skuLabel = [JCHUIFactory createLabel:CGRectZero
                                   title:@"微辣,少油"
                                    font:JCHFont(12.0)
                               textColor:JCHColorHeaderBackground
                                  aligin:NSTextAlignmentCenter];
    [self.contentView addSubview:skuLabel];
    skuLabel.layer.borderColor = [JCHColorHeaderBackground CGColor];
    skuLabel.layer.cornerRadius = 3.0;
    skuLabel.layer.borderWidth = 1.0;
    
    dishCountLabel = [JCHUIFactory createLabel:CGRectZero
                                         title:@"68"
                                          font:JCHFont(14.0)
                                     textColor:JCHColorHeaderBackground
                                        aligin:NSTextAlignmentRight];
    [self.contentView addSubview:dishCountLabel];
    
    bottomLineView = [JCHUIFactory createSeperatorLine:1.0];
    [self.contentView addSubview:bottomLineView];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [dishImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(kStandardLeftMargin);
        make.top.equalTo(self.contentView.mas_top).with.offset(8.0);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-8.0);
        make.width.equalTo(dishImageView.mas_height);
    }];
    
    [dishCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.contentView).multipliedBy(0.15);
        make.top.and.bottom.equalTo(self);
        make.right.equalTo(self).with.offset(-kStandardRightMargin);
    }];
    
    [dishPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(dishCountLabel.mas_left);
        make.top.and.bottom.equalTo(self);
        make.width.equalTo(self.mas_width).with.multipliedBy(0.15);
    }];
    
    [dishNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(dishImageView.mas_right).with.offset(8.0);
        make.top.equalTo(self.contentView);
        make.height.equalTo(self.contentView).multipliedBy(0.66);
        make.right.equalTo(dishPriceLabel.mas_left);
    }];
    
    [skuLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(dishNameLabel.mas_left);
        make.top.equalTo(dishNameLabel.mas_bottom);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(16);
    }];
    

    
    [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.mas_offset(kSeparateLineWidth);
    }];
}

- (void)handleAddDishCount:(id)sender
{
    
}

@end
