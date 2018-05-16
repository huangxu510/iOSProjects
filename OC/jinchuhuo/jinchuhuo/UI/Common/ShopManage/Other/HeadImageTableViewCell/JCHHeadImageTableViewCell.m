//
//  JCHHeadImageTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/9.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHHeadImageTableViewCell.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import "JCHSizeUtility.h"
#import "JCHUIFactory.h"
#import "CommonHeader.h"
#import <Masonry.h>

@interface JCHHeadImageTableViewCell ()
{
    UILabel *_titleLabel;
    UIImageView *_headImageView;
    UIImageView *_arrowImageView;
    UIView *_bottomLine;
}
@end

@implementation JCHHeadImageTableViewCell

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
                                              title:@"头像"
                                               font:[UIFont systemFontOfSize:17]
                                          textColor:UIColorFromRGB(0x333333)
                                             aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_titleLabel];
    
    _headImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"homepage_avatar_default"]] autorelease];
    [self.contentView addSubview:_headImageView];
    
    _arrowImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me_btn_next"]] autorelease];
    [self.contentView addSubview:_arrowImageView];
    
    _bottomLine = [[[UIView alloc] init] autorelease];
    _bottomLine.backgroundColor = JCHColorSeparateLine;
    [self.contentView addSubview:_bottomLine];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView.mas_centerX);
    }];
    
    const CGFloat arrowImageViewHeight = 12;
    const CGFloat arrowImageViewWidth = 7;
    [_arrowImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
        make.height.mas_equalTo(arrowImageViewHeight);
        make.width.mas_equalTo(arrowImageViewWidth);
        make.centerY.equalTo(self.contentView);
    }];
    
    const CGFloat headImageViewHeight = 50;
    [_headImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_arrowImageView.mas_left).with.offset(-kStandardLeftMargin);
        make.width.mas_equalTo(headImageViewHeight);
        make.height.mas_equalTo(headImageViewHeight);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    [_bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

- (void)setData:(NSString *)headImageName
{
    if (headImageName) {
        _headImageView.image = [UIImage jchAvatarImageNamed:headImageName];
    }    
}

@end
