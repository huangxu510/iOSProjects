//
//  JCHImportContactRelationSelectTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/4/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHImportContactRelationSelectTableViewCell.h"
#import "CommonHeader.h"
#import "UIButton+EnlargeTouchArea.h"

@implementation JCHImportContactRelationSelectTableViewCellData

- (void)dealloc
{
    [self.name release];
    [super dealloc];
}


@end

@implementation JCHImportContactRelationSelectTableViewCell
{
    UILabel *_titleLabel;
    UIButton *_clientButton;
    UIButton *_supplierButton;
    UIButton *_colleagueButton;
}

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
    _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:[UIFont systemFontOfSize:15.0]
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_titleLabel];
    
    _clientButton = [JCHUIFactory createButton:CGRectZero
                                        target:self
                                        action:@selector(buttonSelected:)
                                         title:nil
                                    titleColor:nil
                               backgroundColor:nil];
    _clientButton.tag = kJCHClientButtonTag;

    [_clientButton setImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_normal"] forState:UIControlStateNormal];
    [_clientButton setImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_selected"] forState:UIControlStateSelected];
    [self.contentView addSubview:_clientButton];
    
    _supplierButton = [JCHUIFactory createButton:CGRectZero
                                          target:self
                                          action:@selector(buttonSelected:)
                                           title:nil
                                      titleColor:nil
                                 backgroundColor:nil];
    _supplierButton.tag = kJCHSupplierButtonTag;
    [_supplierButton setImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_normal"] forState:UIControlStateNormal];
    [_supplierButton setImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_selected"] forState:UIControlStateSelected];
    [self.contentView addSubview:_supplierButton];
    
    _colleagueButton = [JCHUIFactory createButton:CGRectZero
                                           target:self
                                           action:@selector(buttonSelected:)
                                            title:nil
                                       titleColor:nil
                                  backgroundColor:nil];
    _colleagueButton.tag = kJCHColleagueButtonTag;
    [_colleagueButton setImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_normal"] forState:UIControlStateNormal];
    [_colleagueButton setImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_selected"] forState:UIControlStateSelected];
    [self.contentView addSubview:_colleagueButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat buttonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:50];
    CGFloat buttonSpacing = 15;
    
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.top.and.bottom.equalTo(self.contentView);
        make.width.mas_equalTo(kScreenWidth / 3);
    }];
    
    [_colleagueButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
        make.width.and.height.mas_equalTo(buttonWidth);
        make.centerY.equalTo(self.contentView);
    }];
    
    [_supplierButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_colleagueButton.mas_left).with.offset(-buttonSpacing);
        make.width.and.height.mas_equalTo(buttonWidth);
        make.centerY.equalTo(self.contentView);
    }];
    
    [_clientButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_supplierButton.mas_left).with.offset(-buttonSpacing);
        make.width.and.height.mas_equalTo(buttonWidth);
        make.centerY.equalTo(self.contentView);
    }];
}

- (void)setCellData:(JCHImportContactRelationSelectTableViewCellData *)data
{
    _titleLabel.text = data.name;
    _clientButton.selected = data.clientButtonSelected;
    _supplierButton.selected = data.supplierButtonSelected;
    _colleagueButton.selected = data.colleagueButtonSelected;
}

- (void)buttonSelected:(UIButton *)button
{
    button.selected = !button.selected;
    if ([self.delegate respondsToSelector:@selector(handleSelectCell:Relation:)]) {
        [self.delegate handleSelectCell:self Relation:button];
    }
}

- (void)setTitleLabelColor:(UIColor *)color
{
    _titleLabel.textColor = color;
}

@end
