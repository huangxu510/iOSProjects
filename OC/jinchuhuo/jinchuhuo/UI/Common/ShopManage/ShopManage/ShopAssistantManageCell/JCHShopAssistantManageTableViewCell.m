//
//  JCHShopAssistantManageTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/4/21.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHShopAssistantManageTableViewCell.h"
#import "CommonHeader.h"

@implementation JCHShopAssistantManageTableViewCellData

- (void)dealloc
{
    [self.title release];
    [self.subTitle release];
    [self.headImageName release];
    
    [super dealloc];
}


@end

@implementation JCHShopAssistantManageTableViewCell
{
    UIImageView *_headImageView;
    UILabel *_titleLabel;
    UILabel *_subTitleLabel;
    UISwitch *_statusSwitch;
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
    UIFont *titleFont = [UIFont jchSystemFontOfSize:15.0f];
    //UIFont *subTitleFont = [UIFont jchSystemFontOfSize:14.0f];
    
    _headImageView = [[[UIImageView alloc] init] autorelease];
    [self.contentView addSubview:_headImageView];

    _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:titleFont
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_titleLabel];
#if 0
    _subTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                         title:@""
                                          font:subTitleFont
                                     textColor:JCHColorAuxiliary
                                        aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_subTitleLabel];
#endif
    _statusSwitch = [[[UISwitch alloc] init] autorelease];
    [_statusSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_statusSwitch];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat headImageViewWidth = 42.0f;
    
    [_headImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.and.width.mas_equalTo(headImageViewWidth);
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.centerY.equalTo(self.contentView);
    }];

    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headImageView.mas_right).with.offset(kStandardLeftMargin);
        make.top.equalTo(_headImageView);
        make.height.mas_equalTo(headImageViewWidth); /// 2);
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
    }];
#if 0
    [_subTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(_titleLabel);
        make.top.equalTo(_titleLabel.mas_bottom);
        make.bottom.equalTo(_headImageView);
    }];
#endif
    [_statusSwitch mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-kStandardLeftMargin);
        make.centerY.equalTo(self);
    }];

}

- (void)setCellData:(JCHShopAssistantManageTableViewCellData *)data
{
    _headImageView.image = [UIImage jchAvatarImageNamed:data.headImageName];
    _titleLabel.text = data.title;
    _subTitleLabel.text = data.subTitle;
    _statusSwitch.on = data.status;
}

- (void)switchAction:(UISwitch *)statusSwitch
{
    if ([self.delegate respondsToSelector:@selector(handleSwitchAction:inCell:)]) {
        [self.delegate handleSwitchAction:statusSwitch inCell:self];
    }
}

@end
