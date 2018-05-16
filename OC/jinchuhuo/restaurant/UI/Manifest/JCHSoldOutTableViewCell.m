//
//  JCHSoldOutTableViewCell.m
//  jinchuhuo
//
//  Created by apple on 2016/12/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSoldOutTableViewCell.h"
#import "CommonHeader.h"

@interface JCHSoldOutTableViewCell ()
{
    UIImageView *dishImageView;
    UILabel *dishNameLabel;
    UILabel *dishDetailLabel;
    UIButton *dishSelectButton;
    NSInteger currentCellIndex;
}
@end

@implementation JCHSoldOutTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    
    return self;
}

- (void)dealloc
{
    self.handleClickEvent = nil;
    [super dealloc];
    return;
}

- (void)createUI
{
    dishImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    [self.contentView addSubview:dishImageView];
    dishImageView.layer.cornerRadius = 3.0f;
    dishImageView.clipsToBounds = YES;
    
    dishNameLabel = [JCHUIFactory createLabel:CGRectZero
                                        title:@""
                                         font:JCHFont(14.0)
                                    textColor:JCHColorMainBody
                                       aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:dishNameLabel];
    
    dishDetailLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@""
                                           font:JCHFont(12.0)
                                      textColor:JCHColorMainBody
                                         aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:dishDetailLabel];
    
    dishSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:dishSelectButton];
    [dishSelectButton addTarget:self
                         action:@selector(handleClickButton:)
               forControlEvents:UIControlEventTouchUpInside];
    
    [dishSelectButton setBackgroundImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_normal"]
                                forState:UIControlStateNormal];
    [dishSelectButton setBackgroundImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_selected"]
                                forState:UIControlStateSelected];
    
}

- (void)setCellData:(JCHAddProductTableViewCellData *)cellData cellIndex:(NSInteger)cellIndex
{
    dishImageView.image = [UIImage jchProductImageNamed:cellData.productLogoImage];
    dishNameLabel.text = cellData.productName;
    if (YES == cellData.hasSoldOut) {
        dishSelectButton.selected = YES;
    } else {
        dishSelectButton.selected = NO;
    }
    
    dishDetailLabel.text = @"";
    if (YES == cellData.is_multi_unit_enable) {
        dishDetailLabel.text = cellData.productUnit;
    } else if (NO == cellData.sku_hidden_flag) {
        dishDetailLabel.text = [[JCHTransactionUtility getSKUCombineListWithGoodsSKURecord:cellData.goodsSKURecord] firstObject];
    } else {
        dishDetailLabel.text = cellData.productUnit;
    }
    
    currentCellIndex = cellIndex;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [dishImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(kStandardLeftMargin);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
    }];
    
    [dishNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(dishImageView.mas_right).with.offset(kStandardLeftMargin);
        make.top.equalTo(self.contentView);
        make.height.equalTo(self.contentView).multipliedBy(2.0/3);
        make.right.mas_equalTo(200);
    }];
    
    [dishDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(dishImageView.mas_right).with.offset(kStandardLeftMargin);
        make.top.equalTo(dishNameLabel.mas_bottom).with.offset(-6.0);
        make.height.equalTo(self.contentView).multipliedBy(1.0/3);
        make.right.mas_equalTo(200);
    }];
    
    [dishSelectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.width.and.height.mas_equalTo(23);
        make.right.equalTo(self.contentView.mas_right).with.offset(-kStandardRightMargin);
    }];
}

- (void)handleClickButton:(id)sender
{
    if (YES == dishSelectButton.selected) {
        dishSelectButton.selected = NO;
    } else {
        dishSelectButton.selected = YES;
    }
    
    if (nil != self.handleClickEvent) {
        self.handleClickEvent(dishSelectButton.selected, currentCellIndex);
    }
}

@end
