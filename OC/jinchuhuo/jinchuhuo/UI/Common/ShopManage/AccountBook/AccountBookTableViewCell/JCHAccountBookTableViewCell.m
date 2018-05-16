//
//  JCHAccountBookTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/7.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAccountBookTableViewCell.h"
#import "CommonHeader.h"
#import <Masonry.h>

@implementation JCHAccountBookTableViewCell
{
    UILabel *_titleLabel;
    UILabel *_valueLabel;
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
    UIFont *labelFont = [UIFont systemFontOfSize:15.0f];
    
    
    
    _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:labelFont
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_titleLabel];
    
    _valueLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:labelFont
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentRight];
    [self.contentView addSubview:_valueLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin * 2 + 24);
        make.width.mas_equalTo(120);
        make.top.and.bottom.equalTo(self.contentView);
    }];
    
    [_valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel.mas_right).with.offset(kStandardLeftMargin);
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
        make.top.and.bottom.equalTo(_titleLabel);
    }];
}

- (void)setViewData:(NSString *)data title:(NSString *)title
{
    _titleLabel.text = title;
    _valueLabel.text = data;
}


@end
