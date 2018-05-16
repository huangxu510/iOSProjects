//
//  JCHTakeoutPutawayTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/9.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTakeoutPutawayTableViewCell.h"
#import "CommonHeader.h"

@implementation JCHTakeoutPutawayTableViewCellData

- (void)dealloc
{
    self.skuName = nil;
    self.skuID = nil;
    self.skuTakeoutPrice = nil;
    self.skuTakeoutInventory = nil;
    
    [super dealloc];
}

@end


@implementation JCHTakeoutPutawayTableViewCell
{
    UILabel *_skuNameLabel;
    UILabel *_skuLocalPriceLabel;
    UIButton *_meituanSelectButton;
    UILabel *_meituanPriceLabel;
    UILabel *_meituanInventoryLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    self.selectBlock = nil;
    
    [super dealloc];
}

- (void)createUI
{
    CGFloat buttonWidth = 30;
    CGFloat labelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:70];
    _skuNameLabel = [JCHUIFactory createLabel:CGRectZero
                                        title:@""
                                         font:JCHFont(16.0)
                                    textColor:JCHColorMainBody
                                       aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_skuNameLabel];
    
    [_skuNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(kStandardLeftMargin);
        make.right.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.contentView).offset(5);
        make.bottom.equalTo(self.contentView.mas_centerY);
    }];
    
    _skuLocalPriceLabel = [JCHUIFactory createLabel:CGRectZero
                                         title:@""
                                          font:JCHFont(13.0)
                                     textColor:JCHColorAuxiliary
                                        aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_skuLocalPriceLabel];
    
    [_skuLocalPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_skuNameLabel);
        make.top.equalTo(_skuNameLabel.mas_bottom);
        make.bottom.equalTo(self.contentView);
    }];
    

    
    _meituanSelectButton = [JCHUIFactory createButton:CGRectZero
                                               target:self
                                               action:@selector(handleSelectMeituanPrice:)
                                                title:@""
                                           titleColor:JCHColorMainBody
                                      backgroundColor:[UIColor whiteColor]];
    [_meituanSelectButton setImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_selected"] forState:UIControlStateSelected];
    [_meituanSelectButton setImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_normal"] forState:UIControlStateNormal];
    [self.contentView addSubview:_meituanSelectButton];
    
    
    [_meituanSelectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(buttonWidth);
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-kStandardLeftMargin);
    }];
    
    _meituanInventoryLabel = [JCHUIFactory createLabel:CGRectZero
                                                 title:@"0"
                                                  font:JCHFont(13.0)
                                             textColor:JCHColorMainBody
                                                aligin:NSTextAlignmentRight];
    [self.contentView addSubview:_meituanInventoryLabel];
    
    [_meituanInventoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_meituanSelectButton.mas_left).offset(-kStandardLeftMargin * 2);
        make.top.bottom.equalTo(self.contentView);
        make.width.mas_equalTo(labelWidth);
    }];
    
    _meituanPriceLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@"0.00"
                                              font:JCHFont(13.0)
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentRight];
    [self.contentView addSubview:_meituanPriceLabel];
    
    [_meituanPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_meituanInventoryLabel.mas_left).offset(-kStandardLeftMargin);
        make.top.bottom.equalTo(self.contentView);
        make.width.mas_equalTo(labelWidth);
    }];

}

- (void)handleSelectMeituanPrice:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    if (self.selectBlock) {
        self.selectBlock(sender.selected);
    }
}

- (void)setViewData:(JCHTakeoutPutawayTableViewCellData *)data
{
    _skuNameLabel.text = data.skuName;
    
    _skuLocalPriceLabel.text = [NSString stringWithFormat:@"售价¥%.2f", data.skuLocalPrice];
    _meituanSelectButton.selected = data.status;
    _meituanInventoryLabel.text = data.skuTakeoutInventory;
    _meituanPriceLabel.text = [NSString stringWithFormat:@"¥%.2f", data.skuTakeoutPrice.doubleValue];
}

@end
