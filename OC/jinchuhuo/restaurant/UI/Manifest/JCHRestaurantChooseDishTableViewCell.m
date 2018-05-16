//
//  JCHRestaurantChooseDishTableViewCell.m
//  jinchuhuo
//
//  Created by apple on 2017/1/9.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHRestaurantChooseDishTableViewCell.h"
#import "CommonHeader.h"

@interface JCHRestaurantChooseDishTableViewCell ()
{
    UIImageView *dishImageView;
    UILabel *dishNameLabel;
    UILabel *dishPriceLabel;
    UILabel *skuLabel;
    UILabel *dishCountLabel;
    UIButton *addDishButton;
    UIView *bottomLineView;
}
@end

@implementation JCHRestaurantChooseDishTableViewCell

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
                                        aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:dishPriceLabel];
    
    skuLabel = [JCHUIFactory createLabel:CGRectZero
                                         title:@"多规格"
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
    
    addDishButton = [JCHUIFactory createButton:CGRectZero
                                        target:self
                                        action:@selector(handleAddDishCount:)
                                         title:nil
                                    titleColor:nil
                               backgroundColor:nil];
    [self.contentView addSubview:addDishButton];
    [addDishButton setImage:[UIImage imageNamed:@"addgoods_btn_add"]
                   forState:UIControlStateNormal];
    
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
    
    [dishNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(dishImageView.mas_right).with.offset(8.0);
        make.top.equalTo(dishImageView.mas_top);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(dishImageView.mas_height).with.multipliedBy(0.4);
    }];
    
    [dishPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(dishImageView.mas_right).with.offset(8.0);
        make.bottom.equalTo(dishImageView.mas_bottom);
        make.width.equalTo(dishImageView.mas_width);
        make.height.equalTo(dishImageView.mas_height).with.multipliedBy(0.4);
    }];
    
    [skuLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-kStandardRightMargin);
        make.top.equalTo(dishImageView.mas_top);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(16);
    }];
    
    [addDishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-kStandardRightMargin);
        make.bottom.equalTo(dishPriceLabel.mas_bottom).with.offset(4);
        make.width.mas_equalTo(36);
        make.height.mas_equalTo(36);
    }];
    
    [dishCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(addDishButton.mas_left);
        make.bottom.equalTo(dishPriceLabel.mas_bottom);
        make.width.mas_equalTo(36);
        make.height.equalTo(dishPriceLabel.mas_height);
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
