//
//  JCHCheckoutOrderTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/9.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHCheckoutOrderTableViewCell.h"
#import "CommonHeader.h"
#import <Masonry.h>

@implementation JCHCheckoutOrderTableViewCellData

- (void)dealloc
{
    [self.titleName release];
    [self.centerContent release];
    [self.value release];
    
    [super dealloc];
}


@end

@implementation JCHCheckoutOrderTableViewCell
{
    UILabel *_leftTitleLabel;
    UILabel *_centerLabel;
    UILabel *_valueLabel;
    UIButton *_deleteButton;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = JCHColorGlobalBackground;
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    UIFont *labelFont = [UIFont systemFontOfSize:14.0f];
    
    _leftTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@""
                                           font:labelFont
                                      textColor:JCHColorMainBody
                                         aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_leftTitleLabel];
    
    _centerLabel = [JCHUIFactory createLabel:CGRectZero
                                       title:@""
                                        font:labelFont
                                   textColor:JCHColorMainBody
                                      aligin:NSTextAlignmentRight];
    [self.contentView addSubview:_centerLabel];
    
    _valueLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:labelFont
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentRight];
    [self.contentView addSubview:_valueLabel];
    
    _deleteButton = [JCHUIFactory createButton:CGRectZero
                                        target:self
                                        action:@selector(deleteItem:)
                                         title:nil
                                    titleColor:nil
                               backgroundColor:nil];
    [_deleteButton setImage:[UIImage imageNamed:@"settleAccounts_bt_delete"] forState:UIControlStateNormal];
    [self.contentView addSubview:_deleteButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    [_leftTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(50);
        make.top.and.bottom.equalTo(self.contentView);
    }];
    
    [_centerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftTitleLabel.mas_right).with.offset(kStandardLeftMargin);
        make.top.and.bottom.equalTo(_leftTitleLabel);
        make.width.mas_equalTo(100);
    }];
    
    [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.top.and.bottom.equalTo(self.contentView);
        make.width.mas_equalTo(40);
    }];
    
    [_valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_centerLabel.mas_right).with.offset(kStandardLeftMargin);
        make.right.equalTo(_deleteButton.mas_left);
        make.top.and.bottom.equalTo(_leftTitleLabel);
    }];
}

- (void)deleteItem:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(handleDeleteItem:)]) {
        [self.delegate handleDeleteItem:self];
    }
}

- (void)setCellData:(JCHCheckoutOrderTableViewCellData *)data
{
    _leftTitleLabel.text = data.titleName;
    _centerLabel.text = data.centerContent;
    _valueLabel.text = data.value;
}

- (void)setDeleteButtonHidden:(BOOL)hidden
{
    _deleteButton.hidden = hidden;
}

@end
