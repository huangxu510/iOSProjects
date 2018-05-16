//
//  JCHAccountBookTypeSelectTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/7.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAccountBookTypeSelectTableViewCell.h"
#import "CommonHeader.h"
#import <Masonry.h>


@implementation JCHAccountBookTypeSelectTableViewCell
{
    UIImageView *_iconImageView;
    UILabel *_titleLabel;
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
    UIFont *labelFont = [UIFont systemFontOfSize:17.0f];
    
    _iconImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    _iconImageView.layer.cornerRadius = 15.0f;
    _iconImageView.clipsToBounds = YES;
    [self.contentView addSubview:_iconImageView];
    
    _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:labelFont
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_titleLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(30.0f);
        make.width.mas_equalTo(30.0f);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImageView.mas_right).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(100);
        make.top.and.bottom.equalTo(self.contentView);
    }];
}

- (void)setImageName:(NSString *)imageName title:(NSString *)title
{
    _iconImageView.image = [UIImage imageNamed:imageName];
    _titleLabel.text = title;
}


@end
