//
//  JCHContactsTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/3.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHContactsTableViewCell.h"
#import "CommonHeader.h"
#import "UIImage+JCHImage.h"
#import <Masonry.h>

@implementation JCHContactsTableViewCellData

- (void)dealloc
{
    [self.headImageName release];
    [self.name release];
    [self.companyName release];
    
    [super dealloc];
}


@end

@implementation JCHContactsTableViewCell
{
    UIImageView *_headImageView;
    UILabel *_nameLabel;
    UILabel *_companyNameLabel;
    UIImageView *_savingCardImageView;
    CGFloat _nameLabelHeight;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    CGFloat headImageViewWidth = 42.0f;
    _nameLabelHeight = headImageViewWidth / 2;
    _headImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    _headImageView.layer.cornerRadius = headImageViewWidth / 2;
    _headImageView.clipsToBounds = YES;
    [self.contentView addSubview:_headImageView];
    
    _nameLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@""
                                      font:[UIFont jchSystemFontOfSize:15.0f]
                                 textColor:JCHColorMainBody
                                    aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_nameLabel];
    
    _companyNameLabel = [JCHUIFactory createLabel:CGRectZero
                                        title:@""
                                         font:[UIFont jchSystemFontOfSize:13.0f]
                                    textColor:JCHColorAuxiliary
                                       aligin:NSTextAlignmentLeft];
    //_companyNameLabel.backgroundColor = JCHColorHeaderBackground;
    [self.contentView addSubview:_companyNameLabel];

    _savingCardImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_storedvaluecard"]] autorelease];
    _savingCardImageView.hidden = YES;
    [self.contentView addSubview:_savingCardImageView];
    
    CGFloat savingCardImageViewWidth = 27.0f;
    
    [_savingCardImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
        make.width.height.mas_equalTo(savingCardImageViewWidth);
        make.centerY.equalTo(self.contentView);
    }];
    
    [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.and.width.mas_equalTo(headImageViewWidth);
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.centerY.equalTo(self.contentView);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headImageView.mas_right).with.offset(kStandardLeftMargin);
        make.top.equalTo(_headImageView);
        make.height.mas_equalTo(_nameLabelHeight);
        make.right.equalTo(_savingCardImageView.mas_left).with.offset(-kStandardLeftMargin);
    }];
    
    [_companyNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(_nameLabel);
        make.top.equalTo(_nameLabel.mas_bottom);
        make.bottom.equalTo(_headImageView);
    }];

}


- (void)setData:(JCHContactsTableViewCellData *)data
{
    CGFloat headImageViewWidth = 42.0f;
    UIImage *headImage = [UIImage imageNamed:data.headImageName];
    if (headImage) {
        _headImageView.image = headImage;
    } else {
        
        _headImageView.image = [UIImage imageWithColor:nil
                                                  size:CGSizeMake(headImageViewWidth, headImageViewWidth)
                                                  text:data.name
                                                  font:[UIFont jchSystemFontOfSize:17.0f]];
    }
    
    _nameLabel.text = data.name;
    _companyNameLabel.text = data.companyName;
    
    if ([_companyNameLabel.text isEqualToString:@""] || _companyNameLabel.text == nil) {
        _nameLabelHeight = headImageViewWidth;
    } else {
        _nameLabelHeight = headImageViewWidth / 2;
    }

    [_nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(_nameLabelHeight);
    }];
    
    _savingCardImageView.hidden = data.savingCardHidden;
}

@end
