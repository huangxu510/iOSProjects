//
//  JCHAccountBookTypeTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/7.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAccountBookTypeTableViewCell.h"
#import "CommonHeader.h"
#import <Masonry.h>

@implementation JCHAccountBookTypeTableViewCellData

- (void)dealloc
{
    [self.title release];
    [self.value release];
    [self.imageName release];
    
    [super dealloc];
}


@end

@implementation JCHAccountBookTypeTableViewCell
{
    UIImageView *_iconImageView;
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
    
    _iconImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    _iconImageView.backgroundColor = [UIColor grayColor];
    _iconImageView.layer.cornerRadius = 12.0f;
    _iconImageView.clipsToBounds = YES;
    [self.contentView addSubview:_iconImageView];
    
    _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:labelFont
                                  textColor:JCHColorAuxiliary
                                     aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_titleLabel];
    
    _valueLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:labelFont
                                  textColor:JCHColorAuxiliary
                                     aligin:NSTextAlignmentRight];
    [self.contentView addSubview:_valueLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.centerY.equalTo(self.contentView);
        make.width.and.height.mas_equalTo(24.0f);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImageView.mas_right).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(80);
        make.top.and.bottom.equalTo(self.contentView);
    }];
    
    [_valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel.mas_right).with.offset(kStandardLeftMargin);
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
        make.top.and.bottom.equalTo(_titleLabel);
    }];
}

- (void)setViewData:(JCHAccountBookTypeTableViewCellData *)data
{
    _titleLabel.text = data.title;
    _valueLabel.text = data.value;
    _iconImageView.image = [UIImage imageNamed:data.imageName];
}



@end
